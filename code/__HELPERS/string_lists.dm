GLOBAL_LIST_EMPTY(string_lists)

/**
 * Caches lists with non-numeric stringify-able values (text or typepath).
 */
/proc/string_list(list/values)
	var/string_id = values.Join("-")

	. = GLOB.string_lists[string_id]

	if(.)
		return

	return GLOB.string_lists[string_id] = values

///A wrapper for baseturf string lists, to offer support of non list values, and a stack_trace if we have major issues
/proc/baseturfs_string_list(list/values, turf/baseturf_holder)
	if(!islist(values))
		return values //baseturf things
	//	return values
	if(length(values) > 10)
		//stack_trace("The baseturfs list of [baseturf_holder] at [baseturf_holder.x], [baseturf_holder.y], [baseturf_holder.z] is [length(values)], it should never be this long, investigate. I've set baseturfs to a flashing wall as a visual queue")
		return string_list(list(/turf/open/indestructible/baseturfs_ded)) //I want this reported god damn it
	return string_list(values)

/turf/open/indestructible/baseturfs_ded
	name = "обшивка"
	desc = "НЕМНОГО ПОВРЕЖДЕНА ПИЗДЕЦ."
	icon = DEFAULT_FLOORS_ICON
	icon_state = "plating"
	//icon = 'icons/turf/debug.dmi'
	//icon_state = "fucked_baseturfs"
