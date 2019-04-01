/obj/item/supplypod_beacon/designator
	name = "Supply Pod Designator"
	desc = "A device that can be linked to an Express Supply Console for precision supply pod deliveries. Alt-click to remove link."
	icon = 'icons/obj/cargo.dmi'
	icon_state = "supplypod_designator"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/obj/machinery/podlauncher_loader/linkedConsole
	var/turf/lockedInTurf
	var/lockingDuration = 50
	var/distance_limit = 7

/obj/item/supplypod_beacon/designator/update_status(var/consoleStatus)
	switch(consoleStatus)
		if (SP_LINKED)
			linked = TRUE
			playsound(src,'sound/machines/twobeep.ogg',50,0)
		if (SP_READY)
			ready = TRUE
		if (SP_LAUNCH)
			launched = TRUE
			playsound(src,'sound/machines/triple_beep.ogg',50,0)
			playsound(src,'sound/machines/warning-buzzer.ogg',50,0)
			addtimer(CALLBACK(src, .proc/endLaunch), 33)//wait 3.3 seconds (time it takes for supplypod to land), then update icon
		if (SP_UNLINK)
			linked = FALSE
			playsound(src,'sound/machines/synth_no.ogg',50,0)
		if (SP_UNREADY)
			ready = FALSE
	update_icon()

/obj/item/supplypod_beacon/designator/update_icon()
	cut_overlays()
	if (launched)
		add_overlay("sp_green")
	else if (ready)
		add_overlay("sp_yellow")
	else if (linked)
		add_overlay("sp_orange")

/obj/item/supplypod_beacon/designator/examine(user)
	..()
	if(!linkedConsole)
		to_chat(user, "<span class='notice'>[src] is not currently linked to a Cargo Pod Launcher.</span>")
	else
		to_chat(user, "<span class='notice'>Alt-click to unlink it from [linkedConsole].</span>")


/obj/item/supplypod_beacon/designator/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen)) //give a tag that is visible from the linked express console
		var/new_beacon_name = stripped_input(user, "What would you like the tag to be?")
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(new_beacon_name)
			name += " ([tag])"
		return
	else	
		return ..()

/obj/item/supplypod_beacon/designator/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!check_allowed_items(target, 1))
		return
	var/turf/T = get_turf(target)
	if(T.density)
		return
	if(get_dist(T,src) > distance_limit)
		return

	var/datum/beam/designatorBeam = new(src,target,'icons/effects/beam.dmi',"b_beam",50,distance_limit+1,/obj/effect/ebeam,beam_sleep_time = 3)
	INVOKE_ASYNC(designatorBeam, /datum/beam/.proc/Start)
	user.visible_message("<span class='warning'>[user] begins to designate a supplypod landing zone!</span>","<span class='notice'>You begin to lock in a supplypod landing zone...</span>")
	if(do_after(user, 50, target = src))
		playsound(src,'sound/weapons/resonator_fire.ogg',50,1)
		new /obj/effect/temp_visual/supplypod_inbound(T, lockingDuration)
		addtimer(CALLBACK(src, .proc/loseLockOnTarget), lockingDuration)
		lockedInTurf = T
		to_chat(user, "<span class='notice'>You establish a lock on the landing zone. The lock will dissipate in [lockingDuration/10] seconds.</span>")
		designatorBeam.End()
	else
		to_chat(user, "<span class='warning'>You lose your lock on the landing zone.</span>")
		designatorBeam.End()
	user.changeNext_move(CLICK_CD_MELEE)
		

/obj/item/supplypod_beacon/designator/proc/loseLockOnTarget()
	lockedInTurf = null

/obj/effect/temp_visual/supplypod_inbound
	icon = 'icons/obj/cargo.dmi'
	icon_state = "supplypod_inbound"
	
/obj/effect/temp_visual/Initialize(var/D)
	. = ..()
	duration = D
