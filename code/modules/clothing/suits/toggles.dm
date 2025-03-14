//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	actions_types = list(/datum/action/item_action/toggle_hood)
	var/obj/item/clothing/head/hooded/hood
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this
	///Alternative mode for hiding the hood, instead of storing the hood in the suit it qdels it, useful for when you deal with hooded suit with storage.
	var/alternative_mode = FALSE

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	if(!alternative_mode)
		MakeHood()

/obj/item/clothing/suit/hooded/Destroy()
	. = ..()
	qdel(hood)
	hood = null

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/hooded/W = new hoodtype(src)
		W.suit = src
		hood = W

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_OCLOTHING)
		return 1

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(slot != ITEM_SLOT_OCLOTHING)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	src.icon_state = "[initial(icon_state)]"
	suittoggled = FALSE

	if(hood)
		if(ishuman(hood.loc))
			var/mob/living/carbon/human/H = hood.loc
			H.transferItemToLoc(hood, src, TRUE)
			H.update_inv_wear_suit()
		else
			hood.forceMove(src)

		if(alternative_mode)
			QDEL_NULL(hood)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtons()

/obj/item/clothing/suit/hooded/dropped()
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!suittoggled)
		if(!ishuman(loc))
			return
		var/mob/living/carbon/human/H = loc
		if(H.wear_suit != src)
			to_chat(H, span_warning("Стоит надеть [src] сначала, чтобы поднять капюшон!"))
			return
		if(H.head)
			to_chat(H, span_warning("На моей голове уже что-то есть!"))
			return
		else
			if(alternative_mode)
				MakeHood()
			if(!H.equip_to_slot_if_possible(hood,ITEM_SLOT_HEAD,0,0,1))
				if(alternative_mode)
					RemoveHood()
				return
			suittoggled = TRUE
			icon_state = "[initial(icon_state)]_t"
			H.update_inv_wear_suit()
			for(var/X in actions)
				var/datum/action/A = X
				A.UpdateButtons()
	else
		RemoveHood()

/obj/item/clothing/head/hooded
	var/obj/item/clothing/suit/hooded/suit
	dynamic_hair_suffix = ""

/obj/item/clothing/head/hooded/Destroy()
	suit = null
	return ..()

/obj/item/clothing/head/hooded/dropped()
	..()
	if(suit)
		suit.RemoveHood()

/obj/item/clothing/head/hooded/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_HEAD)
		if(suit)
			suit.RemoveHood()
		else
			qdel(src)

//Toggle exosuits for different aesthetic styles (hoodies, suit jacket buttons, etc)

/obj/item/clothing/suit/toggle/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	else
		suit_toggle(user)

/obj/item/clothing/suit/toggle/ui_action_click()
	suit_toggle()

/obj/item/clothing/suit/toggle/proc/suit_toggle()
	set src in usr

	if(!can_use(usr))
		return 0

	to_chat(usr, span_notice("Переключил [src] [togglename]."))
	if(src.suittoggled)
		src.icon_state = "[initial(icon_state)]"
		src.suittoggled = FALSE
	else if(!src.suittoggled)
		src.icon_state = "[initial(icon_state)]_t"
		src.suittoggled = TRUE
	usr.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtons()

/obj/item/clothing/suit/toggle/examine(mob/user)
	. = ..()
	. += "<hr>Alt+ЛКМ по [src] чтобы переключить [togglename]."

//Hardsuit toggle code
/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	MakeHelmet()
	. = ..()

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(!QDELETED(helmet))
		helmet.suit = null
		qdel(helmet)
		helmet = null
	QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(suit)
		suit.helmet = null
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	if(!helmettype)
		return
	if(slot != ITEM_SLOT_OCLOTHING)
		RemoveHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmet)
		return
	suittoggled = FALSE
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.transferItemToLoc(helmet, src, TRUE)
		H.update_inv_wear_suit()
		to_chat(H, span_notice("Шлем отсоединяется от скафандра."))
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	else
		helmet.forceMove(src)

/obj/item/clothing/suit/space/hardsuit/dropped()
	..()
	RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!helmet)
		to_chat(H, span_warning("Лампочка на шлеме похоже повреждена. Ей понадобиться замена."))
		return
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				to_chat(H, span_warning("Должен носить [src] чтобы использовать шлем!"))
				return
			if(H.head)
				to_chat(H, span_warning("На мою голову уже что-то надето!"))
				return
			else if(H.equip_to_slot_if_possible(helmet,ITEM_SLOT_HEAD,0,0,1))
				to_chat(H, span_notice("Активировал шлем скафандра."))
				suittoggled = TRUE
				H.update_inv_wear_suit()
				playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	else
		RemoveHelmet()
