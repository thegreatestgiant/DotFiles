#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for rainbow borders animation

function random_hex() {
    colors=("'rgb(FF0000)'" "'rgb(FF7F00)'" "'rgb(FFFF00)'" "'rgb(00FF00)'" "'rgb(00FFFF)'" "'rgb(0000FF)'" "'rgb(8A2BE2)'" "'rgb(FF00FF)'" "'rgb(FF1493)'" "'rgb(00FA9A)'")
    echo ${colors[$RANDOM % ${#colors[@]}]}
}

c1=$(random_hex)
c2=$(random_hex)
c3=$(random_hex)
c4=$(random_hex)
c5=$(random_hex)
c6=$(random_hex)
c7=$(random_hex)
c8=$(random_hex)
c9=$(random_hex)
c10=$(random_hex)

# rainbow colors only for active window via Lua eval
hyprctl eval "hl.config({ general = { col = { active_border = { colors = { $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $c10 }, angle = 270 } } } })"

# rainbow colors for inactive window (uncomment to take effect)
# hyprctl eval "hl.config({ general = { col = { inactive_border = { colors = { $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $c10 }, angle = 270 } } } })"
