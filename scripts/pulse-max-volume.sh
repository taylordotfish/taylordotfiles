#!/bin/sh
set -eu
dir="$(dirname "$0")/pulse-max-volume"
if ! make -C "$dir" -s; then
    printf >&2 '%s\n' "error building $dir/pulse-max-volume"
    exit 1
fi
exec "$dir/pulse-max-volume" "$@"
