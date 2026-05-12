#!/usr/bin/env bash

if command -v "nxcli" &> /dev/null; then
	if nxcli status -f 2>/dev/null | jq empty >/dev/null 2>&1; then
		echo "󰖂 "
	else
		echo ""
	fi
fi
