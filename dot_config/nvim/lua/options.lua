--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
-- TODO: AUTO SET THIS IN THE FUTURE
vim.g.have_nerd_font = true

-- LETS DITCH NETRW | Neotree instead
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- <- NUMBERS
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 1

-- MOUSE MODE
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
-- vim.opt.updatetime = 250
vim.opt.updatetime = 50

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Set spaces
vim.opt.sw = 2
vim.opt.ts = 2
vim.opt.sts = 2
-- vim.opt encoding=utf-8
vim.opt.encoding = 'utf-8'
vim.opt.spelllang = 'es,en'

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true
-- vim.opt.cursorcolumn = true

-- Vertical line right
vim.opt.colorcolumn = '80'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
-- vim.opt.incsearch = true

-- [[ OLD MINE ]]

-- vim.g.netrw_banner = 0
-- vim.g.netrw_browse_split = 0
-- vim.g.netrw_liststyle = 3 -- Tree-style view
-- vim.opt.tabstop = 4
-- vim.opt.softtabstop = 4
-- vim.opt.shiftwidth = 4
-- vim.opt.expandtab = true

-- vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.scrolloff = 8
vim.opt.isfname:append '@-@'

-- NERDFONTS (FROM NEOTREE)
-- If you want icons for diagnostic errors, you'll need to define them somewhere:
vim.fn.sign_define('DiagnosticSignError', { text = ' ', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = ' ', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = ' ', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '󰌵', texthl = 'DiagnosticSignHint' })
