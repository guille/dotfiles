-- TODO: Does this speed anything up?
-- vim.loader.enable()

require('options')

require('autocmds')
require('keybinds')
require('statusline')

-- overrides some keybinds, so has to come after
require('fzf')

require('lsp')

--
-- Appearance
-- Thicker borders
vim.opt.fillchars = {
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
}
-- Custom monokai-based colours
local monokai = require('monokai')
local palette = monokai.classic
monokai.setup {
	custom_hlgroups = {
		StatuslineMode = {
			fg = palette.green,
			style = 'bold',
		},
	},
}

-- Opt in to new UI
if vim.version.ge(vim.version(), { 0, 12, 0 }) then
	require('vim._core.ui2').enable({})
end
