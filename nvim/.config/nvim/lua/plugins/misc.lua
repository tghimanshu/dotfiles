-- misc.lua — Small quality-of-life plugins
-- Changes from original:
--   • Removed duplicate scrollEOF entry
--   • flash.nvim enabled (was commented out) with safe 's' key — doesn't break surround
--   • Added yazi.nvim for blazing fast file navigation inside Neovim
--   • Kept everything else intact
return {

  -- ── Scroll past EOF (single entry, was duplicated) ──────────────────
  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'CursorMoved', 'WinScrolled' },
    opts = {},
  },

  -- ── Diagnostics panel ────────────────────────────────────────────────
  {
    'folke/trouble.nvim',
    opts = {},
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Refs/Defs (Trouble)' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    },
  },

  -- ── Tmux / split navigation ──────────────────────────────────────────
  { 'christoomey/vim-tmux-navigator' },

  -- ── Auto-detect indentation ──────────────────────────────────────────
  { 'NMAC427/guess-indent.nvim' },

  -- ── Git: fugitive + GitHub browser ──────────────────────────────────
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>ga', function()
        vim.cmd.Git 'add .'
      end, { desc = 'Git Add all' })
      vim.keymap.set('n', '<leader>gc', function()
        vim.cmd.Git 'commit'
      end, { desc = 'Git Commit' })
      vim.keymap.set('n', '<leader>gP', function()
        vim.cmd.Git 'push'
      end, { desc = 'Git Push' })
      vim.keymap.set('n', '<leader>gp', function()
        vim.cmd.Git { 'pull', '--rebase' }
      end, { desc = 'Git Pull (rebase)' })
      vim.keymap.set('n', '<leader>gs', function()
        vim.cmd.Git()
      end, { desc = 'Git Status' })
      vim.keymap.set('n', '<leader>gd', function()
        vim.cmd.Gdiffsplit()
      end, { desc = 'Git Diff split' })
      vim.keymap.set('n', '<leader>gb', function()
        vim.cmd.Git 'blame'
      end, { desc = 'Git Blame' })
    end,
  },
  { 'tpope/vim-rhubarb' }, -- GBrowse → open in GitHub

  -- ── Which-key — keymap cheatsheet ────────────────────────────────────
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
        },
      },
      spec = {
        { '<leader>a', group = '[A]vante AI' },
        { '<leader>c', group = '[C]ode / Symbols' },
        { '<leader>d', group = '[D]iagnostics / Debug' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>n', group = '[N]otes / Vault' },
        { '<leader>nD', group = '[D]SA / LeetCode notes' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle / Tabs' },
        { '<leader>x', group = 'Trouble / Close' },
      },
    },
  },

  -- ── Autopairs ────────────────────────────────────────────────────────
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },

  -- ── Todo comments ────────────────────────────────────────────────────
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- ── Color highlighter  (#hex, rgb() etc.) ────────────────────────────
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },

  -- ── mini.nvim: text objects + surround ───────────────────────────────
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 } -- va), yinq, ci'
      require('mini.surround').setup() -- saiw), sd', sr)'
    end,
  },

  -- ── Markdown preview (inline rendering) ──────────────────────────────
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    config = function()
      require('markview').setup {
        preview = {
          modes = { 'n', 'i', 'no', 'c' },
          hybrid_modes = { 'n', 'i' },
        },
      }
    end,
  },

  -- ── LeetCode inside Neovim ───────────────────────────────────────────
  {
    'kawre/leetcode.nvim',
    build = ':TSUpdate',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      lang = 'python3',
    },
  },

  -- ── Flash.nvim — lightning fast navigation (s / S) ───────────────────
  -- Uses <leader>j instead of 's' to avoid conflict with mini.surround
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {
      modes = {
        -- Disable flash in regular / search so n/N still work normally
        search = { enabled = false },
        char = { enabled = false },
      },
    },
    keys = {
      {
        '<leader>j',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash Jump',
      },
      {
        '<leader>J',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
    },
  },

  -- ── Yazi — terminal file manager inside Neovim ───────────────────────
  -- Requires `yazi` installed on your system: `yay -S yazi` on Arch/Omarchy
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    dependencies = { 'folke/snacks.nvim' },
    keys = {
      {
        '<leader>Y',
        mode = { 'n', 'v' },
        function()
          require('yazi').yazi()
        end,
        desc = 'Yazi: Open file manager (cwd)',
      },
      {
        '<leader>fy',
        function()
          require('yazi').yazi(nil, vim.fn.getcwd())
        end,
        desc = 'Yazi: Open in working directory',
      },
    },
    ---@type YaziConfig
    opts = {
      -- Opens yazi instead of netrw when opening a directory
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
        open_file_in_vertical_split = '<c-v>',
        open_file_in_horizontal_split = '<c-s>',
        open_file_in_tab = '<c-t>',
        grep_in_directory = '<c-g>',
        replace_in_directory = '<c-r>',
        cycle_open_buffers = '<tab>',
        copy_relative_path_to_clipboard = '<c-y>',
        change_working_directory = '<c-\\>',
        open_url_in_browser = 'gu',
      },
    },
  },
  {
    'nvim-flutter/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = true,
  },
}
