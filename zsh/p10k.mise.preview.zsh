#!/usr/bin/env zsh
# Print every p10k mise segment the way the prompt draws it.

dir=${0:A:h}
POWERLEVEL9K_MODE=nerdfont-v3  # keep in sync with p10k.zsh
source $dir/powerlevel10k/internal/icons.zsh
_p9k_init_icons
source $dir/p10k.mise.zsh

typeset -A tools
for p in ${(k)parameters[(I)POWERLEVEL9K_MISE_*_(FOREGROUND|BACKGROUND|VISUAL_IDENTIFIER_EXPANSION)]}; do
  tools[${${p#POWERLEVEL9K_MISE_}%_(FOREGROUND|BACKGROUND|VISUAL_IDENTIFIER_EXPANSION)}]=1
done

for t in '' ${(ko)tools}; do
  prefix=POWERLEVEL9K_MISE_${t:+${t}_}
  fg_var=${prefix}FOREGROUND bg_var=${prefix}BACKGROUND icon_var=${prefix}VISUAL_IDENTIFIER_EXPANSION
  fg=${(P)fg_var:-$POWERLEVEL9K_MISE_FOREGROUND}
  bg=${(P)bg_var:-$POWERLEVEL9K_MISE_BACKGROUND}
  # Same lookup as p10k: tool override, then the mise-wide one, expanded with the built-in icon.
  P9K_VISUAL_IDENTIFIER=${(g::)icons[${t}_ICON]}
  exp=${(P)icon_var-${POWERLEVEL9K_MISE_VISUAL_IDENTIFIER_EXPANSION-'${P9K_VISUAL_IDENTIFIER}'}}
  icon=${(e)exp}
  print -P "${(r:22:)${t:l}:-(default)} %K{$bg}%F{$fg} $icon 1.2.3 %k%F{$bg}"$'\ue0bc'"%f"
done
