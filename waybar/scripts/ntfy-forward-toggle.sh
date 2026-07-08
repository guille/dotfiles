#!/usr/bin/env bash

SENTINEL="$XDG_RUNTIME_DIR/ntfy-forward"
if [[ -e "$SENTINEL" ]]; then
    rm -f "$SENTINEL"
else
    touch "$SENTINEL"
fi
pkill -RTMIN+8 waybar
