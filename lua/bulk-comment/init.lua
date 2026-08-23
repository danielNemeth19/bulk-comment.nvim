local M = {}

local Commenter = require("bulk-comment.commenter")


M.toggle = function ()
  local filetype = vim.bo.filetype
	local commenter = Commenter:new(filetype)
  if commenter.config then
		commenter:toggle_comment()
	else
    vim.api.nvim_echo({{ "Not yet supported"}}, true, {err = false})
	end
end

M.block_toggle = function ()
  local filetype = vim.bo.filetype
  local commenter = Commenter:new(filetype)
  if commenter.config then
    commenter:block_toggle_comment()
	else
    vim.api.nvim_echo({{ "Not yet supported"}}, true, {err = false})
	end
end

return M
