local assert = require("luassert.assert")
local stub = require("luassert.stub")
local commenter = require("bulk-comment.commenter")

local function buffer_setup(filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = filetype
  vim.api.nvim_set_current_buf(buf)
end

local function buffer_map(mode, lhs)
  local map = vim.fn.maparg(lhs, mode, false, true)
  return map.buffer == 1 and map or nil
end

describe("testing init", function()
  before_each(function()
    print('lets see')
  end)
  it("first", function()
    local plugin = require("bulk-comment")
    plugin.setup({})
    buffer_setup("python")
    local map = buffer_map("n", "<C-q>")
    assert.is_not_nil(map)
  end)
end)
