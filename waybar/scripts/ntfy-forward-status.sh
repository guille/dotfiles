#!/usr/bin/env bash

TOPIC_FILE="$HOME/.config/ntfy-forward/topic"

[[ -r "$TOPIC_FILE" ]] || exit 0

if [[ -e "$XDG_RUNTIME_DIR/ntfy-forward" ]]; then
    echo '{"text":"󰏴","class":"active","tooltip":"ntfy forwarding: ON"}'
else
    echo '{"text":"󰏴","class":"inactive","tooltip":"ntfy forwarding: OFF"}'
fi
