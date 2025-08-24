-- See /usr/share/nvim/runtime/example_init.lua

-- Print the line number in front of each line
vim.o.number = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 3

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight the line where the cursor is on
vim.o.cursorline = true

-- soft wrapping
vim.o.linebreak = true

-- new vertical split goes below the current one
-- new horizontal split goes to the right
vim.o.splitbelow = true
vim.o.splitright = true

vim.o.history = 10000
vim.o.colorcolumn="100"

-- nvim does it by default anyway
vim.o.termguicolors = true

-- complete (kinda) like zsh
vim.o.wildmode = "longest:full,list:full"

-- Subtitute globally by default
vim.o.gdefault = true

vim.o.swapfile = false

vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
-- vim.api.nvim_create_autocmd('UIEnter', {
--   callback = function()
--     vim.o.clipboard = 'unnamedplus'
--   end,
-- })

-- Filetype-specific configs

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'yaml', 'ruby' },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
	end,
	desc = 'Apply custom formatting for Ruby and YAML.',
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'make' },
	callback = function()
		vim.opt_local.tabstop = 8
		vim.opt_local.softtabstop = 8
		vim.opt_local.shiftwidth = 8
		vim.opt_local.expandtab = false
	end,
	desc = 'Apply custom formatting for Makefiles.',
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'gitcommit',
	callback = function()
		vim.opt_local.textwidth = 72
		vim.opt_local.colorcolumn = '50,72'
		vim.opt_local.spell = true
	end,
	desc = 'Custom rulers and spellcheck for Git commit messages.',
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'markdown',
	callback = function()
		vim.opt_local.colorcolumn = ""
		vim.opt_local.spell = true
	end,
	desc = 'Disable ruler and enable spell check on Markdown.',
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*' },
  command = '%s/\\s\\+$//e',
  desc = 'Trim trailing whitespace before saving',
})

-- Appearance
local monokai = require('monokai')
local palette = monokai.classic
monokai.setup {
	palette = {
		base0 = '#2c2c2c',
	}
}
