#!/bin/sh
set -euf
cd "$(dirname "$0")"
unset tmp

before_exit() {
    if [ -n "${tmp-}" ]; then
        rm -f "$tmp"
        tmp=
    fi
    trap - INT HUP QUIT TERM EXIT
}

on_exit() {
    local status=$?
    before_exit
    exit "$status"
}

trap on_exit INT HUP QUIT TERM EXIT
tmp=$(mktemp)
cp layout.conf "$tmp"

awk '
    NR == 1 { first = $0; next }
    { print }
    END { print first }
' "$tmp" > layout.conf
before_exit
exec ./setmap.sh
