# Load shims and general env for Sublime Text
if [[ -o login ]]; then
    eval "$(mise activate zsh --shims)"
    set -a
    eval "$(mise env -s zsh)"
    set +a
fi

export XDG_CONFIG_HOME="$HOME/.config"

# Can't be in zshenv because macOS is stupid
# https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
    path=(/usr/local/opt/util-linux/bin $path)
    path=(/usr/local/opt/util-linux/sbin $path)
    path=(/usr/local/bin $path)
fi

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    exec start-hyprland
fi
