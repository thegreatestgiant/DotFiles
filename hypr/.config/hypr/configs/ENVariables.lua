---@diagnostic disable: lowercase-global
edit = "${EDITOR:-vim}"
term = "kitty"
files = "thunar"
Search_Engine = '"https://www.google.com/search?q={}"'

hl.env("EDITOR", "nvim")

hl.env("HL_GPU_DEVICE", "0")

--## Toolkit Backend Variables ###
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")

--## XDG Specifications ###
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

--## QT Variables ###
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

--## hyprland-qt-support ###
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")

--## xwayland apps scale fix (useful if you are use monitor scaling) ###
-- Set same value if you use scaling in Monitors.conf
-- 1 is 100% 1.5 is 150%
-- see https://wiki.hyprland.org/Configuring/XWayland/
hl.env("GDK_SCALE", "2")
hl.env("QT_SCALE_FACTOR", "1")

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
