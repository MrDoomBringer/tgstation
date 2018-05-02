/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/cargo_factory/factory_input
	name = "factory input machine"
	desc = "IT EATS GARBAGE CODE AND PRODUCES GOOD CODE"
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "inputter"
	density = TRUE
	anchored = TRUE
	var/output_dir = SOUTH
	var/on = FALSE

	var/valuebuffer
	var/production_rate = 50
	var/efficiency = 2

/obj/machinery/cargo_factory/factory_input/attack_hand(mob/living/user)
	if (on)
		on = FALSE
	else
		on = TRUE
	update_icon()
	..()

/obj/machinery/cargo_factory/factory_input/update_icon(mob/living/user)
	if (on)
		icon_state = "[initial(icon_state)]_active"	
	else
		icon_state = initial(icon_state)

/obj/machinery/cargo_factory/factory_input/process()
	if(panel_open || !powered())
		return
	var/atom/T = get_step(src, input_dir)
	for (var/AM in T)
		var/value = 0
		value += export_item_and_contents(AM,TRUE, TRUE, dry_run = TRUE)
		if (value != 0)
			qdel(AM)
		valuebuffer += value*efficiency

	if (valuebuffer - production_rate > 0)
		valuebuffer -= production_rate
		new /obj/item/crate_essence(loc)

