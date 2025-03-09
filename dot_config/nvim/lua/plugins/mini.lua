return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- TODO: CHANGE THIS INTO CUSTOM MINI TEXT OBJECTS
    -- https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-ai.txt
    --
    -- inner line
    vim.keymap.set('x', 'il', 'g_o^', { desc = 'Inner Line selector' })
    vim.keymap.set('o', 'il', ':normal vil<CR>', { desc = 'Inner Line selector' })
    -- Around line
    vim.keymap.set('x', 'al', '$o^', { desc = 'Around Line Selector' })
    vim.keymap.set('o', 'al', ':normal val<CR>', { desc = 'Around Line Selector' })

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
