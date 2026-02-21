-- Enable IPC so that the Hammerspoon CLI will work.
require("hs.ipc")

local logger = hs.logger.new("main", "info")
local kindaVimDir = os.getenv("HOME") .. "/Library/Application\\ Support/kindaVim/"

function kindaVimModeChange(paths, flagTables)
	--for _, file in pairs(paths) do
	--	logger.i(file)
	--	if file == "environment.json" then
			local environment = hs.json.read(kindaVimDir .. "environment.json")

			local kVNormal
			if environment.mode == "normal" then
				kVNormal = 1
			else
				kVNormal = 0
			end

			logger.i(environment.mode, tostring(kVNormal))
			hs.task(
				"/Library/Application\\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli",
				function(exitCode, stdOut, stdErr)
					logger.i(exitCode, stdOut, stdErr)
				end,
				function(task, stdOut, stdErr)
					return true
				end,
				{
					"--set-variables",
					'"{\\"kVNormal\\":' .. kVNormal .. '}"',
				}
			)
	--	end
	--end
end

--hs.pathwatcher.new(kindaVimDir, kindaVimModeChange):start()
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
