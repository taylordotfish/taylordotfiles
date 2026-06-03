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
exec "$dir"/../monitors.sh -r '"__monitor_utils_foreach_invoke" as $func
    | (add | keys_unsorted) as $fields
    | [
        $func + "() {",
        ($fields | to_entries[] | "  local monitor_"
            + .value
            + "=\"${"
            + (.key + 1 | tostring)
            + "}\""),
        "  shift " + ($fields | length | tostring),
        "  \"$@\"",
        "}",
        (.[] | . as $m
            | $fields
            | map($m[.] // "")
            | . + $ARGS.positional
            | [$func] + map(@sh)
            | join(" "))
    ] | join("\n")
' --args -- "$@"
