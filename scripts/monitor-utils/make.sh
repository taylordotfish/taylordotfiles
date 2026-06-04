#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
stale=${MONITORS_STALE-}
verbose=${MONITORS_VERBOSE-}
unset -v MONITORS_STALE
unset -v MONITORS_VERBOSE

case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac
cache=~/.cache/monitor-utils
# Test first to avoid forking.
if ! [ -e "$cache" ]; then
    mkdir -p -- "$cache"
fi

set --
if [ -n "$stale" ]; then
    set -- -B
elif stamp_time=$(date -r "$cache"/screens.stamp '+%s' 2> /dev/null) &&
    [ "$(($(date '+%s') - stamp_time))" -le 2 ]
then
    set -- -o screens-outdated
fi
if [ -z "$verbose" ]; then
    set -- "$@" -s
fi
exec flock -- "$cache"/make.lock make -C "$dir/detail" -f make.mk "$@"
