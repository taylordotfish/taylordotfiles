#!/bin/bash
set -eufo pipefail

prev_inputs=
while true; do
    if ! inputs=$(pactl list short sink-inputs | cut -f1 | sort); then
        sleep 2
        continue
    fi
    new=$(comm -13 <(printf '%s\n' "$prev_inputs") <(printf '%s\n' "$inputs"))
    prev_inputs=$inputs

    for id in $new; do
        volume=$(pactl list sink-inputs |
            grep -A15 "^Sink Input #$id$" |
            grep '^\s*Volume:' |
            grep -o '[0-9]\+%' |
            head -1
        )
        if [ "$volume" != "100%" ]; then
            printf '%s\n' "Setting volume of $id from $volume to 100%"
            pactl set-sink-input-volume "$id" "100%"
        fi
    done
    sleep 0.5
done
