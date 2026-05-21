-- lsp.lua — Language Server Protocol configuration
-- Changes from original:
--   • Removed 'copilot' from the servers table (Copilot is NOT an LSP server;
--     it's managed by copilot.vim / copilot.lua plugins instead)
--   • Added 'basedpyright' as a better Python LSP alternative to pylsp
--     (faster, type-aware, works great with ruff for linting/formatting)
--   • Added 'marksman' for markdown LSP (links, completions inside notes vault)
--   • Added 'bashls' for shell scripts
--   • Inlay hints enabled by default (toggle with <leader>th)
return {
  {
    -- Lua LSP completions for Neovim API
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', config = true },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = { winblend = 0 },
          },
        },
      },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- ── LspAttach: buffer-local keymaps ──────────────────────────────
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local tb = require 'telescope.builtin'
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local supports = function(method)
            return client and client:supports_method(method)
          end
          local lsp_float_opts = {
            border = 'rounded',
            max_width = 80,
            max_height = 12,
            focusable = false,
          }

          if supports('textDocument/definition') then
            map('gd', tb.lsp_definitions, '[G]oto [D]efinition')
          end
          if supports('textDocument/references') then
            map('gr', tb.lsp_references, '[G]oto [R]eferences')
          end
          if supports('textDocument/implementation') then
            map('gI', tb.lsp_implementations, '[G]oto [I]mplementation')
          end
          if supports('textDocument/declaration') then
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          end
          if supports('textDocument/typeDefinition') then
            map('<leader>D', tb.lsp_type_definitions, 'Type [D]efinition')
          end
          if supports('textDocument/documentSymbol') then
            map('<leader>ds', tb.lsp_document_symbols, '[D]ocument [S]ymbols')
          end
          if supports('workspace/symbol') then
            map('<leader>ws', tb.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          end
          if supports('textDocument/rename') then
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame symbol')
          end
          if supports('textDocument/codeAction') then
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          end
          if supports('textDocument/hover') then
            map('K', function()
              vim.lsp.buf.hover(lsp_float_opts)
            end, 'Hover documentation')
          end
          if supports('textDocument/signatureHelp') then
            map('<C-k>', function()
              vim.lsp.buf.signature_help(lsp_float_opts)
            end, 'Signature help', 'i')
          end

          -- Reference highlighting on cursor hold
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local hl_group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer   = event.buf,
              group    = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer   = event.buf,
              group    = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Inlay hints toggle
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- ── Capabilities (extended with cmp) ─────────────────────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- ── Server definitions ───────────────────────────────────────────
      -- NOTE: 'copilot' removed — not an LSP, handled by copilot.vim/copilot.lua
      local servers = {
        -- Web
        angularls   = {},
        ts_ls       = {},
        html        = { filetypes = { 'html', 'twig', 'hbs' } },
        cssls       = {},
        tailwindcss = {},

        -- Python
        -- basedpyright: fast type-checking (replaces the old slow pylsp type checking)
        -- ruff: handles linting + formatting (lightning fast, replaces flake8/black/isort)
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = 'standard', -- options: off | basic | standard | strict | all
                autoSearchPaths  = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        ruff = {},

        -- C / C++ / Systems
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--completion-style=detailed',
            '--header-insertion=iwyu',
            '--suggest-missing-includes',
          },
        },

        -- Rust
        -- rust-analyzer: full Rust LSP (hover, inlay hints, cargo integration)
        -- codelldb (installed via mason-tool-installer) handles debugging
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = { command = 'clippy' },
              inlayHints  = { enable = true },
            },
          },
        },

        -- Go
        -- gopls: official Go LSP (completions, imports, type-checking, renaming)
        gopls = {
          settings = {
            gopls = {
              analyses  = { unusedparams = true },
              staticcheck = true,
              gofumpt   = true,
            },
          },
        },

        -- Infrastructure / Config
        dockerls   = {},
        sqlls      = {},
        terraformls = {},
        jsonls     = {},
        yamlls     = {},
        bashls     = {},    -- shell scripts

        -- Markdown / Notes
        marksman   = {},    -- markdown LSP — great for the notes vault

        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              completion  = { callSnippet = 'Replace' },
              runtime     = { version = 'LuaJIT' },
              workspace   = {
                checkThirdParty = false,
                library         = vim.api.nvim_get_runtime_file('', true),
              },
              diagnostics = {
                globals = { 'vim' },
                disable = { 'missing-fields' },
              },
              format = { enable = false }, -- use stylua via none-ls instead
            },
          },
        },
      }

      -- ── Mason: ensure LSP servers + tools are installed ──────────────
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers or {}),
      }

      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua',           -- Lua formatter
          'codelldb',         -- C/C++/Rust debugger
          'gofumpt',          -- Go formatter (stricter gofmt)
          'goimports',        -- Go import organiser
          'prettier',         -- Web + Markdown formatter
          'ruff',             -- Python linter/formatter
          'shfmt',            -- Shell formatter
          'clang-format',     -- C/C++ formatter
        },
      }

      -- ── Register & enable each server ───────────────────────────────
      for server, cfg in pairs(servers) do
        cfg.capabilities = vim.tbl_deep_extend('force', {}, capabilities, cfg.capabilities or {})
        vim.lsp.config(server, cfg)
        vim.lsp.enable(server)
      end
    end,
  },
}
