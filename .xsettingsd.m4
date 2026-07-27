include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
sinclude_rel(`.xsettingsd.pre.m4')dnl
esyscmd(`~/scripts/monitor-utils/m4/globals.sh')dnl
define(`DPI', `GLOBAL_MONITOR_DPI')dnl
define_default(`SCALE', eval((DPI + 48) / 96))dnl
define(`UNSCALED_DPI', eval(DPI * 1024 / SCALE))dnl
ifelse(eval(UNSCALED_DPI < 98304), 1, `define(`UNSCALED_DPI', 98304)')dnl
dnl
Xft/`DPI' eval(DPI * 1024)
Gdk/UnscaledDPI UNSCALED_DPI
Gdk/WindowScalingFactor SCALE
sinclude_rel(`.xsettingsd.post.m4')dnl
