configs = os.getenv("HOME") .. "/.config/hypr/configs"

require("configs.ENVariables")
require("configs.Keybinds")

-- Load defaults, then user additions/overrides
require("configs.Startup_Apps")

-- For laptop related
require("configs.Laptops")

-- Load defaults, then user additions
require("configs.WindowRules")
require("configs.SystemSettings")
require("configs.Animations")
require("configs.Borders")

-- nwg-displays
require("monitors")
require("workspaces")

hl.on("hyprland.start", function()
	hl.exec_cmd("$HOME/.config/hypr/initial-boot.sh")
end)
