# Load shims and general env for Sublime Text
if [[ -o login ]]; then
    eval "$(mise activate zsh --shims)"
    set -a
    eval $(mise env --dotenv)
    set +a
fi

export XDG_CONFIG_HOME="$HOME/.config"

# Can't be in zshenv because macOS is stupid
# https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
if [[ "${DOTFILES_OS:-}" == "OSX" ]]; then
    export PATH="/usr/local/opt/util-linux/bin:$PATH"
    export PATH="/usr/local/opt/util-linux/sbin:$PATH"
    export PATH="/usr/local/bin:$PATH"
fi

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    export ELECTRON_OZONE_PLATFORM_HINT=wayland # run electron apps in wayland mode
    export GTK_IM_MODULE=simple # https://github.com/ghostty-org/ghostty/discussions/8899
    exec sway
fi
