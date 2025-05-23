#!/bin/sh
set -euf
if ! picom --version | awk -F'[^0-9]+' '{
    for (i = 1; i <= NF; ++i) {
        if ($(i) != "") {
            exit $(i) >= 10 ? 0 : 1
        }
    }
}'; then
    set -- --experimental-backends "$@"
fi
exec picom "$@"
