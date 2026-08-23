local bc = require("bulk-comment")

vim.keymap.set("n", "<C-q>", bc.toggle)
vim.keymap.set("v", "<C-q>", bc.block_toggle)
