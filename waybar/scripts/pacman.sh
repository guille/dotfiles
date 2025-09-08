#!/usr/bin/env bash

count=$(checkupdates | wc -l)
if [ "$count" -ne 0 ]; then
	echo "$count"
fi
