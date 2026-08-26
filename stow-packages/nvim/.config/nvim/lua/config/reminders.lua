local M = {}

local reminders = require("reminders")
local whichkey = require("which-key")

local function load_reminders()
	reminders.AddReminder({
		reminderMsg = "Hydrate",
		remindEvery = "22",
		persistent = true,
		daily = false,
		category = "personal",
	})
	reminders.AddReminder({
		reminderMsg = "Scrum",
		remindAt = "9:28",
		persistent = true,
		daily = true,
		category = "work",
	})
end

function M.setup()
	reminders.setup({
		directory_path = '~/Documents/',

		-- Briefing modal settings
		briefing = {
			on_startup = false,       -- false, true, or "once_daily"
			greeting = true,          -- show greeting with time of day
			name = "Dane",            -- name shown in the greeting
			sections = { "reminders", "personal" },  -- order and visibility of sections
		},

		-- Picker backend
		picker = {
			backend = "telescope",
		},
	})

	-- if there is no reminder file then create one with default events
	if vim.fn.filereadable(reminder_json_file) ~= 1 then
		load_reminders()
	end

	-- function to reload default events
	local function map_reload()
		reminders.RemoveAllReminders()
		load_reminders()
	end

	local keymap = {
		r = {
			name = "Remind Me",
			m = {
				name = "Reminders",
				e = { ":RemindMeEvery ",            "RemindMe Every (type minutes)" },
				a = { ":RemindMeAt ",               "RemindMe At (type hour, 24h)" },
				i = { ":RemindMeIn ",               "RemindMe In (type minutes)" },
				d = {
					name = "Daily",
					a = { ":RemindMeDailyAt ",      "RemindMe Daily At (type hour, 24h)" },
				},
				c = { "<cmd>ReminderClose<CR>",     "Reminder Close" },
				r = {
					name = "Remove",
					z = { "<cmd>ReminderRemoveAll<CR>", "Reminder Remove All" },
					a = { ":ReminderRemoveAt ",         "Reminder Remove At" },
				},
				f = {
					name = "Focus Mode",
					o = { "<cmd>ReminderFocusModeOff<CR>", "Focus Mode Off" },
					m = { "<cmd>ReminderFocusModeOn<CR>",  "Focus Mode On" },
				},
				b = { "<cmd>ReminderBriefing<CR>",  "Reminder Briefing" },
				n = { "<cmd>ReminderNew<CR>",        "Reminder New" },
				l = { "<cmd>ReminderList<CR>",       "Reminder List" },
			},
			r = { map_reload, "Reload reminders from source control" },
		},
	}
	local opts = {
		mode = "n",
		prefix = "<leader>",
		buffer = nil,
		silent = true,
		noremap = true,
		nowait = false,
	}
	whichkey.register(keymap, opts)
end

return M
