include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
merge_env(`HIDPI')dnl
sinclude_rel(`settings.ini.pre.m4')dnl
dnl
[Settings]
gtk-theme-name=Adwaita
gtk-icon-theme-name=gnome
dnl https://bugs.kde.org/show_bug.cgi?id=442901#c7
gtk-font-name=Sans eval(10 / ifdefn(`HIDPI', 2, 1))
sinclude_rel(`settings.ini.post.m4')dnl
