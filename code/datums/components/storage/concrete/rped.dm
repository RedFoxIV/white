/datum/component/storage/concrete/rped
	collection_mode = COLLECT_EVERYTHING
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	click_gather = TRUE
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 200
	max_items = 100
	display_numerical_stacking = TRUE

/datum/component/storage/concrete/rped/can_be_inserted(obj/item/I, stop_messages, mob/M)
	. = ..()
	if(!I.get_part_rating())
		if (!stop_messages)
			to_chat(M, span_warning("В [parent] можно поместить только детали!"))
		return FALSE

/datum/component/storage/concrete/bluespace/rped
	collection_mode = COLLECT_EVERYTHING
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	click_gather = TRUE
	max_w_class = WEIGHT_CLASS_BULKY  // can fit vending refills
	max_combined_w_class = 800
	max_items = 400
	display_numerical_stacking = TRUE

/datum/component/storage/concrete/bluespace/rped/can_be_inserted(obj/item/I, stop_messages, mob/M)
	. = ..()
	if(!I.get_part_rating())
		if (!stop_messages)
			to_chat(M, span_warning("В [parent] можно поместить только детали!"))
		return FALSE
