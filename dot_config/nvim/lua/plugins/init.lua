return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  { 'numToStr/Comment.nvim', opts = {} }, -- "gc" to comment visual regions/lines
  'mbbill/undotree',
  'moll/vim-bbye',
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } }, -- Highlight todo, notes, etc in comments
  { 'windwp/nvim-autopairs', opts = {} },
  'djoshea/vim-autoread',
  { -- RUST TOOLS // needs rust-analyser -> lsp->mason->servers
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    ft = { 'rust' },
  },
}

-- WARN: broke when updating lazy to 11.4
--   , {
--   ui = {
--     -- If you are using a Nerd Font: set icons to an empty table which will use the
--     -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
--     icons = vim.g.have_nerd_font and {} or {
--       cmd = '⌘',
--       config = '🛠',
--       event = '📅',
--       ft = '📂',
--       init = '⚙',
--       keys = '🗝',
--       plugin = '🔌',
--       runtime = '💻',
--       require = '🌙',
--       source = '📄',
--       start = '🚀',
--       task = '📌',
--       lazy = '💤 ',
--     },
--   },
-- }
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
