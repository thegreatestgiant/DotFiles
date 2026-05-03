#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# /* Calculator (using qalculate) and rofi */
# /* Submitted by: https://github.com/JosephArmas */
# /* Updated with dependency checks by Coding Partner */

rofi_theme="$HOME/.config/hypr/rofi/config-calc.rasi"

# Check if necessary dependencies are installed
if ! command -v qalc &> /dev/null; then
    rofi -e "Dependency missing: Please install 'libqalculate' (provides qalc)."
    exit 1
fi

if ! command -v wl-copy &> /dev/null; then
    rofi -e "Dependency missing: Please install 'wl-clipboard' (provides wl-copy)."
    exit 1
fi

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

# main function
result=""
calc_result=""

while true; do
    result=$(
        rofi -i -dmenu \
            -config "$rofi_theme" \
            -mesg "$result      =    $calc_result"
    )

    # If the user presses escape or cancels, exit the loop cleanly
    if [ $? -ne 0 ]; then
        exit 0
    fi

    # If the user typed something, calculate it and copy to clipboard
    if [ -n "$result" ]; then
        calc_result=$(qalc -t "$result")
        echo "$calc_result" | wl-copy
    fi
done
