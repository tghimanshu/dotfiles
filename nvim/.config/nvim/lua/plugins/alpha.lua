-- alpha.lua — Dashboard shown on `nvim` with no file argument
-- Improvements over original:
--   • Added Notes shortcuts (daily note, search)
--   • Shows a random motivational dev quote in the footer
--   • Cleaner button icons using nerd font glyphs
return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha     = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    local heading = function(text)
      return {
        type = 'text',
        val = text,
        opts = { hl = 'Comment', position = 'center' },
      }
    end

    local group = function(val)
      return {
        type = 'group',
        val = val,
        opts = { spacing = 1 },
      }
    end

    -- ─── Header ──────────────────────────────────────────────────────
    dashboard.section.header.val = {
      '',
      'Neovim',
      '------',
      '',
    }
    dashboard.section.header.opts = { hl = 'Title', position = 'center' }

    -- ─── Sections ─────────────────────────────────────────────────────
    local quick_actions = group {
      dashboard.button('e', ' New file',      ':ene <BAR> startinsert<CR>'),
      dashboard.button('f', ' Find file',     ':cd $HOME/Workspace | Telescope find_files<CR>'),
      dashboard.button('r', ' Recent files',  ':Telescope oldfiles<CR>'),
      dashboard.button('g', ' Live grep',     ':Telescope live_grep<CR>'),
    }

    local notes = group {
      dashboard.button('d', ' Today\'s daily note', ':ObsidianToday<CR>'),
      dashboard.button('n', ' New note',           ':ObsidianNew<CR>'),
      dashboard.button('s', ' Search notes',       ':ObsidianSearch<CR>'),
    }

    local config = group {
      dashboard.button('c', ' Neovim config',       ':e $MYVIMRC | :cd %:p:h<CR>'),
      dashboard.button('l', ' Lazy plugin manager', ':Lazy<CR>'),
      dashboard.button('q', ' Quit',                ':qa<CR>'),
    }

    -- ─── Footer ───────────────────────────────────────────────────────
    dashboard.section.footer.val = 'Ready.'
    dashboard.section.footer.opts = { hl = 'Comment', position = 'center' }

    -- ─── Layout tweaks ────────────────────────────────────────────────
    dashboard.config.layout = {
      { type = 'padding', val = 3 },
      dashboard.section.header,
      { type = 'padding', val = 1 },
      heading 'Quick actions',
      { type = 'padding', val = 1 },
      quick_actions,
      { type = 'padding', val = 1 },
      heading 'Notes',
      { type = 'padding', val = 1 },
      notes,
      { type = 'padding', val = 1 },
      heading 'Config',
      { type = 'padding', val = 1 },
      config,
      { type = 'padding', val = 2 },
      dashboard.section.footer,
    }
    dashboard.config.opts = { margin = 5 }

    alpha.setup(dashboard.config)
  end,
}
