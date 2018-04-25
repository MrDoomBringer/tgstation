
/obj/machinery/material_input
	name = "Material Input machine"
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
	var/input_dir = SOUTH
    var/valuebuffer
    var/production_rate = 50
	var/efficiency = 2

/obj/machinery/material_input/process()
	if(panel_open || !powered())
		return
	var/atom/T = get_step(src, input_dir)
	for (var/AM in T)
        if(QDELETED(AM))
                continue
        var/value += export_item_and_contents(AM,TRUE, TRUE, dry_run = TRUE)
        if (value != 0)
            qdel(AM)
        valuebuffer += value*efficiency
	
	if (valuebuffer - production_rate > 0)
		valuebuffer -= production_rate
		new /obj/crateslag//////////////////////////////////////
