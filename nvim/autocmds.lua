vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = { '*' },
	desc = 'Trim trailing whitespace before saving',
	callback = function()
		-- trailing double space is a hard line break in Markdown
		if vim.bo.filetype == 'markdown' then
			return
		end
		local view = vim.fn.winsaveview()
		vim.cmd([[keepjumps keeppatterns silent! %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
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

vim.api.nvim_create_user_command("JsonFormat", function()
	local cmd = { 'jq' }
	if vim.bo.expandtab then
		-- jq caps --indent at 7
		table.insert(cmd, '--indent')
		table.insert(cmd, tostring(math.min(vim.fn.shiftwidth(), 7)))
	else
		table.insert(cmd, '--tab')
	end
	table.insert(cmd, '.')

	local res = vim.system(cmd, {
		stdin = vim.api.nvim_buf_get_lines(0, 0, -1, false),
	}):wait()
	if res.code ~= 0 then
		vim.notify(vim.trim(res.stderr), vim.log.levels.ERROR)
		return
	end

	local view = vim.fn.winsaveview()
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(res.stdout, '\n', { trimempty = true }))
	vim.fn.winrestview(view)
end, { desc = "Format JSON with jq" })


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
				vim.cmd("edit .")
			end)
		end
	end,
})

-- vim.lsp.buf.code_action is async, so on BufWritePre its edits land after the
-- file is written. Request and apply them synchronously instead.
local function apply_source_action(client, bufnr, kind)
	local res = client:request_sync('textDocument/codeAction', {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		range = {
			start = { line = 0, character = 0 },
			['end'] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
		},
		context = { diagnostics = {}, only = { kind } },
	}, 1000, bufnr)
	if not res or res.err or not res.result then
		return
	end
	for _, action in ipairs(res.result) do
		-- servers may defer the edit to codeAction/resolve
		if not action.edit and action.data then
			local resolved = client:request_sync('codeAction/resolve', action, 1000, bufnr)
			action = (resolved and not resolved.err and resolved.result) or action
		end
		if action.edit then
			vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
		end
	end
end

-- Capabilities are resolved at save time rather than at attach time, so a single
-- autocmd per buffer covers clients that attach later or restart.
local function format_on_save(bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if not client:supports_method('textDocument/willSaveWaitUntil')
			and client:supports_method('textDocument/formatting') then
			-- fix and sort first so the formatter has the final word
			apply_source_action(client, bufnr, 'source.organizeImports')
			apply_source_action(client, bufnr, 'source.fixAll')
			-- id is required: without it format runs once per matching client
			vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
		end
	end
end

-- Use LSP for autocompletion when available
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end
		-- LSP-powered completion
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
		-- LSP format on save, registered once per buffer
		if not vim.b[ev.buf].my_lsp_format then
			vim.b[ev.buf].my_lsp_format = true
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
				buffer = ev.buf,
				callback = function()
					format_on_save(ev.buf)
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
