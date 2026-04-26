-- https://wiki.hypr.land/Configuring/

local config = require("config")


-- env vars

hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- run electron apps in wayland mode
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
-- https://github.com/ghostty-org/ghostty/discussions/8899
hl.env("GTK_IM_MODULE", "simple")

-- autostart

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("mpd")
    hl.exec_cmd("lxsession")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("thunar --daemon")
    hl.exec_cmd("wlsunset -l " .. config.latitude .. " -L " .. config.longitude)
    hl.exec_cmd("waybar")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme " .. config.gtk_theme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme " .. config.icon_theme)
    hl.exec_cmd("wallpapered")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch cliphist store")

    hl.exec_cmd("subl")
    hl.exec_cmd(config.terminal, { workspace = 3 })
end)

-- catch-all monitor rule
hl.monitor {
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
}

require("look_and_feel")
require("keybinds")
require("rules")
require("local_confs")

hl.config {
    input = {
        kb_layout          = "es",
        kb_options         = "compose:menu",
        numlock_by_default = true,

        follow_mouse       = 1,

        touchpad           = {
            natural_scroll = false,
        },
    },
}

-- Set up permissions?
-- hl.permission {
--     binary = "/usr/(bin|local/bin)/grim",
--     type = "screencopy",
--     mode = "allow"
-- }
-- hl.permission {
--     binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland",
--     type = "screencopy",
--     mode = "allow"
-- }
-- hl.permission {
--     binary = "/usr/(bin|local/bin)/hyprpm",
--     type = "plugin",
--     mode = "allow"
-- }

hl.config {
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true
        -- enforce_permissions = true
    },
}

-- for now...
hl.config {
    xwayland = {
        enabled = true
    },
}
