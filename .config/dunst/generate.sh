#!/bin/sh
set -euf
cd "$(dirname "$0")"
echo '# AUTOMATICALLY GENERATED!' > dunstrc
echo '# CHANGES WILL BE LOST!' >> dunstrc
echo >> dunstrc
m4 dunstrc.m4 >> dunstrc
