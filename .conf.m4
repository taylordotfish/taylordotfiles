dnl Copyright (C) 2023, 2026 taylor.fish <contact@taylor.fish>
dnl License: GNU GPL version 3 or later
define(`dquote', ```$1''')dnl
define(`define_nonbare', `define(`$1',
    `ifelse'`('dquote(`$'`#')`, `0', ``$1'', `$2')')')dnl
define_nonbare(`make_nonbare', `define_nonbare(`$1', defn(`$1'))')dnl
make_nonbare(`dquote')dnl
make_nonbare(`define_nonbare')dnl
define_nonbare(`define_default', `ifdef(`$1',, `define(`$1', `$2')')')dnl
define_nonbare(`ifdefn', `ifelse(defn(`$1'),, `$3', `$2')')dnl
define_nonbare(`vsyscmd', `syscmd(`exec > /dev/null; $1')sysval')dnl
define_nonbare(`merge_env', `ifelse(
    define_default(`$1', esyscmd(`printf "\`%s'" "$$1"'))
    ifelse(`$#', `1',, `merge_env(shift($@))')
)')dnl
define_nonbare(`getcwd', `ifelse(regexp(__file__, `/'), `-1', `.',
    `regexp(__file__, `^\(.*\)/.*$', ``\1'')')')dnl
define_nonbare(`include_rel', `include(getcwd()`/$1')')dnl
define_nonbare(`sinclude_rel', `sinclude(getcwd()`/$1')')dnl
define_nonbare(`frac', `ifelse(`$3',, `frac(`$1', `$2', `3')',
    `eval(`($1)/($2)').eval(`($1) * 10**($3) / $2 % 10**($3)')')')dnl
