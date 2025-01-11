#!/bin/sh
set -euf
while true; do
    x11vnc -localhost \
        -forever \
        -rfbauth ~/.vnc/passwd \
        -rfbport 5901 \
        -display "${DISPLAY:-:0}" \
        -noxdamage \
        "$@" && true
    printf >&2 '%s\n' "Restarting..."
    sleep 4
done
