#!/bin/sh
set -euf
dir=${0%.*}
name=${dir##*/}
if ! make -C "$dir" -s; then
    printf >&2 '%s\n' "error building $name"
    exit 1
fi
exec "$dir/$name" "$@"
