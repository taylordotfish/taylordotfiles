#!/usr/bin/env -S NOTSOURCED=1 /bin/sh -euf
# Copyright (C) 2024 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later

[ -f ~/.config/monitordef ] && . ~/.config/monitordef

monitors() {
    if [ -z "${NOCACHE-}" ]; then
        if [ -f ~/.cache/monitor-utils/monitors ]; then
            def_date=$(date -r ~/.config/monitordef '+%s')
            cache_date=$(date -r ~/.cache/monitor-utils/monitors '+%s')
            if [ "$def_date" -le "$cache_date" ]; then
                cat ~/.cache/monitor-utils/monitors
                return
            fi
        fi

        if [ -d ~/.cache/monitor-utils ]; then
            NOCACHE=1 monitors > ~/.cache/monitor-utils/monitors
            cat ~/.cache/monitor-utils/monitors
        else
            NOCACHE=1 monitors
        fi
        return
    fi

    local monitors=${monitordef_names-}
    local propertydefs=${monitordef_properties-}
    local tab=$(printf '\t')
    local num_defined=$(printf '%s'"${monitors:+\\t}" "$monitors" |
        grep -o "$tab" |
        wc -l
    )
    local script=$(printf '%s' 's/^\s*\([0-9]\+\):\s*\S*\s*' \
        '\([0-9]\+\)[^x]*x\([0-9]\+\)[^+]*' \
        '+\([0-9]\+\)+\([0-9]\+\)\s*\(\S\+\).*' \
        '/\1\t\2\t\3\t\4\t\5\t\6/p'
    )
    local IFS='
'
    local opts=$-
    set -f
    local line
    for line in $(xrandr --listactivemonitors | sed -n "$script"); do
        local name=$(printf '%s\n' "$line" | cut -f6)
        local priority=$(printf '%s\t\n' "$monitors" |
            grep -o "^\(.*$tab\)*$name$tab" |
            grep -o "$tab" |
            wc -l
        )
        if [ "$priority" -eq 0 ]; then
            num_defined=$((num_defined+1))
            priority=$num_defined
        fi
        local properties=$(printf '%s\n' "$propertydefs" | cut -f"$priority")
        properties=${properties:--}
        printf '%s\t%s\t%s\n' "$(printf '%s\n' "$line" | cut -f1-6)" \
            "$priority" "$properties"
    done
    case "$opts" in
        *f*) ;;
        *) set +f ;;
    esac
}

if [ -z "${NOTSOURCED-}" ]; then
    return 0
fi

USAGE="\
Usage: "$(basename "$0")" <command>

Commands:
  monitors  Display a list of all monitors. Fields are: index, width, height,
            pos_x, pos_y, name, priority, properties.
"

case "${1-}" in
    monitors)
        "$1"
        ;;
    -h|--help)
        printf '%s' "$USAGE"
        exit 0
        ;;
    *)
        printf >&2 '%s' "$USAGE"
        exit 1
        ;;
esac
