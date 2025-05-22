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
    status=$?
    if [ "$status" -ne 0 ]; then
        printf >&2 '%s\n' "x11vnc exited with status $status"
    fi
    printf >&2 '%s\n' "Restarting..."
    sleep 4
done
