#!/bin/sh
set -euf
pointer="1 2 3"
[ -z "${LEFT_MOUSE-}" ] || pointer=$(rev "$pointer")
xmodmap -e "pointer = $pointer" > /dev/null 2>&1
