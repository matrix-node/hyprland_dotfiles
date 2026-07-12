----------------
---- LAYOUT ----
----------------

-- Single active layout: master (matches runtime preference).
-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/

hl.config({
	general = {
		layout = "master",
	},
	master = {
		new_status = "master",
		mfact = 0.55,
	},
})
