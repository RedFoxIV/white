#define CARD_FACEDOWN 0
#define CARD_FACEUP 1

/obj/item/toy/singlecard
	name = "card"
	desc = "A playing card used to play card games like poker."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "sc_Ace of Spades_nanotrasen"
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = "card"
	pixel_x = -5
	resistance_flags = FLAMMABLE
	max_integrity = 50
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	attack_verb_continuous = list("attacks")
	attack_verb_simple = list("attack")
	/// Artistic style of the deck
	var/deckstyle = "nanotrasen"
	/// If the cards in the deck have different icon states (blank and CAS decks do not)
	var/has_unique_card_icons = TRUE
	/// The name of the card
	var/cardname = "Ace of Spades"
	/// Is the card flipped facedown (FALSE) or flipped faceup (TRUE)
	var/flipped = FALSE
	/// The card is blank and can be written on with a pen.
	var/blank = FALSE
	/// The color used to mark a card for cheating (by pens or crayons)
	var/marked_color

/obj/item/toy/singlecard/Initialize(mapload, cardname, obj/item/toy/cards/deck/parent_deck)
	. = ..()
	src.cardname = cardname || src.cardname
	if(istype(parent_deck))
		deckstyle = parent_deck.deckstyle
		has_unique_card_icons = parent_deck.has_unique_card_icons
		icon_state = "singlecard_down_[parent_deck.deckstyle]"
		hitsound = parent_deck.hitsound
		force = parent_deck.force
		throwforce = parent_deck.throwforce
		throw_speed = parent_deck.throw_speed
		throw_range = parent_deck.throw_range
		attack_verb_continuous = parent_deck.attack_verb_continuous
		attack_verb_simple = parent_deck.attack_verb_simple

		if(parent_deck.holodeck)
			flags_1 |= HOLOGRAM_1
			parent_deck.holodeck.spawned += src

	register_context()


/obj/item/toy/singlecard/examine(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return

	if(user.is_holding(src))
		user.visible_message(span_notice("[user] проверяет свою карту."), span_notice("Карта: [cardname]."))
		if(blank)
			. += span_notice("Карта пустая. Надо её заполнить.")
	else if(HAS_TRAIT(user, TRAIT_XRAY_VISION))
		. += span_notice("Сканирую карту своим рентгеновским зрением: [cardname].")
	else
		. += span_warning("Надо бы держать карту в руке!")

	var/marked_color = getMarkedColor(user)
	if(marked_color)
		. += span_notice("Карта имеет [marked_color] пометку с краю!")

/obj/item/toy/singlecard/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item) || src == held_item)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Повернуть по часовой" // add a ALT_RMB screentip to rotate clockwise
		context[SCREENTIP_CONTEXT_RMB] = "Перевернуть"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/dealer_deck = held_item
		if(dealer_deck.wielded)
			context[SCREENTIP_CONTEXT_LMB] = "Разыграть"
			context[SCREENTIP_CONTEXT_RMB] = "Разыграть перевернув"
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Убрать"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/singlecard))
		context[SCREENTIP_CONTEXT_LMB] = "Комбинировать"
		context[SCREENTIP_CONTEXT_RMB] = "Комбинировать перевернув"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/cards/cardhand))
		context[SCREENTIP_CONTEXT_LMB] = "Комбинировать"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/crayon) || istype(held_item, /obj/item/pen))
		context[SCREENTIP_CONTEXT_LMB] = blank ? "Написать на карте" : "Пометить карту"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/toy/singlecard/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] an unlucky card!"))
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	return BRUTELOSS

/**
 * Flips the card over
 *
 * * Arguments:
 * * orientation (optional) - Sets flipped state to CARD_FACEDOWN or CARD_FACEUP if given orientation (otherwise just invert the flipped state)
 */
/obj/item/toy/singlecard/proc/Flip(orientation)
	if(!isnull(orientation))
		flipped = orientation
	else
		flipped = !flipped

	name = flipped ? cardname : "карта"
	update_appearance()

/**
 * Returns a color if a card is marked and the user can see it
 *
 * * Arguments:
 * * user - We need to check if the user see the marked card
 */
