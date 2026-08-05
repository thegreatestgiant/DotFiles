#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for rainbow borders animation

function random_hex() {
    colors=("rgb(FF0000)" "rgb(FF7F00)" "rgb(FFFF00)" "rgb(00FF00)" "rgb(00FFFF)" "rgb(0000FF)" "rgb(8A2BE2)" "rgb(FF00FF)" "rgb(FF1493)" "rgb(00FA9A)")
    echo ${colors[$RANDOM % ${#colors[@]}]}
}

# rainbow colors only for active window
hyprctl keyword general:col.active_border $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) 270deg

# rainbow colors for inactive window (uncomment to take effect)
#hyprctl keyword general:col.inactive_border $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) $(random_hex) 270deg
