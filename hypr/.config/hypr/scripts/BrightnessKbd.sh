#!/usr/bin/env bash
# =============================================================================
# BrightnessKbd.sh — Keyboard backlight brightness control for ASUS ProArt P16
# =============================================================================
#
# WHY THIS EXISTS
# ---------------
# The ProArt P16 H7606WV uses an ITE 8910 USB HID keyboard controller.
# The kernel's hid-asus driver fails to initialise the backlight at boot
# (EOPNOTSUPP -75), so the standard tools don't work:
#   - brightnessctl: "Device '*::kbd_backlight' not found"
#   - asusctl leds:  "No sysfs brightness control"
#
# Brightness is instead controlled by sending raw HID feature reports via
# /usr/local/bin/asus-kbd-backlight (which requires root). A sudoers rule
# at /etc/sudoers.d/asus-kbd-backlight allows this user to call it without
# a password prompt.
#
# BRIGHTNESS LEVELS
# -----------------
#   0 = off   1 = low   2 = med   3 = high
#
# KEYBINDINGS (from Laptops.lua)
# ---------------
#   XF86KbdLightOnOff  → --inc (cycles 0→1→2→3→0)
#   xf86KbdBrightnessUp → --inc
#   xf86KbdBrightnessDown → --dec
# =============================================================================

iDIR="$HOME/.config/swaync/icons"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
get_level() {
    sudo /usr/local/bin/asus-kbd-backlight get 2>/dev/null || echo "2"
}

level_to_pct() {
    # 0→0%, 1→33%, 2→66%, 3→100%
    echo $(( $1 * 33 ))
}

get_icon() {
    local pct=$1
    if   [ "$pct" -le 20 ]; then echo "$iDIR/brightness-20.png"
    elif [ "$pct" -le 40 ]; then echo "$iDIR/brightness-40.png"
    elif [ "$pct" -le 60 ]; then echo "$iDIR/brightness-60.png"
    elif [ "$pct" -le 80 ]; then echo "$iDIR/brightness-80.png"
    else                          echo "$iDIR/brightness-100.png"
    fi
}

notify_brightness() {
    local level pct icon names=("off" "low" "med" "high")
    level=$(get_level)
    pct=$(level_to_pct "$level")
    icon=$(get_icon "$pct")
    notify-send -e \
        -h string:x-canonical-private-synchronous:brightness_notif \
        -h int:value:"$pct" \
        -h boolean:SWAYNC_BYPASS_DND:true \
        -u low -i "$icon" \
        "Keyboard" "Brightness: ${names[$level]}"
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------
case "$1" in
"--get")
    # Return percentage for waybar/scripts
    pct=$(level_to_pct "$(get_level)")
    echo "${pct}%"
    ;;
"--inc")
    sudo /usr/local/bin/asus-kbd-backlight inc > /dev/null
    notify_brightness
    ;;
"--dec")
    sudo /usr/local/bin/asus-kbd-backlight dec > /dev/null
    notify_brightness
    ;;
*)
    pct=$(level_to_pct "$(get_level)")
    echo "${pct}%"
    ;;
esac
