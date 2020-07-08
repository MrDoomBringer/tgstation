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
	var/window_id
	/// Key that is used for remembering the window geometry.
	var/window_key
	/// The interface (template) to be used for this UI.
	var/interface
	/// Update the UI every MC tick.
	var/autoupdate = TRUE
	/// If the UI has been initialized yet.
	var/initialized = FALSE
	/// The data (and datastructure) used to initialize the UI.
	var/list/initial_data
	/// Holder for the json string, that is sent during the initial update
	var/_initial_update
	/// Whether UI has fatally errored
	var/_has_fatal_error = FALSE
	/// The status/visibility of the UI.
	var/status = UI_INTERACTIVE
	/// Topic state used to determine status/interactability.
	var/datum/ui_state/state = null
	/// Asset data to be sent with every update
	var/list/asset_data

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
	log_tgui("[user] ([user.ckey]):\nnew [interface] fancy [user.client.prefs.tgui_fancy]")
	src.user = user
	src.src_object = src_object
	src.window_key = "[REF(src_object)]-main"
	src.interface = interface
	if(title)
		src.title = title
	src.state = src_object.ui_state()
	// Send assets
	var/datum/asset/asset
	asset = get_asset_datum(/datum/asset/group/tgui)
	asset.send(user)
	for(asset in src_object.ui_assets(user))
		src.send_asset(asset)

/**
 * public
 *
 * Open this UI (and initialize it with data).
 */
/datum/tgui/proc/open()
	// Bail if there is no client
	if(!user.client)
		return
	// Bail if window is already open
	if(window_id)
		return
	// Update the window status.
	update_status(push = FALSE)
	// Bail if we're not supposed to open.
	if(status < UI_UPDATE)
		return
	window_id = SStgui.allocate_window(user)
	// Bail if subsystem could not allocate a window_id
	if(!window_id)
		return
	// Pre-fetch initial state while browser is still loading
	if(!initial_data)
		initial_data = src_object.ui_data(user)
	_initial_update = url_encode(get_json(
		initial_data,
		src_object.ui_static_data(user)))
	// Send a full update if window is being reused
	if(SStgui.is_window_ready(user, window_id))
		SStgui.acquire_window(user, window_id)
		SStgui.send_data(user, window_id, _initial_update)
		initialized = TRUE
	SStgui.on_open(src)

/**
 * public
 *
 * Reinitialize the UI.
 * (Possibly with a new interface and/or data).
 *
 * optional template string The name of the new interface.
 * optional data list The new initial data.
 */
/datum/tgui/proc/reinitialize(interface, list/data)
	if(interface)
		src.interface = interface
	if(data)
		initial_data = data
	open()

/**
 * public
 *
 * Close the UI.
 */
/datum/tgui/proc/close(recycle = TRUE)
	if(status == UI_CLOSING)
		return
	status = UI_CLOSING
	// If we don't have window_id, open proc did not have the opportunity
	// to finish, therefore it's safe to skip this whole block.
	if(window_id)
		var/can_be_recycled = recycle && !_has_fatal_error
		if(can_be_recycled)
			SStgui.release_window(user, window_id)
		else
			SStgui.close_window(user, window_id)
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
	if(istype(asset, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/spritesheet = asset
		LAZYINITLIST(asset_data)
		LAZYADD(asset_data["styles"], list(spritesheet.css_filename()))
	asset.send(user)

/**
 * private
 *
 * Package the data to send to the UI, as JSON.
 * This includes the UI data and config_data.
 *
 * return string The packaged JSON.
 */
/datum/tgui/proc/get_json(list/data, list/static_data)
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
			"id" = window_id,
			"key" = window_key,
		),
		// NOTE: Intentional \ref usage; tgui datums can't/shouldn't
		// be tagged, so this is an effective unwrap
		"ref" = "\ref[src]"
	)
	if(!isnull(data))
		json_data["data"] = data
	if(!isnull(static_data))
		json_data["static_data"] = static_data
	if(!isnull(asset_data))
		json_data["assets"] = asset_data
	if(src_object.tgui_shared_states)
		json_data["shared"] = src_object.tgui_shared_states
	// Generate the JSON.
	var/json = json_encode(json_data)
	// Strip #255/improper.
	json = replacetext(json, "\proper", "")
	json = replacetext(json, "\improper", "")
	return json

