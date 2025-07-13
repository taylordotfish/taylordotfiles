#!/bin/sh
# Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

if [ -f "$(dirname "$0")"/monitor-utils.sh ]; then
    . "$(dirname "$0")"/monitor-utils.sh
fi

old_monitors=$(monitors)
mkdir -p ~/.cache/monitor-utils
> ~/.cache/monitor-utils/defs

define_monitor() {
    local name=$1
    local properties=${2:--}
    printf >> ~/.cache/monitor-utils/defs '%s\t%s\n' "$name" "$properties"
}

if [ -f "$(dirname "$0")"/define-monitors.sh ]; then
    . "$(dirname "$0")"/define-monitors.sh
fi

if [ "$(monitors)" != "$old_monitors" ] && pgrep -x i3 > /dev/null; then
    ~/.config/i3/generate.sh
    i3-msg -q reload
fi

if command -v hsetroot > /dev/null; then
    setroot=hsetroot
else
    setroot=xsetroot
fi

if [ -x ~/.fehbg ]; then
    ~/.fehbg
elif [ -n "${MONOCHROME-}" ]; then
    "$setroot" -solid '#ffffff'
else
    "$setroot" -solid '#000000'
fi

if cat ~/.config/color.jcnf 2> /dev/null | grep -q .; then
    set -- dispwin-quiet
    command -v "$1" > /dev/null || set -- dispwin
    "$1" -L || true
fi

if { command -v picom && ! pgrep -x picom; } > /dev/null; then
    "$(dirname "$0")"/picom.sh --daemon
fi
