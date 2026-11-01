local assert = require("luassert.assert")

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
  it("creates toggle comment keymap", function()
    local plugin = require("bulk-comment")
    plugin.setup({})
    buffer_setup("python")
    local map = buffer_map("n", "<C-q>")
    assert.is_not_nil(map)
  end)
  it("creates block toggle comment keymap", function()
    local plugin = require("bulk-comment")
    plugin.setup({})
    buffer_setup("python")
    local map = buffer_map("x", "<C-q>")
    assert.is_not_nil(map)
  end)
  it("does not create Commenter if fileype is unsupported", function()
    local plugin = require("bulk-comment")
    plugin.setup({})
    buffer_setup("not-supported-filetype")
    assert.is_nil(buffer_map("n", "<C-q>"))
    assert.is_nil(buffer_map("x", "<C-q>"))
  end)
  it("creates Commenter with custom config", function ()
    local custom_opts = {
      keymaps = {
        line_comment = "lc",
        block_comment = "bc"
      }
    }
    local plugin = require("bulk-comment")
    plugin.setup(custom_opts)
    buffer_setup("c")
    assert.is_not_nil(buffer_map("n", "lc"))
    assert.is_not_nil(buffer_map("x", "bc"))
    assert.is_nil(buffer_map("n", "<C-q>"))
    assert.is_nil(buffer_map("x", "<C-q>"))
  end)
end)
