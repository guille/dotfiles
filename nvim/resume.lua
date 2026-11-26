-- Program Resume Protocol (OSC 7577): keep a session file up to date and tell
-- the terminal to bring this nvim back with it after the terminal restarts.
local token = vim.env.OSC7577_TOKEN
-- keep the token away from :terminal and child jobs
vim.env.OSC7577_TOKEN = nil
if not token then
	return
end

local dir = vim.fn.stdpath('state') .. '/sessions'
local max_age = 30 * 24 * 60 * 60
local file

local function report(field)
	-- This process is the server. The terminal runs its parent, the TUI.
	local body = ('pid=%d:time=%d:%s'):format(vim.uv.os_getppid(), os.time(), field)
	vim.api.nvim_ui_send(('\27]7577;%s:mac=%s\27\\'):format(body, vim.fn.sha256(body .. ':' .. token)))
end

local function save()
	if not pcall(vim.cmd.mksession, { args = { vim.fn.fnameescape(file) }, bang = true }) then
		return
	end
	local argv = vim.tbl_map(vim.base64.encode, { 'nvim', '-S', file })
	report('argv=' .. table.concat(argv, ','))
end

local pending = false
local function save_soon()
	if pending then
		return
	end
	pending = true
	vim.defer_fn(function()
		pending = false
		save()
	end, 1000)
end

-- Sessions of instances that were killed and never resumed.
local function prune()
	for name in vim.fs.dir(dir) do
		local path = dir .. '/' .. name
		local stat = vim.uv.fs_stat(path)
		if stat and os.time() - stat.mtime.sec > max_age then
			vim.uv.fs_unlink(path)
		end
	end
end

local group = vim.api.nvim_create_augroup('my.resume', {})

vim.api.nvim_create_autocmd('VimEnter', {
	group = group,
	callback = function()
		-- headless: nothing to send the report to
		if #vim.api.nvim_list_uis() == 0 then
			return
		end
		vim.fn.mkdir(dir, 'p', '0700')
		prune()
		-- a resumed instance keeps writing the session it was started from
		if vim.startswith(vim.v.this_session, dir .. '/') then
			file = vim.v.this_session
		else
			file = ('%s/%d-%d.vim'):format(dir, os.time(), vim.uv.os_getpid())
		end
		save()

		vim.api.nvim_create_autocmd(
			{ 'BufEnter', 'WinNew', 'WinClosed', 'TabNew', 'TabClosed', 'DirChanged' },
			{ group = group, callback = save_soon }
		)
		vim.api.nvim_create_autocmd('VimLeavePre', {
			group = group,
			callback = function()
				-- Killed along with the terminal: leave the session to resume from.
				-- A TUI that got the signal is gone by now, without setting v:dying.
				if vim.v.dying ~= 0 or #vim.api.nvim_list_uis() == 0 then
					return
				end
				report('clear=1')
				vim.uv.fs_unlink(file)
			end,
		})
	end,
})
