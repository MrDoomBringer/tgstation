/**
 * tgui
 *
 * /tg/station user interface library
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui datum (represents a UI).
 */
/datum/tgui
	/// The mob who opened/is using the UI.
	var/mob/user
	/// The object which owns the UI.
	var/datum/src_object
	/// The title of te UI.
	var/title
	/// The window_id for browse() and onclose().
	var/datum/tgui_window/window
	/// Key that is used for remembering the window geometry.
	var/window_key
	/// The interface (template) to be used for this UI.
	var/interface
	/// Update the UI every MC tick.
	var/autoupdate = TRUE
	/// If the UI has been initialized yet.
	var/initialized = FALSE
	/// Stops further updates when close() was called.
	var/closing = FALSE
	/// The status/visibility of the UI.
	var/status = UI_INTERACTIVE
	/// Topic state used to determine status/interactability.
	var/datum/ui_state/state = null
	/// Asset data to be sent with every update.
	var/list/asset_data
	/// Timestamp of the last ping
	var/received_ping_at

/**
 * public
 *
 * Create a new UI.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object or datum which owns the UI.
 * required interface string The interface used to render the UI.
 * optional title string The title of the UI.
 *
 * return datum/tgui The requested UI.
 */
/datum/tgui/New(mob/user, datum/src_object, interface, title)
	log_tgui(user, "new [interface] fancy [user.client.prefs.tgui_fancy]")
	src.user = user
	src.src_object = src_object
	src.window_key = "[REF(src_object)]-main"
	src.interface = interface
	if(title)
		src.title = title
	src.state = src_object.ui_state()

/**
 * public
 *
 * Open this UI (and initialize it with data).
 */
/datum/tgui/proc/open()
	if(!user.client)
		return null
	if(window)
		return null
	process_status()
	if(status < UI_UPDATE)
		return null
	// Initialize with current time because process() checks this for timeouts
	received_ping_at = world.time
	window = SStgui.request_pooled_window(user)
	if(!window)
		return null
	window.acquire_lock(src)
	if(!window.is_ready())
		window.initialize()
	else
		window.send_message("ping")
	for(var/datum/asset/asset in src_object.ui_assets(user))
		send_asset(asset)
	window.send_message("update", get_payload(
		with_data = TRUE,
		with_static_data = TRUE))
	SStgui.on_open(src)

/**
 * public
 *
 * Close the UI.
 */
/datum/tgui/proc/close(can_be_suspended = TRUE)
	if(closing)
		return
	closing = TRUE
	// If we don't have window_id, open proc did not have the opportunity
	// to finish, therefore it's safe to skip this whole block.
	if(window)
		window.release_lock(can_be_suspended)
		src_object.ui_close(user)
		SStgui.on_close(src)
	state = null
	qdel(src)

/**
 * public
 *
 * Enable/disable auto-updating of the UI.
 *
 * required value bool Enable/disable auto-updating.
 */
/datum/tgui/proc/set_autoupdate(autoupdate)
	src.autoupdate = autoupdate

/**
 * public
 *
 * Replace current ui.state with a new one.
 *
 * required state datum/ui_state/state Next state
 */
/datum/tgui/proc/set_state(datum/ui_state/state)
	src.state = state

/**
 * public
 *
 * Makes an asset available to use in tgui.
 *
 * required asset datum/asset
 */
/datum/tgui/proc/send_asset(var/datum/asset/asset)
	if(!user.client)
		return
	if(istype(asset, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/spritesheet = asset
		LAZYINITLIST(asset_data)
		LAZYADD(asset_data["styles"], list(spritesheet.css_filename()))
	asset.send(user)

/datum/tgui/proc/send_full_update(custom_data, force)
	if(!user.client || !initialized || closing)
		return
	var/should_update_data = force || status > UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data,
		with_static_data = TRUE))

/datum/tgui/proc/send_update(custom_data, force)
	if(!user.client || !initialized || closing)
		return
	var/should_update_data = force || status > UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data))

/**
 * private
 *
 * Package the data to send to the UI, as JSON.
 *
 * return list JSON
 */
/datum/tgui/proc/get_payload(custom_data, with_data, with_static_data)
	var/list/json_data = list()
	json_data["config"] = list(
		"title" = title,
		"status" = status,
		"interface" = interface,
		"fancy" = user.client.prefs.tgui_fancy,
		"user" = list(
			"name" = "[user]",
			"ckey" = "[user.ckey]",
			"observer" = isobserver(user),
		),
		"window" = list(
			"id" = window.id,
			"key" = window_key,
		),
		// NOTE: Intentional \ref usage; tgui datums can't/shouldn't
		// be tagged, so this is an effective unwrap
		"ref" = "\ref[src]",
	)
	var/data = custom_data || with_data && src_object.ui_data(user)
	if(data)
		json_data["data"] = data
	var/static_data = with_static_data && src_object.ui_static_data(user)
	if(static_data)
		json_data["static_data"] = static_data
	if(asset_data)
		json_data["assets"] = asset_data
	if(src_object.tgui_shared_states)
		json_data["shared"] = src_object.tgui_shared_states
	return json_data

/datum/tgui/proc/on_message(type, list/payload, list/href_list)
	if(type && copytext(type, 1, 6) != "tgui:")
		process_status()
		if(src_object.ui_act(type, payload, src, state))
			SStgui.update_uis(src_object)
		return FALSE
	switch(type)
		if("tgui:ready")
			initialized = TRUE
		if("tgui:close")
			close()
		if("tgui:log")
			if(href_list["fatal"])
				autoupdate = FALSE
		if("tgui:ping_reply")
			initialized = TRUE
			received_ping_at = world.time
		if("tgui:set_shared_state")
			LAZYINITLIST(src_object.tgui_shared_states)
			src_object.tgui_shared_states[href_list["key"]] = href_list["value"]
			SStgui.update_uis(src_object)

/datum/tgui/process(force = FALSE)
	if(closing)
		return
	var/datum/host = src_object.ui_host(user)
	if(!src_object || !host || !user) // If the object or user died (or something else), abort.
		close(can_be_suspended = FALSE)
		return
	// Validate previous ping
	if(world.time - received_ping_at > 5 SECONDS)
		log_tgui(user, "ERROR: Zombie window detected, killing it with fire.")
		close(can_be_suspended = FALSE)
		return
	// Send ping
	window.send_message("ping")
	// Update through a normal call to ui_interact
	if(status != UI_DISABLED && (autoupdate || force))
		src_object.ui_interact(user, src)
		return
	// Update status only
	var/needs_update = process_status()
	if(status <= UI_CLOSE)
		close()
		return
	if(needs_update)
		window.send_message("update", get_payload())

/datum/tgui/proc/process_status()
	var/prev_status = status
	status = src_object.ui_status(user, state)
	return prev_status != status
