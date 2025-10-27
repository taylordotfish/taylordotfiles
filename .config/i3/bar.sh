#!/bin/sh
set -euf
IFS='
'
first=1
for line in $(~/scripts/monitor-utils.sh monitors); do
    [ -n "${first}" ] || printf '\n'
    name=$(printf '%s\n' "$line" | cut -f6)
    priority=$(printf '%s\n' "$line" | cut -f7)
    properties=$(printf '%s\n' "$line" | cut -f8)
    case ",$properties," in
        *,mono,*) prop_mono=1 ;;
        *) prop_mono= ;;
    esac
    case ",$properties," in
        *,hidpi,*) prop_hidpi=1 ;;
        *) prop_hidpi= ;;
    esac
    m4 -D MONITOR_NAME="$name" \
        -D MONITOR_PRIORITY="$priority" \
        -D MONITOR_MONO="$prop_mono" \
        -D MONITOR_HIDPI="$prop_hidpi" \
        bar.m4
    first=
done
