/datum/round_event_control/spider_infestation
	name = "Spider Infestation"
	typepath = /datum/round_event/spider_infestation
	weight = 10
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE

/datum/round_event/spider_infestation
	announceWhen = 400
	var/spawncount = 2

/datum/round_event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/round_event/spider_infestation/announce(fake)
	priority_announce("Неизвестные признаки жизни обнаружены на борту [station_name()]. Заблокируйте любой внешний доступ, включая воздуховоды и вентиляцию.", "Вторжение на борт", ANNOUNCER_ALIENS)

/datum/round_event/spider_infestation/start()
	create_midwife_eggs(spawncount)

/proc/create_midwife_eggs(amount)
	var/list/spawn_locs = list()
	for(var/x in GLOB.xeno_spawn)
		var/turf/spawn_turf = x
		var/light_amount = spawn_turf.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += spawn_turf
	if(spawn_locs.len < amount)
		message_admins("Not enough valid spawn locations found in GLOB.xeno_spawn, aborting spider spawning...")
		return MAP_ERROR
	while(amount > 0)
		var/obj/effect/mob_spawn/spider/midwife/new_eggs = new /obj/effect/mob_spawn/spider/midwife(pick_n_take(spawn_locs))
		new_eggs.amount_grown = 98
		amount--
	log_game("Midwife spider eggs were spawned via an event.")
	return TRUE

