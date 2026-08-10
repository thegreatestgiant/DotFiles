#!/usr/bin/env bash
# Dropdown Terminal for Hyprland
# Toggle a persistent dropdown terminal that lives in a special workspace.
# This prevents it from stealing focus when changing desktops, and handles its own state natively.

# Dynamically set rules for this specific special workspace
hyprctl eval 'hl.config({ decoration = { blur = { special = false } } })' >/dev/null 2>&1
hyprctl eval 'hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "wind", style = "slidevert" })' >/dev/null 2>&1

# Check if kitty-dropterm exists
if ! hyprctl clients -j | jq -e 'any(.[]; .class == "kitty-dropterm")' > /dev/null; then
    # Doesn't exist, spawn it. 
    hyprctl dispatch "hl.dsp.exec_cmd('kitty --class kitty-dropterm')" >/dev/null 2>&1
    
    # Wait for it to appear
    for _ in {1..30}; do
        if hyprctl clients -j | jq -e 'any(.[]; .class == "kitty-dropterm")' > /dev/null; then
            break
        fi
        sleep 0.1
    done

    # Force precise size and position based on the focused monitor
    INFO=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height) \(.scale)"')
    if [[ -n "$INFO" ]]; then
        read -r mx my mw mh mscale <<< "$INFO"
        
        # Calculate logical dimensions
        if command -v bc >/dev/null 2>&1; then
            lw=$(echo "scale=0; $mw / $mscale" | bc | cut -d. -f1)
            lh=$(echo "scale=0; $mh / $mscale" | bc | cut -d. -f1)
        else
            lw=$mw; lh=$mh
        fi
        
        w=$(( lw * 65 / 100 ))
        h=$(( lh * 65 / 100 ))
        x=$(( (lw - w) / 2 + mx ))
        y=$(( (lh - h) / 2 + my )) # Middle of the screen
        
        hyprctl dispatch "hl.dsp.window.resize({ x = $w, y = $h, exact = true, window = 'class:kitty-dropterm' })" >/dev/null 2>&1
        hyprctl dispatch "hl.dsp.window.move({ x = $x, y = $y, exact = true, window = 'class:kitty-dropterm' })" >/dev/null 2>&1
    fi
else
    # Window already exists, so we manually toggle the special workspace natively
    hyprctl dispatch "hl.dsp.workspace.toggle_special('dropdown')" >/dev/null 2>&1
fi
