#!/bin/sh
set -uf
while true; do
    x11vnc -localhost \
        -forever \
        -rfbauth ~/.vnc/passwd \
        -rfbport 5901 \
        -display :0 \
        -noxdamage \
        "$@"
    sleep 2
done
