hl.config {
    general = {
        gaps_in     = 5,
        gaps_out    = 0,

        border_size = 3,

        col         = {
            active_border   = { colors = { "rgba(66d9efee)" } },
            inactive_border = "rgba(595959aa)",
        },

        layout      = "master",
    },
}

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config {
    dwindle = {
        pseudotile = true,
        preserve_split = true,
        default_split_ratio = 1.25,
    },
}

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config {
    master = {
        new_status = "slave",
    },
}

hl.config {
    devocation = {
        rounding         = 10,
        rounding_power   = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.85,

        shadow           = {
            enabled = false
        },
        blur             = {
            enabled = false
        },
    },
}

hl.config {
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true
    },
}

hl.config {
    misc = {
        force_default_wallpaper = 0,
        font_family = "0xProto Nerd Font",
        disable_hyprland_logo = true,
        vfr = true,
        focus_on_activate = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        anr_missed_pings = 10,
    },
}

hl.config {
    animations = {
        enabled = true,
    },
}

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
