# Copyright (C) 2025-2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

escape_sh() {
    printf '%s\n' "$1" | sed "s/'/'\\\\''/g"
}

escape_i3() {
    printf '%s\n' "$1" | sed 's/[\\"]/\\&/g'
}

prompt() {
    exec i3-input -F "exec --no-startup-id sh '$(escape_sh "$0")' \
rename \"%s\"" -P "rename workspace: " "$@"
}

rename() {
    #exec >> "$(dirname -- "$0")"/rename-workspace.log 2>&1
    local new_name="$1"
    [ -n "$new_name" ] || return 0
    local new_number="${new_name%%:*}"
    case "$new_number" in
        *[!0-9]*) new_number= ;;
    esac
    local new_label
    if [ -n "$new_number" ]; then
        new_label=${new_name#*:}
        new_label=${new_label# }
    else
        new_number=$(i3-msg -t get_workspaces |
            jq -r 'map(select(.focused).name)[0] // empty' |
            head -n1 |
            sed 's/^\([0-9]*\).*/\1/')
        new_label=$new_name
    fi
    local final_name
    if [ -n "$new_number" ]; then
        final_name="$new_number: $new_label"
    else
        final_name=$new_label
    fi
    exec i3-msg "rename workspace to \"$(escape_i3 "$final_name")\""
}

if [ "$#" -eq 0 ]; then
    printf >&2 '%s\n' "missing command"
    exit 1
fi
case "$1" in
    prompt|rename)
        "$@"
        ;;
    *)
        printf >&2 '%s\n' "unknown command"
        exit 1
        ;;
esac
