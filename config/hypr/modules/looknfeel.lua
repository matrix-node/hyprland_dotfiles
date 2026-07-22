-----------------------
---- LOOK AND FEEL ----
-----------------------

package.loaded["colors"] = nil

local fallback_colors = {
	primary = "rgb(f5eecb)",
	outline_variant = "rgba(595959aa)",
	shadow = "rgba(000000e0)",
}

local ok, colors = pcall(require, "colors")

if not ok or type(colors) ~= "table" then
	colors = fallback_colors
end

colors.primary = colors.primary or fallback_colors.primary
colors.outline_variant = colors.outline_variant or fallback_colors.outline_variant
colors.shadow = colors.shadow or fallback_colors.shadow

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 8,
		gaps_out = 16,

		border_size = 2,

		col = {
			active_border = colors.primary,
			inactive_border = colors.outline_variant,
		},

		resize_on_border = false,
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		active_opacity = 0.95,
		inactive_opacity = 0.85,

		shadow = {
			enabled = true,
			range = 20,
			render_power = 4,
			color = colors.shadow,
		},

		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			vibrancy = 0.5,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Curves
-- classicIn  : hard settle on open (ease-out expo-ish) — arrives with weight
-- classicOut : commits into the center on close (ease-in) — no soft linger
-- overshoot  : tiny confident land for moves (not used on open/close)
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("classicIn", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("classicOut", { type = "bezier", points = { { 0.7, 0 }, { 0.84, 0 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs (moves / drag — buttery, not bouncy)
hl.curve("easy", { type = "spring", mass = 1, stiffness = 88, dampening = 18 })

hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "classicIn" })
hl.animation({ leaf = "border", enabled = true, speed = 4.5, bezier = "classicIn" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.2, spring = "easy" })

-- Open: grow from center — solid seed (15%), slow enough to read (~700ms)
--   speed is in ds (1 = 100ms). Keep open a touch longer than close.
hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 7.0,
	bezier = "classicIn",
	style = "popin 15%",
})
-- Close: shrink to center and vanish (~600ms) — still decisive, but visible
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 6.0,
	bezier = "classicOut",
	style = "popin 15%",
})

-- Fade rides with the popin (same ballpark so scale + opacity stay readable)
hl.animation({ leaf = "fadeIn", enabled = true, speed = 6.5, bezier = "classicIn" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 5.5, bezier = "classicOut" })
hl.animation({ leaf = "fade", enabled = true, speed = 5.0, bezier = "classicIn" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Smart gaps / no gaps when only:
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
