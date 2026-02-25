return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'master', -- Use legacy branch for compatibility
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'bash',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'vim',
        'vimdoc',
        'make',
        'dockerfile',
        'yaml',
        'rust',
        'tsx',
        'typescript',
        'javascript',
        'json',
        'css',
        'astro',
        'python',
        'terraform',
      },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = {
        enable = true,
        disable = { 'ruby' },
      },
    }
  end,
}
