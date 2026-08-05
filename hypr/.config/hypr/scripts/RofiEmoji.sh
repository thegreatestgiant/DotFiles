#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"

# Natively run rofimoji. Do not capture stdout as it breaks Wayland surface creation on some setups.
rofimoji --action type --selector rofi --selector-args="-config $HOME/.config/hypr/rofi/config-emoji.rasi"
