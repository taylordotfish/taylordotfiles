#!/bin/sh
set -euf
dir=$(dirname "$0")
cache=~/.cache/monitor-utils
mkdir -p -- "$cache"

tmp=
on_exit() {
    local status="$?"
    trap - HUP INT QUIT TERM EXIT
    if [ -n "$tmp" ]; then
        rm -f -- "$tmp"/settings.json
        rmdir -- "$tmp"
    fi
    exit "$status"
}

trap on_exit HUP INT QUIT TERM EXIT
tmp=$(mktemp -d)

set -- "$dir"/settings.default.json
if [ -f "$dir"/settings.override.json ]; then
    set -- "$@" "$dir"/settings.override.json
fi
jq -cs add -- "$@" > "$tmp"/settings.json
mv -- "$tmp"/settings.json "$dir"/

if [ -f "$dir"/generate.post.sh ]; then
    . "$dir"/generate.post.sh
fi
