#!/bin/sh
set -eu
if [ -n "${DISPLAY-}" ]; then
    dpi=$(xrdb -query | grep '^Xft\.dpi:' | cut -f2)
else
    dpi=192
fi
export HIDPI=1
export GDK_SCALE=2
export GDK_DPI_SCALE=$(printf '%.2g' "$(echo "scale=3;96/$dpi" | bc)")
export QT_SCALE_FACTOR=2
export QT_FONT_DPI=96
exec "$@"
