/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			var/obj/item/bodypart/bp = def_zone
			if(bp)
				return checkarmor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(check_zone(def_zone))
		if(affecting)
			return checkarmor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		armorval += checkarmor(BP, type)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/checkarmor(obj/item/bodypart/def_zone, d_type)
	if(!d_type)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor.getRating(d_type)
	protection += physiology.armor.getRating(d_type)
	return protection

///Get all the clothing on a specific body part
/mob/living/carbon/human/proc/clothingonpart(obj/item/bodypart/def_zone)
	var/list/covering_part = list()
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				covering_part += C
	return covering_part

/mob/living/carbon/human/on_hit(obj/projectile/P)
	if(dna?.species)
		dna.species.on_hit(P, src)


/mob/living/carbon/human/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	if(dna?.species)
		var/spec_return = dna.species.bullet_act(P, src)
		if(spec_return)
			return spec_return

	//MARTIAL ART STUFF
	if(mind)
		if(mind.martial_art && mind.martial_art.can_use(src)) //Some martial arts users can deflect projectiles!
			var/martial_art_result = mind.martial_art.on_projectile_hit(src, P, def_zone)
			if(!(martial_art_result == BULLET_ACT_HIT))
				return martial_art_result

	if(SEND_SIGNAL(src, COMSIG_HUMAN_CHECK_SHIELDS, src, P) & SHIELD_BLOCK)
		return BULLET_ACT_FORCE_PIERCE

	if(!(P.original == src && P.firer == src)) //can't block or reflect when shooting yourself
		if(P.reflectable & REFLECT_NORMAL)
			if(check_reflect(def_zone)) // Checks if you've passed a reflection% check
				visible_message(span_danger("[capitalize(src.name)] отражает [P.name]!") , \
								span_userdanger("[capitalize(src.name)] отражает [P.name]!"))
				// Find a turf near or on the original location to bounce to
				if(!isturf(loc)) //Open canopy mech (ripley) check. if we're inside something and still got hit
					P.force_hit = TRUE //The thing we're in passed the bullet to us. Pass it back, and tell it to take the damage.
					loc.bullet_act(P, def_zone, piercing_hit)
					return BULLET_ACT_HIT
				if(P.starting)
					var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/turf/curloc = get_turf(src)

					// redirect the projectile
					P.original = locate(new_x, new_y, P.z)
					P.starting = curloc
					P.firer = src
					P.yo = new_y - curloc.y
					P.xo = new_x - curloc.x
					var/new_angle_s = P.Angle + rand(120,240)
					while(new_angle_s > 180)	// Translate to regular projectile degrees
						new_angle_s -= 360
					P.set_angle(new_angle_s)

				return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

		if(check_shields(P, P.damage, "[P.name]", PROJECTILE_ATTACK, P.armour_penetration))
			P.on_hit(src, 100, def_zone, piercing_hit)
			return BULLET_ACT_HIT

	return ..()

///Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance of the object
/mob/living/carbon/human/proc/check_reflect(def_zone)
	if(wear_suit)
		if(wear_suit.IsReflect(def_zone))
			return TRUE
	if(head)
		if(head.IsReflect(def_zone))
			return TRUE
	for(var/obj/item/I in held_items)
		if(I.IsReflect(def_zone))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/check_shields(atom/AM, damage, attack_text = "атака", attack_type = MELEE_ATTACK, armour_penetration = 0)
	var/block_chance_modifier = round(damage / -3)

	for(var/obj/item/I in held_items)
		if(!istype(I, /obj/item/clothing))
			var/final_block_chance = I.block_chance - (clamp((armour_penetration - I.armour_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
			if(I.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
				if(attack_type == MELEE_ATTACK && a_intent == INTENT_HARM)
					spawn(5)
						try_counterattack(AM, I)
				playsound(get_turf(src), pick(I.block_sounds), 100, TRUE)
				return TRUE
	if(wear_suit)
		var/final_block_chance = wear_suit.block_chance - (clamp((armour_penetration-wear_suit.armour_penetration)/2,0,100)) + block_chance_modifier
		if(wear_suit.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(w_uniform)
		var/final_block_chance = w_uniform.block_chance - (clamp((armour_penetration-w_uniform.armour_penetration)/2,0,100)) + block_chance_modifier
		if(w_uniform.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(wear_neck)
		var/final_block_chance = wear_neck.block_chance - (clamp((armour_penetration-wear_neck.armour_penetration)/2,0,100)) + block_chance_modifier
		if(wear_neck.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(head)
		var/final_block_chance = head.block_chance - (clamp((armour_penetration-head.armour_penetration)/2,0,100)) + block_chance_modifier
		if(head.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/try_counterattack(atom/AM, obj/item/I)
	if(next_move > world.time || !AM?.loc || !I || !isliving(AM.loc) || !(I in held_items))
		return
	var/mob/living/L = AM.loc
	if(!L?.stat && mind)
		I.attack(L, src)
		var/mutual_speed = mind.get_skill_modifier(/datum/skill/parry, SKILL_SPEED_MODIFIER)
		mind.adjust_experience(/datum/skill/parry, 50)
		changeNext_move(mutual_speed)
		adjustStaminaLoss(mutual_speed)

/mob/living/carbon/human/proc/check_block()
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && !incapacitated(IGNORE_GRAB))
			playsound(src, 'white/valtos/sounds/block_hand.ogg', 100)
			return TRUE
	return FALSE

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(dna?.species)
		var/spec_return = dna.species.spec_hitby(AM, src)
		if(spec_return)
			return spec_return
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == WEAKREF(src)) //No throwing stuff at yourself to trigger hit reactions
			return ..()
	if(check_shields(AM, throwpower, "[AM.name]", THROWN_PROJECTILE_ATTACK) || (SEND_SIGNAL(src, COMSIG_HUMAN_CHECK_SHIELDS, src, AM) & SHIELD_BLOCK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE

	return ..()

/mob/living/carbon/human/grippedby(mob/living/user, instant = FALSE)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	..()


/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	if(!I || !user)
		return FALSE

	var/obj/item/bodypart/affecting
	if(user == src)
		affecting = get_bodypart(check_zone(user.zone_selected)) //stabbing yourself always hits the right target
	else
		var/zone_hit_chance = 80
		if(body_position == LYING_DOWN) // half as likely to hit a different zone if they're on the ground
			zone_hit_chance += 10
		affecting = get_bodypart(ran_zone(user.zone_selected, zone_hit_chance))
	var/target_area = parse_zone(check_zone(user.zone_selected)) //our intended target

	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)

	SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[I.force]", "[I.type]"))
	SSblackbox.record_feedback("tally", "zone_targeted", 1, target_area)

	// the attacked_by code varies among species
	return dna.species.spec_attacked_by(I, user, affecting, a_intent, src)


/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	var/hulk_verb = pick("ломает","крушит")
	if(check_shields(user, 15, "the [hulk_verb]ing"))
		return
	playsound(loc, user.dna.species.attack_sound, 25, TRUE, -1)
	visible_message(span_danger("<b>[user]</b> [hulk_verb] <b>[src]</b>!") , \
					span_userdanger("<b>[user]</b> [hulk_verb] <b>[src]</b>!") , span_hear("Слышу как что-то сильно бьёт по плоти!") , null, user)
	to_chat(user, span_danger("Мой удар [hulk_verb] <b>[src]</b>!"))
	apply_damage(15, BRUTE, wound_bonus=10)

/mob/living/carbon/human/attack_hand(mob/user, list/modifiers)
	if(..()) //to allow surgery to return properly.
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src, null, modifiers)

/mob/living/carbon/human/attack_paw(mob/living/carbon/human/M, list/modifiers)
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)

	var/martial_result = M.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

	if(M.a_intent == INTENT_HELP)
		..() //shaking
		return FALSE

	if(M.a_intent == INTENT_DISARM) //Always drop item in hand, if no item, get stunned instead.
		var/obj/item/I = get_active_held_item()
		if(I && !(I.item_flags & ABSTRACT) && dropItemToGround(I))
			playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(span_danger("[M] disarmed [src]!") , \
							span_userdanger("[M] disarmed you!") , span_hear("Слышу агрессивную потасовку!") , null, M)
			to_chat(M, span_danger("You disarm [src]!"))
		else if(!M.client || prob(5)) // only natural monkeys get to stun reliably, (they only do it occasionaly)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			if (src.IsKnockdown() && !src.IsParalyzed())
				Paralyze(40)
				log_combat(M, src, "pinned")
				visible_message(span_danger("[M] pins [src] down!") , \
								span_userdanger("[M] pins you down!") , span_hear("You hear shuffling and a muffled groan!") , null, M)
				to_chat(M, span_danger("You pin [src] down!"))
			else
				Knockdown(30)
				log_combat(M, src, "tackled")
				visible_message(span_danger("[M] tackles [src] down!") , \
								span_userdanger("[M] tackles you down!") , span_hear("Слышу агрессивную потасовку сопровождающуюся громким стуком!") , null, M)
				to_chat(M, span_danger("You tackle [src] down!"))

	if(M.limb_destroyer)
		dismembering_strike(M, affecting.body_zone)

	if(try_inject(M, affecting, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(M.dna.species.punchdamagelow, M.dna.species.punchdamagehigh)
			if(!damage)
				return
			if(check_shields(M, damage, "[M.name]"))
				return FALSE
			if(stat != DEAD)
				apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, MELEE))
		return TRUE

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(M, 0, "когти"))
		visible_message(span_danger("[M] пытается дотронуться до [src]!") , \
						span_danger("[M] пытается дотронуться до меня!") , span_hear("Слышу взмах!") , null, M)
		to_chat(M, span_warning("Пытаюсь дотронуться до [src]!"))
		return FALSE
	. = ..()
	if(!.)
		return
	if(M.a_intent == INTENT_HARM)
		if (w_uniform)
			w_uniform.add_fingerprint(M)
		var/damage = prob(90) ? rand(M.melee_damage_lower, M.melee_damage_upper) : 0
		if(!damage)
			playsound(loc, 'sound/weapons/slashmiss.ogg', 50, TRUE, -1)
			visible_message(span_danger("[M] машет когтями в сторону [src]!") , \
							span_userdanger("[M] машет когтями в мою сторону!") , span_hear("Слышу взмах!") , null, M)
			to_chat(M, span_danger("Пытаюсь поцарапать [src]!"))
			return FALSE
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, MELEE,"","",10)

		playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		visible_message(span_danger("[M] разрывает [src]!") , \
						span_userdanger("[M] разрывает меня!") , span_hear("Слышу звук разрывающейся сочной плоти!") , null, M)
		to_chat(M, span_danger("Разрываю [src]!"))
		log_combat(M, src, "attacked")
		if(!dismembering_strike(M, M.zone_selected)) //Dismemberment successful
			return TRUE
		apply_damage(damage, BRUTE, affecting, armor_block)

	if(M.a_intent == INTENT_DISARM) //Always drop item in hand, if no item, get stun instead.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I))
			playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(span_danger("<b>[M]</b> обезоруживает <b>[skloname(src.name, VINITELNI, src.gender)]</b>!") , \
							span_userdanger("<b>[M]</b> обезоруживает меня!") , span_hear("Слышу агрессивную потасовку!") , null, M)
			to_chat(M, span_danger("Обезоруживаю <b>[skloname(src.name, VINITELNI, src.gender)]</b>!"))
		else if (src.IsKnockdown() && !src.IsParalyzed())
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			Paralyze(30)
			log_combat(M, src, "stunned")
			visible_message(span_danger("[M] тяжко прикладывает <b>[skloname(src.name, VINITELNI, src.gender)]</b>! в пол!") , \
							span_userdanger("[M] обездвиживает меня сильным ударом!") , span_hear("Слышу потасовку сопровождаемую тихим хрипом!") , null, M)
			to_chat(M, span_danger("Принуждаю <b>[skloname(src.name, VINITELNI, src.gender)]</b>! полежать!"))
		else
			Knockdown(90)
			log_combat(M, src, "knocked")
			visible_message(span_danger("<b>[M]</b> роняет <b>[skloname(src.name, VINITELNI, src.gender)]</b>!") , \
							span_userdanger("<b>[M]</b> опрокидывает меня!") , span_hear("Слышу агрессивную потасовку сопровождающуюся громким стуком!") , null, M)
			to_chat(M, span_danger("Сбиваю с ног <b>[skloname(src.name, VINITELNI, src.gender)]</b>!"))


/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L)
	. = ..()
	if(!.)
		return //successful larva bite.
	var/damage = rand(L.melee_damage_lower, L.melee_damage_upper)
	if(!damage)
		return
	if(check_shields(L, damage, "[L.name]"))
		return FALSE
	if(stat != DEAD)
		L.amount_grown = min(L.amount_grown + damage, L.max_grown)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.zone_selected))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, MELEE)
		apply_damage(damage, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(!.)
		return
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(check_shields(M, damage, "[M.name]", MELEE_ATTACK, M.armour_penetration))
		return FALSE
	var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(!dam_zone) //Dismemberment successful
		return TRUE
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	var/armor = run_armor_check(affecting, MELEE, armour_penetration = M.armour_penetration)
	var/attack_direction = get_dir(M, src)
	apply_damage(damage, M.melee_damage_type, affecting, armor, wound_bonus = M.wound_bonus, bare_wound_bonus = M.bare_wound_bonus, sharpness = M.sharpness, attack_direction = attack_direction)


/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M)
	. = ..()
	if(!.) // slime attack failed
		return
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(!damage)
		return
	var/wound_mod = -45 // 25^1.4=90, 90-45=45
	if(M.is_adult)
		damage += rand(5, 10)
		wound_mod = -90 // 35^1.4=145, 145-90=55

	if(check_shields(M, damage, "[M.name]"))
		return FALSE

	var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(!dam_zone) //Dismemberment successful
		return TRUE

	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	var/armor_block = run_armor_check(affecting, MELEE)
	apply_damage(damage, BRUTE, affecting, armor_block, wound_bonus=wound_mod)


