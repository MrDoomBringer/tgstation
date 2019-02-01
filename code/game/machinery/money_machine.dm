/obj/effect/dumpeetFall //Falling pod
	name = ""
	icon = 'icons/obj/money_machine.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	icon_state = "missile_blur"

/obj/effect/dumpeetTarget
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/dumpeetFall/DF
	var/obj/machinery/dumpeet/dump

/obj/effect/ex_act()
	return

/obj/effect/dumpeetTarget/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/startLaunch), 20)

/obj/effect/dumpeetTarget/proc/startLaunch()
	DF = new /obj/effect/dumpeetFall(drop_location())
	dump = new /obj/machinery/dumpeet()
	animate(DF, pixel_z = 0, time = 5, , easing = LINEAR_EASING) //Make the pod fall! At an angle!
	addtimer(CALLBACK(src, .proc/endLaunch), 5, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation
	playFallingSound()

/obj/effect/dumpeetTarget/proc/playFallingSound()
	playsound(src,  'sound/weapons/mortar_whistle.ogg', 80, 1, 6)

/obj/effect/dumpeetTarget/proc/endLaunch()
	QDEL_NULL(DF) //Delete the falling pod effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, "explosion", 80, 1)
	dump.forceMove(get_turf(src))
	qdel(src) //The target's purpose is complete. It can rest easy now

/obj/machinery/dumpeet
	name = "stock market interface" //Names and descriptions are normally created with the setStyle() proc during initialization, but we have these default values here as a failsafe
	desc = "An orbitally dropped interface to Nanotrasen's massive internal stock market."
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	layer = TABLE_LAYER //So that the crate inside doesn't appear underneath
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	anchored = TRUE //So it cant slide around after landing

/obj/machinery/dumpeet/Initialize()
	..()
	add_overlay("fins")
	add_overlay("hatch")
	addtimer(CALLBACK(src, .proc/startUp), 50)

/obj/machinery/dumpeet/proc/startUp()
	playsound(src,  'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("fins")
	sleep(10)
	playsound(src,  'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("hatch")
	sleep(30)
	playsound(src,'sound/machines/twobeep.ogg',50,0)
	add_overlay("hologram")
	add_overlay("holosign")
	sleep(20)
	add_overlay("screen_lines")
	sleep(5)
	cut_overlay("screen_lines")
	sleep(5)
	add_overlay("screen_lines")
	sleep(5)
	add_overlay("screen")
	sleep(5)
	playsound(src,'sound/machines/triple_beep.ogg',50,0)
	add_overlay("text")

		