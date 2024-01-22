#!/bin/sh
set -eu

define_monitor_order() {
    local indices=
    local names=
    local tab=$(printf '\t')
    local def
    for def in "$@"; do
        if ! local match=$(xrandr --listactivemonitors |
            sed -n 's/^\s*\([0-9]*:\).* \([^ ]*\)$/\1\2/p' |
            grep ":$def$"
        ); then
            echo >&2 "Could not find monitor: $def"
            return 1
        fi
        indices="${indices:+$indices$tab}$(printf '%s' "$match" | cut -d: -f1)"
        names="${names:+$names$tab}$(printf '%s' "$match" | cut -d: -f2)"
    done
    local escape='s/\\/\\\\/g;s/"/\\"/g'
    printf > ~/.config/monitor-order \
        'monitor_indices="%s"\nmonitor_names="%s"\n' \
        "$(printf '%s' "$indices" | sed "$escape")" \
        "$(printf '%s' "$names" | sed "$escape")"
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
