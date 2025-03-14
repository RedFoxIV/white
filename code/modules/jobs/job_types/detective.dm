/datum/job/detective
	title = JOB_DETECTIVE
	ru_title = "Детектив"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "начальнику охраны"
	selection_color = "#ffeeee"
	minimal_player_age = 14
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/detective

	skills = list(/datum/skill/ranged = SKILL_EXP_LEGENDARY, /datum/skill/parry = SKILL_EXP_NOVICE)
	minimal_skills = list(/datum/skill/ranged = SKILL_EXP_LEGENDARY, /datum/skill/parry = SKILL_EXP_NOVICE)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DETECTIVE

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 25,
		/obj/item/ammo_box/c38 = 25,
		/obj/item/ammo_box/c38/dumdum = 5,
		/obj/item/ammo_box/c38/hotshot = 5,
		/obj/item/ammo_box/c38/iceblox = 5,
		/obj/item/ammo_box/c38/match = 5,
		/obj/item/ammo_box/c38/trac = 5,
		/obj/item/storage/belt/holster/detective/full = 1
	)

	departments_list = list(
		/datum/job_department/security,
	)

	rpg_title = "Thiefcatcher"
	rpg_title_ru = "Ловец воров"

/datum/outfit/job/detective
	name = JOB_DETECTIVE
	jobtype = /datum/job/detective

	belt = /obj/item/modular_computer/tablet/pda/detective
	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/detective
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/fedora/det_hat
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/lighter
	backpack_contents = list(/obj/item/storage/box/evidence=1,\
		/obj/item/detective_scanner=1,\
		/obj/item/melee/classic_baton=1)
	mask = /obj/item/clothing/mask/cigarette

	implants = list(/obj/item/implant/mindshield)

	chameleon_extras = list(/obj/item/gun/ballistic/revolver/detective, /obj/item/clothing/glasses/sunglasses)

	id_trim = /datum/id_trim/job/detective

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
	if(istype(cig)) //Some species specfic changes can mess this up (plasmamen)
		cig.light("")

	if(visualsOnly)
		return

