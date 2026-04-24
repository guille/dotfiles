#!/usr/bin/env bash

# SELinux fix:
# sudo chmod o+r  /usr/lib/sysimage/libdnf5/*.toml
count=$(dnf check-update -q | grep -c "^[a-z0-9]")

if [ "$count" -ne 0 ]; then
	echo "$count"
fi
