#!/usr/bin/env bash

UNIT=lid-inhibit

case "$1" in
    toggle)
        if systemctl --user is-active -q "$UNIT"; then
            systemctl --user stop "$UNIT"
        else
            systemd-run --user --unit="$UNIT" -q \
                systemd-inhibit --what=handle-lid-switch:sleep --who=waybar \
                --why="waybar toggle" sleep infinity
        fi
        pkill -RTMIN+9 waybar
        ;;
    status)
        if systemctl --user is-active -q "$UNIT"; then
            echo '{"text":"󰌾","class":"active","tooltip":"Lid close and suspend are inhibited"}'
        else
            echo '{"text":"󰌿","tooltip":"Lid close suspends as usual"}'
        fi
        ;;
esac
