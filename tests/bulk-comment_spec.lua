local assert = require("luassert.assert")

local function buffer_setup(filetype, input)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = filetype
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, input)
end

---@param line integer
local function highlight_paragraph(line)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  local keypress = vim.api.nvim_replace_termcodes("vip", true, false, true)
  vim.api.nvim_feedkeys(keypress, "x", false)
end

---@param line integer
---@param hl_direction ("up" | "down")
---@param repeat_count integer
local function highlight_lines_manually(line, hl_direction, repeat_count)
  local movement_map = {
    up = "k",
    down = "j",
  }
  local direction = movement_map[hl_direction]
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  local keypress = vim.api.nvim_replace_termcodes("V", true, false, true)
  vim.api.nvim_feedkeys(keypress, "n", false)
  for _ = 1, repeat_count do
    local move_cursor = vim.api.nvim_replace_termcodes(direction, true, false, true)
    vim.api.nvim_feedkeys(move_cursor, "n", false)
  end
end

local function get_lines_from_buffer()
  local row_num = vim.api.nvim_buf_line_count(0)
  local buffer_content = vim.api.nvim_buf_get_lines(0, 0, row_num, false)
  return buffer_content
end

describe("Single line toggle - with single line support ->", function()
  local line_toggle_keymap = "lc"
  local function press_toggle_line(line)
    vim.api.nvim_win_set_cursor(0, { line, 0 })
    local keypress = vim.api.nvim_replace_termcodes(line_toggle_keymap, true, false, true)
    vim.api.nvim_feedkeys(keypress, "x", false)
  end
  before_each(function()
    local plugin = require("bulk-comment")
    vim.keymap.set("n", line_toggle_keymap, plugin.toggle, { desc = "testing line commenting" })
  end)
  it("can require", function()
    require("bulk-comment")
  end)
  it("comments line: single row", function()
    local input = { "function myTest() int {", "myVar := 5" }
    local expected_output = { "// function myTest() int {", "myVar := 5" }
    buffer_setup("go", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 2)
  end)
  it("comments line: single row with whitespace", function()
    local input = { "  local my_var = 6" }
    local expected_output = { "  -- local my_var = 6" }
    buffer_setup("lua", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("uncomments line: single row", function()
    local input = { "// function myTest() int {" }
    local expected_output = { "function myTest() int {" }
    buffer_setup("go", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("uncomments line: single row - with whitespace", function()
    local input = { "  // myVal := 5" }
    local expected_output = { "  myVal := 5" }
    buffer_setup("go", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("cursor positioning: cursor moved to next row", function()
    local input = { "function myTest() int {", "myVar := 5", "otherVar := 3" }
    buffer_setup("go", input)
    press_toggle_line(1)
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 2)
  end)
  it("cursor positioning: for last row cursor not moved", function()
    local input = {
      "local function my_func(param)",
      "print(param)",
      "end",
    }
    buffer_setup("lua", input)
    press_toggle_line(3)
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 3)
  end)
  it("cursor positioning: empty row not modified, cursor moved to next row", function()
    local input = {"local plugin = require('my-module')", "", "print(a)"}
    buffer_setup("lua", input)
    press_toggle_line(2)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(input, buffer_content)
    assert.equals(3, vim.api.nvim_win_get_cursor(0)[1])
  end)
  it("cursor positioning: if empty line is last line, cursor stays on last row", function()
    local input = {"local plugin = require('my-module')", ""}
    buffer_setup("lua", input)
    press_toggle_line(2)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(input, buffer_content)
    assert.equals(2, vim.api.nvim_win_get_cursor(0)[1])
  end)
end)

describe("Single line toggle - without single line support ->", function()
  local line_toggle_keymap = "lc"
  local function press_toggle_line(line)
    vim.api.nvim_win_set_cursor(0, { line, 0 })
    local keypress = vim.api.nvim_replace_termcodes(line_toggle_keymap, true, false, true)
    vim.api.nvim_feedkeys(keypress, "x", false)
  end
  before_each(function()
    local plugin = require("bulk-comment")
    vim.keymap.set("n", line_toggle_keymap, plugin.toggle, { desc = "testing line commenting" })
  end)
  it("can require", function()
    require("bulk-comment")
  end)
  it("comments line: single row", function()
    local input = { ".navbar {", "  display: grid;" }
    local expected_output = { "/* .navbar { */", "  display: grid;" }
    buffer_setup("css", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("comments line: single row with whitespace", function()
    local input = { "  margin-left: auto;" }
    local expected_output = { "  /* margin-left: auto; */" }
    buffer_setup("css", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("uncomments line: single row", function()
    local input = { "/* .navbar { */" }
    local expected_output = { ".navbar {" }
    buffer_setup("css", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("uncomments line: single row - with whitespace", function()
    local input = { "  /* margin-left: auto; */" }
    local expected_output = { "  margin-left: auto;" }
    buffer_setup("css", input)
    press_toggle_line(1)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("cursor positioning: cursor moved to next row", function()
    local input = { ".navbar {", "  display: grid;" }
    buffer_setup("css", input)
    press_toggle_line(1)
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 2)
  end)
  it("cursor positioning: for last row cursor not moved", function()
    local input = {
      "    </container>",
      "  </body>",
      "</html>",
    }
    buffer_setup("html", input)
    press_toggle_line(3)
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 3)
  end)
  it("cursor positioning: empty row not modified, cursor moved to next row", function()
    local input = {
      "    </container>",
      "",
      "  </body>",
      "</html>",
    }
    buffer_setup("html", input)
    press_toggle_line(2)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(input, buffer_content)
    assert.equals(3, vim.api.nvim_win_get_cursor(0)[1])
  end)
  it("cursor positioning: if empty line is last line, cursor stays on last row", function()
    local input = {
      "    </container>",
      "",
    }
    buffer_setup("html", input)
    press_toggle_line(2)
    local buffer_content = get_lines_from_buffer()
    assert.are.same(input, buffer_content)
    assert.equals(2, vim.api.nvim_win_get_cursor(0)[1])
  end)
end)

describe("Block toggle - with block comment support ->", function()
  local block_toggle_keymap = "vc"
  local function press_block_toggle()
    local keypress = vim.api.nvim_replace_termcodes(block_toggle_keymap, true, false, true)
    vim.api.nvim_feedkeys(keypress, "x", false)
  end
  before_each(function()
    local plugin = require("bulk-comment")
    vim.keymap.set("v", block_toggle_keymap, plugin.block_toggle, { desc = "testing bulk commenting" })
    require("bulk-comment")
  end)
  it("can require", function()
    require("bulk-comment")
  end)
  it("comments selection: visual inner paragraph", function()
    local input = { "#include <stdlib.h>", "#include <string.h>", "#include <snekobject.h>" }
    local expected_output = {
      "/*",
      "#include <stdlib.h>",
      "#include <string.h>",
      "#include <snekobject.h>",
      "*/",
    }
    buffer_setup("c", input)
    highlight_paragraph(1)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
    local mode = vim.api.nvim_get_mode().mode
    assert.equals(mode, "n")
  end)
  it("comments selection: visual linewise + down", function()
    local input = { "#include <stdlib.h>", "#include <string.h>", "#include <snekobject.h>" }
    local expected_output = {
      "#include <stdlib.h>",
      "/*",
      "#include <string.h>",
      "#include <snekobject.h>",
      "*/",
    }
    buffer_setup("c", input)
    highlight_lines_manually(2, "down", 1)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("comments selection: visual linewise + up", function()
    local input = { "#include <stdlib.h>", "#include <string.h>", "#include <snekobject.h>" }
    local expected_output = {
      "/*",
      "#include <stdlib.h>",
      "#include <string.h>",
      "#include <snekobject.h>",
      "*/",
    }
    buffer_setup("c", input)
    highlight_lines_manually(3, "up", 2)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("mode handling: visual mode -> normal mode", function()
    local input = { "#include <stdlib.h>", "#include <string.h>", "#include <snekobject.h>" }
    buffer_setup("c", input)
    highlight_paragraph(1)
    press_block_toggle()
    local mode = vim.api.nvim_get_mode().mode
    assert.equals(mode, "n")
  end)
  it("cursor positioning: cursor moved after block commented block", function()
    local input = {
      "godotenv.Load()",
      "dbQueries := database.New(db)",
      "",
      "serverMux := http.NewServeMux()"
    }
    buffer_setup("go", input)
    highlight_lines_manually(1, "down", 1)
    press_block_toggle()
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 5)
  end)
  it("cursor positioning: cursor moved to the closing block comment if at the end of buffer", function()
    local input = { "#include <stdlib.h>", "#include <string.h>", "#include <snekobject.h>" }
    buffer_setup("c", input)
    highlight_paragraph(1)
    press_block_toggle()
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 5)
  end)
end)

describe("Block toggle - without block comment support ->", function()
  local block_toggle_keymap = "vc"
  local function press_block_toggle()
    local keypress = vim.api.nvim_replace_termcodes(block_toggle_keymap, true, false, true)
    vim.api.nvim_feedkeys(keypress, "x", false)
  end
  before_each(function()
    local plugin = require("bulk-comment")
    vim.keymap.set("v", block_toggle_keymap, plugin.block_toggle, { desc = "testing bulk commenting" })
    require("bulk-comment")
  end)
  it("can require", function()
    require("bulk-comment")
  end)
  it("comments selection: visual inner paragraph", function()
    local input = { "def my_func(x, y):", "    z = x * y", "    return z" }
    local expected_output = {
      "# def my_func(x, y):",
      "    # z = x * y",
      "    # return z",
    }
    buffer_setup("python", input)
    highlight_paragraph(1)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
    local mode = vim.api.nvim_get_mode().mode
    assert.equals(mode, "n")
  end)
  it("comments selection: visual linewise + down", function()
    local input = { "def my_func(x, y):", "    z = x * y", "    return z" }
    local expected_output = {
      "def my_func(x, y):",
      "    # z = x * y",
      "    # return z",
    }
    buffer_setup("python", input)
    highlight_lines_manually(2, "down", 1)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("comments selection: visual linewise + up", function()
    local input = { "def my_func(x, y):", "    z = x * y", "    return z" }
    local expected_output = {
      "# def my_func(x, y):",
      "    # z = x * y",
      "    # return z",
    }
    buffer_setup("python", input)
    highlight_lines_manually(3, "up", 2)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("mode handling: visual mode -> normal mode", function()
    local input = {
      "# def my_func(x, y):",
      "    # z = x * y",
      "    # return z",
    }
    buffer_setup("python", input)
    highlight_paragraph(1)
    press_block_toggle()
    local mode = vim.api.nvim_get_mode().mode
    assert.equals(mode, "n")
  end)
  it("cursor positioning: cursor moved to next line after commented lines", function()
    local input = {
      "import json",
      "import sys",
      "",
      "logger = logging.basicConfig(level=logging.INFO)"
    }
    buffer_setup("python", input)
    highlight_lines_manually(1, "down", 1)
    press_block_toggle()
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 3)
  end)
  it("cursor positioning: cursor stays on the last commented line if at the end of buffer", function()
    local input = { "def my_func(x, y):", "    z = x * y", "    return z" }
    buffer_setup("python", input)
    highlight_paragraph(1)
    press_block_toggle()
    local active_line = vim.api.nvim_win_get_cursor(0)[1]
    assert.equals(active_line, 3)
  end)
  it("cursor positioning: selection ending on an empty last row does not error", function ()
    local input = { "sys.exit(3)", ""}
    local expected_output = {"# sys.exit(3)", "" }
    buffer_setup("python", input)
    highlight_lines_manually(1, "down", 1)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("empty rows inside selection are left untouched", function ()
    local input = {"import functools", "", "import pandas as pd"}
    local expected_output = {"# import functools", "", "# import pandas as pd"}
    buffer_setup("python", input)
    highlight_lines_manually(1, "down", 2)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
  it("entering-leaving visual mode before trigger should be handled", function()
    local input = {"import functools", "import pandas as pd"}
    local expected_output = {
      "# import functools",
      "# import pandas as pd",
    }
    buffer_setup("python", input)

    -- visually highlighting second row
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    local keypress = vim.api.nvim_replace_termcodes("V", true, false, true)
    vim.api.nvim_feedkeys(keypress, "x", false)
    -- exit visual highlight
    local exit_visual = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(exit_visual, "n", false)

    highlight_paragraph(1)
    press_block_toggle()
    local buffer_content = get_lines_from_buffer()
    assert.are.same(expected_output, buffer_content)
  end)
end)
