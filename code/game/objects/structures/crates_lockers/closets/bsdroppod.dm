/obj/structure/closet/bsdroppod
	name = "Bluespace Drop Pod"
	desc = "It's a storage unit for THE FUTURE NI\[B]\[B]A!!!!!"
	icon = 'icons/obj/2x2.dmi'
	icon_state = "BDP"
	pixel_x = -16
	pixel_y = -5
	pixel_z = 0
	layer = TABLE_LAYER
	allow_objects = TRUE
	allow_dense = TRUE
	delivery_icon = null
	can_weld_shut = FALSE
	armor = list(melee = 30, bullet = 50, laser = 50, energy = 100, bomb = 50, bio = 0, rad = 0, fire = 80, acid = 80)
	anchored = TRUE
	anchorable = FALSE

/obj/structure/closet/bsdroppod/Initialize()
	. = ..()


	addtimer(CALLBACK(src, .proc/open), 30)
	//open()

/obj/structure/closet/bsdroppod/update_icon()
	add_overlay("BDP_door")

/obj/structure/closet/bsdroppod/proc/sparks()
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, get_turf(src))
	s.start()


/obj/effect/temp_visual/BDPfall/proc/launch()
	animate(src, pixel_z = 0, time = duration, easing = LINEAR_EASING)
	sleep(duration)
	explosion(src.loc,-1,-1,2, flame_range = 2)
	for(var/mob/M in oview(5, src))
		shake_camera(M,2,2)
	new /obj/structure/closet/bsdroppod(loc)
	qdel(src)

/obj/structure/closet/bsdroppod/PopulateContents()
	..()
	new /obj/structure/closet/crate(src)
	return



/obj/structure/closet/bsdroppod/open(mob/living/user)
	cut_overlays()
	//layer = TABLE_LAYER
	add_overlay("BDP_open")
	playsound(loc, open_sound, 15, 1, -3)
	dump_contents()
	sleep(30)
	sparks()
	qdel(src)
	return 1

/obj/effect/temp_visual/BDPfall
	icon = 'icons/obj/2x2.dmi'
	icon_state = "BDP_falling"
	pixel_x = -16
	pixel_y = -5
	pixel_z = 200
	name = "Bluespace Drop Pod"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	randomdir = FALSE


/obj/effect/temp_visual/BDPtarget
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	duration = 13
	var/turf/open/floor/T2

/obj/effect/temp_visual/BDPtarget/Initialize()
	. = ..()
	sleep(duration-3)
	new /obj/effect/temp_visual/BDPfall(loc, duration-10)


/obj/effect/temp_visual/BDPfall/Initialize(mapload, D)
	duration = D
	launch()
	
