dnl Copyright (C) 2023, 2026 taylor.fish <contact@taylor.fish>
dnl License: GNU GPL version 3 or later
define(`define_default', `ifdef(`$1',, `define(`$1', `$2')')')dnl
define(`ifdefn', `ifelse(defn(`$1'),, `$3', `$2')')dnl
define(`vsyscmd', `syscmd(`exec > /dev/null; $1')sysval')dnl
define(`merge_env', `ifelse(`$#', `0',, `ifelse(
    define_default(`$1', esyscmd(`printf "\`%s'" "$$1"'))
    ifelse(`$#', `1',, `merge_env(shift($@))')
)')')dnl
define(`dquote', ```$1''')dnl
define(`include_rel', `include(ifelse(regexp(`$1', `^/'), `-1',
    `patsubst(dquote(__file__), `[^/]*\(.\)$', `\1')')`$1')')dnl
define(`sinclude_rel', `s'defn(`include_rel'))dnl
