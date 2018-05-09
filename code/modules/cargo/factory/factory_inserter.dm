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
	var/atom/input
	var/atom/output
	var/inputMachine = FALSE
	var/outputMachine = FALSE

/obj/machinery/cargo_factory/inserter/update_icon()
	cut_overlays()

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

/obj/machinery/cargo_factory/inserter/proc/check_for_machine()
	if(panel_open || !powered())
		return
	input = get_step(src,dir)
	output = get_step(src, turn(dir,180))
	var/atom/movable/AM 
	var/obj/machinery/cargo_factory/converter/converter = locate() in input
	
	if (converter)
		input = converter 
	else
		AM = locate() in input
		input = AM

	converter = locate() in output
	if (converter)
		output = converter
	else
		AM = locate() in output
		output = AM
	
	inputMachine = istype(input, converter) 
	outputMachine = istype(output, converter)
	message_admins("input and output: [input] and [output], and [inputmachine] | [outputMachine]")
	return (inputMachine || outputMachine)//at least one of these must be a factory converter

/obj/machinery/cargo_factory/inserter/process()	
	..()
	if (check_for_machine())
		new /obj/effect/temp_visual/emp(input.loc)
		if (!inputMachine)//if the input zone is something movable, then
			output.attempt_insert(input) //try to insert the input into the output (output will be a converter). We can do this because by check_for_machine(), one of these two vars must be a converter
			message_admins("wew")
		else
			if (!outputMachine)
			input.output_buffer[0].conveyorMove(turn(dir,180))
			else
			output.attempt_insert(input.output_buffer[0])


		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)