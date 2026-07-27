#!/usr/bin/env bash

# Find the current wallpaper using the rofi symlink
current_wp=$(readlink -f "$HOME/.config/hypr/rofi/.current_wallpaper")

if [ ! -f "$current_wp" ]; then
    echo "Could not find current wallpaper. Symbolic link might be broken."
    exit 1
fi

echo "Current wallpaper: $current_wp"

read -p "Delete this wallpaper? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -f "$current_wp"
    echo "Deleted $current_wp"
    
    # Trigger a random wallpaper to replace it
    if [ -f "$HOME/.config/hypr/scripts/WallpaperRandom.sh" ]; then
        echo "Selecting a new random wallpaper..."
        "$HOME/.config/hypr/scripts/WallpaperRandom.sh"
    fi
else
    echo "Aborted."
fi
