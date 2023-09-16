#!/bin/bash
set -euo pipefail
DEFAULT_TARGET=i3

if which i3 > /dev/null; then
    start-i3() {
        ~/.config/i3/generate.sh
        prepare-desktop
        exec i3
    }
fi

if which xfce4-session > /dev/null; then
    start-xfce() {
        prepare-desktop
        exec xfce4-session
    }
fi

if which gnome > /dev/null; then
    start-gnome() {
        prepare-desktop
        exec gnome-session
    }
fi

if which wmaker > /dev/null; then
    start-windowmaker() {
        prepare-desktop
        exec wmaker
    }
fi

start-lock() {
    NOXCAPE=1 NOSRVRKEYS=1 ~/.xkb/setmap.sh
    if [ -n "${MONOCHROME:-}" ]; then
        local color=ffffff
    else
        local color=000000
    fi
    exec i3lock -c "$color" -n
}

prepare-session() {
    [ -f ~/.xprofile ] && source ~/.xprofile
}

prepare-desktop() {
    ~/.config/dunst/generate.sh
    dbus-update-activation-environment --all
    dbus-update-activation-environment --systemd DISPLAY
    systemctl --user import-environment DISPLAY
    systemctl --user start dunst || true
    prepare-session
}

target=$DEFAULT_TARGET
[ $# -ge 1 ] && target=$1
"start-$target"
