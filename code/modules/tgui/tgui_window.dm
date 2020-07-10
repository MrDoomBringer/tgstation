/datum/tgui_window
	var/id
	var/client/client
	var/ckey
	var/pooled
	var/pool_index
	var/status = TGUI_WINDOW_CLOSED
	var/locked = FALSE
	var/broken = FALSE
	var/message_queue

/datum/tgui_window/New(client/client, id, pooled = FALSE)
	src.id = id
	src.client = client
	src.ckey = client.ckey
	src.pooled = pooled
	if(pooled)
		client.tgui_windows[id] = src
		src.pool_index = TGUI_WINDOW_INDEX(id)

/datum/tgui_window/proc/initialize()
	log_tgui(client, "[id]/initialize")
	if(!client)
		return null
	status = TGUI_WINDOW_LOADING
	message_queue = null
	// Build window options
	var/options = "file=[id].html;can_minimize=0;auto_format=0;"
	// Remove titlebar and resize handles for a fancy window
	if(client.prefs.tgui_fancy)
		options += "titlebar=0;can_resize=0;"
	else
		options += "titlebar=1;can_resize=1;"
	// Generate page html
	// TODO: Make this static
	var/html = SStgui.basehtml
	html = replacetextEx(html, "\[tgui:windowId]", id)
	// Send required assets
	var/datum/asset/asset
	asset = get_asset_datum(/datum/asset/group/tgui)
	asset.send(client)
	// Open the window
	client << browse(html, "window=[id];[options]")
	// Instruct the client to signal UI when the window is closed.
	winset(client, id, "on-close=\"uiclose [id]\"")

/datum/tgui_window/proc/is_ready()
	return status == TGUI_WINDOW_READY

/datum/tgui_window/proc/can_be_suspended()
	return !broken \
		&& pooled \
		&& pool_index > 0 \
		&& pool_index <= TGUI_WINDOW_SOFT_LIMIT \
		&& status >= TGUI_WINDOW_READY

/datum/tgui_window/proc/acquire_lock()
	log_tgui(client, "[id]/acquire_lock")
	if(!client)
		return null
	locked = TRUE

/datum/tgui_window/proc/release_lock(can_be_suspended = TRUE)
	log_tgui(client, "[id]/release_lock")
	if(!client)
		return null
	locked = FALSE
	if(can_be_suspended && can_be_suspended())
		// TODO: Use an intermediate "RELEASED" state
		// to catch broken windows
		log_tgui(client, "suspending")
		status = TGUI_WINDOW_READY
		send_message("suspend")
	else
		close()

/datum/tgui_window/proc/close()
	log_tgui(client, "[id]/close")
	if(!client)
		return null
	status = TGUI_WINDOW_CLOSED
	message_queue = null
	client << browse(null, "window=[id]")

/datum/tgui_window/proc/send_message(type, list/payload, force)
	var/message = json_encode(list(
		"type" = type,
		"payload" = payload,
	))
	// Strip #255/improper.
	message = replacetext(message, "\proper", "")
	message = replacetext(message, "\improper", "")
	// Pack for sending via output()
	message = url_encode(message)
	// Place into queue if window is still loading
	if(!force && status == TGUI_WINDOW_LOADING)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return null
	client << output(message, "[id].browser:update")

/datum/tgui_window/proc/flush_message_queue()
	if(!client || !message_queue)
		return null
	for(var/message in message_queue)
		client << output(message, "[id].browser:update")
	message_queue = null

/datum/tgui_window/proc/on_message(type, list/payload, list/href_list)
	if(type == "tgui:ready")
		status = TGUI_WINDOW_READY
		var/mob/user = client.mob
		// TODO: Perhaps store the datum that initiated the lock?
		if(locked)
			for(var/datum/tgui/ui in user.tgui_open_uis)
				if(ui.window == src)
					ui.on_message(type, payload)
					flush_message_queue()
					return FALSE
			// Could not find the UI, release the lock
			release_lock()
		return FALSE
	if(type == "tgui:log")
		if(href_list["fatal"])
			broken = TRUE
		return TRUE
	if(type == "tgui:set_prefs")
		if(payload["fancy"])
			client.prefs.tgui_fancy = payload["fancy"]
		return FALSE
	return TRUE
