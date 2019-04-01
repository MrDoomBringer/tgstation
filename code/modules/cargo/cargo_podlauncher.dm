/obj/machinery/computer/cargo_podlauncher
	name = "cargo pod launcher console"
	icon = "supplypods.dmi"
	icon_state = "cargo_podlauncher_nosilo"
	desc = "This console allows the user to bring DEATH upon the station"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	req_access = list(ACCESS_QM)
	var/builtSilo = FALSE

/obj/machinery/computer/cargo_podlauncher/Initialize()
	. = ..()
	
/obj/machinery/computer/cargo_podlauncher/ui_interact(mob/living/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo_podlauncher", name, 1000, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/cargo_podlauncher/ui_data(mob/user)
	var/list/data = list()
	data["builtSilo"] = builtSilo//swipe an ID to unlock
	return data

/obj/machinery/computer/cargo_podlauncher/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if("buildSilo")
			builtSilo = TRUE
			icon_state = "cargo_podlauncher_building"
			sleep(25)
			icon_state = "cargo_podlauncher"
/obj/machinery/computer/cargo_podlauncher/proc/buildSilo()

/obj/machinery/computer/cargo_podlauncher/Destroy()
	return ..()