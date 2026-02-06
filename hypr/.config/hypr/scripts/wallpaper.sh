#!/usr/bin/env bash
# Unified Wallpaper Manager - replaces 4 separate scripts
# Usage: wallpaper.sh [--select|--random|--auto|--set <path>]

PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
WALLDIR="${WALLDIR:-$PICTURES_DIR/wallpapers}"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
ROFI_THEME="$HOME/.config/rofi/config-wallpaper.rasi"

# Auto-change interval in seconds (default 30 minutes)
INTERVAL="${WALLPAPER_INTERVAL:-1800}"

# Get focused monitor
get_focused_monitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
}

# Apply wallpaper and update theme
apply_wallpaper() {
    local wallpaper="$1"
    local monitor="${2:-$(get_focused_monitor)}"
    
    # Ensure swww daemon is running
    if ! pgrep -x swww-daemon >/dev/null; then
        swww-daemon --format xrgb &
        sleep 0.5
    fi
    
    # Apply wallpaper
    swww img -o "$monitor" "$wallpaper" \
        --transition-fps 60 \
        --transition-type random \
        --transition-duration 2
    
    # Update color scheme
    "$SCRIPTSDIR/WallustSwww.sh" "$wallpaper"
    
    # Refresh UI
    sleep 2
    "$SCRIPTSDIR/Refresh.sh"
}

# Select wallpaper with rofi
select_wallpaper() {
    mapfile -d '' wallpapers < <(find -L "$WALLDIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
           -o -iname "*.gif" -o -iname "*.webp" \) -print0)
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        notify-send -u critical "No wallpapers found in $WALLDIR"
        exit 1
    fi
    
    # Create rofi menu
    local choice
    choice=$(printf '%s\0icon\x1f%s\n' ". Random" "${wallpapers[0]}"
        for wp in "${wallpapers[@]}"; do
            printf '%s\0icon\x1f%s\n' "$(basename "$wp")" "$wp"
        done | rofi -dmenu -i -p "Wallpaper" -theme "$ROFI_THEME")
    
    [ -z "$choice" ] && exit 0
    
    if [ "$choice" = ". Random" ]; then
        random_wallpaper
    else
        local selected="${wallpapers[0]}"
        for wp in "${wallpapers[@]}"; do
            [ "$(basename "$wp")" = "$choice" ] && selected="$wp" && break
        done
        apply_wallpaper "$selected"
    fi
}

# Set random wallpaper
random_wallpaper() {
    mapfile -d '' wallpapers < <(find -L "$WALLDIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
           -o -iname "*.gif" -o -iname "*.webp" \) -print0)
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        notify-send -u critical "No wallpapers found in $WALLDIR"
        exit 1
    fi
    
    local random_wp="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    apply_wallpaper "$random_wp"
}

# Auto-change wallpapers on interval
auto_change() {
    local monitor="$(get_focused_monitor)"
    
    while true; do
        mapfile -d '' wallpapers < <(find -L "$WALLDIR" -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
               -o -iname "*.gif" -o -iname "*.webp" \) -print0 | shuf -z)
        
        for wallpaper in "${wallpapers[@]}"; do
            apply_wallpaper "$wallpaper" "$monitor"
            sleep "$INTERVAL"
        done
    done
}

# Main
case "${1:-}" in
    --select|-s)
        select_wallpaper
        ;;
    --random|-r)
        random_wallpaper
        ;;
    --auto|-a)
        auto_change
        ;;
    --set)
        [ -z "$2" ] && { echo "Usage: $0 --set <wallpaper_path>"; exit 1; }
        [ -f "$2" ] || { echo "File not found: $2"; exit 1; }
        apply_wallpaper "$2"
        ;;
    *)
        cat <<EOF
Unified Wallpaper Manager

Usage: $0 [option]

Options:
  --select, -s          Interactive wallpaper selection
  --random, -r          Set random wallpaper
  --auto, -a            Auto-rotate wallpapers every ${INTERVAL}s
  --set <path>          Set specific wallpaper

Environment Variables:
  WALLDIR              Wallpaper directory (default: ~/Pictures/wallpapers)
  WALLPAPER_INTERVAL   Auto-change interval in seconds (default: 1800)

Examples:
  $0 --select                    # Choose wallpaper with rofi
  $0 --random                    # Random wallpaper now
  WALLPAPER_INTERVAL=600 $0 -a   # Auto-change every 10 minutes
EOF
        exit 0
        ;;
esac
