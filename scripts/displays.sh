#!/bin/sh
# Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

mkdir -p ~/.cache/monitor-utils
> ~/.cache/monitor-utils/defs

define_monitor() {
    local name=$1
    local properties=${2:--}
    printf >> ~/.cache/monitor-utils/defs '%s\t%s\n' "$name" "$properties"
}

if command -v hsetroot > /dev/null; then
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

if cat ~/.config/color.jcnf 2> /dev/null | grep -q .; then
    set -- dispwin-quiet
    command -v "$1" > /dev/null || set -- dispwin
    "$1" -L || true
fi

if { command -v picom && ! pgrep '^picom$'; } > /dev/null; then
    picom_args=
    if ! picom --version | awk -F'[^0-9]+' '{
        for (i = 1; i <= NF; ++i) {
            if ($(i) != "") {
                exit $(i) >= 10 ? 0 : 1
            }
        }
    }'; then
        picom_args="$picom_args --experimental-backends"
    fi
    picom $picom_args > /dev/null 2>&1 &
fi
