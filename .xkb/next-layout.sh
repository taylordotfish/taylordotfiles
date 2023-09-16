#!/bin/sh
set -eu
cd "$(dirname "$0")"
tail +2 layout.conf > .layout.conf.tmp
head -1 layout.conf >> .layout.conf.tmp
mv .layout.conf.tmp layout.conf
./setmap.sh
