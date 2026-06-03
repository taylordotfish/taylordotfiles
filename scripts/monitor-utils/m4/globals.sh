#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac
exec "$dir"/../globals.sh -r 'to_entries
    | map("define(`GLOBAL_MONITOR_"
        + (.key | ascii_upcase)
        + "\u0027, `"
        + (.value | tostring | gsub("[`\u0027]"; ""))
        + "\u0027)dnl")
    | join("\n")'
