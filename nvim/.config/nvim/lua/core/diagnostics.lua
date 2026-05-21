-- Diagnostics configuration and editor utilities

local border = 'rounded'

-- Prevent LSP from overwriting treesitter color settings
-- https://github.com/NvChad/NvChad/issues/1907
vim.hl.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

-- Appearance of diagnostics
vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    spacing = 2,
    -- Add a custom format function to show error codes
    format = function(diagnostic)
      local code = diagnostic.code and string.format('[%s]', diagnostic.code) or ''
      return string.format('%s %s', code, diagnostic.message)
    end,
  },
  underline = false,
  update_in_insert = true,
  float = {
    source = 'if_many',
    border = border,
    header = '',
    prefix = '',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = '󰌵 ',
    },
  },
}

-- Make diagnostic virtual text background transparent, applied on every colorscheme change
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Keep DiagnosticVirtualText background transparent',
  group = vim.api.nvim_create_augroup('diagnostics-transparent-bg', { clear = true }),
  callback = function()
    vim.cmd 'highlight DiagnosticVirtualText guibg=NONE'
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
