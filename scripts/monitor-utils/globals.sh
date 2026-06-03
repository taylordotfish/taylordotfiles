#!/bin/sh
set -euf
case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac
"$dir"/make.sh
cache=~/.cache/monitor-utils/globals.json
if [ "$#" -eq 0 ]; then
    exec cat -- "$cache"
else
    cat -- "$cache" | jq "$@"
fi
