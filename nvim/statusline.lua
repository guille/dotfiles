function custom_line()
	local focus = vim.g.statusline_winid == vim.fn.win_getid()
	if focus then
		return "%#StatuslineMode# %{v:lua.string.upper(mode())} %#StatusLine#┃ %<%f %y %-4(%m%) %r %=%-19(%l/%L:%c%)"
	else
		return "%#StatusLineNC#%<%f %y"
	end
end

vim.o.statusline = "%!v:lua.custom_line()"
