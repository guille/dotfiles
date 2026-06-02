#!/usr/bin/env bash
input=$(cat | tee /tmp/claude-statusline-input.json)

MODEL=$(echo "$input"      | jq -r '.model.display_name')
DIR=$(echo "$input"        | jq -r '.workspace.current_dir')
CTX_PCT=$(echo "$input"    | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
FIVE_PCT=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // 0' | cut -d. -f1)
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // ""')
SEVEN_PCT=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_percentage // 0' | cut -d. -f1)
SEVEN_RESET=$(echo "$input"| jq -r '.rate_limits.seven_day.resets_at // ""')

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'

# Returns "2h30m", "45m", "1d8h", or "" if timestamp is empty/past
format_reset() {
    local ts="$1"
    [ -z "$ts" ] && return
    local now epoch_reset delta
    now=$(date +%s)
    # resets_at is Unix epoch seconds
    epoch_reset=$(date -d "@$ts" +%s 2>/dev/null) || return
    delta=$((epoch_reset - now))
    [ "$delta" -le 0 ] && echo "now" && return
    local d=$((delta / 86400))
    local h=$(( (delta % 86400) / 3600 ))
    local m=$(( (delta % 3600) / 60 ))
    if   [ "$d" -gt 0 ]; then printf "%dd%dh" "$d" "$h"
    elif [ "$h" -gt 0 ]; then printf "%dh%02dm" "$h" "$m"
    else                      printf "%dm" "$m"
    fi
}

# --- Line 1: model / dir / git ---
#   model  dir  branch +staged ~modified
BRANCH_SEGMENT=""
if git -C "${DIR}" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "${DIR}" branch --show-current 2>/dev/null)
    STAGED=$(git -C "${DIR}" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git -C "${DIR}" diff --numstat 2>/dev/null | wc -l | tr -d ' ')

    GIT_INDICATORS=""
    [ "${STAGED}"   -gt 0 ] && GIT_INDICATORS="${GREEN}+${STAGED}${RESET}"
    [ "${MODIFIED}" -gt 0 ] && GIT_INDICATORS="${GIT_INDICATORS} ${YELLOW}~${MODIFIED}${RESET}"

    BRANCH_SEGMENT=" | ${BRANCH}${GIT_INDICATORS:+ ${GIT_INDICATORS}}"
fi

printf '%b\n' "${CYAN}[${MODEL}]${RESET} ${DIR##*/}${BRANCH_SEGMENT}"

# --- Line 2: rate limits ---

# 5-hour (always shown)
if [ "${FIVE_PCT}" -gt 80 ]; then
    FIVE_RESET_STR=$(format_reset "${FIVE_RESET}")
    FIVE_SEG="| ${ORANGE}5h usage: ${FIVE_PCT}%${FIVE_RESET_STR:+  ${FIVE_RESET_STR}}${RESET}"
elif [ "${FIVE_PCT}" -gt 0 ]; then
    FIVE_SEG="| ${GREEN}5h usage: ${FIVE_PCT}%${RESET}"
fi

# 7-day (only when >80%)
SEVEN_SEG=""
if [ "${SEVEN_PCT}" -gt 80 ]; then
    SEVEN_RESET_STR=$(format_reset "${SEVEN_RESET}")
    SEVEN_SEG="  ${ORANGE} 7d usage: ${SEVEN_PCT}%${SEVEN_RESET_STR:+  ${SEVEN_RESET_STR}}${RESET}"
fi

# Context window bar (██░░░░░░░░)
if   [ "${CTX_PCT}" -ge 90 ]; then BAR_COLOR="${RED}"
elif [ "${CTX_PCT}" -ge 70 ]; then BAR_COLOR="${ORANGE}"
else                               BAR_COLOR="${GREEN}"
fi
FILLED=$((CTX_PCT / 10))
EMPTY=$((10 - FILLED))
BAR=""
[ "${FILLED}" -gt 0 ] && printf -v F "%${FILLED}s" && BAR="${F// /█}"
[ "${EMPTY}"  -gt 0 ] && printf -v E "%${EMPTY}s"  && BAR="${BAR}${E// /░}"

printf '%b\n' "Ctx: ${BAR_COLOR}${BAR}${RESET} ${CTX_PCT}% ${FIVE_SEG}${SEVEN_SEG}"
