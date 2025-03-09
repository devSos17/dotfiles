-- [[ TELESCOPE ]] by tj
return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make', -- Run when insstalling/updating
      cond = function() -- condition to install
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- [[ Configure Telescope ]]
    require('telescope').setup { -- See `:help telescope` and `:help telescope.setup()`
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`

      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
            ['<C-j>'] = require('telescope.actions').move_selection_next,
            ['<C-k>'] = require('telescope.actions').move_selection_previous,
          },
        },
      },
      pickers = {
        find_files = {
          theme = 'dropdown',
        },
        git_files = {
          theme = 'dropdown',
        },
        live_grep = {
          theme = 'dropdown',
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sG', builtin.git_status, { desc = '[S]earch by [G]it Status' })
    -- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    -- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>srf', builtin.oldfiles, { desc = '[S]earch [R]ecent [F]iles' })
    --  lago
    vim.keymap.set('n', '<C-p>', builtin.git_files, {})
    -- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>sof', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch in [O]pen [F]iles' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}

--  ----------------------------------------------- TELESCOPE
--  local builtin = require 'telescope.builtin'
--  vim.keymap.set('n', '<C-p>', builtin.git_files, {})
--  vim.keymap.set('n', '<leader><C-p>', builtin.find_files, {})
--  -- Search files
--  vim.keymap.set('n', '<leader><C-f>', builtin.live_grep, { desc = '[s]earch by [g]rep' })
--  vim.keymap.set('n', '<leader><leader><C-f>', function()
--    builtin.grep_string { search = vim.fn.input 'Grep> ' }
--  end)
--  vim.keymap.set('n', '<leader><TAB>', builtin.buffers, {})
--  vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
--
--  -- Search in file
--  vim.keymap.set('n', '<leader>f', builtin.current_buffer_fuzzy_find, {}) -- Currently bugged 20/12/22
--
--  -- show registers
--  vim.keymap.set('n', '<leader><leader>y', builtin.registers, {}) -- Currently bugged 20/12/22
--
