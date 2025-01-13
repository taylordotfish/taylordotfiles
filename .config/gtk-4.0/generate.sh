#!/bin/sh
set -euf
cd "$(dirname "$0")"
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    m4 settings.ini.m4
} > settings.ini
