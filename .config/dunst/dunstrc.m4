include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
merge_env(`HIDPI', `MONOCHROME')dnl
sinclude(`dunstrc.pre.m4')dnl
dnl
[global]
    follow = mouse
    width = ifdefn(`HIDPI', `450', `300')
    offset = 35x35
    frame_color = ifelse(defn(`MONOCHROME'), `2', `"#000000"', `"#9090907f"')
    font = DejaVu Sans Mono 10
    icon_position = off
ifelse(defn(`MONOCHROME'), `2', `dnl
    background = "#ffffff"
    foreground = "#000000"
')dnl

[urgency_low]
ifelse(defn(`MONOCHROME'), `2',, `dnl
    background = "#0000007f"
    foreground = "#909090"
')dnl
    timeout = 0

[urgency_normal]
ifelse(defn(`MONOCHROME'), `2',, `dnl
    background = "#0000007f"
    foreground = "#ffffff"
')dnl
    timeout = 0

[urgency_critical]
ifelse(defn(`MONOCHROME'), `2',, `dnl
    background = "#0000007f"
    foreground = "#ffffff"
    frame_color = "#ff5050"
')dnl
    timeout = 0

sinclude(`dunstrc.post.m4')dnl
`#' `vim:ft=cfg'
