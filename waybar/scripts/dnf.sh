#!/usr/bin/env bash

# Fails if /usr/lib/sysimage/libdnf5/*.toml aren't world-readable, e.g. when
# root ran dnf with a restrictive umask.
updates=$(dnf check-update -q 2>/dev/null)
case $? in
	0) ;;
	100) grep -c "^[a-z0-9]" <<< "$updates" ;;
	*) echo "!" ;;
esac
