#!/bin/sh
set -eu
sink="$(pactl list short sinks | tail -1 | cut -f1)"
if [ -z "$sink" ]; then
    echo >&2 "error: no sinks available"
    exit 1
fi
pactl "$1" "$sink" "$2"
