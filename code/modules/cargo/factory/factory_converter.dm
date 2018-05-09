/obj/machinery/cargo_factory/converter
	name = "crate upgrader"
	desc = "A machine that accepts cratres and improves them"
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "generic_factory"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	var/active = TRUE
	density = TRUE
	var/converting = FALSE
	var/convert_sound = 'sound/machines/click.ogg'
	var/list/reqs = list()
	var/list/output_buffer = list()

/obj/machinery/cargo_factory/converter/Initialize()
	..()
	reqs = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/crate,
		/obj/item/crate_essence
		)

/obj/machinery/cargo_factory/converter/attack_hand(mob/living/user)
	active = !active
	update_icon()

/obj/machinery/cargo_factory/converter/update_icon()
	cut_overlays()
	icon_state = "[name][converting]"

/obj/machinery/cargo_factory/converter/proc/attempt_insert(atom/movable/AM)
	if (reqs.Find(AM) && count_by_type(contents, AM) < count_by_type(reqs, AM))//if it is the right type AND we dont already have enough
		AM.forceMove(src)
		return TRUE
	return FALSE

/obj/machinery/cargo_factory/converter/process()
	if (converting)
		return FALSE
	start_convert()

/obj/machinery/cargo_factory/converter/proc/start_convert()
	converting  = TRUE
	if (contents.len >= reqs.len)//reqs is filled, its time to do this shit
		contents = list()//wipe all inventory
		output_buffer.Add(new /obj/structure/closet/crate/engineering(src))
	addtimer(CALLBACK(src, .proc/end_convert), 20)

/obj/machinery/cargo_factory/converter/proc/end_convert()
	converting = FALSE
	