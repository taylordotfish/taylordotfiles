#!/bin/sh
set -euf
xset r rate 200 30
[ -x ~/.xkb/setmap.sh ] && ~/.xkb/setmap.sh
