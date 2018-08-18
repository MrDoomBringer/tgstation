//The "BDPtarget" temp visual is created by the expressconsole, which in turn makes two things: a falling droppod animation, and the droppod itself.
#define POD_STANDARD 0
#define POD_BLUESPACE 1
#define POD_CENTCOM 2

//------------------------------------SUPPLY POD-------------------------------------//
/obj/structure/closet/supplypod
	name = "Supply Drop Pod"
	desc = "A Nanotrasen supply drop pod."
	icon = 'icons/obj/2x2.dmi'
	icon_state = "supplypod"
	pixel_x = -16//2x2 sprite
	pixel_y = -5
	layer = TABLE_LAYER//so that the crate inside doesn't appear underneath
	allow_objects = TRUE
	allow_dense = TRUE
	delivery_icon = null
	can_weld_shut = FALSE
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	anchored = TRUE
	anchorable = FALSE
	var/list/launchList = list()
	var/bluespace = FALSE
	var/landingDelay = 30
	var/openingDelay = 30
	var/damage = 0
	var/effectStun = FALSE
	var/effectLimb = FALSE
	var/effectGib = FALSE
	var/effectStealth = FALSE
	var/effectQuiet = FALSE
	var/reversing = FALSE
	var/bay = 1
	var/list/explosionSize = list(0,0,2,3)

/obj/structure/closet/supplypod/bluespacepod
	name = "Bluespace Drop Pod"
	desc = "A Nanotrasen Bluespace supply pod. Teleports back to CentCom after delivery."
	icon_state = "bluespacepod"
	bluespace = TRUE
	explosionSize = list(0,0,1,2)
	landingDelay = 30

/obj/structure/closet/supplypod/centcompod
	name = "CentCom Drop Pod"
	desc = "A Nanotrasen supply pod, this one has been marked with Central Command's designations. Teleports back to Centcom after delivery."
	icon_state = "centcompod"
	bluespace = TRUE
	explosionSize = list(0,0,0,0)
	landingDelay = 5
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/supplypod/update_icon()
	cut_overlays()
	if (icon_state)//check to ensure pod isnt "invisible"
		if (opened)
			add_overlay("[icon_state]_open")
		else
			add_overlay("[icon_state]_door")

/obj/structure/closet/supplypod/tool_interact(obj/item/W, mob/user)
	if (bluespace)
		return FALSE
	else
		..()

/obj/structure/closet/supplypod/ex_act()
	return

/obj/structure/closet/supplypod/contents_explosion()
	return

/obj/structure/closet/supplypod/toggle(mob/living/user)
	return

