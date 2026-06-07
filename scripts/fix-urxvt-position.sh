#!/bin/sh
# Workaround for urxvt bug where shell prompt appears in middle of screen.
if [ "${1-}" != tmux ]; then
    sleep 0.05
    clear
fi
exec "$@"
