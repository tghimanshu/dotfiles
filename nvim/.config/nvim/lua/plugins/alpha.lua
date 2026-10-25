-- alpha.lua — Konoha-flavoured dashboard for `nvim` with no file argument
--   • "NARUTO" ASCII header in shinobi orange
--   • Themed, colour-coded sections: Missions · Scrolls · Village
--   • A random shinobi greeting + a quote from the Ninja Way
--   • Same muscle-memory keys as before (e, f, r, g, d, n, s, c, l, q)
return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha     = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- ─── Palette: chakra-flavoured highlight groups ───────────────────
    -- Re-applied on ColorScheme so they survive :colorscheme reloads.
    local function define_highlights()
      local set = vim.api.nvim_set_hl
      set(0, 'NarutoOrange',   { fg = '#ff9d3c', bold = true }) -- Naruto's jumpsuit
      set(0, 'NarutoRed',      { fg = '#e5484d', bold = true }) -- Uzumaki red
      set(0, 'NarutoRasengan', { fg = '#38bdf8', bold = true }) -- spiralling sphere
      set(0, 'NarutoChidori',  { fg = '#a78bfa', bold = true }) -- lightning blade
      set(0, 'NarutoSakura',   { fg = '#f472b6', bold = true }) -- Sakura's hair
      set(0, 'NarutoLeaf',     { fg = '#7bd88f', bold = true }) -- the hidden leaf
      set(0, 'NarutoGold',     { fg = '#facc15' })              -- sage-mode eyes
      set(0, 'NarutoMuted',    { fg = '#8b93a7', italic = true })
    end
    define_highlights()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = define_highlights })

    -- Nerd font glyphs referenced by codepoint (keeps this file ASCII-clean).
    local glyph = function(cp) return vim.fn.nr2char(cp) end
    local icons = {
      rocket = glyph(0xf135),
      search = glyph(0xf002),
      clock  = glyph(0xf1da),
      bolt   = glyph(0xf0e7),
      scroll = glyph(0xf02d),
      quill  = glyph(0xf040),
      fire   = glyph(0xf06d),
      leaf   = glyph(0xf06c),
      cog    = glyph(0xf013),
      exit   = glyph(0xf08b),
    }

    local function random(list)
      return list[math.random(#list)]
    end
    math.randomseed(os.time() + math.floor((os.clock() * 1000) % 1000))

    local function heading(icon, text, hl)
      return {
        type = 'text',
        val = icon .. '   ' .. text,
        opts = { hl = hl, position = 'center' },
      }
    end

    -- Alpha's dashboard.button only takes keymap opts, so build it, then style.
    local function button(key, icon, label, cmd, hl)
      local b = dashboard.button(key, icon .. '  ' .. label, cmd)
      b.opts.hl             = hl
      b.opts.hl_shortcut    = 'NarutoGold'
      b.opts.width          = 46
      b.opts.align_shortcut = 'right'
      return b
    end

    local function group(val)
      return { type = 'group', val = val, opts = { spacing = 1 } }
    end

    -- ─── Header ───────────────────────────────────────────────────────
    dashboard.section.header.val = {
      ' _   _      _      ____    _   _   _____    ___  ',
      '| \\ | |    / \\    |  _ \\  | | | | |_   _|  / _ \\ ',
      '|  \\| |   / _ \\   | |_) | | | | |   | |   | | | |',
      '| |\\  |  / ___ \\  |  _ <  | |_| |   | |   | |_| |',
      '|_| \\_| /_/   \\_\\ |_| \\_\\  \\___/    |_|    \\___/ ',
    }
    dashboard.section.header.opts = { hl = 'NarutoOrange', position = 'center' }

    local subtitle = {
      type = 'text',
      val = '·:*  the will of fire burns in your editor  *:·',
      opts = { hl = 'NarutoMuted', position = 'center' },
    }

    -- ─── Sections ─────────────────────────────────────────────────────
    local missions = group {
      button('e', icons.bolt,   'New mission  (new file)', ':ene <BAR> startinsert<CR>', 'NarutoOrange'),
      button('f', icons.search, 'Find a file',             ':cd $HOME/Workspace | Telescope find_files<CR>', 'NarutoOrange'),
      button('r', icons.clock,  'Recent missions',         ':Telescope oldfiles<CR>', 'NarutoOrange'),
      button('g', icons.rocket, 'Search the village',      ':Telescope live_grep<CR>', 'NarutoOrange'),
    }

    local scrolls = group {
      button('d', icons.scroll, 'Today\'s scroll',     ':ObsidianToday<CR>', 'NarutoChidori'),
      button('n', icons.quill,  'New scroll',          ':ObsidianNew<CR>', 'NarutoChidori'),
      button('s', icons.search, 'Search the archives', ':ObsidianSearch<CR>', 'NarutoChidori'),
    }

    local village = group {
      button('c', icons.fire, 'Hokage config',        ':e $MYVIMRC | :cd %:p:h<CR>', 'NarutoLeaf'),
      button('l', icons.cog,  'Jutsu manager  (Lazy)', ':Lazy<CR>', 'NarutoLeaf'),
      button('q', icons.exit, 'Retreat  (quit)',      ':qa<CR>', 'NarutoRed'),
    }

    -- ─── Footer: a random greeting + a quote from the Ninja Way ───────
    local greetings = {
      'welcome home, ninja.',
      'dattebayo!',
      'believe it!',
      'ready to train, shinobi?',
      'the will of fire burns bright today.',
      'a ninja sees through deception — even in code.',
    }

    local quotes = {
      { 'I never go back on my word. That is my ninja way!',                           'Naruto Uzumaki' },
      { 'A dropout will beat a genius through hard work.',                             'Rock Lee' },
      { 'Those who abandon their friends are worse than scum.',                        'Kakashi Hatake' },
      { 'Hard work is worthless for those that don\'t believe in themselves.',         'Naruto Uzumaki' },
      { 'When you\'re sad and alone, just put your hand over your heart.',             'Naruto Uzumaki' },
      { 'Failing doesn\'t give you a reason to give up.',                              'Naruto Uzumaki' },
      { 'The moment people come to know love, they run the risk of carrying hate.',    'Obito Uchiha' },
      { 'A place where someone still thinks about you is a place you can call home.',  'Jiraiya' },
      { 'It is not the face that makes someone a monster, it is the choices they make.', 'Naruto Uzumaki' },
      { 'If you don\'t take risks, you can\'t create a future.',                       'Naruto Uzumaki' },
    }

    local greeting = {
      type = 'text',
      val = random(greetings),
      opts = { hl = 'NarutoGold', position = 'center' },
    }
    local quote = random(quotes)
    dashboard.section.footer.val = { '“' .. quote[1] .. '”', '— ' .. quote[2] }
    dashboard.section.footer.opts = { hl = 'NarutoMuted', position = 'center' }

    -- ─── Layout ───────────────────────────────────────────────────────
    dashboard.config.layout = {
      { type = 'padding', val = 2 },
      dashboard.section.header,
      subtitle,
      { type = 'padding', val = 1 },
      heading(icons.leaf, 'Missions', 'NarutoOrange'),
      { type = 'padding', val = 1 },
      missions,
      { type = 'padding', val = 1 },
      heading(icons.scroll, 'Scrolls', 'NarutoChidori'),
      { type = 'padding', val = 1 },
      scrolls,
      { type = 'padding', val = 1 },
      heading(icons.fire, 'Village', 'NarutoLeaf'),
      { type = 'padding', val = 1 },
      village,
      { type = 'padding', val = 2 },
      greeting,
      dashboard.section.footer,
    }
    dashboard.config.opts = { margin = 5 }

    alpha.setup(dashboard.config)
  end,
}
