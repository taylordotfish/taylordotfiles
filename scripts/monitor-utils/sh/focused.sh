#!/bin/sh
set -euf
case "$0" in
    */*) dir=${0%/*} ;;
    *) dir=. ;;
esac
opts=
for arg do
    case "$arg" in
        --local) opts="$opts --local" ;;
    esac
done
focused=$("$dir"/../xmonutil.sh focused)
exec "$dir"/select.sh $opts ".screen == $((focused))"
