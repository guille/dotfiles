local config = require("config")

-- hyprctl globalshortcuts
-- ghostty quick terminal
hl.bind("SUPER + dead_grave", hl.dsp.global(":LOGO+grave"))

hl.bind("SUPER + Return", hl.dsp.exec_cmd(config.terminal))
hl.bind("SUPER + D", hl.dsp.exec_cmd(config.menu))
hl.bind("SUPER + C", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("vaulter"))
hl.bind("SUPER + J", hl.dsp.exec_cmd("emoji --rofi"))
hl.bind("SUPER + T", hl.dsp.exec_cmd(config.terminal .. " -e zsh -ic nnn", { workspace = 3 }))

-- Clipboard
hl.bind("SUPER + P", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

hl.bind("Print",
	hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | tee " .. config.screenshots_dir .. "/$(date +%F-%T).png | wl-copy"))

-- reload config
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))


hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = 'fullscreen', action = "toggle" }))

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

-- Move window with secondMod + arrow keys
hl.bind("SUPER + SHIFT + left", hl.dsp.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.swap({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.swap({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.swap({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + ordmasculine", hl.dsp.focus({ workspace = 0 }))
hl.bind("SUPER + SHIFT + ordmasculine", hl.dsp.window.move({ workspace = 0 }))

-- Alt+Tab / Shift+Alt+Tab to cycle workspaces
hl.bind("ALT + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SHIFT + ALT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- close focused window
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close())

-- exit menu
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("~/mybin/rofi_logout.sh"))

hl.bind("SUPER + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))

-- Move windows with mainMod + LMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
-- Resize windows with mainMod + RMB and dragging
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move workspace to the next monitor
hl.bind("SUPER + X", hl.dsp.window.move(), { monitor = "+1" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
