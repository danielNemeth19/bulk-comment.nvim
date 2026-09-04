local assert = require("luassert.assert")

local function buffer_setup(filetype, input)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "filetype", filetype)
	vim.api.nvim_command("buffer " .. buf)
	vim.api.nvim_buf_set_lines(0, 0, -1, true, input)
end

local function toggle_line(line)
	vim.api.nvim_win_set_cursor(0, { line, 0 })
	local keypress = vim.api.nvim_replace_termcodes("bc", true, false, true)
	vim.api.nvim_feedkeys(keypress, "x", false)
end

local function toggle_block_paragraph(line)
	vim.api.nvim_win_set_cursor(0, { line, 0 })
	local keypress = vim.api.nvim_replace_termcodes("vip", true, false, true)
	vim.api.nvim_feedkeys(keypress, "x", false)
	local keypress_2 = vim.api.nvim_replace_termcodes("vc", true, false, true)
	vim.api.nvim_feedkeys(keypress_2, "x", false)
end

---@param line integer
---@param hl_direction ("j" | "k")
---@param repeat_count integer
local function toggle_block_with_manual_visual(line, hl_direction, repeat_count)
	vim.api.nvim_win_set_cursor(0, { line, 0 })
	local keypress = vim.api.nvim_replace_termcodes("V", true, false, true)
	vim.api.nvim_feedkeys(keypress, "x", false)
	for _ = 1, repeat_count do
		local move_cursor = vim.api.nvim_replace_termcodes(hl_direction, true, false, true)
		vim.api.nvim_feedkeys(move_cursor, "x", false)
	end
	keypress = vim.api.nvim_replace_termcodes("vc", true, false, true)
	vim.api.nvim_feedkeys(keypress, "x", false)
end

local function get_lines_from_buffer()
	local row_num = vim.api.nvim_buf_line_count(0)
	local buffer_content = vim.api.nvim_buf_get_lines(0, 0, row_num, false)
	return buffer_content
end

describe("bulk-comment", function()
	before_each(function()
		local plugin = require("bulk-comment")
		vim.keymap.set("n", "bc", plugin.toggle, { desc = "testing line commenting" })
		vim.keymap.set("v", "vc", plugin.block_toggle, { desc = "testing bulk commenting" })
	end)
	it("can require", function()
		require("bulk-comment")
	end)
	it("last row can be commented", function()
		local input = { "sys.exit(3)" }
		local expected_output = { "# sys.exit(3)" }

		buffer_setup("python", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("last row can be commented - multiple rows", function()
		local input = {
			"local function my_func(param)",
			"print(param)",
			"end",
		}
		local expected_output = {
			"local function my_func(param)",
			"print(param)",
			"-- end",
		}
		buffer_setup("lua", input)
		toggle_line(3)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("commenting single row", function()
		local input = { "function myTest() int {" }
		local expected_output = { "// function myTest() int {" }
		buffer_setup("go", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("commenting single row - with whitespace", function()
		local input = { "  local my_var = 6" }
		local expected_output = { "  -- local my_var = 6" }
		buffer_setup("lua", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("commenting in-line with block style only language", function()
		local input = { ".navbar {" }
		local expected_output = { "/*.navbar {*/" }
		buffer_setup("css", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("commenting in-lihe with block style only language - with whitespace", function()
		local input = { "  margin-left: auto;" }
		local expected_output = { "  /*margin-left: auto;*/" }
		buffer_setup("css", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("uncommenting single row", function()
		local input = { "// function myTest() int {" }
		local expected_output = { "function myTest() int {" }
		buffer_setup("go", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("uncommenting single row - with whitespace", function()
		local input = { "  // myVal := 5" }
		local expected_output = { "  myVal := 5" }
		buffer_setup("go", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("uncommenting block style", function()
		local input = { "/*.navbar {*/" }
		local expected_output = { ".navbar {" }
		buffer_setup("css", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("uncommenting block style - with whitespace", function()
		local input = { "  /*margin-left: auto;*/" }
		local expected_output = { "  margin-left: auto;" }
		buffer_setup("css", input)
		toggle_line(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("commenting paragraph with block toggle", function()
		local input = { "#include <stdlib.h>", "#include <string.h>", "#include <snekobject.h>" }
		local expected_output = {
			"/*",
			"#include <stdlib.h>",
			"#include <string.h>",
			"#include <snekobject.h>",
			"*/",
		}
		buffer_setup("c", input)
		toggle_block_paragraph(1)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
	it("commenting manually visually highlighted with block toggle", function()
		local input = { "#include <stdlib.h>", "#include <string.h>", "#include <snekobject.h>" }
		local expected_output = {
			"/*",
			"#include <stdlib.h>",
			"#include <string.h>",
			"#include <snekobject.h>",
			"*/",
		}
		buffer_setup("c", input)
		toggle_block_with_manual_visual(3, "k", 2)
		local buffer_content = get_lines_from_buffer()
		assert.are.same(expected_output, buffer_content)
	end)
end)
