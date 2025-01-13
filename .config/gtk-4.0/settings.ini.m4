include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
sinclude(`settings.ini.pre.m4')dnl
[Settings]
gtk-font-name=Sans esyscmd(`
    printf "%s" $((10 * 96 / $(xrdb -query | grep "^Xft\\.dpi:" | cut -f2)))')
sinclude(`settings.ini.post.m4')dnl
