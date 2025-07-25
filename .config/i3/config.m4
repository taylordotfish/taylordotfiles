# This file has been auto-generated by i3-config-wizard(1).
# It will not be overwritten, so edit it as you like.
#
# Should you change your keyboard layout somewhen, delete
# this file and re-run i3-config-wizard(1).

# i3 config file (v4)
# Please see http://i3wm.org/docs/userguide.html for a complete reference!

include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
merge_env(`HIDPI', `MONOCHROME')dnl
sinclude(`config.pre.m4')dnl
dnl
set $mod Mod4
set $alt Mod1

# use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

# kill focused window
bindsym $mod+Shift+q kill

# change focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+g split h

# split in vertical orientation
bindsym $mod+v split v

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent

# focus the child container
bindsym $mod+q focus child

# switch keyboard layout
bindsym $mod+$alt+space exec --no-startup-id ~/.xkb/next-layout.sh

define_default(`WS1', `one')dnl
define_default(`WS2', `two')dnl
define_default(`WS3', `three')dnl
define_default(`WS4', `four')dnl
define_default(`WS5', `five')dnl
define_default(`WS6', `six')dnl
define_default(`WS7', `seven')dnl
define_default(`WS8', `eight')dnl
define_default(`WS9', `nine')dnl
define_default(`WS10', `ten')dnl
set $ws1 1: defn(`WS1')
set $ws2 2: defn(`WS2')
set $ws3 3: defn(`WS3')
set $ws4 4: defn(`WS4')
set $ws5 5: defn(`WS5')
set $ws6 6: defn(`WS6')
set $ws7 7: defn(`WS7')
set $ws8 8: defn(`WS8')
set $ws9 9: defn(`WS9')
set $ws10 10: defn(`WS10')

# switch to workspace
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# workspace navigation
bindsym $mod+$alt+Right workspace next
bindsym $mod+$alt+Left workspace prev
bindsym $mod+$alt+l workspace next
bindsym $mod+$alt+h workspace prev
bindsym $mod+$alt+Shift+Right move workspace to output right
bindsym $mod+$alt+Shift+Left move workspace to output left
bindsym $mod+$alt+Shift+l move workspace to output right
bindsym $mod+$alt+Shift+h move workspace to output left

# brightness keys
bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl set 5%-
bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl set +5%

# volume keys
bindsym XF86AudioMute exec --no-startup-id \
    ~/scripts/pactl.sh set-sink-mute toggle
bindsym XF86AudioLowerVolume exec --no-startup-id \
    ~/scripts/pactl.sh set-sink-volume -2%
bindsym XF86AudioRaiseVolume exec --no-startup-id \
    ~/scripts/pactl.sh set-sink-volume +2%

# reload the configuration file
bindsym $mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+r restart
# exit i3 (logs you out of your X session)
bindsym $mod+Shift+e exit

# resize window (you can also use the mouse for that)
mode "resize" {
    # These bindings trigger as soon as you enter the resize mode

    # Pressing left will shrink the window’s width.
    # Pressing right will grow the window’s width.
    # Pressing up will shrink the window’s height.
    # Pressing down will grow the window’s height.
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt

    # same bindings, but for the arrow keys
    bindsym Left resize shrink width 10 px or 10 ppt
    bindsym Down resize grow height 10 px or 10 ppt
    bindsym Up resize shrink height 10 px or 10 ppt
    bindsym Right resize grow width 10 px or 10 ppt

    # back to normal: Enter or Escape
    bindsym Return mode "default"
    bindsym Escape mode "default"
}

# enter resize mode
bindsym $mod+r mode "resize"

# borders
for_window [class=".*"] border normal 0

# floating
for_window [instance="^jack-keyboard([^A-Za-z]|$)"] floating enable
for_window [instance="^notes-ui$"] floating enable  # carla
for_window [title="^Event Tester$"] floating enable
for_window [instance="^display([^A-Za-z0-9]|$)"] floating enable
for_window [instance="^display([^A-Za-z0-9]|$)"] move position ifdefn(
    `HIDPI', `800 450', `400 225')
for_window [instance="^kmag$"] floating enable
for_window [instance="^kmag$"] resize set ifdefn(
    `HIDPI', `1600 1200', `800 600')

# dunst
bindsym Control+space exec --no-startup-id dunstctl close
bindsym Control+Shift+space exec --no-startup-id dunstctl close-all
bindsym Control+grave exec --no-startup-id dunstctl history-pop
bindsym Control+Shift+period exec --no-startup-id dunstctl context

# fonts
define_default(`I3_FONT', ifdefn(
    `HIDPI',
    ``pango:DejaVu Sans Mono 10'',
    ``-misc-fixed-medium-r-normal--13-120-75-75-c-70-iso10646-1''))dnl
define_default(`DMENU_FONT', ifelse(
    defn(`HIDPI')vsyscmd(
        `[ "$(fc-match "Misc Fixed" family)" = "Misc Fixed" ]'),
    `0', ``Misc Fixed:pixelsize=13'', ``DejaVu Sans Mono:size=10''))dnl
define_default(`DMENU_COLORS',
    ifdefn(`MONOCHROME', ``-nf white -sb white -sf black -nb black''))dnl
dnl
font defn(`I3_FONT')
bindsym $mod+d exec --no-startup-id dmenu_run \
    -fn "defn(`DMENU_FONT')"dnl
ifdefn(`DMENU_COLORS', ` DMENU_COLORS')

# terminal shortcuts
bindsym $mod+Return exec --no-startup-id \
    URXVT_MONITOR=7:1 urxvt -title urxvt -e tmux -2
bindsym $mod+Shift+Return exec --no-startup-id \
    URXVT_MONITOR=7:1 urxvt -title urxvt -e bash

bindsym $mod+$alt+Return exec --no-startup-id \
    URXVT_MONITOR=7:2 urxvt -title urxvt -e tmux -2
bindsym $mod+$alt+Shift+Return exec --no-startup-id \
    URXVT_MONITOR=7:2 urxvt -title urxvt -e bash

ifelse(defn(`MONOCHROME'), `2', `dnl
client.focused          #000000 #ffffff #000000 #ffffff #000000
client.unfocused        #ffffff #ffffff #dddddd #ffffff #000000
client.focused_inactive #000000 #ffffff #dddddd #ffffff #000000
', `dnl
client.focused          #444444 #202020 #ffffff #000000 #000000
client.unfocused        #444444 #000000 #909090 #000000 #000000
client.focused_inactive #444444 #202020 #909090 #000000 #000000
')dnl

syscmd(`./bar.sh')dnl

# rename workspace
bindsym $mod+m exec --no-startup-id sh ~/.config/i3/rename-workspace.sh \
    prompt -f "defn(`I3_FONT')"

sinclude(`config.post.m4')dnl
`#' `vim:ft=conf'
