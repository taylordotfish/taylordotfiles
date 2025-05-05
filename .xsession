#!/bin/sh
# Copyright (C) 2023-2024 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

DEFAULT_TARGET=i3

if which i3 > /dev/null; then
    start_i3() {
        prepare_desktop
        ~/.config/i3/generate.sh
        exec i3
    }
fi

if which xfce4-session > /dev/null; then
    start_xfce() {
        prepare_desktop
        exec xfce4-session
    }
fi

if which gnome-session > /dev/null; then
    start_gnome() {
        prepare_desktop
        exec gnome-session
    }
fi

if which wmaker > /dev/null; then
    start_windowmaker() {
        prepare_desktop
        exec wmaker
    }
fi

start_lock() {
    NOXCAPE=1 NOSRVRKEYS=1 ~/.xkb/setmap.sh
    if [ -n "${MONOCHROME-}" ]; then
        local color=ffffff
    else
        local color=000000
    fi
    exec i3lock -c "$color" -n
}

prepare_session() {
    if [ -f ~/.xprofile ]; then
        . ~/.xprofile
    fi
}

prepare_desktop() {
    prepare_session
    ~/.config/dunst/generate.sh
    systemctl --user start dunst || true
    if { command -v lxpolkit && ! pgrep -x lxpolkit; } > /dev/null; then
        lxpolkit &
    fi
}

target=${1-$DEFAULT_TARGET}
"start_$target"
