#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac

use_local=false
i=0
for arg do
    case "$arg" in
        --local) use_local=true ;;
        -*) ;;
        *) break ;;
    esac
    : $((i += 1))
done
shift "$i"
if [ "$#" -eq 0 ]; then
    printf >&2 '%s\n' "select.sh: missing argument"
    exit 1
fi
filter=$1

set -- --argjson use_local "$use_local"
exec "$dir"/../monitors.sh -r "$@" "map(select($filter))[0]"'
    // ("select.sh: no such monitor\n" | halt_error(1))
    | to_entries
    | if $use_local then
        map("local monitor_" + .key)
    else
        []
    end + map("monitor_" + .key + "=" + ((.value // "") | @sh))
    | join("\n")'
