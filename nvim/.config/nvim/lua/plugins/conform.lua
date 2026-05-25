-- conform.lua — formatting (replaces none-ls formatting sources)
--
-- Design:
--   • conform handles ALL formatting via format-on-save and <leader>f
--   • none-ls is kept only for diagnostics/linting (checkmake, eslint_d, hadolint)
--   • lsp_format = 'fallback' means: if no conform formatter is configured for the
--     filetype, fall back to the LSP's built-in formatter (e.g. rust-analyzer, gopls)
--
-- To check what formatter will run: :ConformInfo
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = true,

    -- Format on save. Timeout is generous (1s) to handle slow formatters.
    -- C/C++ is excluded because clang-format opinions vary wildly per project;
    -- use <leader>f manually when needed.
    format_on_save = function(bufnr)
      -- local disable = { c = true, cpp = true }
      -- if disable[vim.bo[bufnr].filetype] then
      --   return nil
      -- end
      return { timeout_ms = 1000, lsp_format = 'fallback' }
    end,

    formatters_by_ft = {
      -- Lua
      lua = { 'stylua' },

      -- Python: ruff handles both import sorting and formatting (replaces isort+black)
      python = { 'ruff_fix', 'ruff_format' },

      -- Web
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescriptreact = { 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      json = { 'prettier' },
      yaml = { 'prettier' },

      -- Shell
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },

      -- Go: goimports (runs gofmt + organises imports), then gofumpt for stricter style
      go = { 'goimports', 'gofumpt' },

      -- Terraform
      terraform = { 'terraform_fmt' },
      ['terraform-vars'] = { 'terraform_fmt' },

      -- C/C++ — manual only (excluded from format_on_save above)
      c = { 'clang_format' },
      cpp = { 'clang_format' },
    },

    -- Custom formatter options
    formatters = {
      shfmt = {
        prepend_args = { '-i', '4' }, -- 4-space indent
      },
      prettier = {
        -- Use project-local prettier config if present
        require_cwd = false,
      },
    },
  },
}
