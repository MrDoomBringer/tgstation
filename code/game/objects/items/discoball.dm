/obj/item/etherealballdeployer
	name = "Portable Ethereal Disco Ball"
	desc = "Press the button for a deployment of PARTY!"
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "ethereal_head_m"

/obj/item/etherealballdeployer/attack_self(mob/living/carbon/user)
	new /obj/structure/etherealball(user.loc)
	qdel(src)

/obj/structure/etherealball
	name = "Ethereal Disco Ball"
	desc = "The ethics of this discoball are questionable. Be sure to feed it snacks or else it might turn off!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "ethdisco_head"
	anchored = TRUE
	density = TRUE
	var/TurnedOn = FALSE
	var/current_color
	var/TimerID
	var/static/list/wirecutter_colors = list(
		"blue" = "#1861d5",
		"red" = "#951710",
		"pink" = "#d5188d",
		"brown" = "#a05212",
		"green" = "#0e7f1b",
		"cyan" = "#18a2d5",
		"yellow" = "#d58c18"
	)
/obj/structure/etherealball/Initialize()
	. = ..()
	update_icon()

/obj/structure/etherealball/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return //Bish we only play human
	var/mob/living/carbon/human/coolperson = user
	if(!(coolperson.ckey == "qustinnus" || coolperson.ckey == "mrdoombringer"))
		to_chat(user, "Hello buddy, sorry, only cool people can turn the Ethereal Ball 3000 on or off, you can feed it or give it water, though!")
		return
	if(TurnedOn)
		TurnOff()
		to_chat(user, "You turn the disco ball off!")
	else
		TurnOn()
		to_chat(user, "You turn the disco ball on!")

/obj/structure/etherealball/proc/TurnOn()
	TurnedOn = TRUE //Same
	DiscoFever()

/obj/structure/etherealball/proc/TurnOff()
	TurnedOn = FALSE
	set_light(0)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	if(TimerID)
		deltimer(TimerID)

/obj/structure/etherealball/proc/DiscoFever()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	current_color = random_color()
	set_light(4, 3, current_color)
	var/our_color = pick(wirecutter_colors)
	add_atom_colour(wirecutter_colors[our_color], FIXED_COLOUR_PRIORITY)
	update_icon()
	TimerID = addtimer(CALLBACK(src, .proc/DiscoFever), 5, TIMER_STOPPABLE)  //Call ourselves every 0.5 seconds to change colors

/obj/structure/etherealball/update_icon()
	cut_overlays()
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "ethdisco_base")
	var/mutable_appearance/glass_overlay = mutable_appearance(icon, "ethdisco_glass")
	base_overlay.appearance_flags = RESET_COLOR
	glass_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)
	add_overlay(glass_overlay)
