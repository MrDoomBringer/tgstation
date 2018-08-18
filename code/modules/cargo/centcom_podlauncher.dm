/client/proc/centcom_podlauncher()
	set name = "Config/Launch Supplypod"
	set desc = "Configure and launch a Centcom supplypod full of whatever your heart desires!"
	set category = "Admin"
	var/datum/centcom_podlauncher/plaunch  = new(usr)
	if(!holder)
		message_admins("yike2")
	//	return
	message_admins("yike")
	plaunch.ui_interact(usr)

/datum/centcom_podlauncher///obj/structure/closet/supplypod
	var/static/list/ignored_atoms = typecacheof(list(null, /mob/dead, /obj/effect/landmark, /obj/docking_port, /atom/movable/lighting_object, /obj/effect/particle_effect/sparks, /obj/effect/DPtarget))
	var/turf/oldTurf
	var/client/holder
	var/bay = 1
	var/launchClone = FALSE
	var/launchChoice = 0
	var/explosionChoice = 0
	var/damageChoice = 0
	var/launcherActivated = FALSE
	var/numTurfs = 0
	var/launchCounter = 1
	var/list/orderedArea = list()
	var/list/acceptableTurfs = list()
	var/list/launchList = list()
	var/obj/effect/supplypod_selector/selector = new()
	var/obj/structure/closet/supplypod/centcompod/temp_pod = new()

/datum/centcom_podlauncher/New(H)
	if (istype(H,/client))
		var/client/C = H
		holder = C
	else
		var/mob/M = H
		holder = M.client
	setupArea()
	
/*
/datum/centcom_podlauncher/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	message_admins("yiketh")
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	message_admins("[user] is user")
	to_chat(user, "<i>You hear a voice in your head... <b>ur gay ahahha</i></b>")
	if(!ui)
		message_admins("no ui")
		ui = new(user, src, ui_key, "centcom_podlauncher", "Centcom Pod Launcher", 1000, 800, master_ui, state)
		ui.open()
		//ui.set_autoupdate(FALSE) // This UI is only ever opened by one person, and never is updated outside of user input.
		*/
/datum/centcom_podlauncher/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, \
force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "centcom_podlauncher", "Config/Launch Supplypod", 700, 600, master_ui, state)
		ui.open()
		to_chat(user, "asdf")

/datum/centcom_podlauncher/ui_data(mob/user)
	message_admins("who care")
	var/list/data = list()
	data["bay"] = bay
	data["oldTurf"] = (oldTurf ? get_area(oldTurf) : null)
	data["launchClone"] = launchClone
	data["launchChoice"] = launchChoice
	data["explosionChoice"] = explosionChoice
	data["damageChoice"] = damageChoice
	data["landingDelay"] = temp_pod.landingDelay
	data["openingDelay"] = temp_pod.openingDelay
	data["styleChoice"] = temp_pod.icon_state
	data["effectStun"] = temp_pod.effectStun
	data["effectLimb"] = temp_pod.effectLimb
	data["effectBluespace"] = temp_pod.bluespace
	data["effectStealth"] = temp_pod.effectStealth
	data["effectQuiet"] = temp_pod.effectQuiet//, the female sniper
	data["effectReverse"] = temp_pod.reversing
	data["giveLauncher"] = launcherActivated
	data["numObjects"] = numTurfs
	return data