/mob/living/carbon/human/ex_act(severity, target, origin)
	if(TRAIT_BOMBIMMUNE in dna.species.species_traits)
		return
	..()
	if (!severity || QDELETED(src))
		return
	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = getarmor(null, BOMB)

//200 max knockdown for EXPLODE_HEAVY
//160 max knockdown for EXPLODE_LIGHT

	var/obj/item/organ/ears/ears = getorganslot(ORGAN_SLOT_EARS)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(bomb_armor < EXPLODE_GIB_THRESHOLD) //gibs the mob if their bomb armor is lower than EXPLODE_GIB_THRESHOLD
				for(var/thing in contents)
					switch(severity)
						if(EXPLODE_DEVASTATE)
							SSexplosions.high_mov_atom += thing
						if(EXPLODE_HEAVY)
							SSexplosions.med_mov_atom += thing
						if(EXPLODE_LIGHT)
							SSexplosions.low_mov_atom += thing
				gib()
				return
			else
				brute_loss = 500
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, BOMB)

		if (EXPLODE_HEAVY)
			brute_loss = 60
			burn_loss = 60
			if(bomb_armor)
				brute_loss = 30*(2 - round(bomb_armor*0.01, 0.05))
				burn_loss = brute_loss				//damage gets reduced from 120 to up to 60 combined brute+burn
			damage_clothes(200 - bomb_armor, BRUTE, BOMB)
			if (ears && !HAS_TRAIT_FROM(src, TRAIT_DEAF, CLOTHING_TRAIT))
				ears.adjustEarDamage(30, 120)
			Unconscious(20)							//short amount of time for follow up attacks against elusive enemies like wizards
			playsound_local(get_turf(src), 'sound/weapons/flashbang.ogg', 100, TRUE, 8)
			flash_act(1, TRUE, TRUE, length = 2.5)
			Knockdown(200 - (bomb_armor * 1.6)) 	//between ~4 and ~20 seconds of knockdown depending on bomb armor

		if(EXPLODE_LIGHT)
			brute_loss = 30
			if(bomb_armor)
				brute_loss = 15*(2 - round(bomb_armor*0.01, 0.05))
			damage_clothes(max(50 - bomb_armor, 0), BRUTE, BOMB)
			if (ears && !HAS_TRAIT_FROM(src, TRAIT_DEAF, CLOTHING_TRAIT))
				ears.adjustEarDamage(15,60)
			Knockdown(160 - (bomb_armor * 1.6)) //100 bomb armor will prevent knockdown altogether

	take_overall_damage(brute_loss,burn_loss)

	if(severity >= EXPLODE_HEAVY || !bomb_armor)
		var/max_limb_loss = 0
		var/probability = 0
		switch(severity)
			if(EXPLODE_NONE)
				max_limb_loss = 1
				probability = 20
			if(EXPLODE_LIGHT)
				max_limb_loss = 2
				probability = 30
			if(EXPLODE_HEAVY)
				max_limb_loss = 3
				probability = 40
			if(EXPLODE_DEVASTATE)
				max_limb_loss = 4
				probability = 50
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(probability) && !prob(getarmor(BP, BOMB)) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
				BP.receive_damage(INFINITY, wound_bonus = CANT_WOUND) //Capped by proc
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break

