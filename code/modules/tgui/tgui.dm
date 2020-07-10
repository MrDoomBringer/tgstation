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
	/// Gates further updates when close was called.
	var/closing = FALSE
	/// The status/visibility of the UI.
	var/status = UI_INTERACTIVE
	/// Topic state used to determine status/interactability.
	var/datum/ui_state/state = null
	/// Asset data to be sent with every update.
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
	// Update the window status.
	update_status(push = FALSE)
	// Bail if we're not supposed to open.
	if(status < UI_UPDATE)
		return null
	window = SStgui.request_pooled_window(user)
	if(!window)
		return null
	window.acquire_lock()
	if(!window.is_ready())
		window.initialize()
		initialized = TRUE
	for(var/datum/asset/asset in src_object.ui_assets(user))
		send_asset(asset)
	window.send_message("update", get_payload(with_static = TRUE))
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
	if(istype(asset, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/spritesheet = asset
		LAZYINITLIST(asset_data)
		LAZYADD(asset_data["styles"], list(spritesheet.css_filename()))
	asset.send(user)

/**
 * private
 *
 * Package the data to send to the UI, as JSON.
 *
 * return list JSON
 */
/datum/tgui/proc/get_payload(with_static = FALSE)
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
	var/data = src_object.ui_data(user)
	if(data)
		json_data["data"] = data
	var/static_data = with_static && src_object.ui_static_data(user)
	if(static_data)
		json_data["static_data"] = static_data
	if(asset_data)
		json_data["assets"] = asset_data
	if(src_object.tgui_shared_states)
		json_data["shared"] = src_object.tgui_shared_states
	return json_data

/datum/tgui/proc/on_message(type, list/payload, list/href_list)
	if(type && copytext(type, 1, 6) != "tgui:")
		if(src_object.ui_act(type, payload, src, state))
			SStgui.update_uis(src_object)
		return FALSE
	if(type == "tgui:ready")
		initialized = TRUE
		return FALSE
	if(type == "tgui:close")
		close()
		return FALSE
	if(type == "tgui:log")
		if(href_list["fatal"])
			autoupdate = FALSE
		return TRUE
	if(type == "tgui:set_shared_state")
		LAZYINITLIST(src_object.tgui_shared_states)
		src_object.tgui_shared_states[href_list["key"]] = href_list["value"]
		SStgui.update_uis(src_object)
		return FALSE
	return TRUE


/**
 * private
 *
 * Update the UI.
 * Only updates the data if update is true, otherwise only updates the status.
 *
 * optional force bool If the UI should be forced to update.
 */
/datum/tgui/process(force = FALSE)
	if(closing)
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
	// Can not continue if ui is in process of closing
	if(!closing)
		return
	// Cannot update UI if it is not set up yet.
	if(!initialized)
		return
	// Cannot update UI, we have no visibility.
	if(status <= UI_DISABLED && !force)
		return
	window.send_message("update", get_payload())

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
