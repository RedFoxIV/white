#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_NO_CIRCUIT 2 //Circuit board removed, can safely weld apart
#define DEFAULT_STEP_TIME 20 /// default time for each step
#define REACTIVATION_DELAY 3 SECONDS // Delay on reactivation, used to prevent dumb crowbar things. Just trust me

/obj/machinery/door/firedoor
	name = "пожарный шлюз"
	desc = "Используй ломик!"
	icon = 'icons/obj/doors/doorfireglass.dmi'
	icon_state = "door_open"
	opacity = FALSE
	density = FALSE
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	heat_proof = TRUE
	glass = TRUE
	sub_door = TRUE
	explosion_block = 1
	safe = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	closingLayer = CLOSED_FIREDOOR_LAYER
	assemblytype = /obj/structure/firelock_frame
	armor = list(MELEE = 10, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, FIRE = 95, ACID = 70)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN

	COOLDOWN_DECLARE(activation_cooldown)

	///Trick to get the glowing overlay visible from a distance
	luminosity = 1
	///X offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_xoffset = 0
	///Y offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_yoffset = 0

	var/boltslocked = TRUE
	///List of areas we handle. See CalculateAffectingAreas()
	var/list/affecting_areas
	///For the few times we affect only the area we're actually in. Set during Init. If we get moved, we don't update, but this is consistant with fire alarms and also kinda funny so call it intentional.
	var/area/my_area
	///List of problem turfs with bad temperature
	var/list/turf/issue_turfs
	///Tracks if the firelock is being held open by a crowbar. If so, we don't close until they walk away
	var/being_held_open = FALSE
	///Should the firelock ignore atmosphere when choosing to stay open/closed?
	var/ignore_alarms = FALSE
	///Type of alarm we're under. See code/defines/firealarm.dm for the list. This var being null means there is no alarm.
	var/alarm_type = null
	///Is this firelock active/closed?
	var/active = FALSE
	///The merger_id and merger_typecache variables are used to make rows of firelocks activate at the same time.
	var/merger_id = "firelocks"
	var/static/list/merger_typecache

	///Overlay object for the warning lights. This and some plane settings allows the lights to glow in the dark.
	var/mutable_appearance/warn_lights

	var/knock_sound = 'sound/effects/glassknock.ogg'
	var/bash_sound = 'sound/effects/glassbash.ogg'


/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	CalculateAffectingAreas()
	my_area = get_area(src)
	if(!merger_typecache)
		merger_typecache = typecacheof(/obj/machinery/door/firedoor)

	if(prob(0.004) && icon == 'icons/obj/doors/doorfireglass.dmi')
		base_icon_state = "sus"
		desc += " Выглядит немного подозрительно..."

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/firedoor/LateInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_MERGER_ADDING, .proc/merger_adding)
	RegisterSignal(src, COMSIG_MERGER_REMOVING, .proc/merger_removing)
	GetMergeGroup(merger_id, merger_typecache)
	register_adjacent_turfs()

	if(alarm_type) // Fucking subtypes fucking mappers fucking hhhhhhhh
		start_activation_process(alarm_type)

/**
 * Sets the offset for the warning lights.
 *
 * Used for special firelocks with light overlays that don't line up to their sprite.
 */
/obj/machinery/door/firedoor/proc/adjust_lights_starting_offset()
	return

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	return ..()

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	. += "<hr>"
	if(!density)
		. += span_notice("<span class='notice'>Он открыт, но может быть закрыт <b>ломиком</b>.\n")
	else if(!welded)
		. += span_notice("<span class='notice'>Он закрыт, но может быть открыт <i>ломиком</i>. Для разбора придётся <b>заварить</b> его намертво.\n")
	else if(boltslocked)
		. += span_notice("Он <i>заварен</i> намертво. Осталось <b>отвинтить</b> от пола.\n")
	else
		. += span_notice("Он <i>отвинчен</i>, но сами винты <b>прикручены</b> к полу.")

/**
 * Calculates what areas we should worry about.
 *
 * This proc builds a list of areas we are in and areas we border
 * and writes it to affecting_areas.
 */
