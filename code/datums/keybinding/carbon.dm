/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB

/datum/keybinding/carbon/can_use(client/user)
	return iscarbon(user.mob)

/datum/keybinding/carbon/toggle_throw_mode
	hotkey_keys = list("R", "Southwest") // END
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_TOGGLETHROWMODE_DOWN

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE


/datum/keybinding/carbon/select_help_intent
	hotkey_keys = list("1")
	name = "select_help_intent"
	full_name = "Select help intent"
	description = ""
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_SELECTHELPINTENT_DOWN

/datum/keybinding/carbon/select_help_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_HELP)
	return TRUE


/datum/keybinding/carbon/select_disarm_intent
	hotkey_keys = list("2")
	name = "select_disarm_intent"
	full_name = "Select disarm intent"
	description = ""
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_SELECTDISARMINTENT_DOWN

/datum/keybinding/carbon/select_disarm_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_DISARM)
	return TRUE


/datum/keybinding/carbon/select_grab_intent
	hotkey_keys = list("3")
	name = "select_grab_intent"
	full_name = "Select grab intent"
	description = ""
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_SELECTGRABINTENT_DOWN

/datum/keybinding/carbon/select_grab_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_GRAB)
	return TRUE


/datum/keybinding/carbon/select_harm_intent
	hotkey_keys = list("4")
	name = "select_harm_intent"
	full_name = "Select harm intent"
	description = ""
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_SELECTHARMINTENT_DOWN

/datum/keybinding/carbon/select_harm_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_HARM)
	return TRUE

/datum/keybinding/carbon/hold_throw_mode
	hotkey_keys = list("Space")
	name = "hold_throw_mode"
	full_name = "Hold throw mode"
	description = "Hold this to turn on throw mode, and release it to turn off throw mode"
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_HOLDTHROWMODE_DOWN

/datum/keybinding/carbon/hold_throw_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/carbon_user = user.mob
	carbon_user.throw_mode_on(THROW_MODE_HOLD)

/datum/keybinding/carbon/hold_throw_mode/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/carbon_user = user.mob
	carbon_user.throw_mode_off(THROW_MODE_HOLD)

/datum/keybinding/carbon/give
	hotkey_keys = list("G")
	name = "Give_Item"
	full_name = "Give item"
	description = "Give the item you're currently holding"
	keybind_signal = COMSIG_KB_CARBON_GIVEITEM_DOWN

/datum/keybinding/carbon/give/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/carbon_user = user.mob
	carbon_user.give()
	return TRUE

/datum/keybinding/carbon/fixeye
	hotkey_keys = list("F")
	name = "fixeye"
	full_name = "Смотреть прямо"
	description = "Зафиксировать взгляд в текущую сторону."
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_FIXEYE_DOWN

/datum/keybinding/carbon/fixeye/down(client/user)
	. = ..()
	var/mob/living/living_user = user.mob
	if(istype(living_user))
		SEND_SIGNAL(living_user, COMSIG_FIXEYE_TOGGLE)
	return TRUE
