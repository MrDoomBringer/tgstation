/obj/cargo_factory/factory_seller
	name = "Automatic Cargo Seller"
	desc = "An in-line launch system for an automatic cargo rocket. Goods placed on top will enter into the rocket, which will then launch off to Centcom."
	icon = 'icons/obj/machines/cargo.dmi'
	icon_state = "supplyseller"
	density = FALSE 
	anchored = TRUE

/obj/cargo_factory/factory_seller/Initialize()
	..()
	add_overlay("supplyseller_green")

/obj/cargo_factory/factory_seller/Crossed(atom/movable/AM)
	..()
	if (contents.len == 0)
		addtimer(CALLBACK(src, .proc/start_launch), 50)
	take_items()

/obj/cargo_factory/factory_seller/proc/take_items()
	for(var/atom/movable/target in loc)
		target.forceMove(src)	
		playsound(src,'sound/machines/click.ogg', 50, -1, 1)

/obj/cargo_factory/factory_seller/proc/start_launch()
	take_items()
	cut_overlays()
	add_overlay("supplyseller_red")
	icon_state = "supplyseller_open"
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 1)
	playsound(src, 'sound/effects/hyperspace_begin.ogg', 50, 0, 1)
	density = TRUE
	addtimer(CALLBACK(src, .proc/launch), 50)

/obj/cargo_factory/factory_seller/proc/launch()
	cut_overlays()
	add_overlay("supplyseller_yellow")
	new /obj/effect/temp_visual/supplyseller(loc)
	addtimer(CALLBACK(src, .proc/end_launch), 100)

/obj/cargo_factory/factory_seller/proc/end_launch()
	for (var/thing in contents)
		export_item_and_contents(thing)
		if(thing)
			qdel(thing)
	density = FALSE
	cut_overlays()
	add_overlay("supplyseller_green")
	icon_state = "supplyseller"


