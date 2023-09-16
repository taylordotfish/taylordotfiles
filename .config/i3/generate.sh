#!/bin/sh
set -eu
cd "$(dirname "$0")"
echo '# AUTOMATICALLY GENERATED!' > config
echo '# CHANGES WILL BE LOST!' >> config
echo >> config
m4 config.m4 >> config
