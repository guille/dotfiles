---
name: orbit-cli
description: Use the "orbit" CLI, manage tasks and reminders in the user's system. Use this skill when the user asks to set up something via orbit or change their orbit configuration.
---

Orbit is a declarative tool that allows managing scheduled "tasks" and "reminders" via CLI. The CLI is already installed (`orbit --help`) and the config file lives in `~/.config/orbit/orbit.toml`. That same directory has a JSON schema that defines all properties of the config file (`schema.json`).

Generally you may be asked to either modify orbit's configuration or do some sort of debugging.

Use the `--help` liberally for confirming how the CLI works and what subcommands it offers.

## Change configuration

1. Edit the config file with the desired changes applied.
2. Run `orbit plan` to view a diff of what would be applied.
3. Run `orbit apply` to apply the changes.
4. Optionally, run `orbit doctor` to check nothing broke.

## One-off vs periodic

Decide which one the user wants before writing the schedule; ask if the request is ambiguous. Phrasing like "tonight", "tomorrow", "sometime after midnight" or "once" means a single run, not a recurring one.

- Periodic: a recurring OnCalendar expression, e.g. `"Mon..Fri 09:30:00"`, `"daily"`.
- One-off: an absolute timestamp, e.g. `"2026-10-21 00:30:00"`. It fires once and never again, but the entry stays in `orbit.toml` until removed, so mention that to the user.

## Debugging

As a first pass, use the `orbit` CLI to introspect what has been asked. Some useful commands are `orbit list`, `orbit status [NAME]` and `orbit logs [NAME]`. Since `orbit` is just a wrapper for systemd, you may also fall down into systemctl/journalctl raw commands. Orbit-managed units are in `~/.config/systemd/user`. **Prefer editing those through orbit, not manually**. `orbit doctor` will flag divergences.

## One last resort

When something is not obvious from just the instructions above, do two things:
1. Confirm the right behaviour in code (cloned under `~/projects/orbit`)
2. Flag it for the user, so they may consider updating documentation or behaviours (eg exposing more information through orbit commands).
