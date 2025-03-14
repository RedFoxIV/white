#define HEATER_MODE_STANDBY	"standby"
#define HEATER_MODE_HEAT	"heat"
#define HEATER_MODE_COOL	"cool"
#define HEATER_MODE_AUTO "auto"

/obj/machinery/space_heater
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater-off"
	base_icon_state = "sheater"
	name = "обогреватель"
	desc = "Обогреватель/охладитель, сделанный космическими амишами с использованием традиционных космических технологий, гарантированно не подожжет станцию. Гарантия аннулируется при использовании в двигателях."
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 10)
	circuit = /obj/item/circuitboard/machine/space_heater
	/// We don't use area power, we always use the cell
	use_power = NO_POWER_USE
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell
	var/on = FALSE
	var/mode = HEATER_MODE_STANDBY
	var/setMode = HEATER_MODE_AUTO // Anything other than "heat" or "cool" is considered auto.
	var/targetTemperature = T20C
	var/heatingPower = 40000
	var/efficiency = 20000
	var/temperatureTolerance = 1
	var/settableTemperatureMedian = 30 + T0C
	var/settableTemperatureRange = 30

/obj/machinery/space_heater/get_cell()
	return cell

/obj/machinery/space_heater/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	update_icon()

/obj/machinery/space_heater/on_construction()
	qdel(cell)
	cell = null
	panel_open = TRUE
	update_icon()
	return ..()

/obj/machinery/space_heater/on_deconstruction()
	if(cell)
		LAZYADD(component_parts, cell)
		cell = null
	return ..()

/obj/machinery/space_heater/examine(mob/user)
	. = ..()
	. += "<hr>"
	. += "<b>[capitalize(src.name)]</b> [on ? "включен" : "выключен"] и его техническая панель [panel_open ? "открыта" : "закрыта"]."
	if(cell)
		. += "<hr>Заряд: [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "<hr>Внутри нет батарейки."
	if(in_range(user, src) || isobserver(user))
		. += "<hr><span class='notice'>Дисплей: Температурный диапазон <b>[settableTemperatureRange]°C</b>.<br>Сила нагрева <b>[siunit(heatingPower, "W", 1)]</b>.<br>Потребление <b>[(efficiency*-0.0025)+150]%</b>.</span>" //100%, 75%, 50%, 25%

/obj/machinery/space_heater/update_icon_state()
	icon_state = "[base_icon_state]-[on ? mode : "off"]"
	. = ..()
	return

/obj/machinery/space_heater/update_overlays()
	. = ..()

	if(panel_open)
		. += "sheater-open"

/obj/machinery/space_heater/process(delta_time)
	if(!on || !is_operational)
		if (on) // If it's broken, turn it off too
			on = FALSE
		return PROCESS_KILL

	if(cell && cell.charge > 0)
		var/turf/L = loc
		if(!istype(L))
			if(mode != HEATER_MODE_STANDBY)
				mode = HEATER_MODE_STANDBY
				update_icon()
			return

		var/datum/gas_mixture/env = L.return_air()

		var/newMode = HEATER_MODE_STANDBY
		if(setMode != HEATER_MODE_COOL && env.return_temperature() < targetTemperature - temperatureTolerance)
			newMode = HEATER_MODE_HEAT
		else if(setMode != HEATER_MODE_HEAT && env.return_temperature() > targetTemperature + temperatureTolerance)
			newMode = HEATER_MODE_COOL

		if(mode != newMode)
			mode = newMode
			update_icon()

		if(mode == HEATER_MODE_STANDBY)
			return

		var/heat_capacity = env.heat_capacity()
		var/requiredEnergy = abs(env.return_temperature() - targetTemperature) * heat_capacity
		requiredEnergy = min(requiredEnergy, heatingPower * delta_time)

		if(requiredEnergy < 1)
			return

		var/deltaTemperature = requiredEnergy / heat_capacity
		if(mode == HEATER_MODE_COOL)
			deltaTemperature *= -1
		if(deltaTemperature)
			env.set_temperature(env.return_temperature() + deltaTemperature)
			air_update_turf()
		cell.use(requiredEnergy / efficiency)
	else
		on = FALSE
		update_icon()
		return PROCESS_KILL

