/obj/machinery/podlauncher_loader
	name = "cargo pod launcher loader"
	icon = 'icons/obj/cargo.dmi'
	icon_state = "podloader"
	desc = "A device to be linked with a Cargo Pod Launcher using a multitool"
	panel_open = FALSE
	var/hasLinkedLauncher = TRUE

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

/obj/machinery/cargo_podlauncher/proc/set_link(var/toggle)
	if(toggle)
		linkedLoader.hasLinkedLauncher = TRUE
		linkedLoader.update_icon()
		playsound(src,'sound/machines/twobeep.ogg',50,0)
	else
		linkedLoader.hasLinkedLauncher = FALSE
		linkedLoader.update_icon()
		playsound(src,'sound/machines/synth_no.ogg',50,0)

/obj/machinery/podlauncher_loader/update_icon()
	cut_overlays()
	if(hasLinkedLauncher)
		add_overlay("podloader_overlay")
	if(panel_open)
		add_overlay("podloader_panel")

/obj/machinery/cargo_podlauncher
	name = "cargo pod launcher console"
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "cargo_podlauncher_nosilo"
	desc = "This console allows the user to bring DEATH upon the station"
	var/builtSilo = FALSE
	var/obj/machinery/podlauncher_loader/linkedLoader
	var/obj/item/supplypod_beacon/designator/beacon
	var/designatorCooldown = 0
	var/launchCooldown = 0
	var/printed_beacons = 0
	var/openDoor = FALSE

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
			if (linkedLoader != M.buffer)
				if (linkedLoader)
					to_chat(user, "<span class='caution'>You disconnect the previously linked Pod Loader.</span>")
					set_link(FALSE)
				linkedLoader = M.buffer
				set_link(TRUE)
				M.buffer = null
				to_chat(user, "<span class='caution'>You upload the data from the [W.name]'s buffer, linking a new Pod Loader to this Launcher.</span>")
				update_icon()
			else
				to_chat(user, "<span class='notice'>That Pod Loader is already linked to this Launcher!</span>")
		return

/obj/machinery/cargo_podlauncher/update_icon()
	cut_overlays()
	if(panel_open)
		add_overlay("podlauncher_panel")
	if(linkedLoader)
		add_overlay("podlauncher_overlay")
	if(openDoor)
		add_overlay("podlauncher_door")

/obj/machinery/cargo_podlauncher/ui_interact(mob/living/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo_podlauncher", name, 300, 200, master_ui, state)
		ui.open()

/obj/machinery/cargo_podlauncher/ui_data(mob/user)
	var/list/data = list()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		data["points"] = D.account_balance
	data["builtSilo"] = builtSilo
	data["beacon"] = beacon ? "[beacon] at [COORD(beacon)]" : "ERROR:DESIGNATOR REQUIRED"
	data["canLaunch"] = beacon && launchCooldown <= 0
	data["launchMsg"] = beacon ? (launchCooldown > 0 ? "Launch Supplypod ([launchCooldown])" : "Launch Supplypod") : "ERROR: REQUIRES ACTIVE DESIGNATOR"
	data["canBuyDesignator"] = designatorCooldown <= 0 && D.account_balance >= DESIGNATOR_COST
	data["designatorMsg"] = designatorCooldown > 0 ? "Print Beacon for [DESIGNATOR_COST] credits ([designatorCooldown])" : "Print Beacon for [DESIGNATOR_COST] credits"//buttontext for printing beacons
	if (designatorCooldown > 0)//cooldown used for printing designators
		designatorCooldown--
	if (launchCooldown > 0)//cooldown used for launching
		launchCooldown--
	else
		open_door()
	return data

/obj/machinery/cargo_podlauncher/proc/open_door()
	openDoor = TRUE
	update_icon()
	playsound(loc, 'sound/machines/click.ogg', 50,0)

/obj/machinery/cargo_podlauncher/proc/close_door()
	openDoor = FALSE
	update_icon()
	playsound(loc, 'sound/machines/click.ogg', 50,0)

/obj/machinery/cargo_podlauncher/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if("buildSilo")
			buildSilo()
		if("launchPod")
			if (launchCooldown <= 0)
				launchPod()
		if("printDesignator")
			printDesignator()
		
/obj/machinery/cargo_podlauncher/proc/printDesignator()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		if(D.adjust_money(-DESIGNATOR_COST))
			designatorCooldown = 20//a ~twenty second cooldown for printing beacons to prevent spam
			var/obj/item/supplypod_beacon/designator/C = new /obj/item/supplypod_beacon/designator(drop_location())
			C.link_console(src, usr)//rather than in beacon's Initialize(), we can assign the computer to the beacon by reusing this proc)
			printed_beacons++//printed_beacons starts at 0, so the first one out will be called beacon # 1
			beacon.name = "Supply Pod Designator #[printed_beacons]"

/obj/machinery/cargo_podlauncher/proc/loadPod()
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	for (var/atom/movable/O in get_turf(linkedLoader))
		if (O != linkedLoader)
			O.forceMove(pod)
	return pod

/obj/machinery/cargo_podlauncher/proc/launchPod()
	if (!linkedLoader || !beacon.lockedInTurf)
		playsound(src,'sound/machines/synth_no.ogg',50,0)
		return
	else
		launchCooldown = 30
		var/obj/structure/closet/supplypod/bluespacepod/pod = loadPod()
		new /obj/effect/DPtarget(beacon.lockedInTurf, pod)
		addtimer(CALLBACK(src, .proc/close_door), 20)

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

/obj/machinery/computer/cargo/express/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/supplypod_beacon/designator))
		var/obj/item/supplypod_beacon/designator/sd = W
		if (sd.express_console != src)
			sd.link_console(src, user)
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] is already linked to [sd].</span>")
	..()

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