# Prompt is powerlevel10k: see https://github.com/romkatv/powerlevel10k

# ════════════════════ Pacman reminder ════════════════════

if type pacman &> /dev/null; then
	check_pacman() {
		local seconds_since_pacman=$(expr $(date +"%s" ) - $(tail /var/log/pacman.log -n1 | awk '{print substr($1, 2, 24)}'  | xargs date +"%s" -d))
		local days_since_pacman=$(expr $seconds_since_pacman / 86400)
		if [[ $days_since_pacman -ge 6 ]]; then
			echo "Days since last pacman run: ${days_since_pacman}"
		fi
	}
	check_pacman
fi

# ══════════════════ p10k instant prompt ══════════════════

# Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ══════════════════════ zsh options ══════════════════════

# Splits words at / too, useful for paths
autoload -U select-word-style
select-word-style bash

# Random stupid stuff I have to deal with in macOS
if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
	export WORDCHARS=''
	# Move prepended Homebrew's fpath to the end: https://github.com/orgs/Homebrew/discussions/2797
	fpath=(${fpath[@]:1} $fpath[1])
	fpath=($fpath $(brew --prefix)/share/zsh-completions)
fi

bindkey -e            # emacs mode
unsetopt beep         # Disable console beeps
unsetopt flowcontrol  # Disable ctrl s

# Sane history defaults
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=$HISTSIZE
setopt share_history       # Share history among other zsh sessions
setopt hist_ignore_dups    # Don't record an event that was just recorded
setopt hist_ignore_space   # Don't record events starting with a space

# ════════════════════ zsh completions ════════════════════

autoload -U compinit
compinit

# fzf-tab: https://github.com/Aloxaf/fzf-tab/wiki/
source ~/.fzf-tab/fzf-tab.plugin.zsh
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-bindings 'tab:toggle' 'ctrl-a:toggle-all'
zstyle ':fzf-tab:*' prefix '> '
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:*' fzf-min-height 100
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-flags '--info=hidden'

# fzf-tab previews
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --icons=always --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always $realpath'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:pacman:*' fzf-preview 'pacman -Si $word'

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# Menu pops at 5 entries
# zstyle ':completion:*' menu select=5
# Show group descriptions
zstyle ':completion:*:descriptions' format ' [%d]'
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# Case insensitive completion, with substring matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
# Autocomplete on cd ..
zstyle ':completion:*' special-dirs true
# Nicer than "--"
zstyle ':completion:*' list-separator ' =>'

# ═════════════════════════ tools ═════════════════════════

eval "$(mise activate zsh)"

source <(fzf --zsh)
# Similar to base16-tube
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
 --reverse \
 --border=rounded \
 --header-border=rounded \
 --color=border:#959ca1 \
 --color=bg+:#444444,gutter:#444444,hl:#ffffff \
 --color=fg:#959ca1,header:#959ca1,info:#ffd204,pointer:#85cebc \
 --color=marker:#85cebc,fg+:#e7e7e8,prompt:#ffd204,query:#ffffff,hl+:#ffffff \
"

if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
	COPY_CMD=pbcopy
elif [[ "${DOTFILES_OS:-}" == "Linux" ]]; then
	COPY_CMD=wl-copy
fi

export FZF_DEFAULT_COMMAND='fd --hidden --type f'
# CTRL-R - Paste the selected command from history onto the command-line
export FZF_CTRL_R_OPTS=$'--preview \'echo {}\'
--preview-window down:5:hidden:wrap
--bind \'?:toggle-preview\'
--bind \'ctrl-y:execute-silent(echo -n {2..} | '"$COPY_CMD"$')\'
--header \'> CTRL-Y to copy command into clipboard\n> ? to toggle preview\''
# ALT-C - cd into the selected directory
export FZF_ALT_C_COMMAND='fd --hidden --type d'
export FZF_ALT_C_OPTS="--preview 'eza -1 --icons=always --color=always {}'"
# CTRL-T - Paste the selected files and directories onto the command-line
export FZF_CTRL_T_COMMAND='fd --hidden --strip-cwd-prefix'
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || eza -1 --icons=always --color=always {}"'

eval "$(zoxide init zsh)"
# fuzzy search zoxide from its own db, with full paths (unlike zi)
function zz() {
	local result
	result=$(zoxide query -l --exclude "$(__zoxide_pwd)" | fzf -1 --reverse --inline-info --query "${@:-}" --preview 'eza -1 --icons=always --color=always {}')
	if [[ -n "$result" ]]; then
		z "$result"
	fi
}

# Won't work in MacOS / Mandoc: https://github.com/sharkdp/bat/issues/1145
if [[ "${DOTFILES_OS:-}" == "Linux" ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export MANROFFOPT="-c"
fi

# ══════════════════════ extra files ══════════════════════

[[ -f "$HOME/.zkeys" ]] && . "$HOME/.zkeys"
[[ -f "$HOME/.zaliases" ]] && . "$HOME/.zaliases"

# ════════════════════════ plugins ════════════════════════

# To customize prompt, edit dots/p10k
source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.p10k.mise.zsh ]] || source ~/.p10k.mise.zsh

# Plugins
if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
	source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
	source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ "${DOTFILES_OS:-}" == "Linux" ]]; then
	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,bold"

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

ZSH_HIGHLIGHT_STYLES[arg0]=fg=none,bold
ZSH_HIGHLIGHT_STYLES[function]=fg=none,bold
ZSH_HIGHLIGHT_STYLES[alias]=fg=none,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=40,underline
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=12,bold
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=12
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=12
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=11,bold
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=141

ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=magenta,bold'
