local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.gesture({
	fingers = 4,
	direction = "up",
	action = function()
		hl.exec_cmd(
			"hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 1.5}')\""
		)
	end,
})

hl.gesture({
	fingers = 4,
	direction = "down",
	action = function()
		hl.exec_cmd(
			"hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 1.5}')\""
		)
	end,
})

hl.gesture({
	fingers = 3,
	direction = "up",
	action = function()
		hl.exec_cmd(scriptsDir .. "/OverviewToggle.sh")
	end,
})

hl.config({
	master = {
		allow_small_split = true,
		new_status = "slave",
		new_on_top = 1,
		mfact = 0.6,
		smart_resizing = true,
	},
	general = {
		resize_on_border = true,
		layout = "master",
	},
	input = {
		kb_layout = "us, il",
		kb_variant = ",",
		kb_model = "",
		kb_options = "caps:swapescape",
		kb_rules = "",
		repeat_rate = 50,
		repeat_delay = 300,
		sensitivity = 0, --mouse sensitivity
		--accel_profile =     # flat or adaptive or blank or EMPTY means libinput’s default mode
		numlock_by_default = true,
		left_handed = false,
		follow_mouse = 1,
		float_switch_override_focus = false,
		touchpad = {
			disable_while_typing = true,
			natural_scroll = true,
			clickfinger_behavior = false,
			middle_button_emulation = true,
			tap_to_click = true,
			drag_lock = false,
		},
		-- below for devices with touchdevice ie. touchscreen
		touchdevice = {
			enabled = true,
		},
		tablet = {
			transform = 0,
			left_handed = 0,
		},
	},
	gestures = {
		workspace_swipe_distance = 500,
		workspace_swipe_invert = true,
		workspace_swipe_min_speed_to_force = 30,
		workspace_swipe_cancel_ratio = 0.5,
		workspace_swipe_create_new = true,
		workspace_swipe_forever = true,
		--workspace_swipe_use_r = true #uncomment if wanted a forever create a new workspace with swipe right
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		-- vfr = true
		vrr = 2,
		mouse_move_enables_dpms = true,
		enable_swallow = false,
		swallow_regex = "^(kitty)$",
		focus_on_activate = false,
		initial_workspace_tracking = 0,
		middle_click_paste = false,
		enable_anr_dialog = true,
		anr_missed_pings = 15,
		allow_session_lock_restore = true,
		on_focus_under_fullscreen = 1,
		-- 2 - New focused window stays behind the fullscreen one
	},
	--opengl {
	--  nvidia_anti_flicker = true
	--}
	binds = {
		workspace_back_and_forth = true,
		allow_workspace_cycles = true,
		pass_mouse_when_bound = false,
	},
	--Could help when scaling and not pixelating
	xwayland = {
		enabled = true,
		force_zero_scaling = true,
	},
	render = {
		direct_scanout = 0,
	},
	cursor = {
		sync_gsettings_theme = true,
		no_hardware_cursors = true, -- change to 1 if want to disable
		enable_hyprcursor = true,
		warp_on_change_workspace = 2,
		no_warps = false,
	},
})
