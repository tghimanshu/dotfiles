return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    ---@module 'obsidian'
    ---@type obsidian.config.ClientOpts
    opts = {
      workspaces = {
        {
          name = 'personal',
          -- Change this to wherever your vault lives, e.g. '~/notes'
          path = '~/personal/notes',
        },
      },

      -- Daily notes drop into notes/daily/
      daily_notes = {
        folder = 'daily',
        date_format = '%Y-%m-%d',
        -- Uses the template below when creating a new daily note
        template = 'daily_template',
      },

      -- Completion via nvim-cmp
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      -- Note ID: timestamp + slugified title keeps filenames sortable
      note_id_func = function(title)
        local suffix = ''
        if title ~= nil then
          suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. '-' .. suffix
      end,

      -- Auto-generate frontmatter on new notes
      note_frontmatter_func = function(note)
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,

      -- Templates folder inside the vault
      templates = {
        folder = 'templates',
        date_format = '%Y-%m-%d',
        time_format = '%H:%M',
      },

      -- Telescope as the picker
      picker = {
        name = 'telescope.nvim',
        note_mappings = {
          new = '<C-x>',
          insert_link = '<C-l>',
        },
        tag_mappings = {
          tag_note = '<C-x>',
          insert_tag = '<C-l>',
        },
      },

      -- Open URLs with xdg-open (Linux)
      follow_url_func = function(url)
        vim.fn.jobstart({ 'xdg-open', url })
      end,

      -- Rich UI — checkboxes, bullets, highlights
      ui = {
        enable = true,
        update_debounce = 200,
        max_file_length = 5000,
        checkboxes = {
          [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
          ['x'] = { char = '', hl_group = 'ObsidianDone' },
          ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
          ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
          ['!'] = { char = '', hl_group = 'ObsidianImportant' },
        },
        bullets = { char = '•', hl_group = 'ObsidianBullet' },
        external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
        reference_text = { hl_group = 'ObsidianRefText' },
        highlight_text = { hl_group = 'ObsidianHighlightText' },
        tags = { hl_group = 'ObsidianTag' },
        block_ids = { hl_group = 'ObsidianBlockID' },
        hl_groups = {
          -- Matches moonfly colorscheme palette
          ObsidianTodo      = { bold = true, fg = '#f78c6c' },
          ObsidianDone      = { bold = true, fg = '#89ddff' },
          ObsidianRightArrow= { bold = true, fg = '#fc9867' },
          ObsidianTilde     = { bold = true, fg = '#ff5370' },
          ObsidianImportant = { bold = true, fg = '#d73128' },
          ObsidianBullet    = { bold = true, fg = '#89ddff' },
          ObsidianRefText   = { underline = true, fg = '#c3e88d' },
          ObsidianExtLinkIcon = { fg = '#c3e88d' },
          ObsidianTag       = { italic = true, fg = '#89ddff' },
          ObsidianBlockID   = { italic = true, fg = '#89ddff' },
          ObsidianHighlightText = { bg = '#75662e' },
        },
      },
    },

    config = function(_, opts)
      require('obsidian').setup(opts)

      -- Clean markdown rendering
      vim.opt.conceallevel = 2

      -- ─────────────────────────────────────────────────────────────
      -- All note keymaps under <leader>n  (Notes namespace)
      -- ─────────────────────────────────────────────────────────────
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { desc = 'Notes: ' .. desc })
      end

      -- Daily notes
      map('<leader>nd', '<cmd>ObsidianToday<CR>',     'Open today\'s daily note')
      map('<leader>ny', '<cmd>ObsidianYesterday<CR>', 'Open yesterday\'s note')
      map('<leader>nm', '<cmd>ObsidianTomorrow<CR>',  'Open tomorrow\'s note')

      -- Weekly review
      map('<leader>nw', function()
        local week = os.date '%Y-W%V'
        local path = vim.fn.expand('~/personal/notes/daily/') .. week .. '-weekly-review.md'
        vim.cmd('edit ' .. path)
        if vim.fn.filereadable(path) == 0 then
          vim.cmd 'ObsidianTemplate weekly_review_template'
        end
      end, 'Open / create weekly review note')

      -- Create / Navigate
      map('<leader>nn', '<cmd>ObsidianNew<CR>',         'New note')
      map('<leader>nf', '<cmd>ObsidianSearch<CR>',      'Search notes (full-text grep)')
      map('<leader>no', '<cmd>ObsidianQuickSwitch<CR>', 'Quick switch note (fuzzy)')
      map('<leader>nb', '<cmd>ObsidianBacklinks<CR>',   'Show backlinks to this note')
      map('<leader>nt', '<cmd>ObsidianTags<CR>',        'Browse notes by tag')
      map('<leader>nl', '<cmd>ObsidianLinks<CR>',       'Show all links in note')
      map('<leader>ni', '<cmd>ObsidianTemplate<CR>',    'Insert a template')

      -- Open vault root files
      map('<leader>n.', function()
        vim.cmd('edit ' .. vim.fn.expand '~/personal/notes/tasks.md')
      end, 'Open tasks.md')

      -- Linking (also visual mode)
      vim.keymap.set('v', '<leader>nk', '<cmd>ObsidianLink<CR>',    { desc = 'Notes: Link selection to existing note' })
      vim.keymap.set('n', '<leader>nk', '<cmd>ObsidianLinkNew<CR>', { desc = 'Notes: Create & link new note' })

      -- ─────────────────────────────────────────────────────────────
      -- Typed note creators  (<leader>nN*)
      -- Each prompts for a title then opens a pre-templated note in
      -- the correct folder.
      -- ─────────────────────────────────────────────────────────────
      local Path = require 'plenary.path'

      local function new_typed_note(folder, template, label)
        return function()
          vim.ui.input({ prompt = label .. ' title: ' }, function(title)
            if not title or title == '' then return end
            local slug     = title:gsub('%s+', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
            local ts       = tostring(os.time())
            local filename = vim.fn.expand('~/personal/notes/' .. folder .. '/') .. ts .. '-' .. slug .. '.md'
            Path:new(filename):touch { parents = true }
            vim.cmd('edit ' .. filename)
            vim.cmd('ObsidianTemplate ' .. template)
            vim.notify('New ' .. label .. ': ' .. title, vim.log.levels.INFO)
          end)
        end
      end

      map('<leader>nNp', new_typed_note('projects',  'project_template',  'Project'),  'New project note')
      map('<leader>nNl', new_typed_note('learning',  'learning_template', 'Learning'), 'New learning note')
      map('<leader>nNa', new_typed_note('ai',        'article_template',  'Article'),  'New article / reading note')
      map('<leader>nNt', new_typed_note('daily',     'til_template',      'TIL'),      'New TIL note')

      -- ─────────────────────────────────────────────────────────────
      -- LeetCode / DSA note creators
      -- Creates structured markdown notes in ~/personal/notes/dsa/
      -- ─────────────────────────────────────────────────────────────
      local curl    = require 'plenary.curl'
      local DSA_PATH = vim.fn.expand '~/personal/notes/dsa'

      -- Shared content builder for LeetCode notes
      local function build_lc_content(q, url, is_daily)
        local date_label = is_daily and os.date '%Y-%m-%d' .. ' (Daily)' or os.date '%Y-%m-%d'
        return {
          '# ' .. q.questionFrontendId .. '. ' .. q.title,
          '',
          '---',
          '**Difficulty**: ' .. (q.difficulty or 'Unknown'),
          '**Date**: ' .. date_label,
          '**URL**: ' .. (url or 'https://leetcode.com/problems/' .. q.titleSlug),
          '**Tags**: #leetcode',
          '---',
          '',
          '## Problem Statement',
          '',
          '## Idea (1-2 sentences)',
          '<!-- What was the core insight? -->',
          '',
          '## Approach',
          '',
          '- ',
          '',
          '## Edge Cases',
          '',
          '- ',
          '',
          '## Complexity',
          '',
          '- Time: ',
          '- Space: ',
          '',
          '## Solution',
          '',
          '```',
          '```',
        }
      end

      -- <leader>nNd — manual DSA/LeetCode note (no API, prompt for number + slug)
      map('<leader>nNd', function()
        vim.ui.input({ prompt = 'Problem number: ' }, function(num)
          if not num or num == '' then return end
          vim.ui.input({ prompt = 'Title slug (e.g. two-sum): ' }, function(slug)
            if not slug or slug == '' then return end
            local filename = string.format('%s/%03d-%s.md', DSA_PATH, tonumber(num) or 0, slug)
            local q = { questionFrontendId = num, title = slug:gsub('-', ' '), titleSlug = slug, difficulty = '' }
            local content = build_lc_content(q, nil, false)
            Path:new(filename):touch { parents = true }
            Path:new(filename):write(table.concat(content, '\n'), 'w')
            vim.cmd('edit ' .. filename)
            vim.notify('New DSA note: ' .. num .. '-' .. slug, vim.log.levels.INFO)
          end)
        end)
      end, 'New manual DSA/LeetCode note')

      -- <leader>nDd — fetch today's LeetCode daily via API
      map('<leader>nDd', function()
        print 'Fetching LeetCode daily...'
        curl.get('https://leetcode-api-pied.vercel.app/daily', {
          callback = function(response)
            vim.schedule(function()
              if response.status ~= 200 then
                vim.notify('LeetCode API error: ' .. tostring(response.status), vim.log.levels.ERROR)
                return
              end
              local ok, data = pcall(vim.json.decode, response.body)
              if not ok or not data then
                vim.notify('Failed to parse response', vim.log.levels.ERROR)
                return
              end
              local q = data.question
              local filename = string.format('%s/%03d-%s.md', DSA_PATH, q.questionFrontendId, q.titleSlug)
              local content = build_lc_content(q, data.url, true)
              Path:new(filename):touch { parents = true }
              Path:new(filename):write(table.concat(content, '\n'), 'w')
              vim.cmd('edit ' .. filename)
              vim.notify('Daily: ' .. q.title, vim.log.levels.INFO)
            end)
          end,
        })
      end, 'LeetCode: Fetch daily problem note')
    end,
  },
}