/datum/centcom_podlauncher/ui_act(action, params)
	if(..())
		return
	message_admins("asdf")
	switch(action)
		if("bay1")
			bay = 1
			refreshBay()
			. = TRUE
		if("bay2")
			bay = 2
			refreshBay()
			. = TRUE
		if("bay3")
			bay = 3
			refreshBay()
			. = TRUE
		if("bay4")
			bay = 4
			refreshBay()
			. = TRUE
		if("teleportCentcom")
			var/mob/M = holder.mob
			oldTurf = get_turf(M)
			var/area/A = locate(/area/centcom/supplypod/loading) in GLOB.sortedAreas
			var/list/turfs = list()
			for(var/turf/T in A)
				turfs.Add(T)
			var/turf/T = safepick(turfs)
			if(!T)
				to_chat(M, "Nowhere to jump to!")
				return
			M.forceMove(T)
			log_admin("[key_name(usr)] jumped to [AREACOORD(A)]")
			message_admins("[key_name_admin(usr)] jumped to [AREACOORD(A)]")
			. = TRUE
		if("teleportBack")
			var/mob/M = holder.mob
			M.forceMove(oldTurf)
			log_admin("[key_name(usr)] jumped to [AREACOORD(oldTurf)]")
			message_admins("[key_name_admin(usr)] jumped to [AREACOORD(oldTurf)]")
			. = TRUE
		if("launchClone")
			launchClone = !launchClone
			. = TRUE
		if("launchOrdered")
			if (launchChoice == 1)
				launchChoice = 0
				return
			launchChoice = 1
			. = TRUE
		if("launchRandom")
			if (launchChoice == 2)
				launchChoice = 0
				return
			launchChoice = 2
			. = TRUE

		//*		POD OPTIONS		*//
		if("explosionCustom")
			if (explosionChoice == 1)
				explosionChoice = 0
				temp_pod.explosionSize = list(0,0,0,0)
				return
			explosionChoice = 1
			var/list/expNames = list("Devastation", "Heavy Damage", "Light Damage", "Flame")
			for (var/i=1 to expNames.len)
				var/boomInput = input("[expNames[i]] Range", "Enter the [expNames[i]] range of the explosion", 0) as null|num
				if (!isnum(boomInput))
					alert(usr, "That wasnt a number! Value set to default (zero) instead.")
					boomInput = 0
				temp_pod.explosionSize[i] = boomInput
			. = TRUE
		if("explosionBus")
			if (explosionChoice == 2)
				explosionChoice = 0
				temp_pod.explosionSize = list(0,0,0,0)
				return
			explosionChoice = 2
			temp_pod.explosionSize = list(5,10,20,30)
			. = TRUE
		if("damageCustom")
			if (damageChoice == 1)
				damageChoice = 0
				temp_pod.damage = 0
				return
			damageChoice = 1
			var/damageInput = input("How much damage to deal", "Enter the amount of brute damage dealt by getting hit", 0) as null|num
			if (!isnum(damageInput))
				alert(usr, "That wasnt a number! Value set to default (zero) instead.")
				damageInput = 0
			temp_pod.damage = damageInput
			. = TRUE
		if("damageGib")
			if (damageChoice == 2)
				damageChoice = 0
				temp_pod.damage = 0
				temp_pod.effectGib = FALSE
				return
			damageChoice = 2
			temp_pod.damage = 5000
			temp_pod.effectGib = TRUE
			. = TRUE
		if("effectStun")
			temp_pod.effectStun = !temp_pod.effectStun
			. = TRUE
		if("effectLimb")
			temp_pod.effectLimb = !temp_pod.effectLimb
			. = TRUE
		if("effectBluespace")
			temp_pod.bluespace = !temp_pod.bluespace
			. = TRUE
		if("effectStealth")
			temp_pod.effectStealth = !temp_pod.effectStealth
			. = TRUE
		if("effectQuiet")
			temp_pod.effectQuiet = !temp_pod.effectQuiet
			. = TRUE
		if("effectReverse")
			temp_pod.reversing = !temp_pod.reversing
			. = TRUE
		if("landingDelay")
			if (temp_pod.landingDelay != 5)
				temp_pod.landingDelay = 5
				return
			var/timeInput = 10 * input("Delay Time", "Enter the time it takes for the pod to land, in seconds", 0.5) as null|num
			if (!isnum(timeInput))
				alert(usr, "That wasnt a number! Value set to default (0.5) instead.")
				timeInput = 5
			temp_pod.landingDelay = timeInput
			. = TRUE
		if("openingDelay")
			if (temp_pod.openingDelay != 30)
				temp_pod.openingDelay = 30
				return
			var/timeInput = 10 * input("Delay Time", "Enter the time it takes for the pod to open after landing, in seconds", 3) as null|num
			if (!isnum(timeInput))
				alert(usr, "That wasnt a number! Value set to default (3) instead.")
				timeInput = 30
			temp_pod.openingDelay = timeInput
			. = TRUE
		if("styleStandard")
			if (temp_pod.icon_state == "supplypod")
				temp_pod.icon_state = "centcompod"
				return
			temp_pod.icon_state = "supplypod"
			. = TRUE
		if("styleBluespace")
			if (temp_pod.icon_state == "bluespacepod")
				temp_pod.icon_state = "centcompod"
				return
			temp_pod.icon_state = "bluespacepod"
			. = TRUE
		if("styleSyndie")
			if (temp_pod.icon_state == "syndiepod")
				temp_pod.icon_state = "centcompod"
				return
			temp_pod.icon_state = "syndiepod"
			. = TRUE
		if("styleHONK")
			if (temp_pod.icon_state == "honkpod")
				temp_pod.icon_state = "centcompod"
				return
			temp_pod.icon_state = "honkpod"
			. = TRUE
		if("styleInvisible")
			if (temp_pod.icon_state == "")
				temp_pod.icon_state = "centcompod"
				return
			temp_pod.icon_state = ""
			. = TRUE
		if("styleGondola")
			if (temp_pod.icon_state == "gondolapod")
				temp_pod.icon_state = "centcompod"
				return
			temp_pod.icon_state = "gondolapod"
			. = TRUE

		//*		LAUNCH		*//
		if("refresh")
			refreshBay()
			. = TRUE

		if("giveLauncher")
			launcherActivated = !launcherActivated
			updateCursor(launcherActivated)
			. = TRUE

/datum/centcom_podlauncher/ui_close()
	qdel(src)

