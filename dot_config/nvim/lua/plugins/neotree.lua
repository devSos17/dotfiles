-- NOTE: THis is the quickstart exmaple
-- - https://github.com/nvim-neo-tree/neo-tree.nvim?tab=readme-ov-file#quickstart
return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    {
      's1n7ax/nvim-window-picker',
      version = '2.*',
      config = function()
        require('window-picker').setup {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { 'terminal', 'quickfix' },
            },
          },
        }
      end,
    },
  },
  config = function()
    require('neo-tree').setup {
      window = {
        position = 'float',
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
      },
      filesystem = {
        hijack_netrw_behavior = 'open_current', -- netrw disabled, opening a directory opens within the window like netrw would, regardless of window.position
        -- 'open_default', -- netrw disabled, opening a directory opens neo-tree in whatever position is specified in window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
        window = {
          fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
            ['<C-j>'] = 'move_cursor_down',
            ['<C-k>'] = 'move_cursor_up',
          },
        },
      },
    }

    -- vim.cmd [[nnoremap \ :Neotree reveal<cr>]]
    vim.keymap.set('n', '<leader>e', ':Neotree reveal<CR>')
  end,
}