/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message(span_userdanger("Масса атакует меня!"))
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, MELEE))


///Calculates the siemens coeff based on clothing and species, can also restart hearts.
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	//Calculates the siemens coeff based on clothing. Completely ignores the arguments
	if(flags & SHOCK_TESLA) //I hate this entire block. This gets the siemens_coeff for tesla shocks
		if(gloves && gloves.siemens_coefficient <= 0)
			siemens_coeff -= 0.5
		if(wear_suit)
			if(wear_suit.siemens_coefficient == -1)
				siemens_coeff -= 1
			else if(wear_suit.siemens_coefficient <= 0)
				siemens_coeff -= 0.95
		siemens_coeff = max(siemens_coeff, 0)
	else if(!(flags & SHOCK_NOGLOVES)) //This gets the siemens_coeff for all non tesla shocks
		if(gloves)
			siemens_coeff *= gloves.siemens_coefficient
	siemens_coeff *= physiology.siemens_coeff
	siemens_coeff *= dna.species.siemens_coeff
	. = ..()
	//Don't go further if the shock was blocked/too weak.
	if(!.)
		return
	//Note we both check that the user is in cardiac arrest and can actually heartattack
	//If they can't, they're missing their heart and this would runtime
	if(undergoing_cardiac_arrest() && can_heartattack() && !(flags & SHOCK_ILLUSION))
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
			if(heart.Restart() && stat == CONSCIOUS)
				to_chat(src, span_notice("Моё сердце бьётся снова!"))
	electrocution_animation(40)

