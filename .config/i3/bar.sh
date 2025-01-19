#!/bin/sh
set -euf
. ~/scripts/monitor-utils.sh
IFS='
'
first=1
for line in $(monitors); do
    [ -n "${first}" ] || printf '\n'
    name=$(printf '%s\n' "$line" | cut -f6)
    properties=$(printf '%s\n' "$line" | cut -f8)
    prop_mono=
    prop_hidpi=
    case ",$properties," in
        *,mono,*) prop_mono=1 ;;
    esac
    case ",$properties," in
        *,hidpi,*) prop_hidpi=1 ;;
    esac
    m4 -D MONITOR_NAME="$name" -D MONITOR_MONO="$prop_mono" \
        -D MONITOR_HIDPI="$prop_hidpi" bar.m4
    first=
done
