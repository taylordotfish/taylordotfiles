# rgc: finds a C/C++ definition. Sourced by ~/.bashrc.
# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
set -euf

rg=rg
# - c: C/C++ files
# - h: C/C++ headers
# - a: all
files=ch
# - t: type definitions
# - v: global variable definitions
# - f: function definitions
# - m: macro definitions
# - a: all
types=a
while getopts 'f:T:gAhto' name; do
    case "$name" in
        f) files=$OPTARG ;;
        T) types=$OPTARG ;;
        g) rg=rgg ;;
        A) files=a ;;
        h) files=h ;;
        t) types=tm ;;
        o) types=fvm ;;
        \?) exit 1 ;;
    esac
done
shift "$((OPTIND - 1))"
if [ "$#" -lt 1 ]; then
    printf >&2 '%s\n' "error: missing name"
    exit 1
fi

exts=
case "$files" in
    *a*) files= ;;
esac
case "$files" in
    *c*) exts="$exts C c c++ cc cpp cxx" ;;
esac
case "$files" in
    *h*) exts="$exts H h h++ hh hpp hxx" ;;
esac
globs=
for ext in $exts; do
    globs="$globs -g*.$ext"
done

depth=2
comments='((/\*(?s:.)*?\*/|//.*)\s*)*'
pattern=
if case "$types" in *[fa]*) ;; *) false ;; esac; then
    pattern='^[^=;\n]*\<'$1'\>\s*\([^)=;]*\)\s*(->[^{()=;]*\s*)?'$comments'\{'
fi
if case "$types" in *[va]*) ;; *) false ;; esac; then
    # TODO: allow variables to be indented as long as not in a braced block?
    # TODO: find (non-class) enum constants?
    pattern=$pattern'|^\w[^=;\n]*\<'$1'\>\s*[\[);]'
fi
if case "$types" in *[ta]*) ;; *) false ;; esac; then
    body='\{[^{}=]*\}'
    i=1; while [ "$((i += 1))" -le "$depth" ]; do
        body='\{([^{}=]*('$body')?)*\}'
    done
    pattern=$pattern'\<(struct|enum|union|class)\s+\<'$1'\>\s*'$comments'\{'
    pattern=$pattern'|\<typedef\s+([^{}=;]*('$body')?)*\<'$1'\>\s*[\[);]'
    pattern=$pattern'|\<using\s+'$1'\>\s*='
fi
if case "$types" in *[ma]*) ;; *) false ;; esac; then
    pattern=$pattern'|#define\s+'$1'\>'
fi
if [ -z "$pattern" ]; then
    exit 0
fi
pattern=${pattern#|}
shift
"$rg" -U $globs "$pattern" "$@"
