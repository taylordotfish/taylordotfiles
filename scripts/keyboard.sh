#!/bin/sh
set -euf
xset r rate 200 30
if [ -x ~/.xkb/setmap.sh ]; then
    ~/.xkb/setmap.sh
fi
