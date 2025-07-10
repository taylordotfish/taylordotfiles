#!/bin/sh
set -euf
dir=$(dirname "$0")
exec > "$dir"/dunstrc
cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
cd "$dir"
m4 dunstrc.m4
