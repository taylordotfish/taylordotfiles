#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac
cache=~/.cache/monitor-utils
config=~/.config/monitor-utils

if [ -f "$config"/settings.json ]; then
    set -- --slurpfile settings "$config"/settings.json
else
    set -- --argjson settings [{}]
fi

exec jq -c "$@" -f "$dir"/globals.jq -- "$cache"/monitors.json
