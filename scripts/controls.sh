#!/bin/sh
set -euf
for script in keyboard.sh mouse.sh; do
    script=$(dirname "$0")/$script
    if [ -x "$script" ]; then
        "$script"
    fi
done
