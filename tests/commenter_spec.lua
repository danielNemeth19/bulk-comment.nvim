describe("commenter class", function ()
	it("can require", function ()
		require("bulk-comment.commenter")
	end)
	it("can initialize lua commenter", function ()
		local Commenter = require("bulk-comment.commenter")
		local c = Commenter:new('lua')
		assert.equals(c.filetype, 'lua')
		assert.equals(c.symbol, "-- ")
	end)
	it("can initialize python commenter", function ()
		local Commenter = require("bulk-comment.commenter")
		local c = Commenter:new('python')
		assert.equals(c.filetype, 'python')
		assert.equals(c.symbol, "# ")
	end)
	it("can initialize lua commenter", function ()
		local Commenter = require("bulk-comment.commenter")
		local c = Commenter:new('go')
		assert.equals(c.filetype, 'go')
		assert.equals(c.symbol, "// ")
	end)
	it("sets symbol as none for unknown filetype", function ()
		local Commenter = require("bulk-comment.commenter")
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
		local Commenter = require("bulk-comment.commenter")
		local c = Commenter:new('lua')

		for _, example in ipairs(examples) do
			local res = c:count_whitespace(example.line)
			assert.equals(example.result, res)
		end
	end)
	it("can determine if line is a code snippet", function ()
		local Commenter = require("bulk-comment.commenter")
		local c = Commenter:new('lua')
		local non_empty = "function test()"
		local verdict = c:is_empty_row(non_empty)
		assert.equals(false, verdict)
	end)
	it("can determine if line is code snippet even if whitespace present", function ()
		local Commenter = require("bulk-comment.commenter")
		local c = Commenter:new('lua')
		local non_empty = " function test()"
		local verdict = c:is_empty_row(non_empty)
		assert.equals(false, verdict)
	end)
	it("can determine if empty row when line is empty string", function ()
		local Commenter = require("bulk-comment.commenter")
		local c = Commenter:new('lua')
		local empty = ""
		local empty_verdict = c:is_empty_row(empty)
		assert.equals(true, empty_verdict)
	end)
	it("can determine if empty row when line only has whitespaces", function ()
		 local Commenter = require("bulk-comment.commenter")
		 local c = Commenter:new('lua')
		 local non_alphanumeric = "   "
		 local non_alpha_verdict = c:is_empty_row(non_alphanumeric)
		 assert.equals(true, non_alpha_verdict)
	 end)
end)
