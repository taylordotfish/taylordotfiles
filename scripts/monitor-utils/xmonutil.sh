#!/bin/sh
set -euf
dir=${0%.*}
name=${dir##*/}
# Run `make` only if the binary doesn't exist to avoid the overhead of running
# `make` every time.
if ! [ -e "$dir/$name" ] && ! make -C "$dir" -s; then
    printf >&2 '%s\n' "error building $name"
    exit 1
fi
exec "$dir/$name" "$@"
