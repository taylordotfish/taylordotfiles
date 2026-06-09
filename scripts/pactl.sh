#!/bin/sh
set -euf
dir=$(dirname -- "$0")
if [ -f "$dir"/pactl.pre.sh ]; then
    . "$dir"/pactl.pre.sh
fi

sink=$(pactl list short sinks |
    grep -vE '(^|[^A-Za-z0-9])module-(jack|null)-' |
    tail -n1 |
    cut -f1)
if [ -n "$sink" ]; then
    exec pactl "$1" "$sink" "$2"
fi

if [ "$(command -v amixer_sset)" = amixer_sset ]; then
    if [ "$1" = "set-sink-volume" ]; then
        unset -v volume
        case "$2" in
            *[!0-9%+-]*) ;;
            +*%) volume=${2#+}+ ;;
            -*%) volume=${2#-}- ;;
            *%) volume=$2 ;;
        esac
        if [ -n "${volume-}" ]; then
            amixer_sset "$volume"
            exit
        fi
    elif [ "$1" = "set-sink-mute" ]; then
        unset -v param
        case "$2" in
            0) param=unmute ;;
            1) param=mute ;;
            toggle) param=toggle ;;
        esac
        if [ -n "${param-}" ]; then
            amixer_sset "$param"
            exit
        fi
    fi
fi
printf >&2 '%s\n' "error: no sinks available"
exit 1
