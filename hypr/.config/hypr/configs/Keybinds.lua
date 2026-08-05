local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
-- local rofiPath = os.getenv("HOME") .. "/.config/hypr/rofi/config.rasi"

local function bind(key, action, desc, opts)
	opts = opts or {}
	if desc then
		opts.description = desc
	end
	if type(action) == "string" then
		action = hl.dsp.exec_cmd(action)
	end
	hl.bind(key, action, opts)
end

-- -----------------------------------------------------
-- 🚀 APPLICATIONS & LAUNCHERS
-- -----------------------------------------------------
bind(
	"ALT + SPACE",
	"pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window -config ~/.config/hypr/rofi/config.rasi",
	"app launcher"
)
bind(mainMod .. " + Return", term, "Open terminal")
bind(mainMod .. " + E", files, "file manager")
bind(mainMod .. " + B", 'env ELECTRON_OZONE_PLATFORM_HINT=wayland xdg-open "https://"', "open default browser")
bind(mainMod .. " + O", "obsidian", "Obsidian")
bind(mainMod .. " + X", "brave-browser --app-id=hnpfjngllnobngcgfapefoaidbinmjnm", "WhatsApp")
bind("F12", "rog-control-center", "Open the G-Helper Equiv")

-- -----------------------------------------------------
-- 📋 FEATURES / EXTRAS
-- -----------------------------------------------------
bind(mainMod .. " + SHIFT + SLASH", scriptsDir .. "/KeyHints.sh", "help / cheat sheet")
bind(mainMod .. " + ALT + R", scriptsDir .. "/Refresh.sh", "refresh bar and menus")
bind(mainMod .. " + period", scriptsDir .. "/RofiEmoji.sh", "emoji menu")
bind(mainMod .. " + S", scriptsDir .. "/RofiSearch.sh", "web search")
bind(mainMod .. " + V", scriptsDir .. "/ClipManager.sh", "clipboard manager")
bind(mainMod .. " + C", scriptsDir .. "/RofiCalc.sh", "calculator")
bind(mainMod .. " + W", scriptsDir .. "/WallpaperSelect.sh", "select wallpaper")
bind("CTRL + ALT + W", scriptsDir .. "/WallpaperRandom.sh", "random wallpaper")
bind(mainMod .. " + SHIFT + M", scriptsDir .. "/RofiBeats.sh", "online music")
bind(mainMod .. " + SLASH", scriptsDir .. "/KeyBinds.sh", "search keybinds")
bind(mainMod .. " + A", scriptsDir .. "/OverviewToggle.sh", "desktop overview")

-- -----------------------------------------------------
-- 🪟 WINDOW MANAGEMENT
-- -----------------------------------------------------
bind(mainMod .. " + Q", hl.dsp.window.close(), "close active window")
bind(mainMod .. " + SHIFT + Q", function()
	local win = hl.get_active_window()
	if win and win.pid then
		os.execute("kill -9 " .. tostring(win.pid))
	end
end, "Terminate active process natively")
bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }), "Float current window")
bind(mainMod .. " + ALT + SPACE", "hyprctl dispatch workspaceopt allfloat", "Float all windows")
bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), "fullscreen")
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), "maximize window")
bind(
	mainMod .. " + O",
	hl.dsp.window.set_prop({ prop = "opaque", value = "toggle", window = "active" }),
	"toggle active window opacity"
)
bind(mainMod .. " + grave", scriptsDir .. "/Dropterminal.sh $term", "DropDown terminal")

-- -----------------------------------------------------
-- 🎯 FOCUS & NAVIGATION
-- -----------------------------------------------------
bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), "focus left")
bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), "focus right")
bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), "focus up")
bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), "focus down")
bind("ALT + tab", hl.dsp.window.cycle_next({ next = true }), "cycle next window")
bind("ALT + tab", hl.dsp.window.bring_to_top(), "bring active to top")

