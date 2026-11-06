#!/usr/bin/env zsh
# Print a swatch for every color state of the enabled p10k segments.

dir=${0:A:h}
source $dir/p10k.zsh
segments=(${(f)"$(grep -o '^prompt_[a-z0-9_]*' $dir/powerlevel10k/internal/p10k.zsh)"})

for seg in $POWERLEVEL9K_LEFT_PROMPT_ELEMENTS $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS; do
  [[ $seg == (newline|mise) ]] && continue  # mise has its own preview
  base=POWERLEVEL9K_${seg:u}
  # Segments like aws_eb_env share our prefix; their colors aren't ours.
  others=(${${(M)segments:#prompt_${seg}_*}#prompt_})
  # States are whatever sits between the segment name and _FOREGROUND/_BACKGROUND.
  typeset -A states=()
  for p in ${(k)parameters[(I)${base}_*(FOREGROUND|BACKGROUND)]}; do
    (( $#others )) && [[ $p == POWERLEVEL9K_(${(j:|:)${others:u}})_* ]] && continue
    s=${${p#${base}}%_(FOREGROUND|BACKGROUND)}
    states[${s#_}]=1
  done
  if (( ! $#states )); then
    print "${(r:40:)seg} (no colors configured)"
    continue
  fi
  for s in "${(@ko)states}"; do
    fg_var=${base}${s:+_$s}_FOREGROUND bg_var=${base}${s:+_$s}_BACKGROUND
    # Fall back to the segment-wide color, like p10k does.
    fg=${(P)fg_var-${(P)${:-${base}_FOREGROUND}}}
    bg=${(P)bg_var-${(P)${:-${base}_BACKGROUND}}}
    label=${seg}${s:+ ${s:l}}
    print -P "${(r:40:)label} %K{${bg:-default}}%F{${fg:-default}} $label  fg=${fg:-∅} bg=${bg:-∅} %k%F{${bg:-default}}"$''"%f"
  done
done
