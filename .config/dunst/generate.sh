#!/bin/sh
set -euf
cd "$(dirname "$0")"
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    m4 dunstrc.m4
} > dunstrc
