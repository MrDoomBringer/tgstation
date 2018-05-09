/obj/machinery/cargo_factory/inserter
	name = "insert"
	desc = "An industrial input device used to do the thing."
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "generic_factory_0"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	circuit = /obj/item/circuitboard/machine/processor
	var/atom/movable/input
	var/atom/movable/output
	var/obj/machinery/cargo_factory/converter/inputMachine
	var/obj/machinery/cargo_factory/converter/outputMachine

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

	var/obj/machinery/cargo_factory/converter/C1 = locate() in get_step(src,dir)
	var/obj/machinery/cargo_factory/converter/C2 = locate() in get_step(src,turn(dir,180))
	input = C1
	output = C2
	inputMachine = istype(input, /obj/machinery/cargo_factory/converter) ? input : null
	outputMachine = istype(output, /obj/machinery/cargo_factory/converter) ? output : null

	if (!inputMachine && !outputMachine)
		message_admins("failed machine check!")
		return FALSE
	if ((inputMachine && inputMachine.converting) || (outputMachine && outputMachine.converting))
		message_admins("at least one of the two machines were converting!")
		return FALSE
	if (outputMachine)
		if (outputMachine.converted_buffer.len <= outputMachine.converted_buffer_size)
	if (inputMachine)
		if (inputMachine.converted_buffer.len > 0)
			input = inputMachine.converted_buffer[0]
		else
			return FALSE
	if (!inputMachine)
		for(var/atom/movable/target in get_step(src,dir))
			for(var/thing in outputMachine.reqs)
				if(istype(target, thing))
					input = target
					message_admins("we found a target: [target], and the input is [input]")
					return TRUE
		return FALSE

	
	
	message_admins("input and output: [input] and [output], and [inputMachine] | [outputMachine]")
	return TRUE//at least one of these must be a factory converter

/obj/machinery/cargo_factory/inserter/process()	
	..()
	if ( && reqs.Find(AM) && count_by_type(contents, AM) < count_by_type(reqs, AM))//if it is the right type AND we dont already have enough

	if (check_for_machine())
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		new /obj/effect/temp_visual/emp/pulse(input.loc)
		if (inputMachine)//if the input zone is a converter, then
			if (outputMachine)
				outputMachine.attempt_insert(input)
				message_admins("1")
			else
				input.ConveyorMove(turn(dir,180))
				message_admins("2")
			inputMachine.converted_buffer.Remove(input)
		else//if input is not a converter, then output must be a converter
			if (input)
				message_admins("3")
				outputMachine.attempt_insert(input) //try to insert the input into the output (output will be a converter). We can do this because by check_for_machine(), one of these two vars must be a converter
	else
		message_admins("nope")