#!/bin/sh
set -eu
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
    picom > /dev/null 2>&1 &
fi
