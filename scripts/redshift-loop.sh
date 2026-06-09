#!/bin/sh
set -euf
while true; do
    redshift "$@"
    # redshift exits with code 0 when receiving SIGTERM
    printf '%s\n' "redshift exited; restarting in 1 second"
    sleep 1
done
