--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})
-- Float waypaper wallpaper picker
hl.window_rule({
	name = "float-waypaper",
	match = { title = "Waypaper" },
	float = true,
})

-- Blur behind rofi and wlogout (macOS-style glass effect)
hl.config({
    layerrule = {
        "blur, rofi",
        "ignorezero, rofi",
        "blur, wlogout",
        "ignorezero, wlogout"
    }
})
