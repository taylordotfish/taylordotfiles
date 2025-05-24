#!/bin/sh
set -euf
dir=$(dirname "$0")
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    m4 "$dir"/config.m4
} > "$dir"/config
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    m4 ~/.i3status.conf.m4
} > ~/.i3status.conf