/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	var/list/new_affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	if(compare_list(new_affecting_areas, affecting_areas))
		return //No changes needed

	remove_from_areas()
	affecting_areas = new_affecting_areas
	for(var/area/place in affecting_areas)
		LAZYADD(place.firedoors, src)
	if(active)
		add_as_source()

/obj/machinery/door/firedoor/proc/remove_from_areas()
	remove_as_source()
	for(var/area/place in affecting_areas)
		LAZYREMOVE(place.firedoors, src)

/obj/machinery/door/firedoor/proc/merger_adding(obj/machinery/door/firedoor/us, datum/merger/new_merger)
	SIGNAL_HANDLER
	if(new_merger.id != merger_id)
		return
	RegisterSignal(new_merger, COMSIG_MERGER_REFRESH_COMPLETE, .proc/refresh_shared_turfs)

/obj/machinery/door/firedoor/proc/merger_removing(obj/machinery/door/firedoor/us, datum/merger/old_merger)
	SIGNAL_HANDLER
	if(old_merger.id != merger_id)
		return
	UnregisterSignal(old_merger, COMSIG_MERGER_REFRESH_COMPLETE)

/obj/machinery/door/firedoor/proc/refresh_shared_turfs(datum/source, list/leaving_members, list/joining_members)
	SIGNAL_HANDLER
	var/datum/merger/temp_group = source
	if(temp_group.origin != src)
		return
	var/list/shared_problems = list() // We only want to do this once, this is a nice way of pulling that off
	for(var/obj/machinery/door/firedoor/firelock as anything in temp_group.members)
		firelock.issue_turfs = shared_problems
		for(var/dir in GLOB.cardinals)
			var/turf/checked_turf = get_step(get_turf(firelock), dir)
			if(!checked_turf)
				continue
			if(isclosedturf(checked_turf))
				continue
			process_results(checked_turf)

/obj/machinery/door/firedoor/proc/register_adjacent_turfs()
	if(!loc)
		return

	var/turf/our_turf = get_turf(loc)
	RegisterSignal(our_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS, .proc/process_results)
	for(var/dir in GLOB.cardinals)
		var/turf/checked_turf = get_step(our_turf, dir)

		if(!checked_turf)
			continue
		if(isclosedturf(checked_turf))
			continue
		process_results(checked_turf)
		RegisterSignal(checked_turf, COMSIG_TURF_EXPOSE, .proc/process_results)

/obj/machinery/door/firedoor/proc/unregister_adjacent_turfs(atom/old_loc)
	if(!loc)
		return

	var/turf/our_turf = get_turf(old_loc)
	UnregisterSignal(our_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS)
	for(var/dir in GLOB.cardinals)
		var/turf/checked_turf = get_step(our_turf, dir)

		if(!checked_turf)
			continue

		UnregisterSignal(checked_turf, COMSIG_TURF_EXPOSE)

/obj/machinery/door/firedoor/proc/check_atmos(turf/checked_turf)
	var/datum/gas_mixture/environment = checked_turf.return_air()

	if(environment?.return_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return FIRELOCK_ALARM_TYPE_HOT
	if(environment?.return_temperature() <= BODYTEMP_COLD_DAMAGE_LIMIT)
		return FIRELOCK_ALARM_TYPE_COLD
	return

/obj/machinery/door/firedoor/proc/process_results(turf/location, datum/gas_mixture/environment, exposed_temperature)
	SIGNAL_HANDLER

	for(var/area/place in affecting_areas)
		if(!place.fire_detect) //if any area is set to disable detection
			return

	var/turf/checked_turf = location
	var/result = check_atmos(checked_turf)

	if(checked_turf == get_turf(src))
		return

	if(result && TURF_SHARES(checked_turf))
		issue_turfs |= checked_turf
		if(alarm_type) // If you've already got an alarm, go away
			return
		// Store our alarm type, in case we can't activate for some reason
		alarm_type = result
		if(!ignore_alarms)
			start_activation_process(result)
	else if(length(issue_turfs))
		issue_turfs -= checked_turf
		if(length(issue_turfs) && alarm_type != FIRELOCK_ALARM_TYPE_GENERIC)
			return
		alarm_type = null
		if(!ignore_alarms)
			start_deactivation_process()

/**
 * Begins activation process of us and our neighbors.
 *
 * This proc will call activate() on every fire lock (including us) listed
 * in the merge group datum. Returns without doing anything if we're already active, cause of course
 *
 * Arguments:
 * code should be one of three defined alarm types, or can be not supplied. Will dictate the color of the fire alarm lights, and defults to "firelock_alarm_type_generic"
 */
/obj/machinery/door/firedoor/proc/start_activation_process(code = FIRELOCK_ALARM_TYPE_GENERIC)
	if(active)
		return //We're already active
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/door/firedoor/buddylock as anything in merge_group?.members)
		buddylock.activate(code)
