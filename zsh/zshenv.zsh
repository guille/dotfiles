###
# Modifying enviroment variables

[[ -f "$HOME/.zvars" ]] && . "$HOME/.zvars"

export TERMINAL="ghostty"
export EDITOR="subl -w"

export PATH=~/mybin:$PATH # Add scripts

[[ ! -f ~/.zshenv.local ]] || source ~/.zshenv.local
