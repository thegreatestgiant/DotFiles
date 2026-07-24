#!/bin/bash

ACTION=$1
CURRENT=$(gsettings get org.gnome.desktop.interface text-scaling-factor)

if [ "$ACTION" == "up" ]; then
    NEW=$(awk "BEGIN {print $CURRENT + 0.25}")
elif [ "$ACTION" == "down" ]; then
    # Prevent scaling too small
    NEW=$(awk "BEGIN {if ($CURRENT > 0.5) print $CURRENT - 0.25; else print $CURRENT}")
elif [ "$ACTION" == "reset" ]; then
    NEW=1.0
else
    echo "Usage: $0 {up|down|reset}"
    exit 1
fi

gsettings set org.gnome.desktop.interface text-scaling-factor $NEW
notify-send -t 1500 -h string:x-canonical-private-synchronous:gtk_scale "GTK Text Scale" "Scale set to $NEW"
