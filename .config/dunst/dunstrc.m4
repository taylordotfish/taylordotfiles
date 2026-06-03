include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
sinclude_rel(`dunstrc.pre.m4')dnl
esyscmd(`~/scripts/monitor-utils/m4/globals.sh')dnl
define_default(`FONT', `DejaVu Sans Mono 10')dnl
dnl
[global]
    follow = mouse
    width = 300
    offset = 35x35
    frame_color = ifelse(
        defn(`GLOBAL_MONITOR_TECH'),
        epaper,
        `"#000000"',
        `"#9090907f"')
    font = FONT
    icon_position = off
ifelse(defn(`GLOBAL_MONITOR_TECH'), epaper, `dnl
    background = "#ffffff"
    foreground = "#000000"
')dnl

[urgency_low]
ifelse(defn(`GLOBAL_MONITOR_TECH'), epaper,, `dnl
    background = "#0000007f"
    foreground = "#909090"
')dnl
    timeout = 0

[urgency_normal]
ifelse(defn(`GLOBAL_MONITOR_TECH'), epaper,, `dnl
    background = "#0000007f"
    foreground = "#ffffff"
')dnl
    timeout = 0

[urgency_critical]
ifelse(defn(`GLOBAL_MONITOR_TECH'), epaper,, `dnl
    background = "#0000007f"
    foreground = "#ffffff"
    frame_color = "#ff5050"
')dnl
    timeout = 0

sinclude_rel(`dunstrc.post.m4')dnl
`#' `vim:ft=cfg'
