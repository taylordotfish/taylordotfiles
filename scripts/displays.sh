#!/bin/sh
set -eu

define_monitor_order() {
    indices=
    names=
    for def in "$@"; do
        if ! match=$(xrandr --listactivemonitors |
            sed -n 's/^\s*\([0-9]*:\).* \([^ ]*\)$/\1\2/p' |
            grep ":$def$"
        ); then
            echo >&2 "Could not find monitor: $def"
            return 1
        fi
        indices="${indices:+$indices }$(printf '%s' "$match" | cut -d: -f1)"
        names="${names:+$names }$(printf '%s' "$match" | cut -d: -f2)"
    done
    (
        printf "monitor_indices='%s'"'\n' "$indices"
        printf "monitor_names='%s'"'\n' "$names"
    ) > ~/.config/monitor-order
}

if which hsetroot > /dev/null; then
    setroot=hsetroot
else
    setroot=xsetroot
fi

if [ -f ~/.fehbg ]; then
    ~/.fehbg
elif [ -n "${MONOCHROME-}" ]; then
    "$setroot" -solid '#ffffff'
else
    "$setroot" -solid '#000000'
fi

if (which picom && ! pgrep '^picom$') > /dev/null; then
    picom_args=
    if [ "$(picom --version | sed 's/[^0-9]*\([0-9]\+\).*/\1/')" -lt 10 ]; then
        picom_args="$picom_args --experimental-backends"
    fi
    picom $picom_args > /dev/null 2>&1 &
fi
