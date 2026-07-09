#!/usr/bin/env bash

status() {
	if dunstctl is-paused --exit-code; then
		count=$(dunstctl count waiting)
		disabled_text=" "
		if [ "$count" != 0 ]; then
			disabled_text=" $count"
		fi
		printf '{"text":"%s"}\n' "$disabled_text"
	else
		# echo ""
		printf '{"text":" ","class":"active"}\n'
	fi
}

# Print the current state once, then re-print whenever dunst's state changes
# (pause toggled, notification queued/shown/expired). dunst emits these as a
# DBus PropertiesChanged on org.dunstproject.cmd0, so we block on dbus-monitor
# and only wake on real events — no polling.
status

stdbuf -oL dbus-monitor --profile \
	"type='signal',path='/org/freedesktop/Notifications',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'" \
	2>/dev/null |
while read -r line; do
	case "$line" in
	*PropertiesChanged*) status ;;
	esac
done
