#!/bin/sh
# Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
dir=$(dirname "$0")

[ -f "$dir"/layout.conf ] || echo us > "$dir"/layout.conf
layout=$(awk '/./ { print $1; exit }' "$dir"/layout.conf)

xcape_map=
set --
if [ -n "${NOSRVRKEYS-}" ]; then
    set -- "$@" -option srvrkeys:none
fi

if [ -f "$dir"/rules/source/Makefile ]; then
    make --quiet -C "$dir"/rules/source
fi
setxkbmap "-I$HOME/.xkb" \
    -rules 'local' \
    -option compose:menu \
    -option compose:rwin \
    -option compose:ralt \
    -option 'local' \
    "$@" \
    -layout "$layout" \
    -print > "$dir"/.keymap.xkb

run_verbose() {
    xkbcomp "-I$HOME/.xkb" "$dir"/.keymap.xkb "$DISPLAY"
    if [ -z "${NOXCAPE-}" ]; then
        pkill -x xcape || true
    fi
}

if [ -n "${DEBUG-}" ]; then
    run_verbose
else
    run_verbose > /dev/null 2>&1
fi

if [ -z "${NOXCAPE-}" ]; then
    xcape -e "#66=Escape;#37=Caps_Lock${xcape_map:+;$xcape_map}"
fi
