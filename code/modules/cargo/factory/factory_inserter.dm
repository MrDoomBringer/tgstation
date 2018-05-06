
/obj/machinery/inserter
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
	var/machinery/cargo_factory/linked_machine
	var/output_dir = EAST
	var/insert_speed = 10//in deciseconds

/obj/machinery/inserter/update_icon()
	cut_overlays()
	if(linked_machine)
		add_overlay("link[get_dir(src,machine)]")

/obj/machinery/inserter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_FLIP ,null,CALLBACK(src, .proc/can_be_rotated))
	output_dir = turn(dir, 180)

/obj/machinery/inserter/attack_hand(mob/living/user)
	src.add_fingerprint(user)
	link()

/obj/machinery/inserter/proc/link()
	if(panel_open || !powered())
		return
	var/atom/T = get_step(src, dir)
	for (var/machinery/cargo_factory/M in T)
		linked_machine=M
	update_icon()

/obj/machinery/inserter/Process()	
	if (linked_machine)
		var/atom/input = get_step(src, dir)
		var/atom/movable/AM = locate() in input
		if (linked_machine.can_insert(AM))
			target.forceMove(src)
			addtimer(CALLBACK(src, .proc/insertMaterial, AM), insert_speed)

/obj/machinery/inserter/proc/insertMaterial(atom/movable/AM)
	if (linked_machine)
			if (linked_machine.max_contents > linked_machine.contents.len)
				AM.foceMove(linked_machine)
			else
				return
		else
			AM.ConveyorMove(output_dir)