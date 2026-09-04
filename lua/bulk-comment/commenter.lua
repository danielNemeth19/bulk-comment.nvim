table.unpack = table.unpack or unpack
---@type SymbolMap
local symbolMap = require("bulk-comment.config")

---@class Commenter
---@field filetype string
---@field config LanguageConfig
local Commenter = {}
Commenter.__index = Commenter

---@return Commenter
---@param filetype string
function Commenter:new(filetype)
	local self = setmetatable({}, Commenter)
	self.__index = self
	self.filetype = filetype
	self.config = self:_set_config(symbolMap)
	return self
end

--- @param map SymbolMap
function Commenter:_set_config(map)
	local config = map[self.filetype]
	return config
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

---@protected
---@param line string
---@param num_whitespace integer
---@param symbol string
function Commenter:_is_commented(line, num_whitespace, symbol)
		local len_symbol = symbol:len()
    local test_string = line:sub(num_whitespace, len_symbol)
		if line:sub(num_whitespace + 1, num_whitespace + len_symbol) == symbol then
			return true
		end
    return false
end

---@param line string
---@param num_whitespace integer
function Commenter:is_commented(line, num_whitespace)
	if self.config.line_comment then
		local symbol = assert(self.config.line_comment)
    if self:_is_commented(line, num_whitespace, symbol) then
      return true
    end
	end
	if self.config.block_comment then
		local symbol = self.config.block_comment[1]
    if self:_is_commented(line, num_whitespace, symbol) then
      return true
    end
	end
	return false
end

---@param line string
---@param row integer
---@param num_whitespace integer
function Commenter:add_comment(line, row, num_whitespace)
	if type(self.config.line_comment) == "string" then
		vim.api.nvim_win_set_cursor(0, { row, num_whitespace })
		vim.api.nvim_put({ self.config.line_comment }, "c", false, false)
	else
		local endpos = line:len()
		vim.api.nvim_win_set_cursor(0, { row, endpos })
		vim.api.nvim_put({ self.config.block_comment[2] }, "c", true, false)

		vim.api.nvim_win_set_cursor(0, { row, num_whitespace })
		vim.api.nvim_put({ self.config.block_comment[1] }, "c", false, false)
	end
end

---@param line string
---@param row integer
---@param num_whitespace integer
function Commenter:remove_comment(line, row, num_whitespace)
	if type(self.config.line_comment) == "string" then
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
	local end_col = num_whitespace + self.config.line_comment:len()
	vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { "" })
end

function Commenter:remove_block_comment(line, row, num_whitespace)
	local start_pos = num_whitespace + self.config.block_comment[1]:len() + 1
	local end_pos = 0 - self.config.block_comment[2]:len() - 1
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
    print("if we're here then comment missed")
		self:add_comment(line, row, num_whitespace)
	else
		self:remove_comment(line, row, num_whitespace)
	end
	local total_row_num = vim.api.nvim_buf_line_count(0)
	if row ~= total_row_num then
		vim.api.nvim_win_set_cursor(0, { row + 1, num_whitespace })
	end
end

---@protected
---@param mode ("v" | ".")
function Commenter:_get_line_position(mode)
	local _, line_number, _, _ = table.unpack(vim.fn.getpos(mode))
  local zero_based_line_number = line_number - 1
  return zero_based_line_number
end

function Commenter:block_toggle_comment()
	local visual_started_at = self:_get_line_position("v")
	local cursor_at = self:_get_line_position(".")
  local from_pos = math.min(visual_started_at, cursor_at)
  local to_pos = math.max(visual_started_at, cursor_at)
	print("visual starts at " .. visual_started_at .. " cursor at: " .. cursor_at)
	if self.config.block_comment then
    vim.api.nvim_buf_set_lines(0, from_pos, from_pos, true, { self.config.block_comment[1]})
    vim.api.nvim_buf_set_lines(0, to_pos + 2, to_pos + 2, true, { self.config.block_comment[2]})
	else
		print("will need to line comment")
	end
end

return Commenter
