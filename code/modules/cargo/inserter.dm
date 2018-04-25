
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
	var/machinery/cargo/linked_machine

/obj/machinery/inserter/update_icon()
	cut_overlays()
	if(linked_machine)
		add_overlay("link[get_dir(src,machine)]")
	
/obj/machinery/mateinserter/process()
	if(panel_open || !powered())
		return
	var/atom/T = get_step(src, input_dir)
	for (var/machinery/cargo/M in T)
		linked_machine=M
		


