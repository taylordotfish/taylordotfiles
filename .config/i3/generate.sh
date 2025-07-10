#!/bin/sh
set -euf
dir=$(dirname "$0")
{
    cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
    (cd ~; m4 .i3status.conf.m4)
} > ~/.i3status.conf

exec > "$dir"/config
cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
cd "$dir"
m4 config.m4
