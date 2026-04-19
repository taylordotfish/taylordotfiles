#!/bin/sh
set -euf
dir=$(dirname "$0")

exec > ~/.i3status.conf
cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
m4 ~/.i3status.conf.m4

exec > "$dir"/config
cat << 'EOF'
# AUTOMATICALLY GENERATED!
# CHANGES WILL BE LOST!

EOF
m4 "$dir"/config.m4
