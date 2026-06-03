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
exec "$dir"/../monitors.sh -r '"__MONITOR_UTILS_TMP_" as $tmp
    | (add | keys_unsorted) as $fields
    | [
        ($fields[] | ascii_upcase | "ifdef(`MONITOR_"
            + .
            + "\u0027, `define(`"
            + $tmp
            + .
            + "\u0027, defn(`MONITOR_"
            + .
            + "\u0027))\u0027)dnl"),
        (.[] | . as $m
            | $fields
            | map("define(`MONITOR_"
                + ascii_upcase
                + "\u0027, `"
                + ($m[.] // "" | tostring | gsub("[`\u0027]"; ""))
                + "\u0027)")
            | join("") + $ARGS.positional[0] + "`\u0027dnl"),
        ($fields[] | ascii_upcase | "ifdef(`"
            + $tmp
            + .
            + "\u0027, `define(`MONITOR_"
            + .
            + "\u0027, defn(`"
            + $tmp
            + .
            + "\u0027))\u0027, `undefine(`MONITOR_"
            + .
            + "\u0027)\u0027)dnl")
    ] | join("\n")
' --args -- "$@"
