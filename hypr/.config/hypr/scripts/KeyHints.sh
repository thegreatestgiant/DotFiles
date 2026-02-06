#!/usr/bin/env bash

# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# Check if rofi or yad is running and kill them if they are
if pidof rofi >/dev/null; then
    pkill rofi
fi

if pidof yad >/dev/null; then
    pkill yad
fi

# Launch yad with calculated width and height
GDK_BACKEND=$BACKEND yad \
    --center \
    --title="KooL Quick Cheat Sheet" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
    "ESC" "Close this app" "" \
    "" "SUPER KEY (Windows Key)" "(Mod Key)" \
    "" "" "" \
    "<b>🚨 EMERGENCY</b>" "" "" \
    "Shift + Super + Q" "Kill Active Process" "KillActiveProcess.sh" \
    "Ctrl + Alt + L" "Lock Screen" "LockScreen.sh" \
    "Ctrl + Alt + Del" "Exit Hyprland" "exit" \
    "" "" "" \
    "<b>🟢 APPLICATIONS</b>" "" "" \
    "ALT + Space" "App Launcher" "Rofi" \
    "Super + Enter" "Terminal (Kitty)" "kitty" \
    "Ctrl + Alt + T" "Terminal (Ubuntu Style)" "kitty" \
    "Super + B" "Web Browser" "brave" \
    "Super + E" "File Manager" "thunar" \
    "Super + ." "Emoji Picker" "RofiEmoji.sh" \
    "Super + V" "Clipboard Manager" "ClipManager.sh" \
    "Super + C" "Calculator" "RofiCalc.sh" \
    "Super + Grave" "Dropdown Terminal" "Dropterminal.sh" \
    "" "" "" \
    "<b>🔵 WINDOWS (VIM)</b>" "" "" \
    "Super + Q" "Close Window" "killactive" \
    "Super + F" "Maximize (Toggle)" "fullscreen 1" \
    "Shift + Super + F" "True Fullscreen" "fullscreen 0" \
    "Super + Space" "Float Window" "togglefloating" \
    "Super + Alt + Space" "Float All" "workspaceopt allfloat" \
    "Super + H/J/K/L" "Move Focus" "movefocus" \
    "Shift + Super + H/J/K/L" "Move Window (Throw)" "movewindow" \
    "" "" "" \
    "<b>💥 MODAL MODES</b>" "" "" \
    "Super + R" "Resize Mode (H/J/K/L)" "submap resize" \
    "Super + D" "Move Mode (H/J/K/L + 1-0)" "submap move" \
    "" "" "" \
    "<b>🟣 SYSTEM And MEDIA</b>" "" "" \
    "Ctrl + Alt + P" "Power Menu" "Wlogout.sh" \
    "Shift + Super + N" "Notification Panel" "swaync-client" \
    "Shift + Super + E" "Quick Settings" "Kool_Quick_Settings.sh" \
    "Shift + Super + B" "Toggle Waybar" "pkill -SIGUSR1 waybar" \
    "Shift + Super + W" "Wallpaper Effects" "WallpaperEffects.sh" \
    "Super + W" "Wallpaper Select" "WallpaperSelect.sh" \
    "Ctrl + Alt + W" "Random Wallpaper" "WallpaperRandom.sh" \
    "Print" "Screenshot" "ScreenShot.sh" \
    "" "" "" \
    "<b>⚪ MISC</b>" "" "" \
    "Shift + Super + /" "KeyHints (This Help)" "KeyHints.sh" \
    "Super + Alt + R" "Reload Hyprland" "hyprctl reload"
