table.unpack = table.unpack or unpack
---@type LineSymbolMap
local revisedMap = require("bulk-comment.config")

---@class Commenter
---@field filetype string
---@field line_symbol string|string[]
---@field symbol_type string
local Commenter = {}
Commenter.__index = Commenter

---@return Commenter
---@param filetype string
function Commenter:new(filetype)
	local self = setmetatable({}, Commenter)
	self.__index = self
	self.filetype = filetype
	-- self.symbol = self:_set_symbol()
	self.line_symbol = self:set_line_symbol(revisedMap)
	return self
end

---@protected
function Commenter._set_symbol(self)
	local symbol = revisedMap[self.filetype]
	return symbol
end

--- @param symbolMap LineSymbolMap
function Commenter:set_line_symbol(symbolMap)
	for _, language_config in pairs(symbolMap) do
		---@type LanguageConfig
		local config = language_config
		for _, language in pairs(config.languages) do
			if language == self.filetype then
				return config.symbol
			end
		end
	end
	return ""
end

--- @param line string
function Commenter:count_whitespace(line)
	local num_whitespace = line:match("^%s*"):len()
	return num_whitespace
end

---@param line string
function Commenter:is_empty_row(line)
	local non_whitespace = line:match("%S+")
	if non_whitespace == nil then
		return true
	end
	return false
end

---@param line string
---@param num_whitespace integer
function Commenter:is_commented(line, num_whitespace)
	local symbol
	if type(self.line_symbol) == "string" then
		symbol = self.line_symbol
	else
		symbol = self.line_symbol[1]
	end
	if line:sub(num_whitespace + 1, num_whitespace + symbol:len()) == symbol then
		return true
	end
	return false
end

---@param line string
---@param row integer
---@param num_whitespace integer
function Commenter:add_comment(line, row, num_whitespace)
	if type(self.line_symbol) == "string" then
		vim.api.nvim_win_set_cursor(0, { row, num_whitespace })
		vim.api.nvim_put({ self.line_symbol }, "c", false, false)
	else
		local endpos = line:len()
		vim.api.nvim_win_set_cursor(0, { row, endpos })
		vim.api.nvim_put({ self.line_symbol[2] }, "c", true, false)

		vim.api.nvim_win_set_cursor(0, { row, num_whitespace })
		vim.api.nvim_put({ self.line_symbol[1] }, "c", false, false)
	end
end

---@param line string
---@param row integer
---@param num_whitespace integer
function Commenter:remove_comment(line, row, num_whitespace)
	if type(self.line_symbol) == "string" then
		self:remove_inline_comment(row, num_whitespace)
	else
		self:remove_block_comment(line, row, num_whitespace)
	end
end

---@param row number
---@param num_whitespace number
function Commenter:remove_inline_comment(row, num_whitespace)
	-- since nvim_buf_set_text is 0 indexed for row too
	-- row needs to be modified
	-- start_row and end_row is the same as we edit in place
	local start_row, end_row = row - 1, row - 1
	local start_col = num_whitespace
	local end_col = num_whitespace + self.line_symbol:len()
	vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { "" })
end

function Commenter:remove_block_comment(line, row, num_whitespace)
	local start_pos = num_whitespace + self.line_symbol[1]:len() + 1
	local end_pos = 0 - self.line_symbol[2]:len() - 1
	local new_line = line:sub(start_pos, end_pos)
	local ws = ""
	local counter = 0
	while counter < num_whitespace do
		ws = ws .. " "
		counter = counter + 1
	end
	vim.api.nvim_buf_set_lines(0, row - 1, row, true, { ws .. new_line })
end

function Commenter:toggle_comment()
	local line = vim.api.nvim_get_current_line()

	local row, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
	if self:is_empty_row(line) then
		vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
		return
	end

	local num_whitespace = self:count_whitespace(line)
	if not self:is_commented(line, num_whitespace) then
		self:add_comment(line, row, num_whitespace)
	else
		self:remove_comment(line, row, num_whitespace)
	end
	local total_row_num = vim.api.nvim_buf_line_count(0)
	if row ~= total_row_num then
		vim.api.nvim_win_set_cursor(0, { row + 1, num_whitespace })
	end
end

return Commenter
