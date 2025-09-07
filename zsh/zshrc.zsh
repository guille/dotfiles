# Prompt is powerlevel10k: see https://github.com/romkatv/powerlevel10k

if [[ "${DOTFILES_OS:-}" == "Linux" ]]; then
	check_pacman() {
		local seconds_since_pacman=$(expr $(date +"%s" ) - $(tail /var/log/pacman.log -n1 | awk '{print substr($1, 2, 24)}'  | xargs date +"%s" -d))
		local days_since_pacman=$(expr $seconds_since_pacman / 86400)
		if [[ $days_since_pacman -ge 6 ]]; then
			echo "Days since last pacman run: ${days_since_pacman}"
		fi
	}
	check_pacman
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval "$(mise activate zsh)"

autoload -U compinit
compinit

# Splits words at / too, useful for paths
autoload -U select-word-style
select-word-style bash

# fzf-tab: https://github.com/Aloxaf/fzf-tab/wiki/
source ~/.fzf-tab/fzf-tab.plugin.zsh
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format ' [%d]'
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-bindings 'tab:toggle' 'ctrl-a:toggle-all'
zstyle ':fzf-tab:*' prefix '> '
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:*' fzf-min-height 100
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# fzf-tab previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always $realpath'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:pacman:*' fzf-preview 'pacman -Si $word'

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# Autocomplete on cd ..
zstyle ':completion:*' special-dirs true
# Nicer than "--"
zstyle ':completion:*' list-separator ' =>'

# only without fzf-tab
# Menu pops at 5 entries
# zstyle ':completion:*' menu select=5


unsetopt beep
# emacs mode
bindkey -e
# Disable ctrl s
unsetopt flowcontrol

# Sane history defaults
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=$HISTSIZE
setopt histignoredups
setopt share_history

if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
	export WORDCHARS=''
fi

##################################

# Map compose key in X11
if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$DISPLAY" ]; then
	setxkbmap -option compose:menu
fi

[[ -f "$HOME/.zkeys" ]] && . "$HOME/.zkeys"
[[ -f "$HOME/.zaliases" ]] && . "$HOME/.zaliases"

source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_ALT_C_COMMAND='fd --type d'
export FZF_ALT_C_OPTS="--preview 'eza -1 --icons=always --color=always {}'"
export FZF_CTRL_T_COMMAND="fd --strip-cwd-prefix"
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
eval "$(zoxide init zsh)"

# Won't work in MacOS / Mandoc: https://github.com/sharkdp/bat/issues/1145
if [[ "${DOTFILES_OS:-}" == "Linux" ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export MANROFFOPT="-c"
fi

# To customize prompt, edit dots/p10k
source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.p10k.mise.zsh ]] || source ~/.p10k.mise.zsh
