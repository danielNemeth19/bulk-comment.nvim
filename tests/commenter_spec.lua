-- for tests look at: https://github.com/terrortylor/nvim-comment
local assert = require("luassert.assert")
local mock = require("luassert.mock")

describe("commenter class", function ()
	before_each(function ()
		Commenter = require("bulk-comment.commenter")
		API_MOCK = mock(vim.api, true)
	end)
	after_each(function ()
		mock.revert(API_MOCK)
	end)
	it("can require", function ()
		require("bulk-comment.commenter")
	end)
	it("can initialize lua commenter", function ()
		local c = Commenter:new('lua')
		assert.equals(c.filetype, 'lua')
		assert.equals(c.symbol, "-- ")
	end)
	it("can initialize python commenter", function ()
		local c = Commenter:new('python')
		assert.equals(c.filetype, 'python')
		assert.equals(c.symbol, "# ")
	end)
	it("can initialize yaml commenter", function ()
		local c = Commenter:new('yaml')
		assert.equals(c.filetype, 'yaml')
		assert.equals(c.symbol, "# ")
	end)
	it("can initialize go commenter", function ()
		local c = Commenter:new('go')
		assert.equals(c.filetype, 'go')
		assert.equals(c.symbol, "// ")
	end)
	it("can initialize javascript commenter", function ()
		local c = Commenter:new('javascript')
		assert.equals(c.filetype, 'javascript')
		assert.equals(c.symbol, "// ")
	end)
	it("can initialize typescript commenter", function ()
		local c = Commenter:new('typescript')
		assert.equals(c.filetype, 'typescript')
		assert.equals(c.symbol, "// ")
	end)
	it("can initialize sh commenter", function ()
		local c = Commenter:new('sh')
		assert.equals(c.filetype, 'sh')
		assert.equals(c.symbol, "# ")
	end)
	it("can initialize fish commenter", function ()
		local c = Commenter:new('fish')
		assert.equals(c.filetype, 'fish')
		assert.equals(c.symbol, "# ")
	end)
	it("can initialize css commenter", function ()
		local c = Commenter:new('css')
		assert.equals(c.filetype, 'css')
		assert.equals("/* ", c.symbol[1])
		assert.equals(" */", c.symbol[2])
	end)
	it("can initialize html commenter", function ()
		local c = Commenter:new('html')
		assert.equals(c.filetype, 'html')
		assert.equals("<!--", c.symbol[1])
		assert.equals("-->", c.symbol[2])
	end)
	it("sets symbol as none for unknown filetype", function ()
		local c = Commenter:new('unknown-language')
		assert.equals(c.filetype, 'unknown-language')
		assert.equals(c.symbol, nil)
	end)
	it("can count whitespaces", function ()
		local examples = {
			{ line = "", result = 0 },
			{ line = "example 1", result = 0 },
			{ line = " example 2", result = 1 },
			{ line = "  example 3", result = 2 },
			{ line = "   example 4", result = 3 }
		}
		local c = Commenter:new('lua')

		for _, example in ipairs(examples) do
			local res = c:count_whitespace(example.line)
			assert.equals(example.result, res)
		end
	end)
	it("can determine if line is a code snippet", function ()
		local c = Commenter:new('lua')
		local non_empty = "function test()"
		local verdict = c:is_empty_row(non_empty)
		assert.equals(false, verdict)
	end)
	it("can determine if line is code snippet even if whitespace present", function ()
		local c = Commenter:new('lua')
		local non_empty = " function test()"
		local verdict = c:is_empty_row(non_empty)
		assert.equals(false, verdict)
	end)
	it("can determine if empty row when line is empty string", function ()
		local c = Commenter:new('lua')
		local empty = ""
		local empty_verdict = c:is_empty_row(empty)
		assert.equals(true, empty_verdict)
	end)
	it("can determine if empty row when line only has whitespaces", function ()
		local c = Commenter:new('lua')
		local non_alphanumeric = "   "
		local non_alpha_verdict = c:is_empty_row(non_alphanumeric)
		assert.equals(true, non_alpha_verdict)
	end)
	it("toggle returns nil for empty row", function ()
		local c = Commenter:new('lua')

		API_MOCK.nvim_get_current_line.returns(" ")
		API_MOCK.nvim_win_get_cursor.returns({10, 0})

		local result = c:toggle_comment()
		assert.equals(nil, result)
	end)
	it("toggle moves cursor next row for empty row", function ()
		local c = Commenter:new('lua')

		API_MOCK.nvim_get_current_line.returns(" ")
		API_MOCK.nvim_win_get_cursor.returns({12, 0})

		c:toggle_comment()
		assert.stub(API_MOCK.nvim_win_set_cursor).was_called_with(0, {13, 0})
	end)
	it("can toggle inline style comment", function ()
		local c = Commenter:new('python')

		API_MOCK.nvim_get_current_line.returns("class MyClass:")
		API_MOCK.nvim_win_get_cursor.returns({2, 0})
		c:toggle_comment()
		assert.stub(API_MOCK.nvim_win_set_cursor).was_called_with(0, {2, 0})
		assert.stub(API_MOCK.nvim_put).was_called_with({"# "}, 'c', false, false)
		assert.stub(API_MOCK.nvim_win_set_cursor).was_called_with(0, {3, 0})
		assert.stub(API_MOCK.nvim_win_set_cursor).was.called(2)
	end)
	it("can toggle block style comment", function ()
		local c = Commenter:new('css')
		local line = ".myclass {"

		API_MOCK.nvim_get_current_line.returns(line)
		API_MOCK.nvim_win_get_cursor.returns({10, 0})
		c:toggle_comment()
		assert.stub(API_MOCK.nvim_win_set_cursor).was_called_with(0, {10, line:len()})
		assert.stub(API_MOCK.nvim_put).was_called_with({" */"}, 'c', true, false)
		assert.stub(API_MOCK.nvim_win_set_cursor).was_called_with(0, {10, 0})
		assert.stub(API_MOCK.nvim_put).was_called_with({"/* "}, 'c', false, false)
		assert.stub(API_MOCK.nvim_put).was.called(2)
	end)
    it("is commented should return true for commented line", function ()
        local c = Commenter:new('go')
        local line = "// func myFunc(x, y int) bool {"
        local verdict = c:is_commented(line, 0)
        assert.equals(true, verdict)
    end)
    it("is commented should return false for uncommented line", function ()
        local c = Commenter:new('sh')
        local line = "   USERNAME=($whoami)"
        local verdict = c:is_commented(line, 3)
        assert.equals(false, verdict)
    end)
    it("is commented should return true for commented line - block style", function ()
        local c = Commenter:new('css')
        local line = "  /* navbar-brand { */"
        local verdict = c:is_commented(line, 2)
        assert.equals(true, verdict)
    end)
    it("is commented should return false for uncommented line - block style", function ()
        local c = Commenter:new('sh')
        local line = "USERNAME=($whoami)"
        local verdict = c:is_commented(line, 0)
        assert.equals(false, verdict)
    end)
end)
