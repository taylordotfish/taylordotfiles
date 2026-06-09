#!/bin/sh
set -euf
dir=$(dirname -- "$0")
for script in keyboard.sh mouse.sh; do
    script=$dir/$script
    if [ -x "$script" ]; then
        "$script"
    fi
done