/datum/centcom_podlauncher/proc/updateCursor(var/boolean)
	if (boolean)
		holder.mouse_up_icon = 'icons/effects/supplypod_target.dmi'
		holder.mouse_down_icon = 'icons/effects/supplypod_down_target.dmi'
		holder.mouse_pointer_icon = holder.mouse_up_icon
		holder.click_intercept = src
	else
		var/mob/M = holder.mob
		holder.mouse_up_icon = null
		holder.mouse_down_icon = null
		holder.click_intercept = null
		M.update_mouse_pointer()

/datum/centcom_podlauncher/proc/InterceptClickOn(user,params,atom/object) //Click Intercept
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	if (launcherActivated)
		//Clicking on UI elements shouldn't try to build things in nullspace.
		if(istype(object,/obj/screen))
			return FALSE

		. = TRUE

		if(left_click)
			findAcceptable()
			preLaunch()
			launch(object)
			log_admin("Centcom Supplypod Launch: [key_name(user)] launched a supplypod in [AREACOORD(object)]")

/datum/centcom_podlauncher/proc/refreshBay()
	temp_pod.bay = bay//used for the reverse pod
	setupArea()
	findAcceptable()
	preLaunch()	

/datum/centcom_podlauncher/proc/findAcceptable()
	numTurfs = 0
	acceptableTurfs = list()
	for (var/turf/T in orderedArea)
		if (typecache_filter_list_reverse(T.contents, ignored_atoms).len != 0)//if there is something in this turf that isnt in the blacklist, we consider this turf good to go for launching the stuff in it
			acceptableTurfs.Add(T)
			numTurfs ++
	message_admins("\n \n \n acceptabelArea is [acceptableTurfs]")

/datum/centcom_podlauncher/proc/setupArea()
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
		else
			warning("No /area/centcom/supplypod/loading suptype in the world! Yell at a mapper to add one, today!")
	message_admins("area is [A.contents]")
	orderedArea = createOrderedArea(A)
	message_admins("\n \n \n area is [orderedArea]")

/datum/centcom_podlauncher/proc/createOrderedArea(area/A)
	orderedArea = list()
	if (!isemptylist(A.contents)) 
		var/startX = A.contents[1].x
		var/endX = A.contents[1].x
		var/startY = A.contents[1].y
		var/endY = A.contents[1].y
		for (var/turf/T in A)
			if (T.x < startX)
				startX = T.x
			else if (T.x > endX)
				endX = T.x
			else if (T.y > startY)
				startY = T.y
			else if (T.y < endY)
				endY = T.y
		for (var/i in endY to startY)
			for (var/j in startX to endX)
				orderedArea.Add(locate(j,startY - (i - endY),1))
	return orderedArea

/datum/centcom_podlauncher/proc/preLaunch()
	launchList = list()
	if (acceptableTurfs.len && !temp_pod.reversing)
		switch(launchChoice)
			if(0)
				for (var/turf/T in acceptableTurfs)
					launchList |= typecache_filter_list_reverse(T.contents, ignored_atoms)
			if(1)
				if (!launchClone)
					for (var/atom/movable/O in acceptableTurfs[1].contents)
						launchList |= typecache_filter_list_reverse(acceptableTurfs[1].contents, ignored_atoms)
					
				else
					if (launchCounter > acceptableTurfs.len)
						launchCounter = 1
					for (var/atom/movable/O in acceptableTurfs[launchCounter].contents)
						launchList |= typecache_filter_list_reverse(acceptableTurfs[launchCounter].contents, ignored_atoms)
			if(2)
				launchList |= typecache_filter_list_reverse(pick_n_take(acceptableTurfs).contents, ignored_atoms)

/datum/centcom_podlauncher/proc/launch(atom/A)	
	var/obj/structure/closet/supplypod/centcompod/toLaunch = temp_pod.Copy()
	toLaunch.update_icon()//we update_icon() here while the pod is in nullspace so that the door doesnt "flicker on" right after it lands
	if (launchChoice == 1 && !isemptylist(acceptableTurfs))
		var/index = launchClone ? 2 : launchCounter + 1
		if (index > acceptableTurfs.len)
			index = 1
		selector.forceMove(acceptableTurfs[index])
	else
		selector.moveToNullspace()
	
	var/list/cloneList = list()
	if (launchClone)
		for (var/atom/movable/O in launchList)
			cloneList.Add(DuplicateObject(O))
		new /obj/effect/DPtarget(get_turf(A), toLaunch, cloneList)
	else	
		for (var/atom/movable/O in launchList)
			O.moveToNullspace()
		new /obj/effect/DPtarget(get_turf(A), toLaunch, launchList)
	if (launchChoice == 1)
		launchCounter++

/datum/centcom_podlauncher/Destroy()
	updateCursor(FALSE)
	QDEL_NULL(temp_pod)
	. = ..()