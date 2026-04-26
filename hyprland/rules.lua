-- ↓ smart gaps: no gaps if only one window open ↓
hl.workspace_rule { workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 }
hl.workspace_rule { workspace = "f[1]", gaps_out = 0, gaps_in = 0 }
hl.window_rule {
	name        = "no-gaps-wtv1",
	match       = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding    = 0,
}
hl.window_rule {
	name        = "no-gaps-f1",
	match       = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding    = 0,
}

-- ↑ smart gaps: no gaps if only one window open ↑

-- Ignore maximize requests from all apps
-- hl.window_rule {
-- 	name           = "suppress-maximize-events",
-- 	match          = { class = ".*" },

-- 	suppress_event = "maximize",
-- }

hl.window_rule {
	name         = "firefox",
	match        = { class = "^firefox$" },

	idle_inhibit = "fullscreen",
	workspace    = 1,
}

hl.window_rule {
	name         = "firefox2",
	match        = { class = "^org.mozilla.firefox$" },

	idle_inhibit = "fullscreen",
	workspace    = 1,
}

hl.window_rule {
	name      = "sublime_text",
	match     = { class = "^sublime_text$" },

	workspace = 2,
}

hl.window_rule {
	name      = "thunar",
	match     = { class = "^thunar$" },

	workspace = 3,
}

hl.window_rule {
	name      = "evince",
	match     = { class = "^org.gnome.Evince$" },

	workspace = 4,
}

hl.window_rule {
	name      = "obsidian",
	match     = { class = "^obsidian$" },

	workspace = 4,
}

hl.window_rule {
	name      = "libreoffice",
	match     = { class = "^libreoffice-.*" },

	workspace = 4,
}

hl.window_rule {
	name      = "libreoffice-splash",
	match     = { class = "^LibreOffice*" },

	workspace = "4 silent",
}

hl.window_rule {
	name         = "mpv",
	match        = { class = "^mpv$" },

	workspace    = "5",
	fullscreen   = true,
	opaque       = true,
	idle_inhibit = "fullscreen",
}

hl.windowrule {
	name = "qbittorrent",
	match = { class = "^org.qbittorrent.qBittorrent$" },

	workspace = 6,
}

hl.windowrule {
	name = "pavucontrol",
	match = { class = "^org.pulseaudio.pavucontrol$" },

	float = true,
	pin = true,
}

hl.windowrule {
	name = "imv",
	match = { class = "^imv$" },

	opaque = true,
}

hl.windowrule {
	name = "slack",
	match = { class = "^Slack$" },

	workspace = 10,
}
