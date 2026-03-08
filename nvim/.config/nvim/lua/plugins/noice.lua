-- noice.nvim — fancy UI for cmdline, messages, and LSP progress
-- Key config decisions:
--   • search input (/ and ?) uses the NATIVE cmdline to avoid floating-popup jitter
--   • LSP signature from noice is disabled (handled by cmp / lsp hover)
--   • notify backend: uses nvim-notify if available, falls back to mini
return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    require('noice').setup {
      -- Route / and ? search input to the native cmdline so the floating popup
      -- doesn't re-render on every keystroke (eliminates jitter).
      routes = {
        {
          filter = { event = 'cmdline', find = '^[/?]' },
          view   = 'cmdline', -- native bottom cmdline, not floating
        },
      },

      cmdline = {
        enabled = true,
        view    = 'cmdline_popup', -- floating popup for all OTHER commands
        format  = {
          cmdline    = { icon = '>' },
          search_down = { icon = '🔍⌄', view = 'cmdline' },
          search_up   = { icon = '🔍⌃', view = 'cmdline' },
          lua        = { icon = '☾' },
          help       = { icon = '?' },
        },
      },

      lsp = {
        -- Better markdown rendering in hover / docs
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown']                = true,
          ['cmp.entry.get_documentation']                  = true,
        },
        -- Signature popup handled by cmp/lsp — keep noice's off to avoid duplication
        signature = { enabled = false },
      },

      presets = {
        bottom_search         = false, -- we handle search routing manually above
        command_palette       = true,  -- positions cmdline_popup nicely
        long_message_to_split = true,  -- long messages go to split instead of popup
        inc_rename            = false,
        lsp_doc_border        = true,  -- border on LSP hover/doc popups
      },
    }
  end,
}
