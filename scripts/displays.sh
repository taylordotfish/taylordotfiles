#!/bin/sh
set -eu

printf > ~/.config/monitordef '%s=\n \' monitordef_names monitordef_properties

define_monitor() {
    local name=$1
    local properties=${2:--}
    local escape='s/\\/\\\\/g;s/"/\\"/g'
    local fmt='monitordef_names="${monitordef_names:+$monitordef_names\t}%s"\n'
    fmt="$fmt"'monitordef_properties="${monitordef_properties:+'
    fmt="$fmt"'$monitordef_properties\t}%s"\n'
    printf >> ~/.config/monitordef "$fmt" \
        "$(printf '%s' "$name" | sed "$escape")" \
        "$(printf '%s' "$properties" | sed "$escape")"
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