/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	var/informed = FALSE
	for(var/obj/item/bodypart/L in src.bodyparts)
		if(L.status == BODYPART_ROBOTIC)
			if(!informed)
				to_chat(src, span_userdanger("Ощущаю острую боль в области моей роботизированной конечности."))
				informed = TRUE
			switch(severity)
				if(EXPLODE_DEVASTATE)
					L.receive_damage(0,10)
					Paralyze(200)
				if(EXPLODE_HEAVY)
					L.receive_damage(0,5)
					Paralyze(100)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit) //todo: update this to utilize check_obscured_slots() //and make sure it's check_obscured_slots(TRUE) to stop aciding through visors etc
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume*0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD) //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & UNACIDABLE))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_neck()
				update_inv_head()
			else
				to_chat(src, span_notice("[capitalize(head_clothes.name)] защищает моё лицо от кислоты!"))
		else
			. = get_bodypart(BODY_ZONE_HEAD)
			if(.)
				damaged += .
			if(ears)
				inventory_items_to_kill += ears

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & UNACIDABLE))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("[capitalize(chest_clothes.name)] защищает моё тело от кислоты!"))
		else
			. = get_bodypart(BODY_ZONE_CHEST)
			if(.)
				damaged += .
			if(wear_id)
				inventory_items_to_kill += wear_id
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_ARM || bodyzone_hit == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & UNACIDABLE))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("[capitalize(arm_clothes.name)] защищают мои руки от кислоты!"))
		else
			. = get_bodypart(BODY_ZONE_R_ARM)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_ARM)
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_LEG || bodyzone_hit == BODY_ZONE_R_LEG || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (w_uniform.body_parts_covered & LEGS))))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_suit.body_parts_covered & LEGS))))
			leg_clothes = wear_suit
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & UNACIDABLE))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("[capitalize(leg_clothes.name)] защищают мои ноги от кислоты!"))
		else
			. = get_bodypart(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_LEG)
			if(.)
				damaged += .


	//DAMAGE//
	for(var/obj/item/bodypart/affecting in damaged)
		affecting.receive_damage(acidity, 2*acidity)

		if(affecting.name == BODY_ZONE_HEAD)
			if(prob(min(acidpwr*acid_volume/10, 90))) //Applies disfigurement
				affecting.receive_damage(acidity, 2*acidity)
				emote("agony")
				facial_hairstyle = "Shaved"
				hairstyle = "Bald"
				update_hair()
				ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)

		update_damage_overlays()

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt

		inventory_items_to_kill += held_items

	for(var/obj/item/inventory_item in inventory_items_to_kill)
		inventory_item.acid_act(acidpwr, acid_volume)
	return TRUE

///Overrides the point value that the mob is worth
/mob/living/carbon/human/singularity_act()
	. = 20
	if(mind)
		if((mind.assigned_role == JOB_STATION_ENGINEER) || (mind.assigned_role == JOB_CHIEF_ENGINEER))
			. = 100
		if(mind.assigned_role == JOB_CLOWN)
			. = rand(-1000, 1000)
	..() //Called afterwards because getting the mind after getting gibbed is sketchy

/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(!istype(M))
		return

	if(src == M)
		if(has_status_effect(STATUS_EFFECT_CHOKINGSTRAND))
			to_chat(src, span_notice("Пытаюсь снять прядь дюраткани со своей шеи."))
			if(do_after(src, 3.5 SECONDS, src))
				to_chat(src, span_notice("Успешно снимаю прядь дюраткани со своей шеи."))
				remove_status_effect(STATUS_EFFECT_CHOKINGSTRAND)
			return
		check_self_for_injuries()


	else
		if(wear_suit)
			wear_suit.add_fingerprint(M)
		else if(w_uniform)
			w_uniform.add_fingerprint(M)

		..()


/mob/living/carbon/human/check_self_for_injuries()
	if(getorganslot(ORGAN_SLOT_BRAIN_BIOMONITOR))
		to_chat(src, span_notice("Активирую имплант биомонитора..."))
		healthscan(src, src, advanced = TRUE)
		chemscan(src, src)
	else
		if(stat >= UNCONSCIOUS)
			return
		var/list/combined_msg = list()

		visible_message(span_notice("<b>[src]</b> осматривает себя.") , null)

		var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

		combined_msg += "<div class='examine_block'><span class='info'>Моё состояние примерно такое:</span><hr><table>"

		for(var/obj/item/bodypart/body_part as anything in bodyparts)
			missing -= body_part.body_zone
			if(body_part.is_pseudopart) //don't show injury text for fake bodyparts; ie chainsaw arms or synthetic armblades
				continue
			var/limb_max_damage = body_part.max_damage
			var/status = ""
			var/brutedamage = body_part.brute_dam
			var/burndamage = body_part.burn_dam
			if(hallucination)
				if(prob(30))
					brutedamage += rand(30,40)
				if(prob(30))
					burndamage += rand(30,40)

			if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
				status = "ФИЗИЧЕСКИЙ: [brutedamage]</span>\] И \[<span class='warning'>ОЖОГИ: [burndamage]"
				if(!brutedamage && !burndamage)
					status = "НЕТ УРОНА"

			else
				if(body_part.type in hal_screwydoll)//Are we halucinating?
					brutedamage = (hal_screwydoll[body_part.type] * 0.2)*limb_max_damage

				if(brutedamage > 0)
					status = body_part.light_brute_msg
				if(brutedamage > (limb_max_damage*0.4))
					status = body_part.medium_brute_msg
				if(brutedamage > (limb_max_damage*0.8))
					status = body_part.heavy_brute_msg
				if(brutedamage > 0 && burndamage > 0)
					status += "</span>\] \[<span class='warning'>"

				if(burndamage > (limb_max_damage*0.8))
					status += body_part.heavy_burn_msg
				else if(burndamage > (limb_max_damage*0.2))
					status += body_part.medium_burn_msg
				else if(burndamage > 0)
					status += body_part.light_burn_msg

				if(status == "")
					status = "ЦЕЛАЯ"
			var/no_damage
			if(status == "ЦЕЛАЯ" || status == "НЕТ УРОНА")
				no_damage = TRUE
			var/isdisabled = ""
			if(body_part.bodypart_disabled)
				isdisabled = "\[ПАРАЛИЗОВАНА\]"
				if(no_damage)
					isdisabled += " но"
				else
					isdisabled += " и"
			var/partmsg = "<tr><td><b>[uppertext(body_part.name)]:</b></td><td>[isdisabled] \[<span class='[no_damage ? "info" : "red"]'>[uppertext(status)]</span>\] "

			for(var/thing in body_part.wounds)
				var/datum/wound/W = thing
				switch(W.severity)
					if(WOUND_SEVERITY_TRIVIAL)
						partmsg += "\[<span class='danger'>[uppertext(W.name)]</span>\] "
					if(WOUND_SEVERITY_MODERATE)
						partmsg += "\[<span class='red'>[uppertext(W.name)]</span>\] "
					if(WOUND_SEVERITY_SEVERE, WOUND_SEVERITY_CRITICAL)
						partmsg += "\[<span class='red'><b>[uppertext(W.name)]</b></span>\] "

			if(body_part.get_bleed_rate())
				partmsg += "\[<span class='red'>КРОВОТЕЧЕНИЕ</span>\] "

			for(var/obj/item/I in body_part.embedded_objects)
				if(I.isEmbedHarmless())
					partmsg += "\[<a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(body_part)]' class='info'>[uppertext(I.name)]</a>\]"
				else
					partmsg += "\[<a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(body_part)]' class='red'>[uppertext(I.name)]</a>\]"

			combined_msg += "[partmsg]</td></tr>"

		for(var/t in missing)
			combined_msg += "<tr><td><b>[uppertext(ru_exam_parse_zone(parse_zone(t)))]:</b></td><td>\[<span class='boldannounce'>ОТСУТСТВУЕТ</span>\]</td></tr>"

		combined_msg += "</table>"

		if(getStaminaLoss())
			if(getStaminaLoss() > 30)
				combined_msg += span_info("Совсем нет сил.")
			else
				combined_msg += span_info("Чувствую усталость.")
		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			if(toxloss)
				if(toxloss > 10)
					combined_msg += span_danger("Мне плохо.")
				else if(toxloss > 20)
					combined_msg += span_danger("Меня тошнит.")
				else if(toxloss > 40)
					combined_msg += span_danger("Сейчас блевану!")
			if(oxyloss)
				if(oxyloss > 10)
					combined_msg += span_danger("Ощущаю головкружение.")
				else if(oxyloss > 20)
					combined_msg += span_danger("Всё такое мутное в дали.")
				else if(oxyloss > 30)
					combined_msg += span_danger("Задыхаюсь!")

		if(!HAS_TRAIT(src, TRAIT_NOHUNGER))
			switch(nutrition)
				if(NUTRITION_LEVEL_FULL to INFINITY)
					combined_msg += span_info("Мне вообще не хочется есть!")
				if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
					combined_msg += span_info("Почти наелся!")
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					combined_msg += span_info("Не голоден.")
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					combined_msg += span_info("Надо бы покушать.")
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					combined_msg += span_info("Еда?")
				if(0 to NUTRITION_LEVEL_STARVING)
					combined_msg += span_danger("Умираю от голода!")

		//Compiles then shows the list of damaged organs and broken organs
		var/list/broken = list()
		var/list/damaged = list()
		var/broken_message
		var/damaged_message
		var/broken_plural
		var/damaged_plural
		//Sets organs into their proper list
		for(var/O in internal_organs)
			var/obj/item/organ/organ = O
			if(organ.organ_flags & ORGAN_FAILING)
				if(broken.len)
					broken += ", "
				broken += organ.name
			else if(organ.damage > organ.low_threshold)
				if(damaged.len)
					damaged += ", "
				damaged += organ.name
		//Checks to enforce proper grammar, inserts words as necessary into the list
		if(broken.len)
			if(broken.len > 1)
				broken.Insert(broken.len, "и ")
				broken_plural = TRUE
			else
				var/holder = broken[1]	//our one and only element
				if(holder[length(holder)] == "s")
					broken_plural = TRUE
			//Put the items in that list into a string of text
			for(var/B in broken)
				broken_message += B
			combined_msg += span_warning("<hr>Похоже [broken_message] не [broken_plural ? "работает" : "работают"]!")
		if(damaged.len)
			if(damaged.len > 1)
				damaged.Insert(damaged.len, "и ")
				damaged_plural = TRUE
			else
				var/holder = damaged[1]
				if(holder[length(holder)] == "s")
					damaged_plural = TRUE
			for(var/D in damaged)
				damaged_message += D
			combined_msg += span_info("Похоже [damaged_message] [damaged_plural ? "имеет" : "имеют"] повреждения.")

		if(roundstart_quirks.len)
			combined_msg += span_info("<hr>Имею черты: [get_quirk_string(FALSE, CAT_QUIRK_ALL)].")

		to_chat(src, combined_msg.Join("\n"))

