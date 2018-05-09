/obj/machinery/cargo_factory/converter
	name = "crate upgrader"
	desc = "A machine that accepts cratres and improves them"
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "generic_factory_0"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	var/active = TRUE
	density = TRUE
	var/converting = FALSE
	var/convert_sound = 'sound/machines/click.ogg'
	var/list/reqs = list()
	var/list/converted_buffer = list()
	var/converting = FALSE
	var/converted_buffer_size = 3

/obj/machinery/cargo_factory/converter/Initialize()
	..()
	reqs = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/crate,
		/obj/item/crate_essence
		)

/obj/machinery/cargo_factory/converter/update_icon()
	icon_state =  "generic_factory_[converting]"

/obj/machinery/cargo_factory/converter/attack_hand(mob/living/user)
	active = !active
	update_icon()

/obj/machinery/cargo_factory/converter/proc/attempt_insert(atom/movable/AM)
	message_admins("[!converting] && [converted_buffer.len] <= [converted_buffer_size] && re")
	AM.forceMove(src)

/obj/machinery/cargo_factory/converter/process()
	if (converting)
		return FALSE
	if (contents.len >= reqs.len)
		start_convert()//requirements are met, its time to do this shit

/obj/machinery/cargo_factory/converter/proc/start_convert()
	converting  = TRUE
	contents = list()//wipe all inventory
	converted_buffer.Add(new /obj/structure/closet/crate/engineering(src))//add the result to the output buffer
	addtimer(CALLBACK(src, .proc/end_convert), 20)
	update_icon()

/obj/machinery/cargo_factory/converter/proc/end_convert()
	converting = FALSE
	update_icon()
	