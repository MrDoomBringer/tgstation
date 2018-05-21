#define SELLMODE = 0
#define BUYMODE = 1

/obj/item/factory_tool
	name = "factory tool"
	desc = "A tool used to build and sell factory units."
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "factory_tool"
	var/sellmode = FALSE 
	var/obj/machinery/cargo_factory/converter/selected_order = /obj/machinery/cargo_factory/converter

/obj/item/factory_tool/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	sellmode = !sellmode
	to_chat(user, "<span class='notice'>You set the [name]'s mode to" + (sellmode ? " recyle" : " purchase") + ".</span>")
	
/obj/item/factory_tool/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		to_chat(user, "<span class='warning'>The [name]'s display reads: ENGAGING LONGRANGE MODE</span>")//return
	if (sellmode && sell_factory(A, user))
		playsound(src, 'sound/machines/ping.ogg', 25, 0)
	else if (!sellmode && buy_factory(A, user))
		playsound(src, 'sound/machines/chime.ogg', 25, 0)
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25, 0)
	
/obj/item/factory_tool/proc/sell_factory(atom/A, mob/user)
	if (istype(A, /obj/machinery/cargo_factory))
		for(var/atom/movable/thing in A.contents)
			thing.forceMove(A.loc)
		var/value = export_item_and_contents(A, TRUE)
		if (!value)
			value = 0
		display_message(user,"Successfully recycled the [A.name]. Recovered [value] credits.", "notice")
		new /obj/effect/temp_visual/emp/pulse(A.loc)
		qdel(A)
		return TRUE
	else
		display_message(user,"ERROR: CANNOT RECYCLE")
		return FALSE

/obj/item/factory_tool/proc/buy_factory(atom/A, mob/user)
	if (istype(A, /turf/open/floor))
		if (is_blocked_turf(A))
			display_message(user,"ERROR: BLOCKAGE DETECTED")
			return FALSE
		var/obj/machinery/cargo_factory = new selected_order(A)
		var/value = export_item_and_contents(meme,TRUE)
		if (!value)
			value = 0
		display_message(user,"Successfully purchased the [meme.name] for [value] credits.", "notice")
		return TRUE
	else
		display_message(user,"ERROR: ADEQUATE FLOORING REQUIRED")
		return FALSE

/obj/item/factory_tool/proc/display_message(mob/user, var/message, var/message_type = "warning")
	to_chat(user, "<span class='[message_type]'>The [name]'s display reads: \"[message]\"</span>")