/**
 * Begins deactivation process of us and our neighbors.
 *
 * This proc will call reset() on every fire lock (including us) listed
 * in the merge group datum. sets our alarm type to null, signifying no alarm.
 */
/obj/machinery/door/firedoor/proc/start_deactivation_process()
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/door/firedoor/buddylock as anything in merge_group?.members)
		buddylock.reset()

/**
 * Proc that handles activation of the firelock and all this details
 *
 * Sets active and alarm type to properly represent our state.
 * Also calls set_status() on all fire alarms in all affected areas, tells
 * the area the firelock sits in to report the event (AI, alarm consoles, etc)
 * and finally calls correct_state(), which will handle opening or closing
 * this fire lock.
 */
/obj/machinery/door/firedoor/proc/activate(code = FIRELOCK_ALARM_TYPE_GENERIC)
	SIGNAL_HANDLER
	if(active)
		return //Already active
	if(ignore_alarms && code != FIRELOCK_ALARM_TYPE_GENERIC)
		return
	if(code != FIRELOCK_ALARM_TYPE_GENERIC && !COOLDOWN_FINISHED(src, activation_cooldown)) // Non generic activation, subject to crowbar safety
		// Properly activate once the timeleft's up
		addtimer(CALLBACK(src, .proc/activate, code), COOLDOWN_TIMELEFT(src, activation_cooldown))
		return
	active = TRUE
	alarm_type = code
	add_as_source()
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()

/// Adds this fire door as a source of trouble to all of its areas
/obj/machinery/door/firedoor/proc/add_as_source()
	for(var/area/place in affecting_areas)
		LAZYADD(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks) != 1)
			continue
		//if we're the first to activate in this particular area
		place.set_fire_effect(TRUE) //bathe in red
		if(place == my_area)
			// We'll limit our reporting to just the area we're on. If the issue affects bordering areas, they can report it themselves
			place.alarm_manager.send_alarm(ALARM_FIRE, place)

/**
 * Proc that handles reset steps
 *
 * Clears the alarm state and attempts to open the firelock.
 */
/obj/machinery/door/firedoor/proc/reset()
	SIGNAL_HANDLER
	alarm_type = null
	active = FALSE
	remove_as_source()
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()

/**
 * Open the firedoor without resetting existing alarms
 *
 * * delay - Reconsider if this door should be open or closed after some period
 *
 */
/obj/machinery/door/firedoor/proc/crack_open(delay)
	active = FALSE
	ignore_alarms = TRUE
	if(!length(issue_turfs)) // Generic alarms get out
		alarm_type = null
	remove_as_source()
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()

	/// Please be called 3 seconds after the LAST open, rather then 3 seconds after the first
	addtimer(CALLBACK(src, .proc/release_constraints), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/**
 * Reset our temporary alarm ignoring
 * Consider if we should close ourselves/our neighbors or not
 */
/obj/machinery/door/firedoor/proc/release_constraints()
	ignore_alarms = FALSE
	if(!alarm_type || active) // If we have no alarm type, or are already active, go away
		return
	// Otherwise, reactivate ourselves
	start_activation_process(alarm_type)

/// Removes this firedoor from all areas it's serving as a source of problems for
/obj/machinery/door/firedoor/proc/remove_as_source()
	for(var/area/place in affecting_areas)
		if(!LAZYLEN(place.active_firelocks)) // If it has no active firelocks, do nothing
			continue
		LAZYREMOVE(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks)) // If we were the last firelock still active, clear the area effects
			continue
		place.set_fire_effect(FALSE)
		if(place == my_area)
			place.alarm_manager.clear_alarm(ALARM_FIRE, place)

