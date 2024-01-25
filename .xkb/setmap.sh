#!/bin/sh
# Copyright (C) 2023-2024 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -eu

cd "$(dirname "$0")"
[ -f layout.conf ] || echo us > layout.conf
layout=$(cat layout.conf | grep -o '^\w\+' | head -1)

xkb_args=
xcape_map=
if [ -n "${NOSRVRKEYS-}" ]; then
    xkb_args="$xkb_args -option srvrkeys:none"
fi

setxkbmap "-I$HOME/.xkb" \
    -rules local \
    -option compose:menu \
    -option compose:rwin \
    -option local \
    $xkb_args \
    -layout "$layout" \
    -print > .keymap.xkb

run_verbose() {
    xkbcomp "-I$HOME/.xkb" .keymap.xkb "$DISPLAY"
    if [ -z "${NOXCAPE-}" ]; then
        killall xcape || true
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
