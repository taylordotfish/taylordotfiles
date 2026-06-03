#!/bin/sh
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf
cache=~/.cache/monitor-utils
config=~/.config/monitor-utils

if [ -f "$config"/settings.json ]; then
    set -- --slurpfile settings "$config"/settings.json
else
    set -- --argjson settings [{}]
fi

exec jq -c "$@" -- '({
    global_dpi: "priority",
    global_tech: "priority",
} + $settings[0]) as $s | {
    dpi: (if $s.global_dpi == "priority" then
        map(select(.primary))[0].dpi
    elif $s.global_dpi == "minimum" then
        map(.dpi) | min
    elif $s.global_dpi == "maximum" then
        map(.dpi) | max
    elif $s.global_dpi == "average" then
        map(.dpi) | add / length | round
    elif $s.global_dpi | type == "number" then
        $s.global_dpi
    else
        null
    end // 96),

    tech: (if $s.global_tech == "priority" then
        map(select(.primary))[0].tech
    elif $s.global_tech | type == "string" then
        $s.global_tech
    elif $s.global_tech | type == "array" then
        map({
            key: .tech | select(type == "string"),
            value: null,
        }) | from_entries as $used
            | $s.global_tech
            | map(select(type == "string"))
            | first(.[] | select(. | in($used))) // last
    else
        null
    end // "standard"),
}' "$cache"/monitors.json
