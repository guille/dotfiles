if [[ "${DOTFILES_OS:-}" == "Linux" ]]; then
	# Pacman
	alias paci='sudo pacman -S'
	alias pacu='sudo pacman -Syu'
	alias pacuw='sudo pacman -Syuw'
	alias pacc='paccache -rk 1 && paccache -ruk0 && sudo pacman -Rns $(pacman -Qtdq)'

	# Wayland focus activation :(
	# https://github.com/sublimehq/sublime_text/issues/6236#issuecomment-2219709650
	# https://bugs.kde.org/show_bug.cgi?id=442265
	# https://github.com/swaywm/sway/pull/8017#issuecomment-1972210180
	subl() {
		command subl "$@"
		swaymsg '[app_id="sublime_text"] focus'
	}
	xdg-open() { swaymsg exec xdg-open "$(printf ' %q' "$@")" }

	# Notifications
	alias dnd='notify-send "DUNST_COMMAND_PAUSE"'
	alias dnd-='notify-send "DUNST_COMMAND_RESUME"'
fi

if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
	# Force of habit
	alias pidof='pgrep'
fi

# https://unix.stackexchange.com/questions/148545/why-does-sudo-ignore-aliases
alias sudo='sudo '

alias resource='source ~/.zshrc && source ~/.zshenv'

# Terminal: better defaults
alias cal='cal --monday --three'
alias calc='bc --quiet --mathlib'
alias diff='diff --ignore-all-space --unified --color=auto'
alias df='df -hT'
alias du='du --human-readable'
alias grep='grep --color=auto'
alias imv='imv-dir'
alias not='\rg --smart-case -v'
alias pgrep='pgrep -l'
alias rg='rg -n --smart-case'
alias vim='nvim'
alias top='htop'
alias cat="bat"
# eza
alias ls='eza --icons=auto --color=auto --group-directories-first'
alias ll='eza --icons=auto --color=auto --group-directories-first -l'
alias la='eza --icons=auto --color=auto --group-directories-first -a'
alias lsd='eza --icons=auto --color=auto -D'
alias lla='eza --icons=auto --color=auto --group-directories-first -la'
alias laa='eza --icons=auto --color=auto --group-directories-first -la'

# Nicer help texts with bat
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# ripgrep with preview, open selected matches in sublime
rgp() {
	rg -o --vimgrep "$@" | awk -F: '{print $1":"$2}' | fzf -m --delimiter=: --preview "fzf-bat-preview {1} {2}" --preview-window='right:70%' | xargs subl
}

awsp() {
	[[ ! -f ~/.aws/config ]] && echo "No aws config file found" && return 1

	# Use fzf for profile selection, aws CLI is VERY slow so just grep the config
	selected_profile=$(rg profile ~/.aws/config | awk '{print substr($2, 1, length($2)-1)}' | fzf -1 --prompt="AWS Profile: ")

	if [ "$selected_profile" ]; then
		export AWS_PROFILE="$selected_profile"
	else
		echo "Unsetting profile"
		unset AWS_PROFILE
	fi
}

alias docclean='docker ps -aq | xargs -I "{}" bash -c "docker rm --force {}"'

# Cleans branches that were tracking a remote that has been deleted
alias _gitpruneo='git remote prune origin || true'
alias gitbclean="_gitpruneo && git branch -r | awk '{print \$1}' | \egrep -v -f /dev/fd/0 <(git branch -vv | \grep origin) | awk '{print \$1}' | xargs git branch -D"

# Go to the root of git directory
groot() {
	if git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
		pushd "${git_root}"
	fi
}

alias x="mise x --"

alias yt-dlp="yt-dlp --downloader aria2c --output '%(title)s.%(ext)s' --restrict-filenames"
dl() { tv --no-auto -d "$*" }
ytmp3() { yt-dlp --extract-audio --audio-format mp3 "$*" }
music() {
	mpc play -q
	ncmpcpp -q 2>/dev/null
	mpc pause -q
}

untilok() { until $@; do :; done }
untilfail() { while $@; do :; done }

command_exists() {
	type "$1" &> /dev/null ;
}

[[ ! -f ~/.zaliases.local ]] || source ~/.zaliases.local
