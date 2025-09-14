-- TODO: Does this speed anything up?
-- vim.loader.enable()

require('options')

require('autocmds')
require('keybinds')
require('statusline')

-- overrides some keybinds, so has to come after
require('fzf')

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
	}
}

