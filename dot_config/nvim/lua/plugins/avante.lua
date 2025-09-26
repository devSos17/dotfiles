return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  config = function()
    -- Read API keys from config file and set as environment variables
    local avante_tokens = vim.fn.stdpath 'config' .. '/avante_tokens.json'

    if vim.fn.filereadable(avante_tokens) == 1 then
      local file_content = vim.fn.readfile(avante_tokens)
      local json_string = table.concat(file_content, '\n')

      local ok, config = pcall(vim.fn.json_decode, json_string)
      if ok and config then
        if config.anthropic_api_key then
          vim.env.ANTHROPIC_API_KEY = config.anthropic_api_key
        end
        if config.tavily_api_key then
          vim.env.TAVILY_API_KEY = config.tavily_api_key
        end
      end
    end

    require('avante').setup {
      provider = 'claude',
      auto_suggestions_provider = 'claude',
      providers = {
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-3-5-haiku-20241022', -- Latest Claude 4 Sonnet
          timeout = 30000,
          extra_request_body = {
            temperature = 0.1,
            max_tokens = 4096,
          },
        },
      },
      web_search_engine = {
        provider = 'tavily',
        proxy = nil,
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true,
        auto_approve_tool_permissions = false, -- Show permission prompts for tools
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = 'co',
          theirs = 'ct',
          all_theirs = 'ca',
          both = 'cb',
          cursor = 'cc',
          next = ']x',
          prev = '[x',
        },
        suggestion = {
          accept = '<M-l>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
        jump = {
          next = ']]',
          prev = '[[',
        },
        submit = {
          normal = '<CR>',
          insert = '<C-s>',
        },
      },
      hints = { enabled = true },
      windows = {
        ---@type "right" | "left" | "top" | "bottom"
        position = 'right', -- sidebar position (no center option available)
        wrap = true, -- similar to vim.o.wrap
        width = 40, -- percentage of screen width (increased for better visibility)
        sidebar_header = {
          enabled = true,
          align = 'center', -- left, center, right for title
          rounded = true,
        },
        input = {
          prefix = '> ',
          height = 8,
        },
        edit = {
          border = 'rounded',
          start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = true, -- Open the 'AvanteAsk' prompt in a floating window
          start_insert = true, -- Start insert mode when opening the ask window
          border = 'rounded',
          ---@type "ours" | "theirs"
          focus_on_apply = 'ours', -- which diff to focus after applying
        },
      },
      highlights = {
        ---@type AvanteConflictHighlights
        diff = {
          current = 'DiffText',
          incoming = 'DiffAdd',
        },
      },
      --- @class AvanteConflictUserConfig
      diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = 'copen',
      },
    }

    -- Custom keymaps
    vim.keymap.set('n', '<leader>at', ':AvanteToggle<CR>', { desc = 'Toggle Avante sidebar', silent = true })
    vim.keymap.set('n', '<leader>aa', ':AvanteAsk<CR>', { desc = 'Ask Avante', silent = true })
    vim.keymap.set('n', '<leader>ac', ':AvanteChat<CR>', { desc = 'Avante Chat', silent = true })
    vim.keymap.set('n', '<leader>ar', ':AvanteRefresh<CR>', { desc = 'Refresh Avante', silent = true })
  end,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
