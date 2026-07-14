-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Ensure user scripts (cliphist-picker, wallpaper helpers) are always found
local home = os.getenv("HOME") or ""
local path = os.getenv("PATH") or "/usr/bin"
local local_bin = home .. "/.local/bin"
if home ~= "" and not path:find(local_bin, 1, true) then
	path = local_bin .. ":" .. path
end
hl.env("PATH", path)

hl.env("XCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_SIZE", "30")

-- Qt / GTK / Electron on Wayland
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
