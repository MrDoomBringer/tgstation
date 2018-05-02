/obj/machinery/cargo_factory/converter
	name = "crate upgrader"
	desc = "A machine that accepts small crates and transforms them into large crates"
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "converter0"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	density = TRUE
	var/active = FALSE
	var/converting = FALSE
	var/lightIcon = "green"
	var/atom/movable/convertee
	var/convert_sound = 'sound/machines/click.ogg'

/obj/machinery/cargo_factory/converter/attack_hand(mob/living/user)
	active = !active
	update_icon()

/obj/machinery/cargo_factory/converter/update_icon()
	cut_overlays()
	icon_state = "[name][converting]"

/obj/machinery/cargo_factory/converter/Crossed(atom/movable/AM)
	convertee = AM
	if(active)
		tryConvert()

/obj/machinery/cargo_factory/converter/proc/tryConvert()
	if (istype(convertee, /mob/living))
		var/mob/living/M = convertee
		if (M.resting)
			M.Stun(20)
			convert()
			return TRUE
	else if (istype(convertee, /obj/structure/closet/crate/small))
		convert()
		return TRUE
	return FALSE

/obj/machinery/cargo_factory/converter/proc/convert()
	converting = TRUE
	update_icon()
	playsound(loc, convert_sound, 15, 1, -3)
	addtimer(CALLBACK(src, .proc/endConvert), 20)

/obj/machinery/cargo_factory/converter/proc/endConvert()
	converting = FALSE
	playsound(loc, convert_sound, 15, 1, -3)
	if (istype(convertee, /mob/living))
		var/mob/living/M = convertee
		M.gib()
	else if (istype(convertee, /obj/structure/closet/crate/small))
		qdel(convertee)
		new /obj/structure/closet/crate(loc)
	update_icon()

/obj/machinery/cargo_factory/converter/CanPass(atom/movable/mover, turf/target)
	var/mob/living/M = mover
	if ((istype(M) && !M.lying) || converting)
		return FALSE//mobs cant go in if they arent resting, and things cant go in if converting
	return get_dir(loc, target) == dir || get_dir(loc, target) == turn(dir, 180)//allows things to enter via front/back, but not sides

/obj/machinery/cargo_factory/converter/CheckExit(atom/movable/O as mob|obj, target)	
	if(converting)//cant leave while converting 
		return FALSE
	return (get_dir(O.loc, target) == dir || get_dir(O.loc, target) == turn(dir, 180))//allows things to leave via front/back, but not sides