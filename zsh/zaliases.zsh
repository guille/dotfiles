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
	dnd() {
		dunstctl set-paused toggle
		if dunstctl is-paused --exit-code; then
			echo "DND activated"
		else
			echo "DND deactivated"
		fi
	}
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
alias pgrep='pgrep -il'
alias rg='rg -n --smart-case'
alias vim='nvim'
alias top='htop'
alias cat='bat'
alias fd='fd --hidden'
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

# Don't interpret brackets in arguments as glob patterns.
alias bundle='noglob bundle'
alias rake='noglob rake'
# Same for refspec characters (^, @, ~)
alias git='noglob git'

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

awsr() {
	local region=$(echo "eu-west-1\nus-east-1" | fzf --bind=enter:replace-query+print-query)
	if [ "$region" ]; then
		export AWS_REGION="$region"
	fi
}

# Logs in to AWS with SSO, then use credential helper to log into Docker
# Uses AWS_PROFILE from environment or defaults to 'dev-read', exporting it at the end
# Uses AWS_REGION or the default region configured for the profile if unset
awsl() {
	local profile="${AWS_PROFILE:-dev-read}"
	export AWS_PROFILE="$profile"

	aws sso login

	local account_id=$(aws sts get-caller-identity --query Account --output text)
	local region=${AWS_REGION:-$(aws configure get region)}

	aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin "${account_id}.dkr.ecr.${region}.amazonaws.com"
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

pskill() {
	ps -e -o pid,ruser=RealUser,comm=Command,args=Args | fzf \
		--bind 'ctrl-r:reload(ps -e -o pid,ruser=RealUser,comm=Command,args=Args),enter:execute(kill {2})+reload(ps -e -o pid,ruser=RealUser,comm=Command,args=Args)' \
		--header 'Press CTRL-R to reload
		' \
		--header-lines=1 \
		--height=50
}

# Start a program but immediately disown it and detach it from the terminal
function runfree() {
	"$@" > /dev/null 2>&1 & disown
}

alias q='exit'

palette() {
	local -a colors
	for i in {000..255}; do
		colors+=("%F{$i}$i%f")
	done
	print -cP $colors
}

[[ -f ~/.zaliases.local ]] && source ~/.zaliases.local
