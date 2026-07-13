#!/bin/sh
# Copyright (C) 2023-2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
dir=$(dirname "$0")

if [ -f "$dir"/setmap.pre.sh ]; then
    . "$dir"/setmap.pre.sh
fi
# Comma-separated list of XKB layouts; Ctrl+Alt+Space switches between them.
: ${LAYOUTS:=us}

xcape_map=
set --
if [ -n "${NOSRVRKEYS-}" ]; then
    set -- "$@" -option srvrkeys:none
fi

make -sC "$dir"/rules/source

setxkbmap "-I$dir" \
    -rules local \
    -option ctrl:nocaps \
    -option compose:menu \
    -option compose:rwin \
    -option compose:ralt \
    -option local \
    "$@" \
    -layout "$LAYOUTS" \
    -print > "$dir"/.keymap.xkb

run_verbose() {
    xkbcomp "-I$dir" "$dir"/.keymap.xkb "$DISPLAY"
    if [ -z "${NOXCAPE-}" ]; then
        pkill -x xcape || true
    fi
}

if [ -n "${DEBUG-}" ]; then
    run_verbose
else
    run_verbose > /dev/null 2>&1
fi

if [ -z "${NOXCAPE-}" ] && command -v xcape > /dev/null; then
    xcape -e "#66=Escape;#37=Caps_Lock${xcape_map:+;$xcape_map}"
fi
