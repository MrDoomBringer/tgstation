/obj/machinery/cargo/factory_splitter
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
	var/output_dir = NORTH//default, overridden in canPass

/obj/machinery/cargo/factory_splitter/attack_hand(mob/living/user)
	active = !active
	update_icon()

/obj/machinery/cargo/factory_splitter/screwdriver_act(mob/living/user, obj/item/tool)
	flipped = !flipped
	to_chat(user, "<span class='notice'>You flip the output direction.</span>")

/obj/machinery/cargo/factory_splitter/update_icon()
	cut_overlays()
	if (active)
		add_overlay("splitter_green")
	add_overlay("puck")

/obj/machinery/cargo/factory_splitter/CanPass(atom/movable/mover, turf/target)
	var/mob/living/M = mover
	if (istype(M) && !M.resting)
		return FALSE//mobs cant go in if they arent resting
	output_dir = turn(get_dir(loc, target), (flipped ? 90 : -90))
	return TRUE

/obj/machinery/cargo/factory_splitter/Crossed(atom/movable/AM)
	if(step(AM, output_dir))
		cut_overlays()
		add_overlay("puck[output_dir]")
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		update_icon()
	to_chat(user, "<span class='notice'>direction = [output_dir]</span>")