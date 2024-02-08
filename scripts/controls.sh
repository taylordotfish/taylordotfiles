#!/bin/sh
set -euf
cd "$(dirname "$0")"
[ -f keyboard.sh ] && ./keyboard.sh
[ -f mouse.sh ] && ./mouse.sh
