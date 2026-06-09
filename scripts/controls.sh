#!/bin/sh
set -euf
dir=$(dirname -- "$0")
if [ -f "$dir"/controls.pre.sh ]; then
    . "$dir"/controls.pre.sh
fi

xset r rate "${keyboard_repeat_delay:-200}" "${keyboard_repeat_rate:-30}"
if [ -x ~/.config/xkb/setmap.sh ]; then
    ~/.config/xkb/setmap.sh
fi

pointer_map="1 2 3"
if [ -n "${left_mouse-}" ]; then
    pointer_map="3 2 1"
fi
output=$(xmodmap -e "pointer = $pointer_map" 2>&1) && true
status=$?
printf '%s\n' "$output" | grep -Ev '^Warning: Only changing the first 3 |^$'
if [ "$status" -ne 0 ]; then
    exit "$status"
fi

if [ -f "$dir"/controls.post.sh ]; then
    . "$dir"/controls.post.sh
fi
