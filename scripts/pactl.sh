#!/bin/sh
set -euf
sink=$(pactl list short sinks | tail -1 | cut -f1)
if [ -n "$sink" ]; then
    exec pactl "$1" "$sink" "$2"
fi
printf >&2 '%s\n' "error: no sinks available"
exit 1
