#!/bin/sh
# Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

default_target=i3

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

ensure_installed() {
    if ! command -v "$1" > /dev/null; then
        printf >&2 '%s\n' "error: missing $1"
        exit 1
    fi
}

start_i3() {
    ensure_installed i3
    prepare_desktop
    ~/.config/i3/generate.sh
    exec i3
}

start_xfce() {
    ensure_installed xfce4-session
    prepare_desktop
    exec xfce4-session
}

start_gnome() {
    ensure_installed gnome-session
    prepare_desktop
    exec gnome-session
}

start_windowmaker() {
    ensure_installed wmaker
    prepare_desktop
    exec wmaker
}

start_lock() {
    NOXCAPE=1 NOSRVRKEYS=1 ~/.xkb/setmap.sh
    if [ -n "${MONOCHROME-}" ]; then
        local color=ffffff
    else
        local color=000000
    fi
    exec i3lock -c "$color" -n
}

target=${XSESSION_TARGET:-$default_target}
case "$target" in
    i3|xfce|gnome|windowmaker|lock) ;;
    *)
        printf >&2 '%s\n' "unknown target: $target"
        exit 1
        ;;
esac
"start_$target"
