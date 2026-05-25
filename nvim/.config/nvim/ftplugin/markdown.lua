vim.opt_local.wrap = true
vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append { 'r', 'a' }

vim.keymap.set('n', 'j', 'gj', { buffer = true, noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { buffer = true, noremap = true, silent = true })

--Disable math tex conceal and syntax highlight
vim.g.tex_conceal = ''
vim.g.vim_markdown_math = 0

--Let the TOC window autofit so that it doesn't take too much space
vim.g.vim_markdown_toc_autofit = 1
vim.g.vim_markdown_fenced_languages = { 'python', 'javascript', 'lua', 'bash=sh', 'html', 'css', 'typescript', 'jsx', 'tsx', 'ts', 'js' }

-- Add asterisks in block comments
vim.opt.formatoptions:append { 'r' }
vim.g.vim_markdown_override_syntax = 1

-- don't conceal code fences
vim.cmd [[
  let g:pandoc#syntax#conceal#use = 0
  let g:pandoc#syntax#codeblocks#embeds#langs#prefix = "```"
  let g:pandoc#syntax#codeblocks#embeds#langs#suffix = "```"
]]

vim.cmd [[autocmd FileType markdown setlocal syntax=pandoc]]

vim.cmd [[
  augroup markdown
    autocmd!
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal textwidth=80
    autocmd FileType markdown setlocal formatoptions+=a
  augroup END
]]

-- vim.cmd 'setlocal syntax=pandoc'
