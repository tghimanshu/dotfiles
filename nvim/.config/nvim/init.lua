--[[

   / / / /  _/  |/  /   |  / | / / ___// / / / / / ( ) ___/   / | / / |  / /  _/  |/  /
  / /_/ // // /|_/ / /| | /  |/ /\__ \/ /_/ / / / /|/\__ \   /  |/ /| | / // // /|_/ / 
 / __  // // /  / / ___ |/ /|  /___/ / __  / /_/ /  ___/ /  / /|  / | |/ // // /  / /  
/_/ /_/___/_/  /_/_/  |_/_/ |_//____/_/ /_/\____/  /____/  /_/ |_/  |___/___/_/  /_/   

--]]

-- https://patorjk.com/software/taag/#p=display&f=Slant&t=HIMANSHU%27S+NVIM&x=none&v=4&h=4&w=80&we=false

-- Custom Imports
require 'core.options'
require 'core.keymaps'
require 'core.diagnostics'
require 'core.snippets'

vim.g.have_nerd_font = true -- Set to true if you have a Nerd Font installed and selected in the terminal

vim.g.markdown_recommended_style = 0

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- [[ Install `lazy.nvim` plugin manager ]] See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require('lazy').setup({

  -- Installing Plugins from files
  require 'plugins.alpha',
  require 'plugins.autocompletion',
  require 'plugins.bufferline',
  require 'plugins.colortheme',
  require 'plugins.comment',
  require 'plugins.conform',
  require 'plugins.copilot',
  require 'plugins.debugger',
  require 'plugins.gitsigns',
  require 'plugins.harpoon',
  require 'plugins.indent-blankline',
  require 'plugins.lsp',
  require 'plugins.lualine',
  require 'plugins.misc',
  require 'plugins.markdown',
  require 'plugins.neotree',
  require 'plugins.noice',
  require 'plugins.none-ls',
  require 'plugins.obsidian',
  require 'plugins.telescope',
  require 'plugins.treesitter',

  -- NOTE: lazydev is defined in plugins/lsp.lua — do not duplicate here
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
-- Used `:TSInstall lua` to ensure that the lua error is resolved
