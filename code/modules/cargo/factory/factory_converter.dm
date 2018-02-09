/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/cargo/factory_converter
	name = "crate upgrader"
	desc = "A machine that accepts small crates and transforms them into large crates"
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "converter"
	density = TRUE
	anchored = TRUE
	var/input_dir = NORTH
	var/output_dir = SOUTH

/obj/machinery/cargo/factory_converter/CanPass(atom/movable/mover, turf/target)
	var/dir = get_dir(loc, target)
	if(dir == input_dir || dir == output_dir)
		return TRUE
	return FALSE