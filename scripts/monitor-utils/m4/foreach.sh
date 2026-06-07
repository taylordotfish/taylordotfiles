#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac
if [ "$#" -eq 0 ]; then
    printf >&2 '%s\n' "foreach.sh: missing args"
    exit 1
fi
exec "$dir"/../monitors.sh -r -f "$dir"/detail/foreach.jq --args -- "$@"
