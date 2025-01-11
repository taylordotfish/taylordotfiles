#!/bin/sh
set -euf
if ! [ -d /mnt/backup ]; then
    printf >&2 '%s\n' "error: /mnt/backup does not exist"
    exit 1
fi
sudo rsync -avF --delete-after --delete-excluded --info=progress2 / \
    /mnt/backup/ && true
status=$?
if [ "$status" -ne 0 ]; then
    printf >&2 '%s\n' 'warning: `sudo rsync` exited with status '"$status"
fi
