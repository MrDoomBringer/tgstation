/obj/machinery/cargo_factory/factory_splitter
	name = "conveyor splitter"
	desc = "A machine that sends half of a conveyor belt's items off to the side. Output direction configuarble by screwdriver."
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "splitter"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	density = TRUE
	var/active = FALSE
	var/splitting = FALSE
	var/lightIcon = "splitter_green"
	var/flipped = FALSE
	var/output_dir

/obj/machinery/cargo_factory/factory_splitter/Initialize()
	. = ..()
	update_icon()

/obj/machinery/cargo_factory/factory_splitter/attack_hand(mob/living/user)
	active = !active
	update_icon()
	return

/obj/machinery/cargo_factory/factory_splitter/multitool_act(mob/living/user, obj/item/tool)
	flipped = !flipped
	to_chat(user, "<span class='notice'>You flip the output direction.</span>")

/obj/machinery/cargo_factory/factory_splitter/update_icon()
	cut_overlays()
	if (active)
		add_overlay("splitter_green")

/obj/machinery/cargo_factory/factory_splitter/CanPass(atom/movable/mover, turf/target)
	var/mob/living/M = mover
	if (istype(M) && !M.lying)//mobs cant go in if they arent lying down
		return FALSE

	if (splitting && active)
		output_dir = turn(get_dir(loc, target), (flipped ? 90 : -90))
	else
		output_dir = get_dir(loc, target)
	return TRUE

/obj/machinery/cargo_factory/factory_splitter/Crossed(atom/movable/AM)	
	if (splitting)
		AM.ConveyorMove(output_dir)
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
	splitting = !splitting	