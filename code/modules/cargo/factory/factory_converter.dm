/obj/machinery/cargo_factory/converter
	name = "crate upgrader"
	desc = "A machine that accepts small crates and transforms them into large crates"
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "converter0"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	var/active = TRUE
	density = TRUE
	var/converting = FALSE
	var/lightIcon = "green"
	var/convert_sound = 'sound/machines/click.ogg'
	var/max_n_contents = 1
	var/obj/structure/closet/crate/input_type
	var/list/required_materials = list()
	var/list/craftBuffer = list()

/obj/machinery/cargo_factory/converter/Initialize()
	..()
	required_materials = typecacheof(list(/obj/structure/closet/crate, /obj/cratanium))

/obj/machinery/cargo_factory/converter/attack_hand(mob/living/user)
	active = !active
	update_icon()

/obj/machinery/cargo_factory/converter/update_icon()
	cut_overlays()
	icon_state = "[name][converting]"

/obj/machinery/cargo_factory/converter/process()
	attempt_upgrade()

/obj/machinery/cargo_factory/converter/proc/attempt_insert()

/obj/machinery/cargo_factory/converter/proc/attempt_upgrade()
	var/list/index_list = list()
	var/oldLen
	for(var/i in 1 to required_materials.len)
		oldLen = index_list.len
		for (var/j in 1 to contents.len)	
			if(istype(contents[j], required_materials[i]))
				index_list.Add(j)
				break
		if (oldLen == index_list.len)
			return FALSE
		if (index_list.len == required_materials.len)
			for(var/k in 1 to index_list.len)
				qdel(contents[index_list[k]])
			new /obj/structure/closet/crate(loc)