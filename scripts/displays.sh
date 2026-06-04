#!/bin/sh
# Copyright (C) 2023-2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

dir=$(dirname "$0")
wm=$(xprop -root 8s '\n$0\n' XSESSION_TARGET | tail -n+2 | tr -dc A-Za-z0-9_-)

if [ -f "$dir"/init-monitors.sh ]; then
    # Calls to xrandr go in this file
    . "$dir"/init-monitors.sh
fi

run_if_exists() {
    if [ -x "$1" ]; then
        "$@"
    fi
}

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

run_if_exists ~/.config/monitor-utils/generate.sh
eval "$(~/scripts/monitor-utils/sh/globals.sh)"
xrdb ~/.Xresources.m4 -cpp m4

if command -v dunst > /dev/null; then
    run_if_exists ~/.config/dunst/generate.sh
    systemctl --user restart dunst.service
fi

if [ "$wm" = i3 ]; then
    run_if_exists ~/.config/i3/generate.sh
    if pgrep -x i3 > /dev/null && monitors_newer ~/.config/i3/config.m4; then
        i3-msg -q reload
    fi

    if [ "$global_monitor_tech" = epaper ]; then
        setroot -solid '#ffffff'
    else
        setroot -solid '#000000'
    fi
    if ! run_if_exists ~/.fehbg; then
        printf >&2 '%s\n' "warning: failed to run .fehbg"
    fi

    if ! pgrep -x xsettingsd > /dev/null; then
        make_xsettingsd
        xsettingsd &
    elif monitors_newer ~/.xsettingsd.m4; then
        make_xsettingsd
        pkill -x xsettingsd -HUP
    fi

    if { command -v picom && ! pgrep -x picom; } > /dev/null; then
        picom --daemon
    fi
    if [ -f ~/.config/color.jcnf ] && command -v profilectl > /dev/null; then
        profilectl load
    fi
fi
