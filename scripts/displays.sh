#!/bin/sh
# Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

printf > ~/.config/monitordef '%s=\n' monitordef_names monitordef_properties

define_monitor() {
    local name=$1
    local properties=${2:--}
    local escape='s/\\/\\\\/g;s/"/\\"/g'
    local fmt='monitordef_names="${monitordef_names:+$monitordef_names\t}%s"\n'
    fmt="$fmt"'monitordef_properties="${monitordef_properties:+'
    fmt="$fmt"'$monitordef_properties\t}%s"\n'
    printf >> ~/.config/monitordef "$fmt" \
        "$(printf '%s\n' "$name" | sed "$escape")" \
        "$(printf '%s\n' "$properties" | sed "$escape")"
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

if { command -v picom && ! pgrep '^picom$'; } > /dev/null; then
    picom_args=
    if ! awk -F'[^0-9]+' '{
        for (i = 1; i <= NF; ++i) {
            if ($(i) != "") {
                exit $(i) >= 10 ? 0 : 1;
            }
        }
    }'; then
        picom_args="$picom_args --experimental-backends"
    fi
    picom $picom_args > /dev/null 2>&1 &
fi
