#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager. This script uses cliphist, rofi, and wl-copy.

# Variables
rofi_theme="$HOME/.config/hypr/rofi/config-clipboard.rasi"
msg='👀 <b>note</b>  CTRL+DEL = Delete Entry  |  CTRL+SHIFT+DEL = Wipe All'

# Check if rofi is already running
if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
fi

while true; do
    result=$(
        rofi -i -dmenu \
            -kb-custom-1 "Control+Delete" \
            -kb-custom-2 "Control+Shift+Delete" \
            -config "$rofi_theme" \
            -mesg "$msg" \
            -keep-right \
            < <(cliphist list)
    )

    # Store the exit code immediately
    exit_code=$?

    case "$exit_code" in
    1) # Escape / Close
        exit
        ;;
    0) # Select Entry (Enter)
        case "$result" in
        "") continue ;;
        *)
            cliphist decode <<<"$result" | wl-copy
            exit
            ;;
        esac
        ;;
    10) # Control+Delete (Delete Entry)
        cliphist delete <<<"$result"
        ;;
    11) # Alt+Delete (Wipe All)
        cliphist wipe
        ;;
    esac
done
