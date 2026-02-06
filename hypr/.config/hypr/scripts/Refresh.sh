#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for refreshing ags, waybar, rofi, swaync, wallust

SCRIPTSDIR=$HOME/.config/hypr/scripts

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0 # File exists
    else
        return 1 # File does not exist
    fi
}

# Kill already running processes
_ps=(waybar rofi swaync ags)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# added since wallust sometimes not applying
killall -SIGUSR2 waybar
# Added sleep for GameMode causing multiple waybar
sleep 0.1

# quit ags & relaunch ags
ags -q && ags &

# quit quickshell & relaunch quickshell
#pkill qs && qs &

# some process to kill
for pid in $(pidof waybar rofi swaync ags swaybg); do
    kill -SIGUSR1 "$pid"
    sleep 0.1
done

#Restart waybar
sleep 0.1
waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css &

# relaunch swaync
sleep 0.3
swaync -c ~/.config/hypr/swaync/config.json >/dev/null 2>&1 &
# reload swaync
swaync-client --reload-config

# Relaunching rainbow borders if the script exists
~/.config/hypr/scripts/RainbowBorders.sh &
sleep 1

exit 0
