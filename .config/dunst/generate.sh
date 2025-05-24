#!/bin/sh
set -euf
dir=$(dirname "$0")
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    m4 "$dir"/dunstrc.m4
} > "$dir"/dunstrc
