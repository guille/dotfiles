#!/usr/bin/env bash

if dunstctl is-paused --exit-code; then
	count=$(dunstctl count waiting)
	disabled_text=" "
	if [ "$count" != 0 ]; then
		disabled_text=" $count"
	fi
	echo "$disabled_text"
else
	echo ""
	# echo " "
fi
