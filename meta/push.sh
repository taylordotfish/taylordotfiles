#!/bin/sh
# Push this repository's dotfiles to the system. This script only updates
# dotfiles that are already present on the system.
set -euf
cd "$(dirname "$0")"/..
IFS='
'
if ! command -v rsync > /dev/null; then
    printf >&2 '%s\n' "error: missing rsync"
    exit 1
fi
for f in $(find . -type f ! -path './.git/*' ! -path './doc/*' \
    ! -path './extra/*' ! -path './meta/*' ! -path './COPYRIGHT' \
    ! -path './LICENSE' ! -path './README.md' ! -path './.gitignore' \
    ! -name '*.swp' ! -path '*
*'); do
    if [ ! -f ~/"$f" ]; then
        if [ -n "${VERBOSE-}" ]; then
            printf '%s\n' "Skipping $f; does not exist on system"
        fi
        continue
    fi
    if [ "$(($(date -r "$f" '+%s')-1))" -le "$(date -r ~/"$f" '+%s')" ]; then
        if [ -n "${VERBOSE-}" ]; then
            printf '%s\n' "Skipping $f; system file is newer"
        fi
        continue
    fi
    if grep -E ' \.(end|start)$' ~/"$f" > /dev/null; then
        printf '%s\n' "Skipping $f; has local changes"
        continue
    fi
    rsync -a --out-format='%f' ${DRY_RUN:+--dry-run} "$f" "$(realpath ~/"$f")"
done
