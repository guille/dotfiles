---
name: hyprctl-monitors
description: Identify and configure the user's Hyprland monitors — flash a number on each screen so you and the user refer to the same one, show resolution/scale/rotation/position/modes, then apply what the user asks for as `hl.monitor` rules in the dotfiles. Use when the user asks to arrange, rotate, rescale, reposition, enable/disable or otherwise set up monitors/screens/displays/outputs in Hyprland, mentions "monitor 2" or "the left screen", says a new desk/dock/meeting room setup looks wrong, or asks which monitor is which.
---

# Hyprland monitors

## Workflow

1. **Show and wait.** Run `<skill-dir>/scripts/monitors.sh` right away, with no
   preamble. It flashes "#N + connector" on each screen for 8 seconds and prints details. Give the
   user a compact summary (one line per monitor: number, connector, model + serial, mode, scale,
   rotation, position), then stop. Don't suggest changes.
2. **The user says what to change**, by number. Usually that means rotating one to vertical,
   reordering, or fixing the scale. If a request could mean two things, ask.
3. **Apply it.** Edit `local_llm_config.lua`, then run `hyprctl reload` and `hyprctl configerrors`
   (empty output means OK). If a monitor that wasn't vertical before is now vertical, also run the
   user's `rewall` alias, which redraws the wallpapers:
   `pkill -e --full --signal HUP --require-handler '[w]allpapered'`. The brackets stop `--full`
   from also matching, and killing, the shell running the command. Run `monitors.sh` again with the flash, since reordering renumbers the
   monitors. Report the new state in one line per monitor and wait. If the user says it's off, repeat
   from step 2.

Numbers always go left to right by position (disabled monitors come last and get no label). Refer to
monitors by number plus connector, e.g. `#2 (DP-1)`.

## Files

Hyprland 0.56 with a **Lua** config (`hl.monitor { ... }`, not `monitor=` lines). The dotfiles are in
`~/projects/dotfiles/hyprland/hyprland/` and are symlinked file by file into
`~/.config/hypr/hyprland/`.

- `local_confs.lua`: the **user's** file, with their fallbacks and the catch-all rule. Read it for
  context, never edit it.
- `local_llm_config.lua`: **your** file. It's `require`d at the end of `local_confs.lua`, so its
  rules win. Both files are gitignored and local to this machine.

## Writing rules

Key every rule on `desc:` with the full description (serial included). Connector names (`DP-5`)
change between docks and ports, and identical models differ only by serial:

```lua
-- Office desk, right (rotated)
hl.monitor {
    output    = "desc:Dell Inc. DELL S2722QC 4F1VH24",
    mode      = "preferred",       -- or "3840x2160@60"
    position  = "2880x0",
    scale     = "1.6",             -- or "auto"
    transform = 1,                 -- 0 normal, 1 90°, 2 180°, 3 270°, 4-7 flipped variants
}
hl.monitor { output = "desc:...", disabled = true }
```

Other fields (`mirror`, `vrr`, `bitdepth`, `cm`, `reserved_area`, …): see `HL.MonitorSpec` in
`/usr/share/hypr/stubs/hl.meta.lua`.

- **Precedence** (tested): a matching specific rule beats `output = ""` wherever either is declared,
  and a later rule for the same output overrides an earlier one. Keep one rule per monitor in your
  file. Rules for disconnected monitors are harmless, so group them by physical setup with a
  comment (home, office desks, meeting room).
- **Ordering means explicit positions.** `auto` depends on connection order. Positions are in
  logical pixels: physical size ÷ scale, with width and height swapped for transforms 1, 3, 5 and 7.
  The script prints the `logical:` size of each monitor. To put B right of A, use
  `B.x = A.x + A.logical_width`. Recompute everyone's x when a monitor's rotation or scale changes.
- **Scale:** Hyprland silently nudges scales that don't divide the resolution cleanly. After
  reloading, read the real `scale:` back from the script and write that value into the file.
