return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration
    'nvim-telescope/telescope.nvim', -- optional
  },
  opts = {},
  config = function()
    local ng = require 'neogit'
    ng.setup {}
    vim.keymap.set('n', '<leader>gs', ng.open, { desc = 'Open neogit' })
    return true
  end,
}
