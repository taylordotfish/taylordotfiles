#!/bin/sh
set -euf
mtime=$(date -r "$1" '+%s')
unset tmp

on_exit() {
    local status=$?
    [ -z "${tmp-}" ] || rm -f "$tmp"
    exit "$status"
}

trap on_exit HUP INT QUIT TERM EXIT
tmp=$(mktemp)
cp -T -- "$1" "$tmp"
sed -- '/\.end$/,/\.start$/d; /\.start$/d' "$tmp" > "$1"
touch -d "@$((mtime+1))" -- "$1"