/obj/machinery/space_heater/RefreshParts()
	. = ..()
	var/laser = 0
	var/cap = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		laser += M.rating
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		cap += M.rating

	heatingPower = laser * 20000

	settableTemperatureRange = cap * 30
	efficiency = (cap + 1) * 10000

	targetTemperature = clamp(targetTemperature,
		max(settableTemperatureMedian - settableTemperatureRange, TCMB),
		settableTemperatureMedian + settableTemperatureRange)

/obj/machinery/space_heater/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_CONTENTS)
		return
	if(cell)
		cell.emp_act(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	else if(istype(I, /obj/item/stock_parts/cell))
		if(panel_open)
			if(cell)
				to_chat(user, span_warning("Внутри уже есть батарейка!"))
				return
			else if(!user.transferItemToLoc(I, src))
				return
			cell = I
			I.add_fingerprint(usr)

			user.visible_message(span_notice("[capitalize(user)] вставляет батарейку в <b>[src.name]</b>.") , span_notice("Вставляю батарейку внутрь <b>[src.name]</b>."))
			SStgui.update_uis(src)
		else
			to_chat(user, span_warning("Техническая панель должна быть открыта для вставки батарейки!"))
			return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		user.visible_message(span_notice("[capitalize(user)] [panel_open ? "открывает" : "закрывает"] техническую панель <b>[src.name]</b>.") , span_notice("[panel_open ? "Открываю" : "Закрываю"] техническую панель <b>[src.name]</b>."))
		update_icon()
	else if(default_deconstruction_crowbar(I))
		return
	else
		return ..()

/obj/machinery/space_heater/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpaceHeater", name)
		ui.open()

/obj/machinery/space_heater/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["mode"] = setMode
	data["hasPowercell"] = !!cell
	data["chemHacked"] = FALSE
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	data["targetTemp"] = round(targetTemperature - T0C, 1)
	data["minTemp"] = max(settableTemperatureMedian - settableTemperatureRange - T0C, TCMB)
	data["maxTemp"] = settableTemperatureMedian + settableTemperatureRange - T0C

	var/turf/L = get_turf(loc)
	var/curTemp
	if(istype(L))
		var/datum/gas_mixture/env = L.return_air()
		curTemp = env.return_temperature()
	else if(isturf(L))
		curTemp = L.return_temperature()
	if(isnull(curTemp))
		data["currentTemp"] = "N/A"
	else
		data["currentTemp"] = round(curTemp - T0C, 1)
	return data

/obj/machinery/space_heater/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			mode = HEATER_MODE_STANDBY
			usr.visible_message(span_notice("[usr] [on ? "включает" : "выключает"] <b>[src.name]</b>.") , span_notice("[on ? "Включаю" : "Выключаю"] <b>[src.name]</b>."))
			update_icon()
			if (on)
				START_PROCESSING(SSmachines, src)
			. = TRUE
		if("mode")
			setMode = params["mode"]
			. = TRUE
		if("target")
			if(!panel_open)
				return
			var/target = params["target"]
			if(text2num(target) != null)
				target= text2num(target) + T0C
				. = TRUE
			if(.)
				targetTemperature = clamp(round(target),
					max(settableTemperatureMedian - settableTemperatureRange, TCMB),
					settableTemperatureMedian + settableTemperatureRange)
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				. = TRUE

///For use with heating reagents in a ghetto way
/obj/machinery/space_heater/improvised_chem_heater
	icon = 'icons/obj/chemical.dmi'
	icon_state = "sheater-off"
	name = "Improvised chem heater"
	desc = "A space heater hacked to reroute heating to a water bath on the top."
	panel_open = TRUE //This is always open - since we've injected wires in the panel
	//We inherit the cell from the heater prior
	cell = null
	///The beaker within the heater
	var/obj/item/reagent_containers/beaker = null
	///How powerful the heating is, upgrades with parts. (ala chem_heater.dm's method, basically the same level of heating, but this is restricted)
	var/chem_heating_power = 1


/obj/machinery/space_heater/improvised_chem_heater/Destroy()
	. = ..()
	QDEL_NULL(beaker)

/obj/machinery/space_heater/improvised_chem_heater/process(delta_time)
	if(!on)
		update_icon()
		return PROCESS_KILL

	if(!is_operational || !cell || cell.charge <= 0)
		on = FALSE
		update_icon()
		return PROCESS_KILL

	if(!beaker)//No beaker to heat
		update_icon()
		return

	if(beaker.reagents.total_volume)
		var/power_mod = 0.1 * chem_heating_power
		switch(setMode)
			if(HEATER_MODE_AUTO)
				power_mod *= 0.5
				beaker.reagents.adjust_thermal_energy((targetTemperature - beaker.reagents.chem_temp) * power_mod * delta_time * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume)
				beaker.reagents.handle_reactions()
			if(HEATER_MODE_HEAT)
				if(targetTemperature < beaker.reagents.chem_temp)
					return
				beaker.reagents.adjust_thermal_energy((targetTemperature - beaker.reagents.chem_temp) * power_mod * delta_time * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume)
			if(HEATER_MODE_COOL)
				if(targetTemperature > beaker.reagents.chem_temp)
					return
				beaker.reagents.adjust_thermal_energy((targetTemperature - beaker.reagents.chem_temp) * power_mod * delta_time * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume)
		var/requiredEnergy = heatingPower * delta_time * (power_mod * 4)
		cell.use(requiredEnergy / efficiency)
		beaker.reagents.handle_reactions()
	update_icon()

/obj/machinery/space_heater/improvised_chem_heater/ui_data()
	. = ..()
	.["chemHacked"] = TRUE
	.["beaker"] = beaker
	.["currentTemp"] = beaker ? (round(beaker.reagents.chem_temp - T0C)) : "N/A"

/obj/machinery/space_heater/improvised_chem_heater/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("ejectBeaker")
			//Eject doesn't turn it off, so you can preheat for beaker swapping
			replace_beaker(usr)
			. = TRUE

///Slightly modified to ignore the open_hatch - it's always open, we hacked it.
/obj/machinery/space_heater/improvised_chem_heater/attackby(obj/item/item, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, item))
		return
	if(default_deconstruction_crowbar(item))
		return
	if(istype(item, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, span_warning("There is already a power cell inside!"))
			return
		else if(!user.transferItemToLoc(item, src))
			return
		cell = item
		item.add_fingerprint(usr)

		user.visible_message(span_notice("\The [user] inserts a power cell into [src].") , span_notice("You insert the power cell into [src]."))
		SStgui.update_uis(src)
	//reagent containers
	if(is_reagent_container(item) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		. = TRUE //no afterattack
		var/obj/item/reagent_containers/container = item
		if(!user.transferItemToLoc(container, src))
			return
		replace_beaker(user, container)
		to_chat(user, span_notice("You add [container] to [src]'s water bath."))
		updateUsrDialog()
		return
	//Dropper tools
	if(beaker)
		if(is_type_in_list(item, list(/obj/item/reagent_containers/dropper, /obj/item/ph_meter, /obj/item/ph_paper, /obj/item/reagent_containers/syringe)))
			item.afterattack(beaker, user, 1)
		return


/obj/machinery/space_heater/improvised_chem_heater/on_deconstruction(disassembled = TRUE)
	. = ..()
	if(disassembled)
		beaker?.forceMove(drop_location())
		beaker = null
	var/static/bonus_junk = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/thermometer = 1
		)
	for(var/item in bonus_junk)
		if(prob(80))
			new item(get_turf(loc))

/obj/machinery/space_heater/improvised_chem_heater/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_icon()
	return TRUE

/obj/machinery/space_heater/improvised_chem_heater/AltClick(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)

/obj/machinery/space_heater/improvised_chem_heater/update_icon_state()
	. = ..()
	if(!on || !beaker || !cell)
		icon_state = "sheater-off"
		return
	if(targetTemperature < beaker.reagents.chem_temp)
		icon_state = "sheater-cool"
		return
	if(targetTemperature > beaker.reagents.chem_temp)
		icon_state = "sheater-heat"
		return
	icon_state = "sheater-off"

/obj/machinery/space_heater/improvised_chem_heater/RefreshParts()
	. = ..()
	var/lasers_rating = 0
	var/capacitors_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		lasers_rating += laser.rating
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		capacitors_rating += capacitor.rating

	heatingPower = lasers_rating * 20000

	settableTemperatureRange = capacitors_rating * 50 //-20 - 80 at base
	efficiency = (capacitors_rating + 1) * 10000

	targetTemperature = clamp(targetTemperature,
		max(settableTemperatureMedian - settableTemperatureRange, TCMB),
		settableTemperatureMedian + settableTemperatureRange)

	chem_heating_power = efficiency/20000 //1-2.5

#undef HEATER_MODE_STANDBY
#undef HEATER_MODE_HEAT
#undef HEATER_MODE_COOL
#undef HEATER_MODE_AUTO
