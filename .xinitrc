#!/bin/sh
set -eu

DEFAULT_TARGET=i3

if which i3 > /dev/null; then
    start_i3() {
        ~/.config/i3/generate.sh
        prepare_desktop
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
    [ -f ~/.xprofile ] && . ~/.xprofile
}

prepare_desktop() {
    ~/.config/dunst/generate.sh
    dbus-update-activation-environment --all
    dbus-update-activation-environment --systemd DISPLAY
    systemctl --user import-environment DISPLAY
    systemctl --user start dunst || true
    prepare_session
}

target=$DEFAULT_TARGET
[ $# -ge 1 ] && target=$1
"start_$target"
