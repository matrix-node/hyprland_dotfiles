-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon")
	-- cliphist: watch clipboard and store history (requires cliphist + wl-clipboard)
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("sh -lc '~/.local/bin/restore-wallpaper'")
	hl.exec_cmd("sh -lc 'waybar & swaync'")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 30")
	hl.exec_cmd("hypridle")
end)
