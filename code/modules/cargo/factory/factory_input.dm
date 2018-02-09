/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/cargo/factory_input
	name = "factory input machine"
	desc = "IT EATS GARBAGE CODE AND PRODUCES GOOD CODE"
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "inputter"
	density = TRUE
	anchored = TRUE
	var/output_dir = SOUTH
	var/on = FALSE

/obj/machinery/cargo/factory_input/attack_hand(mob/living/user)
	if (on)
		on = FALSE
	else
		on = TRUE
	update_icon()
	..()

/obj/machinery/cargo/factory_input/update_icon(mob/living/user)
	if (on)
		icon_state = "[initial(icon_state)]_active"	
	else
		icon_state = initial(icon_state)
		
