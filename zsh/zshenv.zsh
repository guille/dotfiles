###
# Modifying enviroment variables

[[ -f "$HOME/.zvars" ]] && . "$HOME/.zvars"

# Dedupe PATH. Only array assignments (path=...) dedupe, PATH=... does not
typeset -U path

export TERMINAL="ghostty"
export EDITOR="subl -w"

path=(~/mybin $path)
path=(~/.local/bin $path)
if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
	path=(/usr/local/opt/libpq/bin $path)
fi
path=(${KREW_ROOT:-$HOME/.krew}/bin $path)

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

export OPENCODE_DISABLE_LSP_DOWNLOAD=true
export CARGO_NET_GIT_FETCH_WITH_CLI=true

export GOPRIVATE="go.guillerg.dev/arca"

# export DOTNET_CLI_TELEMETRY_OPTOUT=1

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
[[ -f ~/.zshenv.$HOST ]] && source ~/.zshenv.$HOST
