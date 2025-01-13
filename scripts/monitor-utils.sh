#!/usr/bin/env -S NOTSOURCED=1 /bin/sh -euf
# Copyright (C) 2024-2025 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later

[ -f ~/.config/monitordef ] && . ~/.config/monitordef

monitors() {
    if [ -z "${NOCACHE-}" ]; then
        if [ -f ~/.cache/monitor-utils/monitors ] &&
            [ ~/.cache/monitor-utils/monitors -nt ~/.config/monitordef ]
        then
            cat ~/.cache/monitor-utils/monitors
            return
        fi

        if [ -d ~/.cache/monitor-utils ]; then
            NOCACHE=1 monitors | tee ~/.cache/monitor-utils/monitors
        else
            NOCACHE=1 monitors
        fi
        return
    fi

    local monitors=${monitordef_names-}
    local propertydefs=${monitordef_properties-}
    local num_defined=$(printf '%s\n' "$monitors" | awk -F'\t' '{ print NF }')
    local IFS='
'
    local opts=$-
    set -f
    local line
    for line in $(xrandr --listactivemonitors | awk -vOFS='\t' 'NF >= 4 {
        split($1, a, ":")
        if (length(a) != 2) next
        if (a[1] !~ /^[0-9]+$/) next
        if (a[2] != "") next
        mon_index = a[1]

        split($3, a, "+")
        if (length(a) != 3) next
        if (a[2] a[3] !~ /^[0-9]+$/) next
        mon_posx = a[2]
        mon_posy = a[3]

        split(a[1], a, "x")
        if (length(a) != 2) next
        for (i in a) {
            sub(/[^0-9].*/, "", a[i])
            if (a[i] == "") next
        }
        mon_width = a[1]
        mon_height = a[2]

        mon_name = $4
        print mon_index, mon_width, mon_height, mon_posx, mon_posy, mon_name
    }'); do
        local name=$(printf '%s\n' "$line" | cut -f6)
        local priority=$(printf '%s\n' "$monitors" | awk -F'\n' -vRS='\t' '
            BEGIN { ARGC = 1 }
            $1 == ARGV[1] { print NR; exit }
        ' "$name")
        if [ -z "$priority" ]; then
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

usage() {
    cat << EOF
Usage: $(basename "$0") <command>

Commands:
  monitors  Display a list of all monitors. Fields are: index, width, height,
            pos_x, pos_y, name, priority, properties.
EOF
}

case "${1-}" in
    monitors)
        "$1"
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac
