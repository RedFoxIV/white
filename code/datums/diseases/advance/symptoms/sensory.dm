/datum/symptom/mind_restoration
	name = "Восстановление разума"
	desc = "Вирус укрепляет связи между нейронами, сокращая продолжительность любых психических заболеваний."
	stealth = -1
	resistance = -2
	stage_speed = 1
	transmittable = -3
	level = 5
	symptom_delay_min = 5
	symptom_delay_max = 10
	var/purge_alcohol = FALSE
	var/trauma_heal_mild = FALSE
	var/trauma_heal_severe = FALSE
	threshold_descs = list(
		"Сопротивление 6" = "Лечит незначительные травмы головного мозга.",
		"Сопротивление 9" = "Лечит тяжелые травмы головного мозга.",
		"Передача 8" = "Удаляет алкоголь из кровотока.",
	)

/datum/symptom/mind_restoration/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 6) //heal brain damage
		trauma_heal_mild = TRUE
	if(A.properties["resistance"] >= 9) //heal severe traumas
		trauma_heal_severe = TRUE
	if(A.properties["transmittable"] >= 8) //purge alcohol
		purge_alcohol = TRUE

/datum/symptom/mind_restoration/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob


	if(A.stage >= 3)
		M.dizziness = max(0, M.dizziness - 2)
		M.drowsyness = max(0, M.drowsyness - 2)
		M.slurring = max(0, M.slurring - 2)
		M.set_confusion(max(0, M.get_confusion() - 2))
		if(purge_alcohol)
			M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.drunkenness = max(H.drunkenness - 5, 0)

	if(A.stage >= 4)
		M.drowsyness = max(0, M.drowsyness - 2)
		if(M.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
			M.reagents.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
		if(M.reagents.has_reagent(/datum/reagent/toxin/histamine))
			M.reagents.remove_reagent(/datum/reagent/toxin/histamine, 5)
		M.hallucination = max(0, M.hallucination - 10)

	if(A.stage >= 5)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3)
		if(trauma_heal_mild && iscarbon(M))
			var/mob/living/carbon/C = M
			if(prob(10))
				if(trauma_heal_severe)
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_LOBOTOMY)
				else
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)



/datum/symptom/sensory_restoration
	name = "Сенсорное восстановление"
	desc = "Вирус стимулирует производство и замену сенсорных тканей, заставляя хозяина регенерировать глаза и уши при повреждении."
	stealth = 0
	resistance = 1
	stage_speed = -2
	transmittable = 2
	level = 4
	base_message_chance = 7
	symptom_delay_min = 1
	symptom_delay_max = 1

/datum/symptom/sensory_restoration/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/obj/item/organ/ears/ears = M.getorganslot(ORGAN_SLOT_EARS)
			if(ears)
				ears.adjustEarDamage(-4, -4)
			M.adjust_blindness(-2)
			M.adjust_blurriness(-2)
			var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
			if(!eyes) // only dealing with eye stuff from here on out
				return
			eyes.applyOrganDamage(-2)
			if(HAS_TRAIT_FROM(M, TRAIT_BLIND, EYE_DAMAGE))
				if(prob(20))
					to_chat(M, span_warning("Зрение возвращается..."))
					M.cure_blind(EYE_DAMAGE)
					M.cure_nearsighted(EYE_DAMAGE)
					M.blur_eyes(35)
			else if(HAS_TRAIT_FROM(M, TRAIT_NEARSIGHT, EYE_DAMAGE))
				to_chat(M, span_warning("Темнота уходит из периферийного зрения."))
				M.cure_nearsighted(EYE_DAMAGE)
				M.blur_eyes(10)
		else
			if(prob(base_message_chance))
				to_chat(M, span_notice("[pick("Глазам стало лучше.","Глаза теперь могут видеть лучше.", "Можно не моргать.","Ушам стало лучше.","Слышу всё гораздо лучше.")]"))
