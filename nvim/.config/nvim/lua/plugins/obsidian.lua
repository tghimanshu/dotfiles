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

      -- <leader>nDn — fetch note by problem number via API
      map('<leader>nDn', function()
        vim.ui.input({ prompt = 'LeetCode problem number: ' }, function(num)
          if not num or num == '' then return end
          print('Fetching problem #' .. num .. '...')
          curl.get('https://leetcode-api-pied.vercel.app/problems', {
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
                local problem = nil
                for _, p in ipairs(data) do
                  if tostring(p.questionFrontendId) == tostring(num) then
                    problem = p
                    break
                  end
                end
                if not problem then
                  vim.notify('Problem #' .. num .. ' not found', vim.log.levels.ERROR)
                  return
                end
                local filename = string.format('%s/%03d-%s.md', DSA_PATH, problem.questionFrontendId, problem.titleSlug)
                if vim.fn.filereadable(filename) == 1 then
                  vim.cmd('edit ' .. filename)
                  vim.notify('Opened existing note: ' .. problem.title, vim.log.levels.INFO)
                  return
                end
                local content = build_lc_content(problem, nil, false)
                Path:new(filename):touch { parents = true }
                Path:new(filename):write(table.concat(content, '\n'), 'w')
                vim.cmd('edit ' .. filename)
                vim.notify('New note: ' .. problem.title, vim.log.levels.INFO)
              end)
            end,
          })
        end)
      end, 'LeetCode: Fetch problem by number')

      -- <leader>nDs — Telescope fuzzy search inside dsa/
      map('<leader>nDs', function()
        require('telescope.builtin').find_files {
          prompt_title = 'DSA Notes',
          cwd = DSA_PATH,
          hidden = false,
        }
      end, 'LeetCode: Browse DSA notes')

      -- <leader>nDr — open a random existing DSA note for review
      map('<leader>nDr', function()
        local files = vim.fn.globpath(DSA_PATH, '*.md', false, true)
        if #files == 0 then
          vim.notify('No DSA notes found', vim.log.levels.WARN)
          return
        end
        math.randomseed(os.time())
        local pick = files[math.random(#files)]
        vim.cmd('edit ' .. pick)
        vim.notify('Review: ' .. vim.fn.fnamemodify(pick, ':t'), vim.log.levels.INFO)
      end, 'LeetCode: Open random DSA note')

      -- <leader>nDx — mark current note as solved (appends Solved line + updates tags)
      map('<leader>nDx', function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        -- Check if already solved
        for _, line in ipairs(lines) do
          if line:match '^%*%*Solved%*%*' then
            vim.notify('Already marked as solved', vim.log.levels.WARN)
            return
          end
        end
        -- Find the --- line after frontmatter block (second ---)
        local dash_count = 0
        local insert_at = nil
        for i, line in ipairs(lines) do
          if line == '---' then
            dash_count = dash_count + 1
            if dash_count == 2 then
              insert_at = i
              break
            end
          end
        end
        local solved_line = '**Solved**: ' .. os.date '%Y-%m-%d'
        if insert_at then
          vim.api.nvim_buf_set_lines(0, insert_at - 1, insert_at - 1, false, { solved_line })
        else
          -- Fallback: append after line 1 (title)
          vim.api.nvim_buf_set_lines(0, 1, 1, false, { '', solved_line })
        end
        vim.cmd 'write'
        vim.notify('Marked as solved', vim.log.levels.INFO)
      end, 'LeetCode: Mark current note solved')

      -- <leader>nDu — Telescope list of DSA notes NOT containing "**Solved**"
      map('<leader>nDu', function()
        local files = vim.fn.globpath(DSA_PATH, '*.md', false, true)
        local unsolved = {}
        for _, f in ipairs(files) do
          local content = Path:new(f):read()
          if not content:match '%*%*Solved%*%*' then
            table.insert(unsolved, f)
          end
        end
        if #unsolved == 0 then
          vim.notify('All DSA notes are marked solved!', vim.log.levels.INFO)
          return
        end
        local pickers   = require 'telescope.pickers'
        local finders   = require 'telescope.finders'
        local conf      = require('telescope.config').values
        local actions   = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'
        pickers.new({}, {
          prompt_title = 'Unsolved DSA Notes (' .. #unsolved .. ')',
          finder = finders.new_table {
            results = unsolved,
            entry_maker = function(f)
              return {
                value   = f,
                display = vim.fn.fnamemodify(f, ':t'),
                ordinal = vim.fn.fnamemodify(f, ':t'),
                path    = f,
              }
            end,
          },
          sorter = conf.generic_sorter {},
          previewer = conf.file_previewer {},
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              vim.cmd('edit ' .. entry.path)
            end)
            return true
          end,
        }):find()
      end, 'LeetCode: List unsolved DSA notes')

      -- <leader>nDo — open the LeetCode URL from the current note in the browser
      map('<leader>nDo', function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for _, line in ipairs(lines) do
          local url = line:match '%*%*URL%*%*:%s*(https?://%S+)'
          if url then
            vim.fn.jobstart({ 'xdg-open', url })
            vim.notify('Opening: ' .. url, vim.log.levels.INFO)
            return
          end
        end
        vim.notify('No URL found in this note', vim.log.levels.WARN)
      end, 'LeetCode: Open problem URL in browser')

      -- <leader>nDT — Telescope DSA notes last modified today (by mtime)
      map('<leader>nDT', function()
        local files = vim.fn.globpath(DSA_PATH, '*.md', false, true)
        local today_files = {}
        local today_str = os.date '%Y-%m-%d'
        for _, f in ipairs(files) do
          local mtime = vim.fn.getftime(f)
          if os.date('%Y-%m-%d', mtime) == today_str then
            table.insert(today_files, f)
          end
        end
        if #today_files == 0 then
          vim.notify('No DSA notes modified today', vim.log.levels.INFO)
          return
        end
        if #today_files == 1 then
          vim.cmd('edit ' .. today_files[1])
          return
        end
        local pickers      = require 'telescope.pickers'
        local finders      = require 'telescope.finders'
        local conf         = require('telescope.config').values
        local actions      = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'
        pickers.new({}, {
          prompt_title = "Today's DSA Notes",
          finder = finders.new_table {
            results = today_files,
            entry_maker = function(f)
              return {
                value   = f,
                display = vim.fn.fnamemodify(f, ':t'),
                ordinal = vim.fn.fnamemodify(f, ':t'),
                path    = f,
              }
            end,
          },
          sorter = conf.generic_sorter {},
          previewer = conf.file_previewer {},
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              vim.cmd('edit ' .. entry.path)
            end)
            return true
          end,
        }):find()
      end, "LeetCode: Jump to today's DSA note")

      -- <leader>nDc — prompt for Time + Space complexity, replace in current note
      map('<leader>nDc', function()
        vim.ui.input({ prompt = 'Time complexity (e.g. O(n log n)): ' }, function(time_c)
          if not time_c or time_c == '' then return end
          vim.ui.input({ prompt = 'Space complexity (e.g. O(n)): ' }, function(space_c)
            if not space_c or space_c == '' then return end
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local replaced = false
            for i, line in ipairs(lines) do
              if line:match '^%- Time:' then
                lines[i] = '- Time: ' .. time_c
                replaced = true
              elseif line:match '^%- Space:' then
                lines[i] = '- Space: ' .. space_c
                replaced = true
              end
            end
            if replaced then
              vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
              vim.cmd 'write'
              vim.notify('Complexity updated', vim.log.levels.INFO)
            else
              vim.notify('No "- Time:" / "- Space:" lines found in note', vim.log.levels.WARN)
            end
          end)
        end)
      end, 'LeetCode: Fill complexity section')
    end,
  },
}
