#!/bin/sh
set -euf
cd "$(dirname "$0")"
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    m4 config.m4
} > config

cd
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    m4 .i3status.conf.m4
} > .i3status.conf
