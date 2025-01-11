#!/bin/sh
set -euf
cd "$(dirname "$0")"
[ -x keyboard.sh ] && ./keyboard.sh
[ -x mouse.sh ] && ./mouse.sh
