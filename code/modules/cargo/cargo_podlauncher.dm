/obj/machinery/podlauncher_loader
	name = "cargo pod launcher loader"
	icon = 'icons/obj/cargo.dmi'
	icon_state = "podlauncher_loader"
	desc = "A device to be linked with a Cargo Pod Launcher using a multitool"
	panel_open = FALSE

/obj/machinery/podlauncher_loader/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		update_icon()
		return
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if (panel_open)
			M.buffer = src
			to_chat(user, "<span class='caution'>You upload the data into the [W.name]'s buffer.</span>")

/obj/machinery/podlauncher_loader/update_icon()
	cut_overlays()
	if(panel_open)
		add_overlay("podloader_panel")

/obj/machinery/cargo_podlauncher
	name = "cargo pod launcher console"
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "cargo_podlauncher_nosilo"
	desc = "This console allows the user to bring DEATH upon the station"
	var/builtSilo = FALSE
	var/obj/machinery/podlauncher_loader/linkedLoader

/obj/machinery/cargo_podlauncher/Initialize()
	. = ..()

/obj/machinery/cargo_podlauncher/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		update_icon()
		return
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/podlauncher_loader))
			linkedLoader = M.buffer
			M.buffer = null
			to_chat(user, "<span class='caution'>You upload the data from the [W.name]'s buffer.</span>")
		return

/obj/machinery/cargo_podlauncher/update_icon()
	cut_overlays()
	if(panel_open)
		add_overlay("podlauncher_panel")

/obj/machinery/cargo_podlauncher/ui_interact(mob/living/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo_podlauncher", name, 100, 200, master_ui, state)
		ui.open()

/obj/machinery/cargo_podlauncher/ui_data(mob/user)
	var/list/data = list()
	data["builtSilo"] = builtSilo//swipe an ID to unlock
	return data

/obj/machinery/cargo_podlauncher/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if("buildSilo")
			buildSilo()
		if("launchPod")
			launchPod()

/obj/machinery/cargo_podlauncher/proc/launchPod()
	if (!linkedLoader)
		playsound(src,'sound/machines/synth_no.ogg',50,0)
		return
	else
		var/obj/structure/closet/supplypod/bluespacepod/pod = new()
		pod.explosionSize = list(0,0,1,2)
		for (var/atom/movable/O in get_turf(linkedLoader))
			if (!istype(O, /obj/machinery/podlauncher_loader))
				O.forceMove(pod)
		var/area/landingzone = /area/quartermaster/storage //where we droppin boys
		var/list/empty_turfs
		var/LZ
		landingzone = GLOB.areas_by_type[/area/quartermaster/storage]
		if (!landingzone)
			WARNING("[src] couldnt find a Quartermaster/Storage (aka cargobay) area on the station, and as such it has set the supplypod landingzone to the area it resides in.")
			landingzone = get_area(src)
		for(var/turf/open/floor/T in landingzone.contents)//uses default landing zone
			if(is_blocked_turf(T))
				continue
			LAZYADD(empty_turfs, T)
			CHECK_TICK
		if(empty_turfs && empty_turfs.len)
			LZ = pick(empty_turfs)
		new /obj/effect/DPtarget(LZ, pod)

/obj/machinery/cargo_podlauncher/proc/buildSilo()
	var/list/turfsToCheck = list()
	turfsToCheck.Add(get_step(src, NORTH))
	turfsToCheck.Add(get_step(src, EAST))
	turfsToCheck.Add(get_step(get_step(src, NORTH), EAST))
	var/turfsAllGood = TRUE
	for (var/turf/T in turfsToCheck)
		sleep(2)
		if (is_blocked_turf(T))
			new /obj/effect/temp_visual/turf_nogood(T)
			playsound(src,'sound/machines/synth_no.ogg',50,0)
			turfsAllGood = FALSE
		else
			new /obj/effect/temp_visual/turf_ok(T)
			playsound(src,'sound/machines/beep.ogg',50,0)
	if (!turfsAllGood)
		return
	builtSilo = TRUE
	sleep(20)
	playsound(src,'sound/machines/twobeep.ogg',50,0)
	icon_state = "cargo_podlauncher_building"
	sleep(25)
	icon_state = "cargo_podlauncher"
	playsound(src,'sound/machines/triple_beep.ogg',50,0)
	return TRUE

/obj/machinery/cargo_podlauncher/Destroy()
	return ..()

/obj/effect/temp_visual/turf_ok
	icon = 'icons/obj/cargo.dmi'
	icon_state = "turf_ok"
	duration = 30

/obj/effect/temp_visual/turf_nogood
	icon = 'icons/obj/cargo.dmi'
	icon_state = "turf_nogood"
	duration = 30