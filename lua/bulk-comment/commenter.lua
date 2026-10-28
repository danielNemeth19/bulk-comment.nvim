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
  local instance = setmetatable({}, self)
  instance.__index = instance
  instance.filetype = filetype
  instance.config = instance:_set_config(symbolMap)
  return instance
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
  local row_num = self:to_zero_based(row)
  if type(self.config.line_comment) == "string" then
    vim.api.nvim_buf_set_text(0, row_num, num_whitespace, row_num, num_whitespace, { self.config.line_comment })
  else
    local endpos = line:len()
    local padded_open_symbol = self.config.block_comment[1] .. " "
    local padded_close_symbol = " " .. self.config.block_comment[2]
    vim.api.nvim_buf_set_text(0, row_num, endpos, row_num, endpos, { padded_close_symbol })
    vim.api.nvim_buf_set_text(0, row_num, num_whitespace, row_num, num_whitespace, { padded_open_symbol })
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
  local start_row, end_row = self:to_zero_based(row), self:to_zero_based(row)
  local start_col = num_whitespace
  local end_col = num_whitespace + self.config.line_comment:len()
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { "" })
end

function Commenter:remove_block_comment(line, row, num_whitespace)
  local row_num = self:to_zero_based(row)
  local open_len = self.config.block_comment[1]:len() + 1
  local close_len = self.config.block_comment[2]:len() + 1
  local line_len = line:len()
  vim.api.nvim_buf_set_text(0, row_num, line_len - close_len, row_num, line_len, { "" })
  vim.api.nvim_buf_set_text(0, row_num, num_whitespace, row_num, num_whitespace + open_len, { "" })
end

-- TODO: consider taking row (1-based line number)
function Commenter:toggle_comment()
  local line = vim.api.nvim_get_current_line()
  local row, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
  if self:is_empty_row(line) then
    self:move_cursor(row, 0)
    return
  end

  local num_whitespace = self:count_whitespace(line)
  if not self:is_commented(line, num_whitespace) then
    self:add_comment(line, row, num_whitespace)
  else
    self:remove_comment(line, row, num_whitespace)
  end
  self:move_cursor(row, 0)
end

---@protected
---@param mode ("v" | ".")
---@return integer # Returns 1-based row position
function Commenter:_get_line_position(mode)
  local _, line_number, _, _ = table.unpack(vim.fn.getpos(mode))
  return line_number
end

---@param row_num integer
---@return integer
function Commenter:to_zero_based(row_num)
  return row_num - 1
end

---Moves the cursor to the line after `row`, or keeps it on the last line
---@param row integer # 1-based row
---@param col integer # 0-based column
function Commenter:move_cursor(row, col)
  local next_row = row + 1
  local last_row = vim.api.nvim_buf_line_count(0)
  local target_row = math.min(next_row, last_row)
  vim.api.nvim_win_set_cursor(0, { target_row, col }) -- nvim_win_set_cursor api uses 1-based count
end

---@param start_idx integer -- 0-based start idx of visual block
---@param end_idx integer -- 0-based end idx of visual block
---@return boolean
function Commenter:is_block_commented(start_idx, end_idx)
  local first_line = vim.api.nvim_buf_get_lines(0, start_idx, start_idx + 1, true)
  local end_line = vim.api.nvim_buf_get_lines(0, end_idx, end_idx + 1, true)
  local open_comment = self.config.block_comment[1]
  local close_comment = self.config.block_comment[2]
  return first_line[1] == open_comment and end_line[1] == close_comment
end

---@param start_idx integer -- 0-based start idx of visual block
---@param end_idx integer -- 0-based end idx of visual block
function Commenter:add_block_comment(start_idx, end_idx)
  local close_idx = end_idx + 1 -- line after the last selected one
  vim.api.nvim_buf_set_lines(0, close_idx, close_idx, true, { self.config.block_comment[2] })
  vim.api.nvim_buf_set_lines(0, start_idx, start_idx, true, { self.config.block_comment[1] })
end

---@param start_idx integer -- 0-based start idx of visual block
---@param end_idx integer -- 0-based end idx of visual block
function Commenter:remove_block_comment_lines(start_idx, end_idx)
  vim.api.nvim_buf_set_lines(0, end_idx, end_idx + 1, true, {})
  vim.api.nvim_buf_set_lines(0, start_idx, start_idx + 1, true, { })
end

function Commenter:block_toggle_comment()
  local visual_started_at = self:_get_line_position("v")
  local cursor_at = self:_get_line_position(".")
  local visual_from = math.min(visual_started_at, cursor_at)
  local visual_to = math.max(visual_started_at, cursor_at)

  -- leaving visual mode for synchronous edits
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! \27")
  end

  if self.config.block_comment then
    local start_idx = self:to_zero_based(visual_from)
    local end_idx = self:to_zero_based(visual_to)
    if not self:is_block_commented(start_idx, end_idx) then
      self:add_block_comment(start_idx, end_idx)
      local rows_added = #self.config.block_comment
      local closing_row = visual_to + rows_added
      self:move_cursor(closing_row, 0)
    else
      self:remove_block_comment_lines(start_idx, end_idx)
      local rows_removed = #self.config.block_comment
      local closing_row = visual_to - rows_removed
      self:move_cursor(closing_row, 0)
    end
  else
    for i = visual_from, visual_to do
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      self:toggle_comment()
    end
  end
end

return Commenter
