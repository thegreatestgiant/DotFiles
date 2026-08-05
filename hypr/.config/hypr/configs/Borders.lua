local function load_wallust()
	local colors = {}
	local path = os.getenv("HOME") .. "/.config/hypr/wallust/wallust-hyprland.conf"
	local f = io.open(path, "r")
	if f then
		for line in f:lines() do
			local k, v = line:match("^%$([%w_]+)%s*=%s*(.*)$")
			if k and v then
				colors[k] = v
			end
		end
		f:close()
	end
	return colors
end
local c = load_wallust()

hl.config({
	general = {
		border_size = 2,
		gaps_in = 5,
		gaps_out = 10,
		col = {
			active_border = c.color12,
			inactive_border = c.color10,
		},
	},
	decoration = {
		rounding = 10,
		active_opacity = 1.0,
		inactive_opacity = 0.9,
		fullscreen_opacity = 1.0,
		dim_inactive = true,
		dim_strength = 0.1,
		dim_special = 0.8,
		shadow = {
			enabled = true,
			range = 3,
			render_power = 1,
			color = c.color12,
			color_inactive = c.color10,
		},
		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			new_optimizations = true,
			xray = true,
			ignore_opacity = true,
			special = true,
			popups = true,
		},
	},
	group = {
		col = {
			border_active = c.color15,
		},
		groupbar = {
			col = {
				active = c.color0,
			},
		},
	},
})