/obj/machinery/door/firedoor/emag_act(mob/user, obj/item/card/emag/doorjack/digital_crowbar)
	if(obj_flags & EMAGGED)
		return
	if(!isAI(user)) //Skip doorjack-specific code
		if(!user || digital_crowbar.charges < 1)
			return
		digital_crowbar.use_charge(user)
	obj_flags |= EMAGGED
	INVOKE_ASYNC(src, .proc/open)

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating)
		return
	if(ismob(AM))
		var/mob/user = AM
		if(allow_hand_open(user))
			add_fingerprint(user)
			open()
			return TRUE
	if(!density)
		return ..()
	return FALSE

/obj/machinery/door/firedoor/bumpopen(mob/living/user)
	return FALSE //No bumping to open, not even in mechs

/obj/machinery/door/firedoor/power_change()
	. = ..()
	update_icon()

	if(machine_stat & NOPOWER)
		return

	correct_state()

/obj/machinery/door/firedoor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(operating || !density)
		return
	user.changeNext_move(CLICK_CD_MELEE)

	if(!user.a_intent == INTENT_HARM)
		user.visible_message(span_notice("[user] бьётся в [src]."), \
			span_notice("Бьюсь в [src]."))
		playsound(src, knock_sound, 50, TRUE)
	else
		user.visible_message(span_warning("[user] лупит по [src]!"), \
			span_warning("Луплю [src]!"))
		playsound(src, bash_sound, 100, TRUE)

/obj/machinery/door/firedoor/wrench_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	if(operating || !welded)
		return FALSE

	if(boltslocked)
		to_chat(user, span_notice("Есть винты, фиксирующие болты на месте!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	tool.play_tool_sound(src)
	user.visible_message(span_notice("[user] начинает откручивать болты [src]..."), \
		span_notice("Начинаю откручивать болты [src]..."))
	if(!tool.use_tool(src, user, DEFAULT_STEP_TIME))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] откручивает болты [src]."), \
		span_notice("Откручиваю болты [src]."))
	deconstruct(TRUE)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/firedoor/screwdriver_act(mob/living/user, obj/item/tool)
	if(operating || !welded)
		return FALSE
	user.visible_message(span_notice("[user] [boltslocked ? "разблокирует" : "блокирует"] болты [src]."), \
				span_notice("[boltslocked ? "Разблокирую" : "Блокирую"] болты [src]."))
	tool.play_tool_sound(src)
	boltslocked = !boltslocked
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/firedoor/try_to_activate_door(mob/user, access_bypass = FALSE)
	return

/obj/machinery/door/firedoor/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message(span_notice("[user] начинает [welded ? "разваривать" : "заваривать"] [src].") , span_notice("Начинаю оперировать сваркой над [src]."))
	if(W.use_tool(src, user, DEFAULT_STEP_TIME, volume=50))
		welded = !welded
		to_chat(user, span_danger("[user] [welded?"заваривает":"разваривает"] [src].") , span_notice("[welded ? "Завариваю" : "Развариваю"] [src]."))
		log_game("[key_name(user)] [welded ? "welded":"unwelded"] firedoor [src] with [W] at [AREACOORD(src)]")
		update_appearance()
		correct_state()

/// We check for adjacency when using the primary attack.
/obj/machinery/door/firedoor/try_to_crowbar(obj/item/acting_object, mob/user)
	if(welded || operating)
		return

	if(density)
		being_held_open = TRUE
		user.balloon_alert_to_viewers("держит [src] открытым", "держу [src] открытым")
		COOLDOWN_START(src, activation_cooldown, REACTIVATION_DELAY)
		open()
		if(QDELETED(user))
			being_held_open = FALSE
			return
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/handle_held_open_adjacency)
		RegisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION, .proc/handle_held_open_adjacency)
		RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/handle_held_open_adjacency)
		handle_held_open_adjacency(user)
	else
		close()

