
/obj/machinery/cargo_factory/inserter
	name = "insert"
	desc = "An industrial input device used to do the thing."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor1"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	circuit = /obj/item/circuitboard/machine/processor
	var/obj/machinery/cargo_factory/converter/linked_machine
	var/insert_speed = 10//in deciseconds

/obj/machinery/cargo_factory/inserter/update_icon()
	cut_overlays()
	//if(linked_machine)
		//add_overlay("link[get_dir(src,linked_machine)]")

/obj/machinery/cargo_factory/inserter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_FLIP ,null,CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/cargo_factory/inserter/proc/can_be_rotated(mob/user,rotation_type)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/machinery/cargo_factory/inserter/attack_hand(mob/living/user)
	src.add_fingerprint(user)
	link_machine()

/obj/machinery/cargo_factory/inserter/proc/link_machine()
	if(panel_open || !powered())
		return
	var/atom/T = get_step(src, turn(dir,180))
	for (var/obj/machinery/cargo_factory/M in T)
		linked_machine=M
	update_icon()


/obj/machinery/cargo_factory/inserter/process()	
	if (linked_machine)
		var/atom/input = get_step(src, dir)
		var/atom/movable/AM = locate() in input
		if (linked_machine.can_insert(AM))
			AM.forceMove(src)
			addtimer(CALLBACK(src, .proc/insertMaterial, AM), insert_speed)

/obj/machinery/cargo_factory/inserter/proc/insertMaterial(atom/movable/AM)
	if (linked_machine)
		if (linked_machine.max_n_contents > linked_machine.contents.len)
			AM.forceMove(linked_machine)
		else
			return
	else
		AM.ConveyorMove(output_dir)