-- -----------------------------------------------------
-- 🏗️ LAYOUT CONTROLS (Master)
-- -----------------------------------------------------
bind(mainMod .. " + CTRL + D", hl.dsp.layout("removemaster"), "remove master")
bind(mainMod .. " + I", hl.dsp.layout("addmaster"), "add master")
bind(mainMod .. " + SHIFT + Return", hl.dsp.layout("swapwithmaster"), "swap with master")

-- -----------------------------------------------------
-- 🖥️ WORKSPACE CONTROLS
-- -----------------------------------------------------
bind(mainMod .. " + tab", hl.dsp.focus({ workspace = "m+1" }), "next workspace")
bind(mainMod .. " + SHIFT + tab", hl.dsp.focus({ workspace = "m-1" }), "previous workspace")
bind(mainMod .. " + U", hl.dsp.workspace.toggle_special(""), "toggle special workspace")
bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special" }), "move to special workspace")
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "next workspace")
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "previous workspace")

-- Monitor switching
bind(mainMod .. " + CTRL + F9", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "l" }))
end, "move workspace to left monitor")
bind(mainMod .. " + CTRL + F10", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "r" }))
end, "move workspace to right monitor")
bind(mainMod .. " + CTRL + F11", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "u" }))
end, "move workspace to up monitor")
bind(mainMod .. " + CTRL + F12", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "d" }))
end, "move workspace to down monitor")

-- Numeric workspace switching (1-10)
bind(mainMod .. " + code:10", hl.dsp.focus({ workspace = 1 }), "workspace 1")
bind(mainMod .. " + code:11", hl.dsp.focus({ workspace = 2 }), "workspace 2")
bind(mainMod .. " + code:12", hl.dsp.focus({ workspace = 3 }), "workspace 3")
bind(mainMod .. " + code:13", hl.dsp.focus({ workspace = 4 }), "workspace 4")
bind(mainMod .. " + code:14", hl.dsp.focus({ workspace = 5 }), "workspace 5")
bind(mainMod .. " + code:15", hl.dsp.focus({ workspace = 6 }), "workspace 6")
bind(mainMod .. " + code:16", hl.dsp.focus({ workspace = 7 }), "workspace 7")
bind(mainMod .. " + code:17", hl.dsp.focus({ workspace = 8 }), "workspace 8")
bind(mainMod .. " + code:18", hl.dsp.focus({ workspace = 9 }), "workspace 9")
bind(mainMod .. " + code:19", hl.dsp.focus({ workspace = 10 }), "workspace 10")

-- Move window to workspace (1-10)
bind(mainMod .. " + SHIFT + code:10", hl.dsp.window.move({ workspace = 1 }), "move to workspace 1")
bind(mainMod .. " + SHIFT + code:11", hl.dsp.window.move({ workspace = 2 }), "move to workspace 2")
bind(mainMod .. " + SHIFT + code:12", hl.dsp.window.move({ workspace = 3 }), "move to workspace 3")
bind(mainMod .. " + SHIFT + code:13", hl.dsp.window.move({ workspace = 4 }), "move to workspace 4")
bind(mainMod .. " + SHIFT + code:14", hl.dsp.window.move({ workspace = 5 }), "move to workspace 5")
bind(mainMod .. " + SHIFT + code:15", hl.dsp.window.move({ workspace = 6 }), "move to workspace 6")
bind(mainMod .. " + SHIFT + code:16", hl.dsp.window.move({ workspace = 7 }), "move to workspace 7")
bind(mainMod .. " + SHIFT + code:17", hl.dsp.window.move({ workspace = 8 }), "move to workspace 8")
bind(mainMod .. " + SHIFT + code:18", hl.dsp.window.move({ workspace = 9 }), "move to workspace 9")
bind(mainMod .. " + SHIFT + code:19", hl.dsp.window.move({ workspace = 10 }), "move to workspace 10")