/// A simple toggle for firedoors between on and off
/obj/machinery/door/firedoor/attackby_secondary(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(welded || operating)
			return

		if(density)
			open()
			if(active)
				addtimer(CALLBACK(src, .proc/correct_state), 2 SECONDS, TIMER_UNIQUE)
		else
			close()
	else
		. = ..()

/obj/machinery/door/firedoor/proc/handle_held_open_adjacency(mob/user)
	SIGNAL_HANDLER

	var/mob/living/living_user = user
	if(!QDELETED(user) && Adjacent(user) && isliving(user) && (living_user.body_position == STANDING_UP))
		return
	being_held_open = FALSE
	correct_state()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(user, COMSIG_PARENT_QDELETING)
	if(user)
		user.balloon_alert_to_viewers("отпускает [src]", "отпускаю [src]")

/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
		if(active)
			addtimer(CALLBACK(src, .proc/correct_state), 2 SECONDS, TIMER_UNIQUE)
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/door/firedoor/attack_alien(mob/user, list/modifiers)
	add_fingerprint(user)
	if(welded)
		to_chat(user, span_warning("[src] не поддаётся!"))
		return
	open()
	if(active)
		addtimer(CALLBACK(src, .proc/correct_state), 2 SECONDS, TIMER_UNIQUE)

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_icon_state]_opening", src)
		if("closing")
			flick("[base_icon_state]_closing", src)

/obj/machinery/door/firedoor/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[density ? "closed" : "open"]"

/obj/machinery/door/firedoor/update_overlays()
	. = ..()
	if(welded)
		. += density ? "welded" : "welded_open"
	if(alarm_type && powered() && !ignore_alarms)
		var/mutable_appearance/hazards
		hazards = mutable_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]")
		hazards.pixel_x = light_xoffset
		hazards.pixel_y = light_yoffset
		. += hazards
		hazards = emissive_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]", alpha = src.alpha)
		hazards.pixel_x = light_xoffset
		hazards.pixel_y = light_yoffset
		. += hazards

/**
 * Corrects the current state of the door, based on its activity.
 *
 * This proc is called after weld and power restore events. Gives the
 * illusion that the door is constantly attempting to move without actually
 * having to process it. Timers also call this, so that if activity
 * changes during the timer, the door doesn't close or open incorrectly.
 */
/obj/machinery/door/firedoor/proc/correct_state()
	if(obj_flags & EMAGGED || being_held_open || QDELETED(src))
		return //Unmotivated, indifferent, we have no real care what state we're in anymore.
	if(active && !density) //We should be closed but we're not
		INVOKE_ASYNC(src, .proc/close)
		return
	if(!active && density) //We should be open but we're not
		INVOKE_ASYNC(src, .proc/open)
		return

/obj/machinery/door/firedoor/open()
	if(welded)
		return
	playsound(src, 'white/valtos/sounds/firelock.ogg', 25)
	var/old_activity = active
	. = ..()
	if(old_activity != active) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/close()
	if(HAS_TRAIT(loc, TRAIT_FIREDOOR_STOP))
		return
	playsound(src, 'white/valtos/sounds/firelock.ogg', 25)
	var/old_activity = active
	. = ..()
	if(old_activity != active) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/proc/emergency_pressure_stop()
	set waitfor = 0
	if(density || operating || welded)
		return
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC
	start_activation_process()
	close()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/targetloc = get_turf(src)
		if(disassembled || prob(40))
			var/obj/structure/firelock_frame/unbuilt_lock = new assemblytype(targetloc)
			if(disassembled)
				unbuilt_lock.constructionStep = CONSTRUCTION_PANEL_OPEN
			else
				unbuilt_lock.constructionStep = CONSTRUCTION_NO_CIRCUIT
				unbuilt_lock.update_integrity(unbuilt_lock.max_integrity * 0.5)
			unbuilt_lock.update_appearance()
		else
			new /obj/item/electronics/firelock (targetloc)
	qdel(src)

/obj/machinery/door/firedoor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	unregister_adjacent_turfs(old_loc)
	register_adjacent_turfs()

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	density = TRUE
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	can_crush = FALSE
	flags_1 = ON_BORDER_1
	CanAtmosPass = ATMOS_PASS_PROC

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	density = TRUE
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC

