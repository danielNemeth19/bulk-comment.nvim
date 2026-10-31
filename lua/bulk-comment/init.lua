local M = {}

local Commenter = require("bulk-comment.commenter")

local keymap_presets = {
  line_comment = "<C-q>",
  block_comment = "<C-q>",
}

M.defaults = {
  keymaps = keymap_presets
}

function M.setup(opts)
  local options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

  vim.api.nvim_create_autocmd("FileType", {
    pattern = Commenter.supported_languages(),
    group = vim.api.nvim_create_augroup("BulkComment", { clear = true }),
    callback = function(args)
      local commenter = Commenter.new(args.match)

      if not commenter then
        vim.api.nvim_echo({ { "Not yet supported: " .. args.match } }, true, { err = false })
        return
      end

      vim.keymap.set("n", options.keymaps.line_comment, function()
        commenter:toggle_comment()
      end, { buffer = args.buf, nowait = true })
      vim.keymap.set("x", options.keymaps.block_comment, function()
        commenter:block_toggle_comment()
      end, { buffer = args.buf })
    end
  })
end

return M
