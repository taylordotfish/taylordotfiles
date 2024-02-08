#!/bin/sh
set -eu
. ~/scripts/monitor-utils.sh
IFS='
'
set -f
for line in $(monitors); do
    [ -n "${newline-}" ] && printf '\n'
    name=$(printf '%s\n' "$line" | cut -f6)
    properties=$(printf '%s\n' "$line" | cut -f8)
    prop_mono=
    prop_hidpi=
    printf '%s\n' "$properties" | grep '\bmono\b' > /dev/null && prop_mono=1
    printf '%s\n' "$properties" | grep '\bhidpi\b' > /dev/null && prop_hidpi=1
    m4 -D MONITOR_NAME="$name" -D MONITOR_MONO="$prop_mono" \
        -D MONITOR_HIDPI="$prop_hidpi" bar.m4
    newline=1
done
