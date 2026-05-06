#!/usr/bin/env bash

nxcli status 2>/dev/null | grep -qi disconnected || echo "󰖂 "
