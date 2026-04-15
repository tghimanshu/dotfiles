return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*',
    ft = 'markdown',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = 'main',
          path = '~/personal/my-daily-driver',
        },
      },
      notes_subdir = '03-resources',
      new_notes_location = '00-inbox',

      daily_notes = {
        folder = '10-daily',
        date_format = '%Y-%m-%d',
        template = 'daily',
      },

      templates = {
        folder = '90-templates',
        date_format = '%Y-%m-%d',
        time_format = '%H:%M',
      },

      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      picker = {
        name = 'telescope.nvim',
      },

      checkbox = {
        enabled = true,
        create_new = true,
        order = { ' ', '/', 'x', '-' },
      },

      note_id_func = function(title)
        local ts = tostring(os.time())
        if title and title ~= '' then
          local slug = title:gsub('%s+', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
          return ts .. '-' .. slug
        end
        return ts
      end,
    },

    keys = {
      {
        '<leader>nh',
        function()
          vim.cmd('edit ' .. vim.fn.expand '~/personal/my-daily-driver/Home.md')
        end,
        desc = 'Notes: Home',
      },
      {
        '<leader>nI',
        function()
          vim.cmd('edit ' .. vim.fn.expand '~/personal/my-daily-driver/00-inbox/inbox.md')
        end,
        desc = 'Notes: Inbox',
      },
      {
        '<leader>n.',
        function()
          vim.cmd('edit ' .. vim.fn.expand '~/personal/my-daily-driver/tasks.md')
        end,
        desc = 'Notes: Tasks',
      },
      { '<leader>nd', '<cmd>ObsidianToday<CR>', desc = "Notes: Today's note" },
      { '<leader>ny', '<cmd>ObsidianYesterday<CR>', desc = "Notes: Yesterday's note" },
      { '<leader>nn', '<cmd>ObsidianNew<CR>', desc = 'Notes: New note' },
      { '<leader>no', '<cmd>ObsidianQuickSwitch<CR>', desc = 'Notes: Quick switch' },
      { '<leader>nf', '<cmd>ObsidianSearch<CR>', desc = 'Notes: Search' },
      { '<leader>nb', '<cmd>ObsidianBacklinks<CR>', desc = 'Notes: Backlinks' },
      { '<leader>nt', '<cmd>ObsidianTags<CR>', desc = 'Notes: Tags' },
      { '<leader>ni', '<cmd>ObsidianTemplate<CR>', desc = 'Notes: Insert template' },
      { '<leader><CR>', '<cmd>Obsidian toggle_checkbox<CR>', desc = 'Notes: Toggle checkbox' },
      {
        '<leader>np',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.expand '~/personal/my-daily-driver/01-projects' }
        end,
        desc = 'Notes: Projects',
      },
      {
        '<leader>na',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.expand '~/personal/my-daily-driver/02-areas' }
        end,
        desc = 'Notes: Areas',
      },
      {
        '<leader>nr',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.expand '~/personal/my-daily-driver/03-resources' }
        end,
        desc = 'Notes: Resources',
      },
      {
        '<leader>nP',
        function()
          vim.ui.input({ prompt = 'Project title: ' }, function(title)
            if not title or title == '' then
              return
            end
            local slug = title:gsub('%s+', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
            local path = vim.fn.expand '~/personal/my-daily-driver/01-projects/' .. slug .. '.md'
            local exists = vim.fn.filereadable(path) == 1
            vim.cmd('edit ' .. path)
            if not exists then
              vim.cmd 'ObsidianTemplate project'
            end
          end)
        end,
        desc = 'Notes: New project',
      },
      {
        '<leader>nA',
        function()
          vim.ui.input({ prompt = 'Area title: ' }, function(title)
            if not title or title == '' then
              return
            end
            local slug = title:gsub('%s+', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
            local path = vim.fn.expand '~/personal/my-daily-driver/02-areas/' .. slug .. '.md'
            local exists = vim.fn.filereadable(path) == 1
            vim.cmd('edit ' .. path)
            if not exists then
              vim.cmd 'ObsidianTemplate area'
            end
          end)
        end,
        desc = 'Notes: New area',
      },
      {
        '<leader>nR',
        function()
          vim.ui.input({ prompt = 'Resource title: ' }, function(title)
            if not title or title == '' then
              return
            end
            local slug = title:gsub('%s+', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
            local path = vim.fn.expand '~/personal/my-daily-driver/03-resources/' .. slug .. '.md'
            local exists = vim.fn.filereadable(path) == 1
            vim.cmd('edit ' .. path)
            if not exists then
              vim.cmd 'ObsidianTemplate resource'
            end
          end)
        end,
        desc = 'Notes: New resource',
      },
    },

    config = function(_, opts)
      require('obsidian').setup(opts)
      vim.opt.conceallevel = 2
    end,
  },
}
