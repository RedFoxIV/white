/obj/item/picket_sign
	icon_state = "picket"
	name = "пустой транспарант"
	desc = "он пустой."
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("призывает на митинг", "оппозиционирует", "либерализует")
	attack_verb_simple = list("призывает на митинг", "оппозиционирует", "либерализует")
	resistance_flags = FLAMMABLE

	var/label = ""
	COOLDOWN_DECLARE(picket_sign_cooldown)

/obj/item/picket_sign/cyborg
	name = "металлический нано транспарант"
	desc = "Высокотехнологичный транспарант, используемый роботами, которые могут по желанию перепрограммировать его поверхность. Наверное, будет больно, если им ударить."
	force = 13
	resistance_flags = NONE
	actions_types = list(/datum/action/item_action/nano_picket_sign)

/obj/item/picket_sign/proc/retext(mob/user)
	if(!user.is_literate())
		to_chat(user, span_notice("Карябаю неразборчивые символы [src]!"))
		return
	var/txt = stripped_input(user, "What would you like to write on the sign?", "Sign Label", null , 30)
	if(txt && user.canUseTopic(src, BE_CLOSE))
		label = txt
		name = "[label] знак"
		desc =	"It reads: [label]"

/obj/item/picket_sign/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/toy/crayon))
		retext(user)
	else
		return ..()

/obj/item/picket_sign/attack_self(mob/living/carbon/human/user)
	if(!COOLDOWN_FINISHED(src, picket_sign_cooldown))
		return
	COOLDOWN_START(src, picket_sign_cooldown, 5 SECONDS)
	if(label)
		user.manual_emote("waves around \the \"[label]\" sign.")
	else
		user.manual_emote("waves around a blank sign.")
	var/direction = prob(50) ? -1 : 1
	if(NSCOMPONENT(user.dir)) //So signs are waved horizontally relative to what way the player waving it is facing.
		animate(user, pixel_x = user.pixel_x + (1 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_x = user.pixel_x - (2 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_x = user.pixel_x + (2 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_x = user.pixel_x - (2 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_x = user.pixel_x + (1 * direction), time = 1, easing = SINE_EASING)
	else
		animate(user, pixel_y = user.pixel_y + (1 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_y = user.pixel_y - (2 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_y = user.pixel_y + (2 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_y = user.pixel_y - (2 * direction), time = 1, easing = SINE_EASING)
		animate(pixel_y = user.pixel_y + (1 * direction), time = 1, easing = SINE_EASING)
	user.changeNext_move(CLICK_CD_MELEE)

/datum/action/item_action/nano_picket_sign
	name = "Retext Nano Picket Sign"

/datum/action/item_action/nano_picket_sign/Trigger(trigger_flags)
	if(!istype(target, /obj/item/picket_sign))
		return
	var/obj/item/picket_sign/sign = target
	sign.retext(owner)

/datum/crafting_recipe/picket_sign
	name = "Транспарант для пикетов"
	result = /obj/item/picket_sign
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80
	category = CAT_MISC
