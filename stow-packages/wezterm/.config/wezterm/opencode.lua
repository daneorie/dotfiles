local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local TIMEOUT   = "0.3"
local REGISTRY  = os.getenv("HOME") .. "/.local/state/opencode/instances"

local STATUS_ICON = {
  busy    = "⟳",  -- agent is actively working
  retry   = "⚠",  -- retrying after error
  idle    = "●",  -- waiting for input
}

-- Parse sessions JSON from a temp file
local function parse_sessions(json_str)
  if not json_str or json_str == "" then return {} end
  
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  if not f then return {} end
  f:write(json_str)
  f:close()
  
  local ok, out, _ = wezterm.run_child_process({
    "python3", "-c",
    "import sys, json; "
    .. "data=json.load(open(sys.argv[1])); "
    .. "[print(s.get('id',''), s.get('title','Untitled'), sep='\t') for s in data]",
    tmpfile
  })
  os.remove(tmpfile)
  
  if not ok then return {} end
  local sessions = {}
  for line in (out or ""):gmatch("[^\n]+") do
    local id, title = line:match("^([^\t]+)\t(.*)$")
    if id then table.insert(sessions, { id = id, title = title }) end
  end
  return sessions
end

-- Fetch HTTP endpoint and return raw response
local function http_json(url)
  local ok, stdout, _ = wezterm.run_child_process({
    "curl", "-s", "--max-time", TIMEOUT, url
  })
  if ok and stdout and stdout:match("%S") then
    return stdout:gsub("%s+$", "")
  end
end

-- Determine session status by examining the most recent message
-- Returns: "busy" (agent working), or "idle" (waiting for input/response)
local function get_session_status(base_url, session_id)
  local msg_json = http_json(base_url .. "/session/" .. session_id .. "/message?limit=1")
  if not msg_json or msg_json == "" then return "idle" end
  
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  if not f then return "idle" end
  f:write(msg_json)
  f:close()
  
  local ok, out, _ = wezterm.run_child_process({
    "python3", "-c",
    "import sys, json; "
    .. "msgs=json.load(open(sys.argv[1])); "
    .. "if not msgs: print('idle'); exit(0); "
    .. "msg=msgs[0]; "
    .. "role=msg.get('info',{}).get('role','user'); "
    .. "parts=msg.get('parts',[]); "
    .. "last_part_type=parts[-1].get('type','') if parts else ''; "
    .. "if role=='user': print('idle'); "
    .. "elif last_part_type=='step-finish': print('idle'); "
    .. "else: print('busy')",
    tmpfile
  })
  os.remove(tmpfile)
  
  if ok and out then
    local status = (out or ""):match("^%s*(%S+)")
    if status == "busy" or status == "idle" then return status end
  end
  return "idle"
end

-- Derive workspace name from path, matching the convention in workspace.lua
-- Paths under ~/repos/ strip the ~/repos/ prefix
-- Paths directly under ~/ strip the ~/ prefix
-- Fallback: last path segment
local function workspace_name(path)
  local home = os.getenv("HOME")
  
  -- Paths under ~/repos/ strip the ~/repos/ prefix
  local name = path:match("^" .. home .. "/repos/(.+)$")
  if name then return name end
  
  -- Paths directly under ~/ strip the ~/ prefix
  name = path:match("^" .. home .. "/(.+)$")
  if name then return name end
  
  -- Fallback: last path segment
  return path:match("([^/]+)$") or path
end

