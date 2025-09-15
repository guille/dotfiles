-- Pacman already puts fzf in /usr/share/vim, so it gets loaded
-- This is needed for homebrew-installed fzf
vim.opt.runtimepath:append('/usr/local/opt/fzf')

-- TODO: v0.12.x. Installed manually for now
-- vim.pack.add({
-- 	{ src = 'https://github.com/junegunn/fzf.vim', version = '879db51' },
-- })

-- Replaces netrw with fzf popup
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
local opened = {}

vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function(args)
		local name = vim.api.nvim_buf_get_name(args.buf)
		if vim.fn.isdirectory(name) == 0 then return end
		if opened[name] then return end
		opened[name] = true

		vim.bo[args.buf].bufhidden = "wipe"
		vim.bo[args.buf].buflisted = false

		vim.schedule(function()
			vim.cmd("Files " .. vim.fn.fnameescape(name))
		end)
	end
})

vim.api.nvim_create_autocmd("BufLeave", {
	pattern = "*",
	callback = function(args)
		local name = vim.api.nvim_buf_get_name(args.buf)
		if vim.fn.isdirectory(name) == 0 then return end
		opened[name] = nil
	end
})
--
-- Keys

vim.g.fzf_action = {
	['enter'] = 'edit',
	['ctrl-x'] = 'vsplit', -- override: ctrl+v pastes
	['ctrl-h'] = 'split',
	['ctrl-t'] = 'tabedit',
}
-- leader + b for quick buffer switching
vim.keymap.set('n', '<leader>b', ':Buffers <CR>', {noremap = true, silent = true})
-- leader + e for quick file switching
vim.keymap.set('n', '<leader>e', ':Files <CR>', {noremap = true, silent = true})
-- control + p for quick file switching (git repo)
vim.keymap.set('n', '<c-p>', ':GFiles <CR>', {noremap = true, silent = true})
