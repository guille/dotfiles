#!/usr/bin/env bash

if [[ "$DOTFILES_DISTRO" == "Fedora" ]]; then
	count=$(dnf check-update -q | grep -c "^[a-z0-9]")
elif [[ "$DOTFILES_DISTRO" == "Fedora" ]]; then
	count=$(checkupdates | wc -l)
else
	exit 1
fi

if [ "$count" -ne 0 ]; then
	echo "$count"
fi
