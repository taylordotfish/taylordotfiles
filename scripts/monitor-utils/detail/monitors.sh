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

set -- --slurpfile screens "$cache"/screens.json \
    --slurpfile outputs "$cache"/outputs.json
if [ -f "$config"/monitors.json ]; then
    set -- "$@" --slurpfile monitors "$config"/monitors.json
else
    set -- "$@" --argjson monitors '[[]]'
fi
if [ -f "$config"/outputs.json ]; then
    set -- "$@" --slurpfile output_map "$config"/outputs.json
else
    set -- "$@" --argjson output_map '[{}]'
fi

exec jq -cn "$@" -f "$dir"/monitors.jq
