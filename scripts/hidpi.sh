#!/bin/sh
set -euf
export HIDPI=1
export GDK_SCALE=2
export QT_SCALE_FACTOR=2
exec "$@"
