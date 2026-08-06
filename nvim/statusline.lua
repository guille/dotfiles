-- highest first: the segment reads worst-to-least severe
local levels = {
	{ severity = vim.diagnostic.severity.ERROR, hl = 'StatusErrorIcon', icon = '' },
	{ severity = vim.diagnostic.severity.WARN,  hl = 'StatusWarnIcon',  icon = '' },
	{ severity = vim.diagnostic.severity.INFO,  hl = 'StatusInfoIcon',  icon = '' },
	{ severity = vim.diagnostic.severity.HINT,  hl = 'StatusHintIcon',  icon = '' },
}

local function get_diagnostics(bufnr)
	local s = ""
	for _, level in ipairs(levels) do
		local n = #vim.diagnostic.get(bufnr, { severity = level.severity })
		if n > 0 then
			s = s .. ("%%#%s#%s %d "):format(level.hl, level.icon, n)
		end
	end
	return s
end

function custom_line()
	-- statusline is evaluated per window, so counts must follow that window's
	-- buffer rather than the focused one
	local winid = vim.g.statusline_winid
	local bufnr = vim.api.nvim_win_get_buf(winid)

	local st = ""
	local di = get_diagnostics(bufnr)
	if di ~= "" then
		st = "%#StatusLSP# " .. di .. "%#StatusLine#"
	end

	if winid == vim.fn.win_getid() then
		return "%#StatuslineMode# %{v:lua.string.upper(mode())} %#StatusLine#┃ %<%f %y %-4(%m%) %r %=%-19(%l/%L:%c%)" ..
			st
	else
		return "%#StatusLineNC#%<%f %y" .. st
	end
end

vim.o.statusline = "%!v:lua.custom_line()"

-- diagnostics arrive asynchronously and do not themselves trigger a redraw
vim.api.nvim_create_autocmd('DiagnosticChanged', {
	desc = 'Refresh statusline diagnostic counts',
	callback = function()
		vim.cmd('redrawstatus!')
	end,
})