/mob/living/carbon/human/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	var/list/torn_items = list()

	//HEAD//
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			torn_items += head_clothes
		else if(ears)
			torn_items += ears

	//CHEST//
	if(!def_zone || def_zone == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			torn_items += chest_clothes

	//ARMS & HANDS//
	if(!def_zone || def_zone == BODY_ZONE_L_ARM || def_zone == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit
		if(arm_clothes)
			torn_items |= arm_clothes

	//LEGS & FEET//
	if(!def_zone || def_zone == BODY_ZONE_L_LEG || def_zone == BODY_ZONE_R_LEG)
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
			leg_clothes = wear_suit
		if(leg_clothes)
			torn_items |= leg_clothes

	for(var/obj/item/I in torn_items)
		I.take_damage(damage_amount, damage_type, damage_flag, 0)

/**
 * Used by fire code to damage worn items.
 *
 * Arguments:
 * - delta_time
 * - times_fired
 * - stacks: Current amount of firestacks
 *
 */

/mob/living/carbon/human/proc/burn_clothing(delta_time, times_fired, stacks)
	var/list/burning_items = list()
	var/obscured = check_obscured_slots(TRUE)
	//HEAD//

	if(glasses && !(obscured & ITEM_SLOT_EYES))
		burning_items += glasses
	if(wear_mask && !(obscured & ITEM_SLOT_MASK))
		burning_items += wear_mask
	if(wear_neck && !(obscured & ITEM_SLOT_NECK))
		burning_items += wear_neck
	if(ears && !(obscured & ITEM_SLOT_EARS))
		burning_items += ears
	if(head)
		burning_items += head

	//CHEST//
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING))
		burning_items += w_uniform
	if(wear_suit)
		burning_items += wear_suit

	//ARMS & HANDS//
	var/obj/item/clothing/arm_clothes = null
	if(gloves && !(obscured & ITEM_SLOT_GLOVES))
		arm_clothes = gloves
	else if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
		arm_clothes = wear_suit
	else if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
		arm_clothes = w_uniform
	if(arm_clothes)
		burning_items |= arm_clothes

	//LEGS & FEET//
	var/obj/item/clothing/leg_clothes = null
	if(shoes && !(obscured & ITEM_SLOT_FEET))
		leg_clothes = shoes
	else if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
		leg_clothes = wear_suit
	else if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
		leg_clothes = w_uniform
	if(leg_clothes)
		burning_items |= leg_clothes

	for(var/obj/item/burning in burning_items)
		burning.fire_act((stacks * 25 * delta_time)) //damage taken is reduced to 2% of this value by fire_act()

/mob/living/carbon/human/on_fire_stack(delta_time, times_fired, datum/status_effect/fire_handler/fire_stacks/fire_handler)
	SEND_SIGNAL(src, COMSIG_HUMAN_BURNING)
	burn_clothing(delta_time, times_fired, fire_handler.stacks)
	var/no_protection = FALSE
	if(dna && dna.species)
		no_protection = dna.species.handle_fire(src, delta_time, times_fired, no_protection)
	fire_handler.harm_human(delta_time, times_fired, no_protection)
