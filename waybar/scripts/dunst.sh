#!/usr/bin/env bash

if ! dunstctl is-paused --exit-code; then
	echo ""
	exit
fi

count=$(dunstctl count waiting)
disabled_text=" "
if [ "$count" != 0 ]; then
	disabled_text=" $count"
fi
echo "$disabled_text"
