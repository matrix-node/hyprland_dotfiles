--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

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

-- Full opacity for productivity surfaces (override global glass opacity)
local opaque_apps = {
	{ name = "opaque-kitty", class = "kitty" },
	{ name = "opaque-ghostty", class = "com.mitchellh.ghostty" },
	{ name = "opaque-code", class = "Code" },
	{ name = "opaque-code-oss", class = "code-oss" },
	{ name = "opaque-brave", class = "brave-origin-nightly" },
	{ name = "opaque-brave-browser", class = "Brave-browser" },
	{ name = "opaque-firefox", class = "firefox" },
	{ name = "opaque-zen", class = "zen-beta" },
	{ name = "opaque-zen-release", class = "zen" },
}

for _, app in ipairs(opaque_apps) do
	hl.window_rule({
		name = app.name,
		match = { class = app.class },
		-- Absolute opacity (active / inactive / fullscreen)
		opacity = "1.0 override 1.0 override 1.0 override",
		opaque = true,
	})
end

-- Layer blur (HyprLua API — not classic layerrule strings)
hl.layer_rule({
	name = "blur-rofi",
	match = { namespace = "rofi" },
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "blur-wlogout",
	match = { namespace = "wlogout" },
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "blur-swaync-cc",
	match = { namespace = "swaync-control-center" },
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "blur-swaync-notif",
	match = { namespace = "swaync-notification-window" },
	blur = true,
	ignore_alpha = 0,
})