/obj/item/toy/singlecard/proc/getMarkedColor(mob/living/carbon/user)
	if(!istype(user))
		return
	var/is_marked_with_visible_color = (marked_color && marked_color != "невидимую")
	if(is_marked_with_visible_color || (marked_color == "невидимую" && user.can_see_reagents()))
		return marked_color

/obj/item/toy/singlecard/update_icon_state()
	if(!flipped)
		icon_state = "singlecard_down_[deckstyle]"
	else if(has_unique_card_icons) // each card in a deck has a different icon
		icon_state = "sc_[cardname]_[deckstyle]"
	else // all cards are the same icon state (blank or scribble)
		icon_state = blank ? "sc_blank_[deckstyle]" : "sc_scribble_[deckstyle]"
	return ..()

/obj/item/toy/singlecard/update_name()
	name = flipped ? cardname : "card"
	return ..()

/obj/item/toy/singlecard/attackby(obj/item/item, mob/living/user, params, flip_card=FALSE)
	var/obj/item/toy/singlecard/card

	if(istype(item, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/dealer_deck = item
		if(!dealer_deck.wielded) // recycle card into deck (if unwielded)
			dealer_deck.insert(src)
			user.balloon_alert_to_viewers("кладёт карту в колоду")
			return
		card = dealer_deck.draw(user)

	if(istype(item, /obj/item/toy/singlecard))
		card = item

	if(card) // card + card = combine into cardhand
		if(flip_card)
			card.Flip()

		if(istype(item, /obj/item/toy/cards/deck))
			// only decks cause a balloon alert
			user.balloon_alert_to_viewers("разыгрывает карту")

		var/obj/item/toy/cards/cardhand/new_cardhand = new (drop_location(), list(src, card))
		new_cardhand.pixel_x = pixel_x
		new_cardhand.pixel_y = pixel_y

		if(!isturf(loc)) // make a cardhand in our active hand
			user.temporarilyRemoveItemFromInventory(src, TRUE)
			new_cardhand.pickup(user)
			user.put_in_active_hand(new_cardhand)
		return

	if(istype(item, /obj/item/toy/cards/cardhand)) // insert into cardhand
		var/obj/item/toy/cards/cardhand/target_cardhand = item
		target_cardhand.insert(src)
		return

	var/can_item_write
	var/marked_cheating_color

	if(istype(item, /obj/item/pen))
		var/obj/item/pen/pen = item
		can_item_write = TRUE
		marked_cheating_color = (pen.colour == "белую" && "невидимую") || pen.colour

	if(istype(item, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = item
		can_item_write = TRUE
		marked_cheating_color = (crayon.crayon_color == "мимскую" && "невидимую") || crayon.crayon_color

	if(can_item_write && !blank) // You cheated not only the game, but yourself
		marked_color = marked_cheating_color
		to_chat(user, span_notice("Устанавливаю [marked_color] пометку на краю [src] используя [item]. Победим!"))
		return

	if(can_item_write)
		if(!user.is_literate())
			to_chat(user, span_notice("Чет рисую на [src]!"))
			return

		var/cardtext = stripped_input(user, "Что же мы напишем на карте?", "Картопис", "", 50)
		if(!cardtext || !user.canUseTopic(src, BE_CLOSE))
			return

		cardname = cardtext
		blank = FALSE
		update_appearance()
		return
	return ..()

/obj/item/toy/singlecard/attackby_secondary(obj/item/item, mob/living/user, modifiers)
	attackby(item, user, modifiers, flip_card=TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/toy/singlecard/attack_hand_secondary(mob/living/carbon/human/user, modifiers)
	attack_self(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/toy/singlecard/attack_self_secondary(mob/living/carbon/human/user, modifiers)
	attack_self(user)

/obj/item/toy/singlecard/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, !iscyborg(user)))
		return

	Flip()
	if(isturf(src.loc)) // only display tihs message when flipping in a visible spot like on a table
		user.balloon_alert_to_viewers("переворачивает карту")

/obj/item/toy/singlecard/AltClick(mob/living/carbon/human/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, !iscyborg(user)))
		transform = turn(transform, 90)
		// use the simple_rotation component to make this turn with Alt+RMB & Alt+LMB at some point in the future - TimT
	return ..()
