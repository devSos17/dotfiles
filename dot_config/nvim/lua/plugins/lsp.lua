return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = { -- Automatically install LSPs and related tools to stdpath for Neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- Useful status updates for LSP.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} }, -- used for completion, annotations and signatures of Neovim apis
  },
  config = function()
    -- bind this keybins to any lsp that attaches to  a buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Fuzzy find all the symbols
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        -- Opens a popup that displays documentation about the word under your cursor
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end

        -- Auto-show diagnostics on cursor hold (uncomment to enable)
        -- vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        --   buffer = event.buf,
        --   callback = function()
        --     vim.diagnostic.open_float(nil, { focus = false })
        --   end,
        -- })
      end,
    })
    -- TODO: Decide where does diagnostics live...
    -- [[ DIAGNOSTICS BIDNINGS ]]
    vim.keymap.set('n', '{d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
    vim.keymap.set('n', '}d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic float' })
    vim.keymap.set('n', '<leader>D', function()
      vim.diagnostic.open_float({ scope = 'buffer', header = 'Buffer Diagnostics:' })
    end, { desc = 'Show all buffer [D]iagnostics in float' })
    vim.keymap.set('n', '<leader>qf', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    --[[ Enable the following language servers 
     - cmd (table): Override the default command used to start the server
     - filetypes (table): Override the default list of associated filetypes for the server
     - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
     - settings (table): Override the default settings passed when initializing the server.
    For example, to see the options for `lua_ls`, you could go to: 
        https://luals.github.io/wiki/settings/ 
     ]]
    local servers = { -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
      ansiblels = {
        filetypes = { 'yaml.ansible' },
      },
      terraformls = {},
      -- clangd = {},
      -- gopls = {},
      pyright = {},
      -- rust_analyzer = {}, -- This will be manged by rustacian and "local" rust-analyzer
      ts_ls = {}, -- Some languages (like typescript) have entire language plugins that can be useful: https://github.com/pmizio/typescript-tools.nvim
      lua_ls = {
        -- cmd = {...},
        -- filetypes = { ...},
        -- capabilities = {},
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
      docker_compose_language_service = {},
      dockerls = {},
    }

    -- Ensure the servers and tools above are installed
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run
    --    :Mason
    --
    --  You can press `g?` for help in this menu.
    require('mason').setup()

    -- You can add other tools here that you want Mason to install
    -- for you, so that they are available from within Neovim.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format Lua code
      'ansible-lint',
      'tflint',
      'hadolint',
      -- guess im js dev after all...
      'emmet_ls',
      'prettierd',
      -- 'volar', -- Vue
      'vue_ls', -- Vue
      'astro', -- Astro
      -- 'eslint',
      -- 'eslint_d',
      'ts_ls',
      'tailwindcss',
      'cssls',
      'jsonlint',
      'stylelint',
      'actionlint',
      -- F'in python man... but i need to work
      'black',
      'flake8',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- This handles overriding only values explicitly passed
          -- by the server configuration above. Useful when disabling
          -- certain features of an LSP (for example, turning off formatting for tsserver)
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
