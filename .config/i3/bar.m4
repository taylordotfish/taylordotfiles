include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
merge_env(`HIDPI')dnl
sinclude(`bar.pre.m4')dnl
dnl
define_default(`I3BAR_HIDPI_FONT', `pango:DejaVu Sans Mono 22px')dnl
dnl
bar {
    output MONITOR_NAME
    tray_output primary
    status_command i3status | `MONITOR_PRIORITY'=MONITOR_PRIORITY ifdefn(
        `MONITOR_MONO', ``MONOCHROME=2 '')~/.i3/status-wrapper.py
ifdefn(`HIDPI',, ifdefn(`MONITOR_HIDPI', ``dnl
    font I3BAR_HIDPI_FONT
''))dnl
    colors {
ifdefn(`MONITOR_MONO', `dnl
        background #ffffff
        statusline #000000
        separator #000000
        focused_workspace #000000 #ffffff #000000
        active_workspace #000000 #ffffff #000000
        inactive_workspace #ffffff #ffffff #000000
', `dnl
        background #000000
        statusline #ffffff
        focused_workspace #303030 #303030 #ffffff
        active_workspace #202020 #202020 #c0c0c0
        inactive_workspace #101010 #101010 #909090
')dnl
    }
}
sinclude(`bar.post.m4')dnl
