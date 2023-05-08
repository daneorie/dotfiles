local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>ma", mark.add_file)
vim.keymap.set("n", "<leader>me", ui.toggle_quick_menu)
