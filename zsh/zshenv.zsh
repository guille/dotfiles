###
# Modifying enviroment variables

[[ -f "$HOME/.zvars" ]] && . "$HOME/.zvars"

export TERMINAL="ghostty"
export EDITOR="subl -w"

export PATH=~/mybin:$PATH # Add scripts
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

[[ ! -f ~/.zshenv.local ]] || source ~/.zshenv.local
