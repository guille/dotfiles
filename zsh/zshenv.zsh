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
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

export OPENCODE_DISABLE_LSP_DOWNLOAD=true
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# export DOTNET_CLI_TELEMETRY_OPTOUT=1

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
[[ -f ~/.zshenv.$(hostname) ]] && source ~/.zshenv.$(hostname)
