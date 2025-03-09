return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    --
    -- this are disabled and ignored
    -- local banned_langs = { 'astro' }
    local banned_langs = {}

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
      -- Autoinstall languages that are not installed
      auto_install = true,
      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- List of parsers to ignore installing (or "all")
      ignore_install = banned_langs,

      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },

        disable = function(lang, bufnr) -- not pretty but it should work
          -- best of both worlds... ?
          for _, v in ipairs(banned_langs) do
            if lang == v then
              return true
            end
          end
          return lang == 'cpp' and vim.api.nvim_buf_line_count(bufnr) > 50000 -- Disable in large C++ buffers
        end,
      },
      indent = {
        enable = true,
        disable = { 'ruby' },
      },
    }

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  end,
}
