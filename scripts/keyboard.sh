#!/bin/sh
set -euf
xset r rate 200 30
[ -f ~/.xkb/setmap.sh ] && ~/.xkb/setmap.sh
