#!/bin/sh
# Pull system dotfiles into this repository.
set -euf
dir=$(dirname "$(realpath "$0")")
cd "$dir"/..

u=
if [ -z "${OVERWRITE-}" ]; then
    u=u
fi

rsync -avL$u "$@" ~/ ./ \
    --include /.bashrc \
    --include /.cargo \
    --include /.cargo/config.toml \
    --exclude /.cargo/* \
    --include /.conf.m4 \
    --include /.config \
    --include /.config/dunst \
    --exclude /.config/dunst/dunstrc \
    --exclude /.config/dunst/dunstrc.*.m4 \
    --include /.config/gtk-3.0 \
    --include /.config/gtk-3.0/settings.ini \
    --exclude /.config/gtk-3.0/* \
    --include /.config/gtk-4.0 \
    --include /.config/gtk-4.0/settings.ini \
    --exclude /.config/gtk-4.0/* \
    --include /.config/i3 \
    --include /.config/i3/bar.m4 \
    --include /.config/i3/config.m4 \
    --include /.config/i3/generate.sh \
    --include /.config/i3/status-wrapper.py \
    --include /.config/i3/rename-workspace.sh \
    --include /.config/i3/timer.py \
    --include /.config/i3/update-status.sh \
    --exclude /.config/i3/* \
    --include /.config/logrotate.conf \
    --include /.config/monitor-utils \
    --include /.config/monitor-utils/*.default.json \
    --include /.config/monitor-utils/*.example.json \
    --include /.config/monitor-utils/generate.sh \
    --include /.config/monitor-utils/README \
    --exclude /.config/monitor-utils/* \
    --include /.config/mpv \
    --include /.config/mpv/mpv.conf \
    --include /.config/mpv/scripts \
    --include /.config/mpv/scripts/delay.lua \
    --exclude /.config/mpv/scripts/* \
    --exclude /.config/mpv/* \
    --include /.config/picom.conf \
    --include /.config/feh \
    --include /.config/feh/themes \
    --exclude /.config/feh/* \
    --include /.config/fontconfig \
    --include /.config/redshift.conf \
    --include /.config/xkb \
    --include /.config/xkb/rules \
    --include /.config/xkb/rules/source \
    --exclude /.config/xkb/rules/* \
    --include /.config/xkb/setmap.sh \
    --include /.config/xkb/symbols \
    --exclude /.config/xkb/* \
    --exclude /.config/* \
    --include /.fehbg \
    --include /.gitconfig \
    --include /.gitignore-global \
    --include /.gtkrc-2.0 \
    --include /.i3status.conf.m4 \
    --include /.inputrc \
    --include /.mailrc \
    --include /.npmrc \
    --include /.profile \
    --include /.tmux.conf \
    --include /.vim \
    --include /.vim/*.vim \
    --include /.vim/after \
    --include /.vim/colors \
    --include /.vim/plugin \
    --include /.vim/syntax \
    --include /.vim/syntax/rust.vim \
    --exclude /.vim/syntax/* \
    --exclude /.vim/* \
    --include /.vimrc \
    --include /.XCompose \
    --include /.xprofile \
    --include /.Xresources.m4 \
    --include /.xserverrc \
    --include /.xsession \
    --include /.xsettingsd.m4 \
    --include /bin \
    --include /bin/clear-clipboard \
    --include /bin/commonmark \
    --include /bin/controls \
    --include /bin/ds \
    --include /bin/git-batch \
    --include /bin/git-retag-annotated \
    --include /bin/lddsafe \
    --include /bin/lock \
    --include /bin/paragraph-join \
    --include /bin/profilectl \
    --include /bin/random-phrase \
    --include /bin/random-string \
    --include /bin/redshift \
    --include /bin/scrot \
    --include /bin/serial-configure \
    --include /bin/serial-connect \
    --include /bin/showcolors \
    --include /bin/truncline \
    --include /bin/unicode-id \
    --include /bin/urxvt \
    --include /bin/urxvt-large \
    --include /bin/urxvt-vim \
    --exclude /bin/* \
    --include /scripts \
    --include /scripts/backup.sh \
    --include /scripts/bpm.sh \
    --include /scripts/controls.sh \
    --include /scripts/displays.sh \
    --include /scripts/fix-urxvt-position.sh \
    --include /scripts/monitor-utils \
    --include /scripts/monitor-utils/detail \
    --include /scripts/monitor-utils/globals.sh \
    --include /scripts/monitor-utils/m4 \
    --include /scripts/monitor-utils/make.sh \
    --include /scripts/monitor-utils/monitors.sh \
    --include /scripts/monitor-utils/sh \
    --include /scripts/monitor-utils/xmonutil \
    --include /scripts/monitor-utils/xmonutil/*.c \
    --include /scripts/monitor-utils/xmonutil/*.h \
    --include /scripts/monitor-utils/xmonutil/Makefile \
    --include /scripts/monitor-utils/xmonutil/licenses \
    --exclude /scripts/monitor-utils/xmonutil/* \
    --include /scripts/monitor-utils/xmonutil.sh \
    --exclude /scripts/monitor-utils/* \
    --include /scripts/pactl.sh \
    --include /scripts/pulse-max-volume.sh \
    --include /scripts/pulse-max-volume \
    --include /scripts/pulse-max-volume/main.c \
    --include /scripts/pulse-max-volume/Makefile \
    --exclude /scripts/pulse-max-volume/* \
    --include /scripts/redshift-loop.sh \
    --include /scripts/rgc.sh \
    --include /scripts/set-urxvt-colors.sh \
    --include /scripts/x11vnc.sh \
    --exclude /scripts/* \
    --exclude /* \
    --exclude .*

IFS='
'
for f in $(find -type f ! -path '*/.git/*' ! -path '*
*' -exec grep -El '\.(end|start)$' {} +
); do
    printf '%s\n' "Post-processing $f"
    "$dir"/detail/post.sh "$f"
done
