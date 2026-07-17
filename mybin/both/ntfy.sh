#!/usr/bin/env bash

SENTINEL="$XDG_RUNTIME_DIR/ntfy-forward"
SERVER_FILE="$HOME/.config/ntfy-forward/server"
TOPIC_FILE="$HOME/.config/ntfy-forward/topic"

[[ -e "$SENTINEL" ]] || exit 0
[[ -r "$TOPIC_FILE" ]] || exit 0

topic="$(<"$TOPIC_FILE")"

[[ -r "$SERVER_FILE" ]] && server="$(<"$SERVER_FILE")"
server="${server:-ntfy.sh}"

curl -H "Title: ${DUNST_APP_NAME}" -d "$DUNST_SUMMARY" "https://${server}/${topic}"
