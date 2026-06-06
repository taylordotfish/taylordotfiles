include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
sinclude_rel(`.Xresources.pre.m4')dnl
esyscmd(`~/scripts/monitor-utils/m4/globals.sh')dnl
define(`DPI', `GLOBAL_MONITOR_DPI')dnl
Xft.dpi: DPI

define_default(`TERM_FONT_FAMILY', `DejaVu Sans Mono')dnl
define_default(`TERM_FONT_SIZE', `10')dnl
ifdef(`BITMAP_FONT',, `ifelse(
    define(`BITMAP_SUFFIX', ifelse(eval(DPI >= 144), 1, -2x))
    define(`BITMAP_FONT', `9x15`'BITMAP_SUFFIX')
    define_default(`BITMAP_FONT_BOLD', `9x15`'BITMAP_SUFFIX`'bold')
    define_default(`BITMAP_FONT_ITALIC', `BITMAP_FONT')
    define_default(`BITMAP_FONT_BOLD_ITALIC', `BITMAP_FONT_BOLD')
)')dnl
dnl
xterm*background: black
xterm*foreground: white
xterm*color4: rgb:0f/6b/b0
xterm*color12: rgb:60/a4/ff
xterm*metaSendsEscape: true
xterm*locale: true
xterm*font: BITMAP_FONT
ifdef(`BITMAP_FONT_BOLD', `xterm*boldFont: BITMAP_FONT_BOLD
')dnl
xterm*colorITMode: true

Rxvt*foreground: white
Rxvt*background: [75]#000000
Rxvt*epaper*foreground: black
Rxvt*epaper*background: white
Rxvt*scrollBar: false
Rxvt*color4: #0f6bb0
Rxvt*color12: #60a4ff
Rxvt*depth: 32
Rxvt*perl-ext-common:

ifdefn(`RXVT_USE_BITMAP_FONT', `dnl
Rxvt*font: BITMAP_FONT
ifdefn(`BITMAP_FONT_BOLD', `Rxvt*boldFont: BITMAP_FONT_BOLD
')dnl
ifdefn(`BITMAP_FONT_ITALIC', `Rxvt*italicFont: BITMAP_FONT_ITALIC
')dnl
ifdefn(`BITMAP_FONT_BOLD_ITALIC', `Rxvt*boldItalicFont: BITMAP_FONT_BOLD_ITALIC
')dnl', `dnl
Rxvt*font: xft:TERM_FONT_FAMILY:size=TERM_FONT_SIZE
define(`RXVT_DPI_FONTS', `ifelse(`$#$1', 1,, `dnl
Rxvt*$1dpi*font: xft:TERM_FONT_FAMILY:size=frac($1 * TERM_FONT_SIZE, DPI)
RXVT_DPI_FONTS(shift($@))')')dnl
RXVT_DPI_FONTS(esyscmd(`~/scripts/monitor-utils/monitors.sh -j \
    "map(.dpi | select(. != 'DPI`)) | unique | join(\",\")"'))')dnl
sinclude(`.Xresources.post.m4')dnl
