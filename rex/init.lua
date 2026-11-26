-- Resume nvim from the sessions nvim/resume.lua keeps.
rex.set("resume.trust.nvim", {
	command = { "nvim", "-S", rex.match.under("~/.local/state/nvim/sessions") },
})
