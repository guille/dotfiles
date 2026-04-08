local function get_diagnostics()
	if not vim.diagnostic then
		return ""
	end
	local d = vim.diagnostic.get(0)
	local e, w, i, h = 0, 0, 0, 0
	for _, v in ipairs(d) do
		if v.severity == vim.diagnostic.severity.ERROR then
			e = e + 1
		elseif v.severity == vim.diagnostic.severity.WARN then
			w = w + 1
		elseif v.severity == vim.diagnostic.severity.INFO then
			i = i + 1
		elseif v.severity == vim.diagnostic.severity.HINT then
			h = h + 1
		end
	end

	local s = ""
	if e > 0 then
		s = s .. "%#StatusErrorIcon# " .. e .. " "
	end
	if w > 0 then
		s = s .. "%#StatusWarnIcon# " .. w .. " "
	end
	if i > 0 then
		s = s .. "%#StatusInfoIcon# " .. i .. " "
	end
	if h > 0 then
		s = s .. "%#StatusHintIcon# " .. h .. " "
	end

	-- reset to StatusLine for following text
	return s .. "%#StatusLine#"
end

function custom_line()
	local st = ""
	local di = get_diagnostics()
	if di ~= "" then
		st = st .. "%#StatusLSP# " .. di .. " " .. "%#StatusLSPToNorm#"
	end

	local focus = vim.g.statusline_winid == vim.fn.win_getid()
	if focus then
		return "%#StatuslineMode# %{v:lua.string.upper(mode())} %#StatusLine#┃ %<%f %y %-4(%m%) %r %=%-19(%l/%L:%c%)" ..
			st
	else
		return "%#StatusLineNC#%<%f %y" .. st
	end
end

vim.o.statusline = "%!v:lua.custom_line()"
