/*
Slimecrossing Weapons
	Weapons added by the slimecrossing system.
	Collected here for clarity.
*/

//Boneblade - Burning Green
/obj/item/melee/arm_blade/slime
	name = "slimy boneblade"
	desc = "What remains of the bones in your arm. Incredibly sharp, and painful for both you and your opponents."
	force = 15
	force_string = "painful"

/obj/item/melee/arm_blade/slime/attack(mob/living/L, mob/user)
	. = ..()
	if(prob(20))
		user.emote("agony")

//Rainbow knife - Burning Rainbow
/obj/item/kitchen/knife/rainbowknife
	name = "rainbow knife"
	desc = "A strange, transparent knife which constantly shifts color. It hums slightly when moved."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rainbowknife"
	inhand_icon_state = "rainbowknife"
	force = 15
	throwforce = 15
	damtype = BRUTE

/obj/item/kitchen/knife/rainbowknife/afterattack(atom/O, mob/user, proximity)
	random_type_damage(O, proximity)
	return ..()

/obj/item/proc/random_type_damage(atom/O, proximity)
	if(proximity && istype(O, /mob/living))
		damtype = pick(BRUTE, BURN, TOX, OXY, CLONE)
	switch(damtype)
		if(BRUTE)
			hitsound = 'sound/weapons/bladeslice.ogg'
			attack_verb_continuous = string_list(list("режет","рубит","кромсает"))
			attack_verb_simple = string_list(list("режет","рубит","кромсает"))
		if(BURN)
			hitsound = 'sound/weapons/sear.ogg'
			attack_verb_continuous = string_list(list("жгёт","поджигает","даёт прикурить"))
			attack_verb_simple = string_list(list("жгёт","поджигает","даёт прикурить"))
		if(TOX)
			hitsound = 'sound/weapons/pierce.ogg'
			attack_verb_continuous = string_list(list("отравляет","накачивает","токсифицирует"))
			attack_verb_simple = string_list(list("отравляет","накачивает","токсифицирует"))
		if(OXY)
			hitsound = 'sound/effects/space_wind.ogg'
			attack_verb_continuous = string_list(list("душит","ветрит","вакуумирет"))
			attack_verb_simple = string_list(list("душит","ветрит","вакуумирет"))
		if(CLONE)
			hitsound = 'sound/items/geiger/ext1.ogg'
			attack_verb_continuous = string_list(list("радиацинирует","мутирует","чернобылит"))
			attack_verb_simple = string_list(list("радиацинирует","мутирует","чернобылит"))

//Adamantine shield - Chilling Adamantine
/obj/item/shield/adamantineshield
	name = "adamantine shield"
	desc = "A gigantic shield made of solid adamantium."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "adamshield"
	inhand_icon_state = "adamshield"
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 80, ACID = 70)
	slot_flags = ITEM_SLOT_BACK
	block_chance = 75
	force = 0
	throw_range = 1 //How far do you think you're gonna throw a solid crystalline shield...?
	throw_speed = 2
	attack_verb_continuous = list("колотит","лупит","ломает")
	attack_verb_simple = list("колотит","лупит","ломает")
	item_flags = SLOWS_WHILE_IN_HAND

/obj/item/shield/adamantineshield/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_wielded=15)

//Bloodchiller - Chilling Green
/obj/item/gun/magic/bloodchill
	name = "blood chiller"
	desc = "A horrifying weapon made of your own bone and blood vessels. It shoots slowing globules of your own blood. Ech."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "bloodgun"
	inhand_icon_state = "bloodgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	force = 5
	max_charges = 1 //Recharging costs blood.
	recharge_rate = 1
	ammo_type = /obj/item/ammo_casing/magic/bloodchill
	fire_sound = 'sound/effects/attackblob.ogg'

/obj/item/gun/magic/bloodchill/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/gun/magic/bloodchill/process(delta_time)
	charge_timer += delta_time
	if(charge_timer < recharge_rate || charges >= max_charges)
		return FALSE
	charge_timer = 0
	var/mob/living/M = loc
	if(istype(M) && M.blood_volume >= 20)
		charges++
		M.blood_volume -= 20
	if(charges == 1)
		recharge_newshot()
	return TRUE

/obj/item/ammo_casing/magic/bloodchill
	projectile_type = /obj/projectile/magic/bloodchill

/obj/projectile/magic/bloodchill
	name = "blood ball"
	icon_state = "pulse0_bl"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	hitsound = 'sound/effects/splat.ogg'

/obj/projectile/magic/bloodchill/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		target.apply_status_effect(/datum/status_effect/bloodchill)
