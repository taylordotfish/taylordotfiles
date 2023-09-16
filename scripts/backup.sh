#!/bin/bash
set -euo pipefail
sudo rsync -avF --delete-after --delete-excluded --info=progress2 / \
    /mnt/backup/
