/mob/living/silicon/ai/proc/get_camera_list()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/C in L)
		var/list/tempnetwork = C.network&src.network
		if (length(tempnetwork))
			T[text("[][]", C.c_tag, (C.can_use() ? null : " (Отключена)"))] = C

	return T

/mob/living/silicon/ai/proc/show_camera_list()
	var/list/cameras = get_camera_list()
	var/camera = tgui_input_list(src, "Выберите камеру наблюдения", "Камеры", cameras)
	if(isnull(camera))
		return
	if(isnull(cameras[camera]))
		return
	switchCamera(cameras[camera])

/datum/trackable
	var/initialized = FALSE
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()

/mob/living/silicon/ai/proc/trackable_mobs(mob/user)
	track.initialized = TRUE
	track.names.Cut()
	track.namecounts.Cut()
	track.humans.Cut()
	track.others.Cut()

	if(!user)
		user = usr

	if(user.stat == DEAD)
		return list()

	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(!L.can_track(user))
			continue

		var/name = L.name
		while(name in track.names)
			track.namecounts[name]++
			name = text("[] ([])", name, track.namecounts[name])
		track.names.Add(name)
		track.namecounts[name] = 1

		if(ishuman(L))
			track.humans[name] = WEAKREF(L)
		else
			track.others[name] = WEAKREF(L)

	var/list/targets = sort_list(track.humans) + sort_list(track.others)

	return targets

/mob/living/silicon/ai/verb/ai_camera_track(target_name in trackable_mobs(src))
	set name = "track"
	set hidden = TRUE //Don't display it on the verb lists. This verb exists purely so you can type "track Oldman Robustin" and follow his ass

	if(!target_name)
		return

	if(!track.initialized)
		trackable_mobs(src)

	var/datum/weakref/target = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])

	if(target)
		ai_actual_track(target.resolve())

/mob/living/silicon/robot/shell/proc/ai_camera_track(target_name) // for the case if we still have tracking panel still open
	var/mob/living/silicon/ai/AI = mainframe

	undeploy()
	AI.ai_camera_track(target_name)

/mob/living/silicon/robot/shell/proc/ai_actual_track(mob/living/target)
	var/mob/living/silicon/ai/AI = mainframe

	undeploy()
	AI.ai_actual_track(target)

/mob/living/silicon/ai/proc/ai_actual_track(mob/living/target)
	if(!istype(target))
		return
	var/mob/living/silicon/ai/U = src

	U.cameraFollow = target
	U.tracking = 1

	if(!target || !target.can_track(src))
		to_chat(U, span_warning("Цель не видна на активных камерах."))
		U.cameraFollow = null
		return

	to_chat(U, span_notice("Теперь следим за [target.get_visible_name()]."))

	INVOKE_ASYNC(src, .proc/do_track, target, U)

/mob/living/silicon/ai/proc/do_track(mob/living/target, mob/living/silicon/ai/U)
	var/cameraticks = 0

	while(U.cameraFollow == target)
		if(U.cameraFollow == null)
			return

		if(!target.can_track(usr))
			U.tracking = TRUE
			if(!cameraticks)
				to_chat(U, span_warning("Цель не видна на активных камерах. Пытаемся найти снова..."))
			cameraticks++
			if(cameraticks > 9)
				U.cameraFollow = null
				to_chat(U, span_warning("Не смогли найти цель, отменяем слежку..."))
				tracking = FALSE
				return
			else
				sleep(10)
				continue

		else
			cameraticks = 0
			U.tracking = FALSE

		if(U.eyeobj)
			U.eyeobj.setLoc(get_turf(target))

		else
			view_core()
			U.cameraFollow = null
			return

		sleep(10)

/proc/near_camera(mob/living/M)
	if (!isturf(M.loc))
		return FALSE
	if(issilicon(M))
		var/mob/living/silicon/S = M
		if((QDELETED(S.builtInCamera) || !S.builtInCamera.can_use()) && !GLOB.cameranet.checkCameraVis(M))
			return FALSE
	else if(!GLOB.cameranet.checkCameraVis(M))
		return FALSE
	return TRUE

/obj/machinery/camera/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!can_use())
		return
	user.switchCamera(src)

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = length(L), i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (sorttext(a.c_tag, b.c_tag) < 0)
				L.Swap(j, j + 1)
	return L
