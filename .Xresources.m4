include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
merge_env(`HIDPI')dnl
sinclude(`.Xresources.pre.m4')dnl
dnl
Xft.dpi: ifdefn(`HIDPI', `192', `96')

xterm*background: black
xterm*foreground: white
xterm*color4: rgb:0f/6b/b0
xterm*color12: rgb:60/a4/ff
xterm*metaSendsEscape: true
xterm*locale: true

xterm*font: -misc-fixed-medium-r-normal--15-140-75-75-c-90-iso10646-1
xterm*boldFont: -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso10646-1
xterm*colorITMode: true

Rxvt*foreground: white
Rxvt*background: [75]#000000

Rxvt*mono*foreground: black
Rxvt*mono*background: #ffffff

Rxvt*scrollBar: false
Rxvt*color4: #0f6bb0
Rxvt*color12: #60a4ff
Rxvt*depth: 32

Rxvt*font: -misc-fixed-medium-r-normal--15-140-75-75-c-90-iso10646-1
Rxvt*boldFont: -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso10646-1
Rxvt*italicFont: -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso10646-1
Rxvt*boldItalicFont: -misc-fixed-bold-r-normal--15-140-75-75-c-90-iso10646-1

Rxvt*2x*font: -misc-2xfixed-medium-r-normal--30-280-75-75-c-180-iso10646-1
Rxvt*2x*boldFont: -misc-2xfixed-bold-r-normal--30-280-75-75-c-180-iso10646-1
Rxvt*2x*italicFont: -misc-2xfixed-bold-r-normal--30-280-75-75-c-180-iso10646-1
Rxvt*2x*boldItalicFont: -misc-2xfixed-bold-r-normal--30-280-75-75-c-180-iso10646-1

Rxvt*mono*2x*font: xft:DejaVu Sans Mono:pixelsize=22
Rxvt*mono*2x*boldFont: xft:DejaVu Sans Mono:pixelsize=22:bold
Rxvt*mono*2x*italicFont: xft:DejaVu Sans Mono:pixelsize=22:italic
Rxvt*mono*2x*boldItalicFont: xft:DejaVu Sans Mono:pixelsize=22:bold:italic
sinclude(`.Xresources.post.m4')dnl
