#!/bin/bash

# 1. Open rofimoji and capture the chosen emoji
# Using '--action print' so it simply outputs the result instead of typing or copying
chosen=$(rofimoji --action print --selector-args="-config $HOME/.config/hypr/rofi/config-emoji.rasi")

# 2. Exit cleanly if nothing was selected (e.g., you pressed Escape)
if [ -z "$chosen" ]; then
    exit 0
fi

# 3. Wait for Rofi to close and the window underneath to regain focus
sleep 0.3

# 4. Type the emoji directly into the active window
wtype "$chosen"
