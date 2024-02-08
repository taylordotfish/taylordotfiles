#!/bin/sh
set -euf
sudo rsync -avF --delete-after --delete-excluded --info=progress2 / \
    /mnt/backup/
