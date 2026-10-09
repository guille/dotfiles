#!/usr/bin/env bash
input=$(cat | tee /tmp/claude-statusline-input.json)

MODEL=$(echo "$input"      | jq -r '.model.display_name | sub(" \\(.*\\)$"; "")')
EFFORT=$(echo "$input"     | jq -r '.effort.level // ""')
DIR=$(echo "$input"        | jq -r '.workspace.current_dir')
CTX_PCT=$(echo "$input"    | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
FIVE_PCT=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // 0' | cut -d. -f1)
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // ""')
SEVEN_PCT=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_percentage // 0' | cut -d. -f1)
SEVEN_RESET=$(echo "$input"| jq -r '.rate_limits.seven_day.resets_at // ""')
TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path // ""')
SESSION_ID=$(echo "$input" | jq -r '.session_id // ""')
# Name other sessions use to message this one; only the session registry has it.
PEER=$(jq -r --arg s "$SESSION_ID" 'select(.sessionId == $s) | .name // empty' ~/.claude/sessions/*.json 2>/dev/null | head -1)

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
ORANGE='\033[38;5;208m'
ICE='\033[38;5;45m'
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
NAME="${DIR##*/}"
if GIT_COMMON=$(git -C "${DIR}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
    # Common dir is shared by all worktrees: <repo>/.git or a bare <repo>.git
    GIT_COMMON="${GIT_COMMON%/}"
    if [ "${GIT_COMMON##*/}" = ".git" ]; then
        GIT_COMMON="${GIT_COMMON%/.git}"
    fi
    NAME="${GIT_COMMON##*/}"
    NAME="${NAME%.git}"

    BRANCH=$(git -C "${DIR}" branch --show-current 2>/dev/null)
    STAGED=$(git -C "${DIR}" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git -C "${DIR}" diff --numstat 2>/dev/null | wc -l | tr -d ' ')

    GIT_INDICATORS=""
    [ "${STAGED}"   -gt 0 ] && GIT_INDICATORS="${GREEN}+${STAGED}${RESET}"
    [ "${MODIFIED}" -gt 0 ] && GIT_INDICATORS="${GIT_INDICATORS} ${YELLOW}~${MODIFIED}${RESET}"

    BRANCH_SEGMENT=" | ${BRANCH}${GIT_INDICATORS:+ ${GIT_INDICATORS}}"
fi

printf '%b\n' "${CYAN}[${MODEL}${EFFORT:+ · ${EFFORT}}]${RESET}  ${NAME}${BRANCH_SEGMENT}${PEER:+ | ✉ ${PEER}}"

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

# Prompt cache: expiry clock time while warm, recache cost once cold.
# The statusline doesn't refresh while idle, so expiry is checked against the clock.
# prompt_cache is null until the session makes a request (e.g. right after --resume),
# so fall back to the last response recorded in the transcript.
CACHE_EXP=""
CACHE_TOKENS=0
if [ "$(echo "$input" | jq '.prompt_cache != null')" = "true" ]; then
    read -r CACHE_EXP CACHE_TOKENS < <(echo "$input" | jq -r '.prompt_cache |
        "\(if .warm then .expires_at // 0 else 0 end) \(.recache_tokens_if_cold // 0)"')
elif [ -f "${TRANSCRIPT}" ]; then
    read -r CACHE_EXP CACHE_TOKENS < <(tac "${TRANSCRIPT}" | jq -rn '
        first(inputs | select(.type == "assistant" and .message.usage)) |
        .message.usage as $u |
        (.timestamp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) as $ts |
        (if ($u.cache_creation.ephemeral_5m_input_tokens // 0) > 0 then 300 else 3600 end) as $ttl |
        "\($ts + $ttl) \($u.input_tokens + $u.cache_creation_input_tokens + $u.cache_read_input_tokens)"
    ' 2>/dev/null)
fi

CACHE_SEG=""
if [ -n "${CACHE_EXP}" ]; then
    if [ "${CACHE_EXP}" -gt "$(date +%s)" ]; then
        CACHE_SEG=" | cache →$(date -d "@${CACHE_EXP}" +%H:%M)"
    else
        if   [ "${CACHE_TOKENS}" -ge 1000000 ]; then TOKENS=$(awk "BEGIN{printf \"%.1fM\", ${CACHE_TOKENS}/1000000}")
        elif [ "${CACHE_TOKENS}" -ge 1000 ];    then TOKENS="$((CACHE_TOKENS / 1000))k"
        else                                         TOKENS="${CACHE_TOKENS}"
        fi
        CACHE_SEG=" | ${ICE}󰜗 cache cold (${TOKENS})${RESET}"
    fi
fi

printf '%b\n' "Ctx: ${BAR_COLOR}${BAR}${RESET} ${CTX_PCT}% ${FIVE_SEG}${SEVEN_SEG}${CACHE_SEG}"
