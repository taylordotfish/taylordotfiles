#!/bin/sh
set -euf
xset r rate 200 30
if [ -x ~/.config/xkb/setmap.sh ]; then
    ~/.config/xkb/setmap.sh
fi