/obj/machinery/door/firedoor/border_only/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	adjust_lights_starting_offset()

/obj/machinery/door/firedoor/border_only/adjust_lights_starting_offset()
	light_xoffset = 0
	light_yoffset = 0
	switch(dir)
		if(NORTH)
			light_yoffset = 2
		if(SOUTH)
			light_yoffset = -2
		if(EAST)
			light_xoffset = 2
		if(WEST)
			light_xoffset = -2
	update_icon()

/obj/machinery/door/firedoor/border_only/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	adjust_lights_starting_offset()

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!(border_dir == dir)) //Make sure looking at appropriate border
		return TRUE

/obj/machinery/door/firedoor/border_only/CanAStarPass(obj/item/card/id/ID, to_dir)
	return !density || (dir != to_dir)

/obj/machinery/door/firedoor/border_only/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving.movement_type & PHASING)
		return
	if(leaving == src)
		return // Let's not block ourselves.

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/firedoor/border_only/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return TRUE

/obj/machinery/door/firedoor/heavy
	name = "тяжёлый пожарный шлюз"
	icon = 'icons/obj/doors/Doorfire.dmi'
	glass = FALSE
	explosion_block = 2
	assemblytype = /obj/structure/firelock_frame/heavy
	max_integrity = 550

/obj/item/electronics/firelock
	name = "микросхема пожарного шлюза"
	desc = "Печатная плата, используемая в конструкции пожарных шлюзов."
	icon_state = "mainboard"

/obj/structure/firelock_frame
	name = "рама пожарного шлюза"
	desc = "Почти готовый пожарный шлюз."
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "frame1"
	base_icon_state = "frame"
	anchored = FALSE
	density = TRUE
	var/constructionStep = CONSTRUCTION_NO_CIRCUIT
	var/reinforced = 0

/obj/structure/firelock_frame/examine(mob/user)
	. = ..()
	. += "<hr>"
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			. += span_notice("Он <i>откручен</i> от пола. Микросхема может быть изъята <b>ломиком</b>.")
			if(!reinforced)
				. += span_notice("\nОн может быть укреплён пласталью.")
		if(CONSTRUCTION_NO_CIRCUIT)
			. += span_notice("Здесь нет <i>микросхемы</i> внутри. Рама может быть <b>разварена</b> на части.")

/obj/structure/firelock_frame/update_icon_state()
	icon_state = "[base_icon_state][constructionStep]"
	return ..()

