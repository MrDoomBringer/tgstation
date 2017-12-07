/obj/machinery/computer/cargo_express
	name = "express supply console"
	desc = "Used to order express supplies"
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo
	light_color = "#E2853D"//orange
	var/launch = 5


/obj/machinery/computer/cargo_express/Initialize()
	..()

/obj/machinery/computer/cargo_express/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "cargo_express", name, 275, 100, master_ui, state)
    ui.open()


/obj/machinery/computer/cargo_express/ui_data()
	//var/list/data = list()
//	data["launch"] = launch
	//return data

	var/list/data = list()

	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)

		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"id" = pack
		))


	return data
/obj/machinery/computer/cargo_express/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("add")
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			//if((pack.hidden && !emagged) || (pack.contraband && !contraband))
			//	return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment()
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/reason = ""

			
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason)
			SO.generate(loc)




			//var/list/empty_turfs = list()
			//var/area/quartermaster/meme = /area/quartermaster/storage.contents
			var/list/empty_turfs23 = list()
			var/area/quartermaster/yeet = locate() in GLOB.sortedAreas
			for(var/turf/open/floor/T in yeet.contents)
				if(is_blocked_turf(T))
					continue
				empty_turfs23.Add(T)

			if (empty_turfs23.len != 0 && launch >0)
				launch--
				var/LZ = empty_turfs23[rand(empty_turfs23.len-1)]
				var/obj/effect/temp_visual/BDPtarget/Testopresta = new /obj/effect/temp_visual/BDPtarget(LZ)
			//	Testopresta.launch(LZ)
				message_admins("i birthed a nibba [Testopresta.x],[Testopresta.y],[Testopresta.z] haha")


			. = TRUE
			update_icon()


				/*-------------------
					switch(action)
						if("launch")

			//var/list/empty_turfs = list()
			//var/area/quartermaster/meme = /area/quartermaster/storage.contents
			var/area/quartermaster/yeet = locate() in GLOB.sortedAreas
			for(var/turf/open/floor/T in yeet.contents)
				if(is_blocked_turf(T))
					message_admins("miss that shis")
					continue
				new /obj/structure/closet/dropcloset(T)

	--------------------------------------*/
///	shuttle_areas = list()

			//empty_turfs += T
		//	for(var/turf/place in /area/quartermaster/storage)
			//	new /obj/structure/closet/dropcloset(place)
			//	for (var/E in I.contents)
					//if (E.density == FALSE && E.istype(obj))

///	shuttle_areas = list()
//	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
//	for(var/i in 1 to all_turfs.len)
	//	var/turf/curT = all_turfs[i]
	//	var/area/cur_area = curT.loc
		//if(istype(cur_area, area_type))
		//	shuttle_areas[cur_area] = TRUE




	//add this
		//add research grants
	//add roblox tycoon to game (uses droppods to deliver objects)

	//roblox tycoons take metal, produce magic boxes which in turn make credits
	//credits can be used to upgrade conveyors and efficiency etc
	//maybe order special seed which grows into a beautiful magic box converter (botany)
	//or magic flour which can be added into a machine to increase efficiency
	//or a cool chemical which can be added to do this as well
	//somehow genetics, sec, medbay involvement?
	//engineering can create higher-tier efficiency as well (maybe they are provided with boards or a paper showing specific building instruction)
	//research can use stock parts to upgrade machines


	//add something to spend cargopoints on other than better tycoons (maybe a mining megaboss meme) (or a auto singulo gen for cargo)

	//if(is_blocked_turf(T))
			//	continue