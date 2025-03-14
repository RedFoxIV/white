///spaghetti prototype used by all subtypes
/obj/item/food/spaghetti
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	microwaved_type = /obj/item/food/spaghetti/boiledspaghetti
	tastes = list("паста" = 1)
	foodtypes = GRAIN
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/spaghetti/Initialize(mapload)
	. = ..()
	if(!microwaved_type) // This isn't cooked, why would you put uncooked spaghetti in your pocket?
		var/list/display_message = list(
			span_notice("Something wet falls out of their pocket and hits the ground. Is that... [name]?") ,
			span_warning("Oh shit! All your pocket [name] fell out!"))
		AddComponent(/datum/component/spill, display_message, 'sound/effects/splat.ogg')

/obj/item/food/spaghetti/raw
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"
	microwaved_type = /obj/item/food/spaghetti/boiledspaghetti
	tastes = list("pasta" = 1)

/obj/item/food/spaghetti/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this needs more ingredients."
	icon_state = "spaghettiboiled"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/food/spaghetti/boiledspaghetti/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_SCATTER, max_ingredients = 6)

/obj/item/food/spaghetti/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	microwaved_type = null
	tastes = list("паста" = 1, "томаты" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/spaghetti/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	trash_type = /obj/item/trash/plate
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/tomatojuice = 20, /datum/reagent/consumable/nutriment/vitamin = 8)
	microwaved_type = null
	tastes = list("паста" = 1, "томаты" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/spaghetti/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon_state = "meatballspaghetti"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 2)
	microwaved_type = null
	tastes = list("паста" = 1, "мясо" = 1)
	foodtypes = GRAIN | MEAT

/obj/item/food/spaghetti/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 20, /datum/reagent/consumable/nutriment/vitamin = 3)
	microwaved_type = null
	tastes = list("паста" = 1, "мясо" = 1)

/obj/item/food/spaghetti/chowmein
	name = "chow mein"
	desc = "A nice mix of noodles and fried vegetables."
	icon_state = "chowmein"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	microwaved_type = null
	tastes = list("лапша" = 1, "томаты" = 1)

/obj/item/food/spaghetti/beefnoodle
	name = "beef noodle"
	desc = "Nutritious, beefy and noodly."
	icon_state = "beefnoodle"
	trash_type = /obj/item/reagent_containers/glass/bowl
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/liquidgibs = 3)
	microwaved_type = null
	tastes = list("лапша" = 1, "мясо" = 1)
	foodtypes = GRAIN | MEAT

/obj/item/food/spaghetti/butternoodles
	name = "butter noodles"
	desc = "Noodles covered in savory butter. Simple and slippery, but delicious."
	icon_state = "butternoodles"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 2)
	microwaved_type = null
	tastes = list("лапша" = 1, "масло" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/spaghetti/mac_n_cheese
	name = "mac n' cheese"
	desc = "Made the proper way with only the finest cheese and breadcrumbs. And yet, it can't scratch the same itch as Ready-Donk."
	icon_state = "mac_n_cheese"
	food_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cheese" = 1, "breadcrumbs" = 1, "pasta" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/spaghetti/lasagna
	name = "Lasagna"
	desc = "A slice of lasagna. Perfect for a Monday afternoon."
	icon_state = "lasagna"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/tomatojuice = 10)
	tastes = list("мясо" = 3, "pasta" = 3, "tomato" = 2, "cheese" = 2)
	foodtypes = MEAT | DAIRY | GRAIN
