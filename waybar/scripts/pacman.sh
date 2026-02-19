#!/usr/bin/env bash

if ! type pacman &> /dev/null; then
	exit 1
fi

count=$(checkupdates | wc -l)
if [ "$count" -ne 0 ]; then
	echo "$count"
fi
