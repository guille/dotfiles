#!/usr/bin/env bash

if type "nxcli" &> /dev/null; then
	nxcli status 2>/dev/null | grep -qi disconnected || echo "󰖂 "
fi
