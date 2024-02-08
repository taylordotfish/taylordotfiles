#!/bin/sh
set -euf
cd "$(dirname "$0")"
echo '# AUTOMATICALLY GENERATED!' > config
echo '# CHANGES WILL BE LOST!' >> config
echo >> config
m4 config.m4 >> config

cd
echo '# AUTOMATICALLY GENERATED!' > .i3status.conf
echo '# CHANGES WILL BE LOST!' >> .i3status.conf
echo >> .i3status.conf
m4 .i3status.conf.m4 >> .i3status.conf
