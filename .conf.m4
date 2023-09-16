define(`define_default', `ifdef(`$1',, `define(`$1', `$2')')')
define(`ifdefn', `ifelse(defn(`$1'),, `$3', `$2')')
define(`concat', ``$1'ifelse(`$#', `1',, `concat(shift($@))')')
define(`vsyscmd', `syscmd($@)sysval')
define(`merge_env', `ifelse(`$#', `0',, `ifelse(
    define_default(`$1', esyscmd(`printf "\`%s'" "$$1"'))
    ifelse(`$#', `1',, `merge_env(shift($@))')
)')')
