#!/usr/bin/env bash

# Fails when offline, or if /usr/lib/sysimage/libdnf5/*.toml aren't world-readable
# (root ran dnf with a restrictive umask). Errors print nothing until the next run.
updates=$(dnf check-update -q 2>/dev/null)
if [ $? -eq 100 ]; then
	grep -c "^[a-z0-9]" <<< "$updates"
fi
