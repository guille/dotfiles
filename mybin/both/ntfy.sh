#!/usr/bin/env bash

SENTINEL="$XDG_RUNTIME_DIR/ntfy-forward"
TOPIC_FILE="$HOME/.config/ntfy-forward/topic"

[[ -e "$SENTINEL" ]] || exit 0
[[ -r "$TOPIC_FILE" ]] || exit 0

topic="$(<"$TOPIC_FILE")"

curl -H "Title: ${DUNST_APP_NAME}" -d "$DUNST_SUMMARY" "https://ntfy.sh/${topic}"
