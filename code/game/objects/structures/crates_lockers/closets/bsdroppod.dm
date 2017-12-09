//The "BDPtarget" temp visual is created by the expressconsole, which in turn makes two things: a falling droppod animation, and the droppod itself.


//------------------------------------BLUESPACE DROP POD-------------------------------------//
/obj/structure/closet/bsdroppod
	name = "Bluespace Drop Pod"
	desc = "It's a storage unit for THE FUTURE NI\[B]\[B]A!!!!!"
	icon = 'icons/obj/2x2.dmi'
	icon_state = "BDP"
	pixel_x = -16//2x2 sprite
	pixel_y = -5
	pixel_z = 0
	layer = TABLE_LAYER//so that the crate inside doesn't appear underneath
	allow_objects = TRUE
	allow_dense = TRUE
	delivery_icon = null
	can_weld_shut = FALSE
	armor = list(melee = 30, bullet = 50, laser = 50, energy = 100, bomb = 90, bio = 0, rad = 0, fire = 80, acid = 80)
	anchored = TRUE
	anchorable = FALSE
	var/datum/supply_order/SupplyOrder

/obj/structure/closet/bsdroppod/Initialize(mapload, datum/supply_order/so)
	. = ..()
	src.SupplyOrder = so//uses Supply Order passed from expressconsole into BDPtarget
	addtimer(CALLBACK(src, .proc/open), 30)//open 3seconds after appearing

/obj/structure/closet/bsdroppod/update_icon()//called in initialize, all we have to do is add a door icon
	cut_overlays()//just incase update_icon somehow gets called multiple times, prevents overlay spam
	add_overlay("BDP_door")
	return

/obj/structure/closet/bsdroppod/proc/sparks()
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, get_turf(src))
	s.start()

/obj/structure/closet/bsdroppod/attackby()//only exists for a few seconds, so no need to be welded or anchored or whatever
	return

/obj/structure/closet/bsdroppod/open(mob/living/user)
	var/turf/T = get_turf(src)
	SupplyOrder.generate(T)//not called during populateContents as supplyorder generation requires a turf
	cut_overlays()
	add_overlay("BDP_open")
	playsound(loc, open_sound, 15, 1, -3)
	sleep(30)
	sparks()//wait 3 seconds, then make some sparks and delete
	qdel(src)

//------------------------------------FALLING BLUESPACE DROP POD-------------------------------------//
/obj/effect/temp_visual/BDPfall
	icon = 'icons/obj/2x2.dmi'
	icon_state = "BDP_falling"
	pixel_x = -16
	pixel_y = -5
	pixel_z = 200
	name = "Bluespace Drop Pod"
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	randomdir = FALSE

/obj/effect/temp_visual/BDPfall/Initialize()//prevents QDEL_IN timer creation
	return

//------------------------------------TEMPORARY_VISUAL-------------------------------------//
/obj/effect/temp_visual/BDPtarget
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2

/obj/effect/temp_visual/BDPtarget/Initialize(mapload, datum/supply_order/SO)//Doesnt call ..() or set a duration, so that we can delete the visual directly after creating the droppod
	addtimer(CALLBACK(src, .proc/beginLaunch, SO), 30)//wait 3 seconds

/obj/effect/temp_visual/BDPtarget/proc/beginLaunch(datum/supply_order/SO)
	var/obj/effect/temp_visual/fallingPod = new /obj/effect/temp_visual/BDPfall(loc)
	animate(fallingPod, pixel_z = 0, time = 3, easing = LINEAR_EASING)//make and animate a falling pod
	sleep(3)//pod falls for 0.3 seconds
	qdel(fallingPod)//delete pod after animation's over

	explosion(src.loc,-1,-1,2, flame_range = 2) //explosion and camshake
	for(var/mob/M in oview(7, src))
		shake_camera(M,2,2)
	new /obj/structure/closet/bsdroppod(loc, SO)//pod is created after explosion (so that it doesn't get damaged)
	qdel(src)