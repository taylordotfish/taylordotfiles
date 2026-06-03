#!/bin/sh
# Copyright (C) 2023-2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

dir=$(dirname "$0")
wm=$(xprop -root 8s '\n$0\n' XSESSION_TARGET | tail -n+2 | tr -dc A-Za-z0-9_-)

monitors_newer() {
    [ ~/.cache/monitor-utils/monitors.json -nt "$1" ]
}

setroot() {
    if command -v hsetroot > /dev/null; then
        hsetroot "$@"
    else
        xsetroot "$@"
    fi
}

make_xsettingsd() {
    {
        printf '%s\n' "# AUTOMATICALLY GENERATED!"
        printf '%s\n\n' "# CHANGES WILL BE LOST!"
        m4 ~/.xsettingsd.m4
    } > ~/.xsettingsd
}

if [ -f "$dir"/init-monitors.sh ]; then
    # Calls to xrandr go in this file
    . "$dir"/init-monitors.sh
fi

eval "$(~/scripts/monitor-utils/sh/globals.sh)"

if [ "$wm" = i3 ]; then
    if pgrep -x i3 > /dev/null && monitors_newer ~/.config/i3/config.m4; then
        ~/.config/i3/generate.sh
        i3-msg -q reload
    fi

    if [ -x ~/.fehbg ] && command -v feh > /dev/null; then
        ~/.fehbg
    elif [ "$global_monitor_tech" = epaper ]; then
        setroot -solid '#ffffff'
    else
        setroot -solid '#000000'
    fi

    if ! pgrep -x xsettingsd; then
        make_xsettingsd
        xsettingsd &
    elif monitors_newer ~/.xsettingsd.m4; then
        make_xsettingsd
        pkill -x xsettingsd -HUP
    fi

    if { command -v picom && ! pgrep -x picom; } > /dev/null; then
        picom --daemon
    fi

    if command -v profilectl > /dev/null &&
        cat ~/.config/color.jcnf 2> /dev/null | grep -q .
    then
        profilectl load
    fi
fi
