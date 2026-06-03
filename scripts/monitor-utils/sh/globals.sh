#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac
use_local=false
for arg do
    case "$arg" in
        --local) use_local=true ;;
    esac
done
exec "$dir"/../globals.sh -r --argjson use_local "$use_local" 'to_entries
    | if $use_local then
        map("local global_monitor_" + .key)
    else
        []
    end + map("global_monitor_" + .key + "=" + ((.value // "") | @sh))
    | join("\n")'