-- Resolve which WezTerm pane belongs to the opencode process
-- Chain: registry shell_pid -> opencode child pid (pgrep -P) -> tty (ps) -> pane_id (wezterm cli)
local function resolve_pane_id(shell_pid)
  -- Find the opencode child of the shell
  local ok, out, _ = wezterm.run_child_process({
    "pgrep", "-P", tostring(shell_pid)
  })
  if not ok or not out or out:match("^%s*$") then return nil end
  local oc_pid = out:match("^%s*(%d+)")
  if not oc_pid then return nil end

  -- Get its controlling tty
  ok, out, _ = wezterm.run_child_process({
    "ps", "-p", oc_pid, "-o", "tty="
  })
  if not ok or not out or out:match("^%s*$") then return nil end
  local tty = "/dev/" .. out:match("%S+")

  -- Find the matching pane in wezterm
  ok, out, _ = wezterm.run_child_process({
    "wezterm", "cli", "list", "--format", "json"
  })
  if not ok or not out then return nil end

  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  if not f then return nil end
  f:write(out)
  f:close()

  ok, out, _ = wezterm.run_child_process({
    "python3", "-c",
    "import sys, json; "
    .. "data=json.load(open(sys.argv[1])); "
    .. "match=[p for p in data if p.get('tty_name')=='" .. tty .. "']; "
    .. "print(match[0]['pane_id']) if match else print('')",
    tmpfile
  })
  os.remove(tmpfile)

  if ok and out then
    local id = out:match("^%s*(%d+)")
    if id then return tonumber(id) end
  end
  return nil
end

-- Discover all live OpenCode servers from registry and collect session info
local function discover_sessions()
  local entries = {}
  
  -- Read the registry file
  local f = io.open(REGISTRY, "r")
  if not f then return entries end
  
  local instances = {}
  for line in f:lines() do
    local pid, port, cwd = line:match("^(%d+):(%d+):(.+)$")
    if pid and port and cwd then
      table.insert(instances, {
        pid = tonumber(pid),
        port = tonumber(port),
        cwd = cwd
      })
    end
  end
  f:close()
  
  -- Filter instances: keep only those where process is still alive
  for _, inst in ipairs(instances) do
    local ok = wezterm.run_child_process({"kill", "-0", tostring(inst.pid)})
    if ok then
      local base = "http://127.0.0.1:" .. inst.port

      local health = http_json(base .. "/global/health")
      if health then
        local sessions_json = http_json(base .. "/session?limit=1")

        local sessions  = sessions_json and parse_sessions(sessions_json) or {}
        local proj_path = inst.cwd
        local proj_name = workspace_name(proj_path)
        local pane_id = resolve_pane_id(inst.pid)

        for _, session in ipairs(sessions) do
          -- Fetch status by inspecting the most recent message
          local status = get_session_status(base, session.id)
          local icon   = STATUS_ICON[status] or "●"
          table.insert(entries, {
            -- id encodes everything needed to act on selection
            id    = proj_path .. "\t" .. inst.port .. "\t" .. session.id,
            label = icon .. "  " .. session.title
                    .. "  —  " .. proj_name
                    .. "  [" .. status .. "]",
            -- carry metadata for action
            path  = proj_path,
            name  = proj_name,
            port  = inst.port,
            sid   = session.id,
            status = status,
            pane_id = pane_id,
          })
        end
      end
    end
  end
  return entries
end

function M.show_session_picker()
  return wezterm.action_callback(function(window, pane)
    local entries = discover_sessions()

    local choices
    if #entries == 0 then
      -- No active sessions: show a placeholder message in the picker
      choices = {
        {
          id = "none",
          label = "(no active OpenCode sessions)",
        }
      }
    else
      choices = {}
      for _, e in ipairs(entries) do
        table.insert(choices, { id = e.id, label = e.label })
      end
    end

    -- Build a lookup by id for use in the callback
    local lookup = {}
    for _, e in ipairs(entries) do lookup[e.id] = e end

    window:perform_action(
      act.InputSelector({
        title   = "OpenCode Sessions",
        fuzzy   = true,
        choices = choices,
        action  = wezterm.action_callback(function(inner_window, inner_pane, id, label)
          -- If user selected "no active sessions" or cancelled, just return
          if not id or id == "none" then return end
          
          local entry = lookup[id]
          if not entry then return end

           -- Switch to (or create) a workspace for this project
           inner_window:perform_action(
             act.SwitchToWorkspace({
               name  = entry.name,
               spawn = { cwd = entry.path },
             }),
             inner_pane
           )

           -- Activate the specific pane to select the right tab
           if entry.pane_id then
             local mux_pane = wezterm.mux.get_pane(entry.pane_id)
             if mux_pane then mux_pane:activate() end
           end
        end),
      }),
      pane
    )
  end)
end

return M
