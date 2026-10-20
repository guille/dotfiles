#!/usr/bin/env bash
# Number connected monitors left-to-right, flash the number on each screen, and print their details.
# Usage: monitors.sh [--no-flash] [--seconds N]
set -euo pipefail

flash=1
seconds=8
while (($#)); do
    case $1 in
        --no-flash) flash=0 ;;
        --seconds) seconds=$2; shift ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
    shift
done

# Enabled monitors by position, then disabled ones (they can't show a label).
monitors=$(hyprctl monitors all -j | jq '
    (map(select(.disabled | not)) | sort_by(.x, .y)) + map(select(.disabled))
    | to_entries | map(.value + {n: (.key + 1)})')

flash_kitty() {
    local n=$1 name=$2 label=$3
    timeout "$seconds" kitty +kitten panel --output-name "$name" --edge center-sized \
        --layer overlay --focus-policy not-allowed --lines 4 --columns 12 \
        -o font_size=48 -o background_opacity=0.85 \
        sh -c "printf '\e[?25l\n\e[1;33m%7s\e[0m\n\n%s' '$n' '$label'; sleep $seconds" \
        >/dev/null 2>&1 &
}

# A unique --class makes ghostty its own process instead of handing off to its single-instance
# service, so the exec rule can match it. A `monitor` rule would focus that monitor; `workspace … silent` doesn't.
# Ghostty's minimum window size grows with font size, so the font (not a size rule) sets the window size.
flash_ghostty() {
    local n=$1 name=$2 label=$3 ws cmd
    ws=$(jq -r --arg m "$name" '.[] | select(.name == $m) | .activeWorkspace.id' <<<"$monitors")
    cmd="timeout $seconds ghostty --class=dev.monitors.flash.${name//[^A-Za-z0-9]/} --window-decoration=none \
--font-size=28 --background-opacity=0.85 --confirm-close-surface=false \
-e sh -c \"printf '\\033[?25l\\n\\033[1;33m%7s\\033[0m\\n\\n%s' '$n' '$label'; sleep $seconds\""
    hyprctl eval "hl.exec_cmd([[$cmd]], { workspace = '$ws silent', float = true, pin = true, center = true, no_initial_focus = true })" >/dev/null
}

if ((flash)); then
    if command -v kitty >/dev/null; then
        flasher=flash_kitty
    elif command -v ghostty >/dev/null; then
        flasher=flash_ghostty
    else
        echo "note: neither kitty nor ghostty is installed, so no numbers are flashed" >&2
        flash=0
    fi
fi

if ((flash)); then
    jq -r '.[] | select(.disabled | not) | "\(.n)\t\(.name)"' <<<"$monitors" |
        while IFS=$'\t' read -r n name; do
            "$flasher" "$n" "$name" "$(printf '%-12s' "$name" | head -c 12)"
        done
fi

jq -r '.[] |
    (if .transform % 2 == 1 then [.height, .width] else [.width, .height] end) as [$w, $h]
    | (if .physicalWidth > 0 then ((.physicalWidth * .physicalWidth + .physicalHeight * .physicalHeight) | sqrt / 25.4) else null end) as $diag
    | (if .physicalWidth > 0 then (.width / (.physicalWidth / 25.4)) else null end) as $ppi
    | "#\(.n)  \(.name)\(if .disabled then "  (DISABLED)" else "" end)\(if .focused then "  (focused)" else "" end)",
      "    desc:      \(.description)",
      "    mode:      \(.width)x\(.height)@\(.refreshRate * 100 | round / 100)Hz",
      "    position:  \(.x)x\(.y)",
      "    scale:     \(.scale)   transform: \(.transform)",
      "    logical:   \($w / .scale | floor)x\($h / .scale | floor)",
      "    physical:  \(.physicalWidth)x\(.physicalHeight)mm\(if $diag then "  ~\($diag * 10 | round / 10)in  ~\($ppi | round)ppi" else "" end)",
      "    modes:     \(.availableModes | map(capture("(?<r>[0-9]+x[0-9]+)@(?<hz>[0-9.]+)")) | group_by(.r)
                        | map({r: .[0].r, hz: (map(.hz | tonumber) | max)}) | sort_by(.r | split("x") | map(tonumber) | -(.[0] * .[1]))
                        | map("\(.r)@\(.hz)") | join(", "))",
      ""' <<<"$monitors"
