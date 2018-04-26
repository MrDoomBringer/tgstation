/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/cargo_factory/factory_mover
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets. Points for ore are generated based on type and can be redeemed at a mining equipment vendor."
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "mover"
	density = TRUE
	anchored = TRUE
	var/input_dir = WEST
	var/output_dir = EAST

/obj/machinery/cargo_factory/factory_mover/screwdriver_act(mob/living/user)
	var/atom/input = get_step(src, input_dir)
	var/obj/target = locate() in input
	target.forceMove(src)
	sleep(10)
	target.ConveyorMove(output_dir)

/obj/machinery/cargo_factory/factory_mover/attack_hand(mob/living/user)
	var/atom/input = get_step(src, input_dir)
	var/obj/structure/closet/crate/target = locate() in input
	target.forceMove(src)
	sleep(10)
	target.ConveyorMove(output_dir)
