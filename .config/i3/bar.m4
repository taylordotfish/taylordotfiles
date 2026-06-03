bar {
    output defn(`MONITOR_OUTPUT')
    tray_output ifelse(MONITOR_PRIORITY, 0, `defn(`MONITOR_OUTPUT')', none)
    status_command i3status | `MONITOR_PRIORITY'=MONITOR_PRIORITY \
        `MONITOR_TECH'=defn(`MONITOR_TECH') ~/.config/i3/status-wrapper.py
    font ifdefn(`USE_BITMAP_FONT', `I3_BITMAP_FONT',
        `pango:VECTOR_FONT_FAMILY frac(MONITOR_DPI * VECTOR_FONT_SIZE, DPI)')
    colors {
ifelse(defn(`MONITOR_TECH'), epaper, `dnl
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
