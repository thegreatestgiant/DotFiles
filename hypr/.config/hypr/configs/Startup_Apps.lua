local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
-- local lock = scriptsDir .. "/LockScreen.sh"
local AwwwRandom = scriptsDir .. "/WallpaperAutoChange.sh"
local wallDIR = os.getenv("HOME") .. "/Pictures/wallpapers"

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("$HOME/.config/hypr/scripts/Dropterminal.sh kitty &")
	hl.exec_cmd(scriptsDir .. "/Polkit.sh")
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("swaync -c ~/.config/hypr/swaync/config.json")
	hl.exec_cmd("rog-control-center")
	hl.exec_cmd("waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css &")
	hl.exec_cmd("hypridle")
	hl.exec_cmd(scriptsDir .. "/Hyprsunset.sh daemon &")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd(AwwwRandom .. " " .. wallDIR)
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("ags")
	hl.exec_cmd(scriptsDir .. "/KeybindsLayoutInit.sh")
end)