/obj/structure/closet/supplypod/proc/preOpen()
	var/turf/T = get_turf(src)
	var/boomTotal = 0
	for (var/mob/living/M in T)
		if (effectLimb && iscarbon(M))
			var/mob/living/carbon/CM = M
			for (var/obj/item/bodypart/bodypart in CM.bodyparts)
				if(bodypart.body_part != HEAD && bodypart.body_zone != CHEST)//we dont want to kill him, just teach em a lesson!
					bodypart.dismember()
					playsound(CM,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		if (effectGib)
			M.gib()
			damage=5000
		M.adjustBruteLoss(damage)
	var/list/B = explosionSize
	for (var/i in 1 to B.len-1)
		boomTotal += i
	if (boomTotal != 0)
		explosion(get_turf(src), B[1], B[2], B[3], flame_range = B[4], silent = effectQuiet, ignorecap = istype(src, /obj/structure/closet/supplypod/centcompod)) //less advanced equipment than bluespace pod, so larger explosion when landing
	else if (!effectQuiet)
		playsound(src, "explosion", 80, 1)//theres no explosion, but we can still pretend!
	if (damage != 0)
		for(var/mob/living/M in T.contents)
			M.adjustBruteLoss(damage)
	if (icon_state == "gondolapod")
		var/mob/living/simple_animal/pet/gondola/gondolapod/benis = new(get_turf(src), src)
		moveToNullspace()
		addtimer(CALLBACK(src, .proc/open, benis), openingDelay)//open 3seconds after appearing
	else
		addtimer(CALLBACK(src, .proc/open, src), openingDelay)//open 3seconds after appearing

/obj/structure/closet/supplypod/open(atom/movable/holder, var/broken = FALSE, var/manual = FALSE)
	var/turf/T = get_turf(holder)
	var/mob/M
	if (istype(holder, /mob))
		M = holder
		if (M.key && !manual && !broken)//dont auto-open if we are player controlled (usually a gondola), 
			return
	opened = TRUE
	INVOKE_ASYNC(holder, .proc/setOpened)
	while(!isemptylist(launchList))
		if (QDELETED(launchList[1]))
			warning("[holder] contained a deleted object somehow. Skipping!")
			continue
		if (istype(launchList[1], /datum/supply_order))
			var/datum/supply_order/SO = launchList[1]
			SO.generate(T)//not called during populateContents as supplyorder generation requires a turf
		else
			launchList[1].forceMove(T)
		launchList.Cut(1,2)

	if (!effectQuiet)
		playsound(holder, open_sound, 15, 1, -3)
	if (bluespace && icon_state && !broken)//dont want to create sparks/delete ourselves if we're invisible or broken
		addtimer(CALLBACK(holder, .proc/sparks), 30)
	if (reversing)
		addtimer(CALLBACK(src, .proc/close, holder), 30)
	else if (bluespace)
		QDEL_IN(src,31)

/obj/structure/closet/supplypod/centcompod/close(atom/movable/holder)
	opened = FALSE
	INVOKE_ASYNC(holder, .proc/close)
	for (var/atom/movable/O in get_turf(holder))
		if (ismob(O) && !isliving(O))
			continue
		launchList.Add(O)
	var/area/A
	switch(bay)
		if(1)
			A = locate(/area/centcom/supplypod/loading/one) in GLOB.sortedAreas
		if(2)
			A = locate(/area/centcom/supplypod/loading/two) in GLOB.sortedAreas
		if(3)
			A = locate(/area/centcom/supplypod/loading/three) in GLOB.sortedAreas
		if(4)
			A = locate(/area/centcom/supplypod/loading/four) in GLOB.sortedAreas
	var/obj/effect/temp_visual/risingPod = new /obj/effect/temp_visual/DPfall(get_turf(holder), src)
	risingPod.pixel_z = 0
	holder.forceMove(A)
	animate(risingPod, pixel_z = 200, time = 10, easing = LINEAR_EASING)//make and animate a falling pod
	reversing = FALSE
	open(holder, manual = TRUE)
	return

/obj/structure/closet/supplypod/proc/setOpened()
	update_icon()

/obj/structure/closet/supplypod/proc/setClosed()
	update_icon()

/obj/structure/closet/supplypod/proc/sparks()//sparks cant be called from addtimer
 	do_sparks(5, TRUE, src)

/obj/structure/closet/supplypod/Destroy()
	if (!opened)
		open(src, TRUE)
	for (var/i=1 to launchList.len)
		if (istype(launchList[i], /datum/supply_order))
			QDEL_NULL(launchList[i])
	return ..()

/obj/structure/closet/supplypod/proc/Copy()
	var/obj/structure/closet/supplypod/centcompod/pod = new()
	pod.explosionSize = src.explosionSize
	pod.damage = src.damage
	pod.effectGib = src.effectGib
	pod.effectLimb = src.effectLimb
	pod.effectStun = src.effectStun
	pod.effectStealth = src.effectStealth
	pod.effectQuiet = src.effectQuiet
	pod.bluespace = src.bluespace
	pod.landingDelay = src.landingDelay
	pod.openingDelay = src.openingDelay
	pod.icon_state = src.icon_state
	pod.bluespace = src.bluespace
	pod.bay = src.bay
	pod.reversing = src.reversing
	return pod
//------------------------------------FALLING SUPPLY POD-------------------------------------//
/obj/effect/temp_visual/DPfall
	name = ""
	icon = 'icons/obj/2x2.dmi'
	pixel_x = -16
	pixel_y = -5
	pixel_z = 200
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	randomdir = FALSE
	icon_state = ""

/obj/effect/temp_visual/DPfall/Initialize(dropLocation, obj/structure/closet/supplypod/pod)
	if (pod.icon_state)//check to ensure pod isnt "invisible"
		icon_state = "[pod.icon_state]_falling"
		name = pod.name
	. = ..()

//------------------------------------TEMPORARY_VISUAL-------------------------------------//
/obj/effect/DPtarget
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/temp_visual/fallingPod
	var/obj/structure/closet/supplypod/podID

/obj/effect/DPtarget/Initialize(mapload, pod, launchList)
	if (ispath(pod))//id like to make a shout out
		pod = new pod()//to my man ninjanomnom
	podID = pod
	podID.launchList |= launchList
	if(podID.effectStun)
		for (var/mob/living/M in get_turf(src))
			M.Stun(podID.landingDelay, ignore_canstun = TRUE)//you aint goin nowhere, kid.
	if (podID.effectStealth)
		icon_state = ""
	addtimer(CALLBACK(src, .proc/beginLaunch), podID.landingDelay)//standard pods take 3 seconds to come in, bluespace pods take 1.5

/obj/effect/DPtarget/proc/beginLaunch()
	fallingPod = new /obj/effect/temp_visual/DPfall(drop_location(), podID)
	animate(fallingPod, pixel_z = 0, time = 3, easing = LINEAR_EASING)//make and animate a falling pod
	addtimer(CALLBACK(src, .proc/endLaunch), 3, TIMER_CLIENT_TIME)//fall 0.3seconds

/obj/effect/DPtarget/proc/endLaunch()
	podID.forceMove(drop_location())//pod is created
	podID.preOpen()
	qdel(src)

/obj/effect/DPtarget/Destroy()
	QDEL_NULL(fallingPod)//delete falling pod after animation's over
	return ..()

//------------------------------------UPGRADES-------------------------------------//
/obj/item/disk/cargo/bluespace_pod
	name = "Bluespace Drop Pod Upgrade"
	desc = "This disk provides a firmware update to the Express Supply Console, granting the use of Nanotrasen's Bluespace Drop Pods to the supply department."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL
