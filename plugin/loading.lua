local bc = require("bulk-comment")

vim.keymap.set("n", "<C-q>", bc.toggle)
vim.keymap.set("x", "<C-q>", bc.block_toggle)
