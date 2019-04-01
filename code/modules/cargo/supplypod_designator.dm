/obj/item/supplypod_beacon/designator
	name = "Supply Pod Designator"
	desc = "A device that can be linked to an Express Supply Console for precision supply pod deliveries. Alt-click to remove link."
	icon = 'icons/obj/cargo.dmi'
	icon_state = "supplypod_designator"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/obj/machinery/podlauncher_loader/linkedLauncher
	var/linked = FALSE
	var/ready = FALSE
	var/launched = FALSE

/obj/item/supplypod_beacon/designator/proc/update_status(var/consoleStatus)
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

/obj/item/supplypod_beacon/designator/proc/endLaunch()
	launched = FALSE
	update_status()

/obj/item/supplypod_beacon/designator/examine(user)
	..()
	if(!linkedLauncher)
		to_chat(user, "<span class='notice'>[src] is not currently linked to a Cargo Pod Launcher.</span>")
	else
		to_chat(user, "<span class='notice'>Alt-click to unlink it from [linkedLauncher].</span>")

/obj/item/supplypod_beacon/designator/Destroy()
	if(linkedLauncher)
		linkedLauncher.beacon = null
	return ..()

/obj/item/supplypod_beacon/designator/proc/unlink_console()
	if(linkedLauncher)
		linkedLauncher.beacon = null
		linkedLauncher = null
	update_status(SP_UNLINK)
	update_status(SP_UNREADY) 

/obj/item/supplypod_beacon/designator/proc/link_console(obj/machinery/podlauncher_loader/C, mob/living/user)
	if (C.beacon)//if new console has a beacon, then...
		C.beacon.unlink_console()//unlink the old beacon from new console
	if (linkedLauncher)//if this beacon has an express console
		linkedLauncher.beacon = null//remove the connection the expressconsole has from beacons
	linkedLauncher = C//set the linked console var to the console
	linkedLauncher.beacon = src//out with the old in with the news
	update_status(SP_LINKED)
	if (linkedLauncher.usingBeacon)
		update_status(SP_READY)
	to_chat(user, "<span class='notice'>[src] linked to [C].</span>")

/obj/item/supplypod_beacon/designator/AltClick(mob/user)
	if (!user.canUseTopic(src, !issilicon(user)))
		return
	if (linkedLauncher)
		unlink_console()
	else
		to_chat(user, "<span class='notice'>There is no linked console!</span>")

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