#!/usr/bin/env bash
# Notification hook: a desktop notification that says which session wants what.
# Types where the session is blocked on the user are critical and ding; the rest are quiet.
input=$(cat)

SESSION_ID=$(echo "$input" | jq -r '.session_id // ""')
TYPE=$(echo "$input"       | jq -r '.notification_type // ""')
MESSAGE=$(echo "$input"    | jq -r '.message // "Claude needs your attention"')
DIR=$(echo "$input"        | jq -r '.cwd // ""')

WHERE=$(basename "$(git -C "$DIR" rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git/\?$##; s#\.git/\?$##')" 2>/dev/null)
[ -z "$WHERE" ] && WHERE=$(basename "$DIR")
BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)

TITLE="${WHERE}${BRANCH:+/${BRANCH}}"

case "$TYPE" in
    auth_success | elicitation_complete | elicitation_response) exit 0 ;;
    permission_prompt | elicitation_dialog | elicitation_url_dialog | agent_needs_input) URGENCY=critical ;;
    *) URGENCY=normal ;;
esac

if [[ "$(uname)" == "Darwin" ]]; then
    osascript -e "display notification \"${MESSAGE//\"/\\\"}\" with title \"${TITLE//\"/\\\"}\""
else
    # Same stack tag per session: a newer notification replaces the older one instead of piling up.
    notify-send -a "Claude Code" -u "$URGENCY" -i org.gnome.Robots \
        -h "string:x-dunst-stack-tag:claude-${SESSION_ID}" \
        "$TITLE" "$MESSAGE"
fi

[ "$URGENCY" = "critical" ] && ding &
exit 0