/**
 * private
 *
 * Handle clicks from the UI.
 * Call the src_object's ui_act() if status is UI_INTERACTIVE.
 * If the src_object's ui_act() returns 1, update all UIs attacked to it.
 */
/datum/tgui/Topic(href, href_list)
	if(user != usr)
		return // Something is not right here.

	var/action = href_list["action"]
	var/params = href_list; params -= "action"

	switch(action)
		if("tgui:close")
			close()
		if("tgui:initialize")
			SStgui.acquire_window(user, window_id)
			SStgui.send_data(user, window_id, _initial_update)
			initialized = TRUE
		if("tgui:setSharedState")
			// Update the window state.
			update_status(push = FALSE)
			// Bail if UI is not interactive or usr calling Topic
			// is not the UI user.
			if(status != UI_INTERACTIVE)
				return
			var/key = params["key"]
			var/value = params["value"]
			if(!src_object.tgui_shared_states)
				src_object.tgui_shared_states = list()
			src_object.tgui_shared_states[key] = value
			SStgui.update_uis(src_object)
		if("tgui:setFancy")
			var/value = text2num(params["value"])
			user.client.prefs.tgui_fancy = value
		if("tgui:log")
			if(params["fatal"])
				_has_fatal_error = TRUE
				autoupdate = FALSE
			// NOTE: Logging is handled in client_procs.dm (/client/Topic)
		if("tgui:link")
			user << link(params["url"])
		else
			// Update the window state.
			update_status(push = FALSE)
			// Call ui_act() on the src_object.
			if(src_object.ui_act(action, params, src, state))
				// Update if the object requested it.
				SStgui.update_uis(src_object)

/**
 * private
 *
 * Update the UI.
 * Only updates the data if update is true, otherwise only updates the status.
 *
 * optional force bool If the UI should be forced to update.
 */
/datum/tgui/process(force = FALSE)
	if(status == UI_CLOSING)
		return
	var/datum/host = src_object.ui_host(user)
	if(!src_object || !host || !user) // If the object or user died (or something else), abort.
		close()
		return
	if(status && (force || autoupdate))
		update() // Update the UI if the status and update settings allow it.
	else
		update_status(push = TRUE) // Otherwise only update status.

/**
 * private
 *
 * Push data to an already open UI.
 *
 * required data list The data to send.
 * optional force bool If the update should be sent regardless of state.
 */
/datum/tgui/proc/push_data(data, static_data, force = FALSE)
	// Update the window state.
	update_status(push = FALSE)
	// Cannot update UI if it is not set up yet.
	if(!initialized)
		return
	// Cannot update UI, we have no visibility.
	if(status <= UI_DISABLED && !force)
		return
	SStgui.send_data(user, window_id, url_encode(get_json(data, static_data)))

/**
 * private
 *
 * Updates the UI by interacting with the src_object again, which will hopefully
 * call try_ui_update on it.
 *
 * optional force_open bool If force_open should be passed to ui_interact.
 */
/datum/tgui/proc/update(force_open = FALSE)
	src_object.ui_interact(user, src, force_open)

/**
 * private
 *
 * Update the status/visibility of the UI for its user.
 *
 * optional push bool Push an update to the UI (an update is always sent for UI_DISABLED).
 */
/datum/tgui/proc/update_status(push = FALSE)
	var/status = src_object.ui_status(user, state)
	set_status(status, push)
	if(status == UI_CLOSE)
		close()

/**
 * private
 *
 * Set the status/visibility of the UI.
 *
 * required status int The status to set (UI_CLOSE/UI_DISABLED/UI_UPDATE/UI_INTERACTIVE).
 * optional push bool Push an update to the UI (an update is always sent for UI_DISABLED).
 */
/datum/tgui/proc/set_status(status, push = FALSE)
	// Only update if status has changed.
	if(src.status != status)
		if(src.status == UI_DISABLED)
			src.status = status
			if(push)
				update()
		else
			src.status = status
			// Update if the UI just because disabled, or a push is requested.
			if(status == UI_DISABLED || push)
				push_data(null, force = TRUE)
