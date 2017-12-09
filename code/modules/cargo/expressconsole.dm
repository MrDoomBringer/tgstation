/obj/machinery/computer/cargo/express
	name = "express supply console"
	desc = "This console allows the user to purchase a package for double the price,\
		with 1/40th of the delivery time: made possible by NanoTrasen's new \"Drop Pod Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	blockade_warning = "Bluespace instability detected. Delivery impossible."

/obj/machinery/computer/cargo/express/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "cargo_express", name, 1000, 800, master_ui, state)
    ui.open()


/obj/machinery/computer/cargo/express/ui_data()
	var/list/data = list()
	data["points"] = SSshuttle.points
	data["supplies"] = list()
	var/message = "For normally priced items, please use the standard Supply or Request Console. \
		Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message

	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && !emagged) || (P.contraband && !contraband) || (P.special && !P.special_enabled))
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost * 2, //displays twice the normal cost
			"id" = pack
		))

	return data
/obj/machinery/computer/cargo/express/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if("add")//Generate Supply Order first
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
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
			if(SO.pack.cost* 2 <= SSshuttle.points) //If you can afford it, then begin the delivery
				SO.generateRequisition(get_turf(src))
				SSshuttle.points -= SO.pack.cost * 2//twice the normal cost

				var/list/empty_turfs = list()
				var/area/quartermaster/landingzone = locate() in GLOB.sortedAreas

				for(var/turf/open/floor/T in landingzone.contents) //get all the turfs in cargo bay
					if(is_blocked_turf(T))//wont land on a blocked turf
						continue
					empty_turfs.Add(T)

				if (empty_turfs.len != 0 )
					var/LZ = empty_turfs[rand(empty_turfs.len-1)]//pick a random turf
					new /obj/effect/temp_visual/BDPtarget(LZ, SO)//where the magic happens. this temp visual makes the actual droppod after a pause
				. = TRUE
				update_icon()