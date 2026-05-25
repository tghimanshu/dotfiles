return {
  -- ── Markdown stack (reference + local) ────────────────────────────────
  -- {
  --   'preservim/vim-markdown',
  --   ft = { 'markdown' },
  --   init = function()
  --     vim.g.vim_markdown_folding_disabled = 1
  --     vim.g.tex_conceal = ''
  --     vim.g.vim_markdown_math = 0
  --     vim.g.vim_markdown_frontmatter = 1
  --     vim.g.vim_markdown_toc_autofit = 1
  --     vim.g.vim_markdown_fenced_languages = {
  --       'python',
  --       'javascript',
  --       'lua',
  --       'bash=sh',
  --       'html',
  --       'css',
  --       'typescript',
  --       'jsx',
  --       'tsx',
  --       'ts',
  --       'js',
  --     }
  --     vim.g.vim_markdown_override_syntax = 1
  --   end,
  -- },
  {
    'vim-pandoc/vim-pandoc-syntax',
    ft = { 'markdown', 'pandoc' },
    init = function()
      vim.g['pandoc#syntax#conceal#use'] = 0
      vim.g['pandoc#syntax#codeblocks#embeds#langs#prefix'] = '```'
      vim.g['pandoc#syntax#codeblocks#embeds#langs#suffix'] = '```'
    end,
  },
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    build = 'cd app && npm install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
  },
  {
    'rhysd/vim-grammarous',
    ft = { 'markdown' },
  },
  {
    'OXY2DEV/markview.nvim',
    ft = 'markdown',
    config = function()
      require('markview').setup {
        markdown = {
          list_items = {
            shift_width = function(buffer, item)
              ---@type integer Parent list items indent. Must be at least 1.
              local parent_indnet = math.max(1, item.indent - vim.bo[buffer].shiftwidth)
              return item.indent * (1 / (parent_indnet * 2))
            end,
            marker_minus = {
              add_padding = function(_, item)
                return item.indent > 1
              end,
            },
          },
        },
        preview = {
          modes = { 'n', 'i', 'no', 'c' },
          hybrid_modes = { 'n', 'i' },
          callbacks = {
            on_enable = function(buf, win)
              vim.wo[win].conceallevel = 2
              vim.wo[win].concealcursor = 'nc'
            end,
            on_disable = function(buf, win)
              vim.wo[win].conceallevel = 0
            end,
          },
        },
      }
      require('markview.extras.editor').setup()
    end,
  },
}
