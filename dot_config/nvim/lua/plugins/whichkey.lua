-- return { -- Useful plugin to show you pending keybinds.
--     'folke/which-key.nvim',
--     event = 'VimEnter', -- Sets the loading event to 'VimEnter'
--       -- Document existing key chains
--       require('which-key').register {
--         ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
--         ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
--         ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
--         ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
--         ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
--       }
--     end,
-- }
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show { global = false }
      end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
}
