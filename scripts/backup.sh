#!/bin/sh
set -euf
if ! [ -d /mnt/backup ]; then
    printf >&2 '%s\n' "error: /mnt/backup does not exist"
    exit 1
fi
set +e
sudo rsync -avF --delete-after --delete-excluded --info=progress2 / \
    /mnt/backup/
status=$?
set -e
if [ "$status" -ne 0 ]; then
    printf >&2 '%s\n' 'warning: `sudo rsync` exited with status '"$status"
fi
