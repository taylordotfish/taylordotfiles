#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
cache=~/.cache/monitor-utils
config=~/.config/monitor-utils

set -- --slurpfile screens "$cache"/screens.json \
    --slurpfile outputs "$cache"/outputs.json
if [ -f "$config"/monitors.json ]; then
    set -- "$@" --slurpfile monitors "$config"/monitors.json
else
    set -- "$@" --argjson monitors '[[]]'
fi
if [ -f "$config"/outputs.json ]; then
    set -- "$@" --slurpfile output_map "$config"/outputs.json
else
    set -- "$@" --argjson output_map '[{}]'
fi
exec jq -cn "$@" '
def validate(prop; filt):
    .[prop] | if filt | not then
        "monitor-utils: invalid \""
            + prop
            + "\": "
            + tojson
            + "\n"
            | halt_error(1)
    end;
def is_unsigned: isfinite and . >= 0 and (. | floor) == .;
def is_safe_string: type == "string" and (test("[^A-Za-z0-9._-]") | not);
def sanitize_string: gsub("[^A-Za-z0-9._-]"; "");
($screens[0] + $outputs[0])
    | group_by(.screen)
    | map(add | select(has("output")))
    | . + ($output_map[0] | to_entries | map({output: .key, name: .value}))
    | group_by(.output)
    | map(add | select(has("screen")))
    | map(.output |= sanitize_string)
    | map({name: .output} + .)
    | . + $monitors[0]
    | group_by(.name)
    | map(add | select(has("screen")))
    | map({priority: 0, dpi: 96, tech: "standard"} + .)
    | sort_by(.priority, .screen)
    | to_entries
    | map(.value + {priority: .key})
    | map({
        priority: validate("priority"; is_unsigned),
        screen: validate("screen"; is_unsigned),
        x: validate("x"; is_unsigned),
        y: validate("y"; is_unsigned),
        width: validate("width"; is_unsigned),
        height: validate("height"; is_unsigned),
        output: validate("output"; is_safe_string),
        name: validate("name"; is_safe_string),
        dpi: validate("dpi"; is_unsigned),
        tech: validate("tech"; is_safe_string),
    })'
