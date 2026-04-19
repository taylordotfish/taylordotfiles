#!/bin/sh
set -euf
dir=$(dirname "$0")

ed=ed
if command -v ed > /dev/null; then
    :
elif command -v ex > /dev/null; then
    ed=ex
elif command -v vi > /dev/null; then
    ed="vi -e"
fi

$ed -s "$dir"/layout.conf << 'EOF'
1m$
w
EOF
exec "$dir"/setmap.sh
