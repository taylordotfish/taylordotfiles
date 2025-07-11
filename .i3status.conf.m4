# i3status configuration file.
# see "man i3status" for documentation.

# It is important that this file is edited as UTF-8.
# The following line should contain a sharp s:
# ß
# If the above line is not correctly displayed, fix your editor first!

include(esyscmd(`printf "\`%s'" "$HOME"')`/.conf.m4')dnl
sinclude(`.i3status.conf.pre.m4')dnl
dnl
general {
    output_format="i3bar"
    colors = true
    interval = "5"
    color_good = "#000001"
    color_degraded = "#000002"
    color_bad = "#000003"
}

#order += "ipv6"
order += "disk /"
#order += "volume master"
#order += "run_watch DHCP"
#order += "run_watch VPN"
order += "wireless _first_"
order += "ethernet _first_"
define(`BATTERY', esyscmd(`printf \\140
printf "%s\n" /sys/class/power_supply/BAT* | head -1 | tr -dc "[0-9]"
printf \\47
'))dnl
ifelse(defn(`BATTERY'),,, `dnl
order += "battery BATTERY"
')dnl
order += "load"
order += "tztime local"

wireless _first_ {
    #format_up = "W: ([%quality] %essid) %ip"
    format_up = "W: [%quality] %ip"
    format_down = "W: down"
    format_quality = "%02d%s"
}

ethernet _first_ {
    # if you use %speed, i3status requires root privileges
    #format_up = "E: %ip (%speed)"
    format_up = "E: %ip"
    format_down = "E: down"
}
ifelse(defn(`BATTERY'),,, `dnl
define_default(`BATTERY_FORMAT', `%status %percentage %remaining')dnl

battery BATTERY {
    format = "defn(`BATTERY_FORMAT')"
}
')dnl

run_watch DHCP {
    pidfile = "/var/run/dhclient*.pid"
}

run_watch VPN {
    pidfile = "/var/run/vpnc/pid"
}

tztime local {
    format = "%Y-%m-%d %H:%M:%S"
}

load {
    format = "%1min"
}

disk "/" {
    format = "%avail"
    prefix_type = "decimal"
}

volume master {
    format = "V: %volume"
    format_muted = "V: %volume [M]"
    device = "pulse"
    mixer = "Master"
}
dnl
sinclude(`.i3status.conf.post.m4')dnl