/obj/structure/firelock_frame/attackby(obj/item/attacking_object, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(attacking_object.tool_behaviour == TOOL_CROWBAR)
				attacking_object.play_tool_sound(src)
				user.visible_message(span_notice("[user] начинает извлекать микросхему из [src]...") , \
					span_notice("Начинаю извлекать микросхему из [src]..."))
				if(!attacking_object.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				user.visible_message(span_notice("[user] извлекает плату из [src].") , \
					span_notice("Извлекаю плату из [src]."))
				new /obj/item/electronics/firelock(drop_location())
				constructionStep = CONSTRUCTION_NO_CIRCUIT
				update_appearance()
				return
			if(attacking_object.tool_behaviour == TOOL_WRENCH)
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					to_chat(user, span_warning("Здесь уже есть пожарный шлюз."))
					return
				attacking_object.play_tool_sound(src)
				user.visible_message(span_notice("[user] начинает прикручивать [src]...") , \
					span_notice("Начинаю прикручивать [src]..."))
				if(!attacking_object.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					return
				user.visible_message(span_notice("[user] заканчивает пожарный шлюз.") , \
					span_notice("Заканчиваю пожарный шлюз."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(reinforced)
					new /obj/machinery/door/firedoor/heavy(get_turf(src))
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(attacking_object, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/plasteel_sheet = attacking_object
				if(reinforced)
					to_chat(user, span_warning("[capitalize(src.name)] уже укреплён."))
					return
				if(plasteel_sheet.get_amount() < 2)
					to_chat(user, span_warning("Мне потребуется чуть больше пластали для [src]."))
					return
				user.visible_message(span_notice("[user] начинает укреплять [src]...") , \
					span_notice("Начинаю укреплять [src]..."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(do_after(user, DEFAULT_STEP_TIME, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || plasteel_sheet.get_amount() < 2 || !plasteel_sheet)
						return
					user.visible_message(span_notice("[user] укрепляет [src].") , \
						span_notice("Укрепляю [src]."))
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
					plasteel_sheet.use(2)
					reinforced = 1
				return
		if(CONSTRUCTION_NO_CIRCUIT)
			if(istype(attacking_object, /obj/item/electronics/firelock))
				user.visible_message(span_notice("[user] начинает устанавливает [attacking_object] к [src]...") , \
					span_notice("Начинаю вставлять плату в [src]..."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(!do_after(user, DEFAULT_STEP_TIME, target = src))
					return
				if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
					return
				qdel(attacking_object)
				user.visible_message(span_notice("[user] устанавливает плату в [src].") , \
					span_notice("Вставляю плату в [attacking_object]."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				constructionStep = CONSTRUCTION_PANEL_OPEN
				return
			if(attacking_object.tool_behaviour == TOOL_WELDER)
				if(!attacking_object.tool_start_check(user, amount=1))
					return
				user.visible_message(span_notice("[user] начинает разваривать [src]...") , \
					span_notice("Начинаю разваривать [src] на куски..."))
				if(attacking_object.use_tool(src, user, DEFAULT_STEP_TIME, volume=50, amount=1))
					if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
						return
					user.visible_message(span_notice("[user] разваривает на куски [src]!") , \
						span_notice("Развариваю [src] в метал."))
					var/turf/T = get_turf(src)
					new /obj/item/stack/sheet/iron(T, 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(T, 2)
					qdel(src)
				return
			if(istype(attacking_object, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/raspberrypi = attacking_object
				if(!raspberrypi.adapt_circuit(user, DEFAULT_STEP_TIME * 0.5))
					return
				user.visible_message(span_notice("[user] создаёт специальную плату и вставляет в [src].") , \
					span_notice("Адаптирую микросхему и вставляю в пожарный шлюз."))
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_appearance()
				return
	return ..()

/obj/structure/firelock_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 16)
	else if((constructionStep == CONSTRUCTION_NO_CIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/structure/firelock_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message(span_notice("[user] создаёт специальную плату и вставляет в [src].") , \
			span_notice("Адаптирую микросхему и вставляю в пожарный шлюз."))
			constructionStep = CONSTRUCTION_PANEL_OPEN
			update_appearance()
			return TRUE
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("Разбираю [src]."))
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "рама тяжёлого пожарного шлюза"
	reinforced = TRUE

#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_NO_CIRCUIT
#undef REACTIVATION_DELAY

/obj/machinery/door/firedoor/proc/allow_hand_open(mob/user)
	var/area/A = get_area(src)
	if(A && A.fire)
		return FALSE
	return !is_holding_pressure()

/obj/machinery/door/firedoor/border_only/allow_hand_open(mob/user)
	var/area/A = get_area(src)
	if((!A || !A.fire) && !is_holding_pressure())
		return TRUE
	var/turf/T = loc
	var/turf/T2 = get_step(T, dir)
	if(!T || !T2)
		return
	var/status1 = check_door_side(T)
	var/status2 = check_door_side(T2)
	if((status1 == 1 && status2 == -1) || (status1 == -1 && status2 == 1))
		to_chat(user, "<span class='warning'>Доступ запрещён.</span>")
		return FALSE
	return TRUE

/obj/machinery/door/firedoor/border_only/proc/check_door_side(turf/open/start_point)
	var/list/turfs = list()
	turfs[start_point] = 1
	for(var/i = 1; (i <= turfs.len && i <= 11); i++) // check up to 11 turfs.
		var/turf/open/T = turfs[i]
		if(istype(T, /turf/open/space))
			return -1
		for(var/T2 in T.atmos_adjacent_turfs)
			turfs[T2] = 1
	if(turfs.len <= 10)
		return 0 // not big enough to matter
	return start_point.air.return_pressure() < 20 ? -1 : 1
