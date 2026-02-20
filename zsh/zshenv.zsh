###
# Modifying enviroment variables

[[ -f "$HOME/.zvars" ]] && . "$HOME/.zvars"

export TERMINAL="ghostty"
export EDITOR="subl -w"

export PATH=~/mybin:$PATH
export PATH=~/.local/bin:$PATH
if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
	export PATH="/usr/local/opt/libpq/bin:$PATH"
fi

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

# export DOTNET_CLI_TELEMETRY_OPTOUT=1

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
[[ -f ~/.zshenv.$(hostname) ]] && source ~/.zshenv.$(hostname)
