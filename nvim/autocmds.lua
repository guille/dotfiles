vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = { '*' },
	command = '%s/\\s\\+$//e',
	desc = 'Trim trailing whitespace before saving',
})

vim.api.nvim_create_autocmd("BufReadPost", {
	desc = 'Remember last cursor position when closing and reopening a file',
	callback = function()
			local mark = vim.api.nvim_buf_get_mark(0, '"')
			local lcount = vim.api.nvim_buf_line_count(0)
			if mark[1] > 0 and mark[1] <= lcount then
					pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
	end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	callback = function()
		vim.hl.on_yank()
	end,
})

-- format on save for JSON only
vim.api.nvim_create_user_command(
	"JsonFmt", "%!jq '.'", { desc = "Format JSON with jq" }
)
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.json",
	callback = function()
		vim.cmd("JsonFmt")
	end,
})


--
-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		vim.o.clipboard = 'unnamedplus'
	end,
})

-- When launching nvim without args: emulate "nvim ."
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.schedule(function()
				vim.cmd("e " .. vim.loop.cwd())
			end)
		end
	end,
})

-- Use LSP for autocompletion when avaialble
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		-- LSP-powered completion
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
		-- LSP format on save
		if not client:supports_method('textDocument/willSaveWaitUntil')
		    and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
				buffer = ev.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
				end,
			})
		end
	end,
})


--
-- Filetype-specific configs
--
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