-- -----------------------------------------------------
-- 🛠️ SYSTEM & HARDWARE
-- -----------------------------------------------------
bind("CTRL + ALT + Delete", hl.dsp.exit(), "exit Hyprland")
bind("CTRL + ALT + L", scriptsDir .. "/LockScreen.sh", "lock screen")
bind(mainMod .. " + P", scriptsDir .. "/Wlogout.sh", "powermenu")
bind(mainMod .. " + N", "swaync-client -t -sw", "notification panel")
bind(mainMod .. " + SHIFT + E", scriptsDir .. "/Kool_Quick_Settings.sh", "Quick settings menu")
bind(mainMod .. " + SHIFT + B", "pkill -SIGUSR1 waybar", "toggle waybar on/off")
bind(
	"ALT_L + SHIFT_L",
	hl.dsp.exec_cmd(scriptsDir .. "/KeyboardLayout.sh switch"),
	"switch keyboard layout globally",
	{ locked = true, non_consuming = true }
)

-- Media & Hardware Keys
bind(
	"xf86audioraisevolume",
	hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --inc"),
	"volume up",
	{ locked = true, repeating = true }
)
bind(
	"xf86audiolowervolume",
	hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --dec"),
	"volume down",
	{ locked = true, repeating = true }
)
bind("xf86AudioMicMute", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle-mic"), "toggle mic mute", { locked = true })
bind("xf86Sleep", hl.dsp.exec_cmd("systemctl suspend"), "sleep", { locked = true })
bind("xf86Rfkill", hl.dsp.exec_cmd(scriptsDir .. "/AirplaneMode.sh"), "airplane mode", { locked = true })
bind("Print", scriptsDir .. "/ScreenShot.sh --swappy", "screenshot (swappy)")

-- -----------------------------------------------------
-- 📏 RESIZE, MOVE, & SWAP (Mouse/Keyboard)
-- -----------------------------------------------------
bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), nil, { repeating = true })
bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), nil, { repeating = true })
bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), nil, { repeating = true })
bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), nil, { repeating = true })

hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + ALT + h", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + ALT + l", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + ALT + k", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + ALT + j", hl.dsp.window.swap({ direction = "d" }))

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "move window")
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "resize window")

-- -----------------------------------------------------
-- 🔄 MODAL SUBMAPS
-- -----------------------------------------------------
-- Resize Submap (Super + R)
bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	bind("h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), nil, { repeating = true })
	bind("l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), nil, { repeating = true })
	bind("k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), nil, { repeating = true })
	bind("j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), nil, { repeating = true })

	-- GTK Ad-Hoc Text Scaler
	bind("equal", hl.dsp.exec_cmd(scriptsDir .. "/GtkScale.sh up"), nil, { repeating = true })
	bind("minus", hl.dsp.exec_cmd(scriptsDir .. "/GtkScale.sh down"), nil, { repeating = true })
	bind("backspace", scriptsDir .. "/GtkScale.sh reset")

	bind("escape", hl.dsp.submap("reset"))
	bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

-- Move Submap (Super + D)
bind(mainMod .. " + D", hl.dsp.submap("move"))
hl.define_submap("move", function()
	hl.bind("h", hl.dsp.window.move({ direction = "l" }))
	hl.bind("l", hl.dsp.window.move({ direction = "r" }))
	hl.bind("k", hl.dsp.window.move({ direction = "u" }))
	hl.bind("j", hl.dsp.window.move({ direction = "d" }))
	hl.bind(1, hl.dsp.window.move({ workspace = 1 }))
	hl.bind(2, hl.dsp.window.move({ workspace = 2 }))
	hl.bind(3, hl.dsp.window.move({ workspace = 3 }))
	hl.bind(4, hl.dsp.window.move({ workspace = 4 }))
	hl.bind(5, hl.dsp.window.move({ workspace = 5 }))
	hl.bind(6, hl.dsp.window.move({ workspace = 6 }))
	hl.bind(7, hl.dsp.window.move({ workspace = 7 }))
	hl.bind(8, hl.dsp.window.move({ workspace = 8 }))
	hl.bind(9, hl.dsp.window.move({ workspace = 9 }))
	hl.bind(0, hl.dsp.window.move({ workspace = 10 }))
	bind("escape", hl.dsp.submap("reset"))
	bind(mainMod .. " + D", hl.dsp.submap("reset"))
end)
