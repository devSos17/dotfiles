-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ NAVIAGTION ]]
--Use ctrl alt to new splits
vim.keymap.set('n', '<C-A-j>', ':split<CR>', { desc = 'Add split' })
vim.keymap.set('n', '<C-A-k>', ':split<CR>', { desc = 'Add split' })
vim.keymap.set('n', '<C-A-h>', ':vsplit<CR>', { desc = 'Add split' })
vim.keymap.set('n', '<C-A-l>', ':vsplit<CR>', { desc = 'Add split' })

--Alt to resize windows
vim.keymap.set('n', '<A-j>', ':resize -2<CR>', { desc = 'Resize window -' })
vim.keymap.set('n', '<A-k>', ':resize +2<CR>', { desc = 'Resize window +' })
vim.keymap.set('n', '<A-h>', ':vertical resize -2<CR>', { desc = 'Vertical Resize window -' })
vim.keymap.set('n', '<A-l>', ':vertical resize +2<CR>', { desc = 'Vertical Resize window +' })

-- Buffer nav
vim.keymap.set('n', '<leader>n', ':bnext<CR>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>p', ':bprev<CR>', { desc = 'Previous Buffer' })

-- Close buffer and keep the 'buffer'
-- vim.keymap.set('n', '<leader><leader>q', ':bd<CR>')
-- vim.keymap.set('n', '<leader><leader>Q', ':bd!<CR>')
vim.keymap.set('n', '<leader><leader>q', ':b#|bd#<CR>')
vim.keymap.set('n', '<leader><leader>Q', ':b#|bd#!<CR>')

--  NOTE: Managed in tmux Navigator plugin setup
--
--  -- Better window navigation
--  -- vim.keymap.set("n", "<C-h>", "<C-w>h")
--  -- vim.keymap.set("n", "<C-j>", "<C-w>j")
--  -- vim.keymap.set("n", "<C-k>", "<C-w>k")
--  -- vim.keymap.set("n", "<C-l>", "<C-w>l")
--  vim.keymap.set('n', '<C-h>', '<cmd><C-U>TmuxNavigateLeft<CR>')
--  vim.keymap.set('n', '<C-j>', '<cmd><C-U>TmuxNavigateDown<CR>')
--  vim.keymap.set('n', '<C-k>', '<cmd><C-U>TmuxNavigateUp<CR>')
--  vim.keymap.set('n', '<C-l>', '<cmd><C-U>TmuxNavigateRight<CR>')
--

--  [[ NOTE: HELPFUL UTILS]]
--
-- reload
-- vim.keymap.set('n', '<leader>r', ':source $MYVIMRC<CR>', { desc = 'Resource my VIMRC' }) -- NOTE: LAZU DOES NOT SUPPORT RELOADING CONFIG ...
-- Better tabbing
vim.keymap.set('v', '<', '<gv', { desc = 'Better tab <' })
vim.keymap.set('v', '>', '>gv', { desc = 'Better tab >' })

-- Save file as sudo when no sudo permissions
vim.keymap.set('c', 'w!!', 'w !sudo tee > /dev/null %', { desc = 'Sudo save' })

-- Fix Y
vim.keymap.set('n', 'Y', 'y$', { desc = 'Fix Y' })

-- Missing Line object
-- Easy TO-UPPER
vim.keymap.set('i', '<leader>uu', '<ESC>viwUa', { desc = 'Easy to lower' })
vim.keymap.set('n', '<leader>uu', 'viwU<Esc>', { desc = 'Easy to UPPER' })
-- ============================================ FrOM the PRIMAGEN
-- move when selected
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move Selection' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move Selection' })

-- Stay centered
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Paste selected and no overwrite copied
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without overwrite' })

-- Copy to +registry
-- vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])
-- vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Jump to tmux session
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Quick list position list
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- substitute selected word
vim.keymap.set('n', '<C-A-s>', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make executable
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })

-- undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- [[ OLD MINE ]] =============================================================
--
-- Alias replace all to
-- vim.keymap.set('n', '<A-s>', ':%s//gI<Left><Left><Left>', { desc = 'Replace' })
--
--  --
--  vim.keymap.set('n', '<leader>e', vim.cmd.Lex)
--  vim.keymap.set('n', '<leader>E', ':Lex %:p:h<CR>')
--
--  -- save
--  vim.keymap.set('n', '<leader>s', ':w<CR>')
--  -- Save as
--  vim.keymap.set('n', '<leader><S-s>', ':w')
--
--  -- spell
--  vim.keymap.set('n', '<leader><S-d>', ':set spell!<CR>')
--  vim.keymap.set('n', '<leader>d', ']s z=')
--
--  -- Go to current file directory
--  vim.keymap.set('n', '<leader>gc', ':cd %:p:h<CR>')
--
--  -- New empty buffer
--  vim.keymap.set('n', '<leader>n', ':enew<CR>')
--
--
--  -- Better terminal mode (changed for toogle term)
--  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')
--  -- Expplicit toggle vertical
--  vim.keymap.set('n', '<leader>tv', ":ToggleTerm direction='vertical'<CR>")
--  vim.keymap.set('n', '<leader>tt', ":ToggleTerm direction='horizontal'<CR>")
--  vim.keymap.set('n', '<leader>tf', ":ToggleTerm direction='float'<CR>")
--
--  -- " Tab shortcuts (pending, maybe)
--  -- vim.keymap.set("n","<TaB>",":tabp<CR>")
--  -- vim.keymap.set("n","<S-TaB>",":tabn<CR>")
--  -- vim.keymap.set("n","<leader>t",":tabnew<CR>")
--
--  -- Clear search
--  vim.keymap.set('n', 'cl', ':let @/ =""<CR>')
--
--
--  -- git show
--  vim.keymap.set('n', '<leader><leader><S-g>', ':GitGutterBufferToggle<CR>')
--
--  -- git commands
--  vim.keymap.set('n', '<leader>gs', ':G<CR>')
--  -- For merging conflicts
--  -- Right
--  -- vim.keymap.set("n","<leader>gl ",":diffget //3<CR>")
--  -- Left
--  -- vim.keymap.set("n","<leader>gh ",":diffget //2<CR>")
--
--  -- Autoformat
--  vim.keymap.set('n', '<leader><C-a>', vim.lsp.buf.format)
