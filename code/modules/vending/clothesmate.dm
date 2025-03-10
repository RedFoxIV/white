//DON'T FORGET TO CHANGE THE REFILL SIZE IF YOU CHANGE THE MACHINE'S CONTENTS!
/obj/machinery/vending/clothing
	name = "ClothesMate" //renamed to make the slogan rhyme
	desc = "Автомат по продаже одежды."
	icon_state = "clothes"
	icon_deny = "clothes-deny"
	product_slogans = "Одевайся на успех!;Готовься выглядеть шикарно!;Посмотри на весь этот хабар! Зачем оставлять стиль на произвол судьбы? Используй ClothesMate!"
	vend_reply = "Спасибо за использование ClothesMate!"
	product_categories = list(
		list(
			"name" = "Голова",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/wig/natural = 4,
				/obj/item/clothing/head/fancy = 4,
				/obj/item/clothing/head/beanie = 8,
				/obj/item/clothing/head/beret/black = 3,
				/obj/item/clothing/mask/bandana = 3,
				/obj/item/clothing/mask/bandana/striped = 3,
				/obj/item/clothing/mask/bandana/skull = 3,
				/obj/item/clothing/neck/scarf = 6,
				/obj/item/clothing/neck/large_scarf = 6,
				/obj/item/clothing/neck/infinity_scarf = 6,
				/obj/item/clothing/neck/tie = 6,
				/obj/item/clothing/head/rasta = 3,
				/obj/item/clothing/head/kippah = 3,
				/obj/item/clothing/head/taqiyahred = 3,
				/obj/item/clothing/head/that = 3,
				/obj/item/clothing/head/fedora = 3,
				/obj/item/clothing/head/bowler = 3,
				/obj/item/clothing/head/cowboy_hat_white = 1,
				/obj/item/clothing/head/cowboy_hat_grey = 1,
				/obj/item/clothing/head/sombrero = 1,
			),
		),

		list(
			"name" = "Причендалы",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/accessory/waistcoat = 4,
				/obj/item/clothing/suit/toggle/suspenders = 4,
				/obj/item/clothing/neck/tie/horrible = 3,
				/obj/item/clothing/glasses/regular = 2,
				/obj/item/clothing/glasses/regular/jamjar = 1,
				/obj/item/clothing/glasses/orange = 1,
				/obj/item/clothing/glasses/red = 1,
				/obj/item/clothing/glasses/monocle = 1,
				/obj/item/clothing/gloves/fingerless = 2,
				/obj/item/storage/belt/fannypack = 3,
				/obj/item/storage/belt/fannypack/blue = 3,
				/obj/item/storage/belt/fannypack/red = 3,
			),
		),

		list(
			"name" = "Одежда",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/pants/slacks = 5,
				/obj/item/clothing/under/shorts = 5,
				/obj/item/clothing/under/pants/jeans = 5,
				/obj/item/clothing/under/jeanshorts = 5,
				/obj/item/clothing/under/costume/buttondown/slacks = 4,
				/obj/item/clothing/under/costume/buttondown/shorts = 4,
				/obj/item/clothing/under/dress/sundress = 2,
				/obj/item/clothing/under/dress/tango = 2,
				/obj/item/clothing/under/dress/skirt/plaid = 4,
				/obj/item/clothing/under/dress/skirt/turtleskirt = 4,
				/obj/item/clothing/under/misc/overalls = 2,
				/obj/item/clothing/under/pants/camo = 2,
				/obj/item/clothing/under/pants/track = 2,
				/obj/item/clothing/under/costume/kilt = 1,
				/obj/item/clothing/under/dress/striped = 1,
				/obj/item/clothing/under/dress/sailor = 1,
				/obj/item/clothing/under/dress/redeveninggown = 1,
				/obj/item/clothing/suit/apron/purple_bartender = 2,
			),
		),

		list(
			"name" = "Костюмы & Платья",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/jacket/sweater = 4,
				/obj/item/clothing/suit/jacket/oversized = 4,
				/obj/item/clothing/suit/jacket/fancy = 4,
				/obj/item/clothing/suit/hooded/wintercoat/custom = 2,
				/obj/item/clothing/under/suit/navy = 1,
				/obj/item/clothing/under/suit/black_really = 1,
				/obj/item/clothing/under/suit/burgundy = 1,
				/obj/item/clothing/under/suit/charcoal = 1,
				/obj/item/clothing/under/suit/white = 1,
				/obj/item/clothing/under/suit/sl = 1,
				/obj/item/clothing/suit/jacket = 2,
				/obj/item/clothing/suit/jacket/puffer/vest = 2,
				/obj/item/clothing/suit/jacket/puffer = 2,
				/obj/item/clothing/suit/jacket/letterman = 2,
				/obj/item/clothing/suit/jacket/letterman_red = 2,
				/obj/item/clothing/suit/poncho = 1,
				/obj/item/clothing/under/dress/skirt = 2,
				/obj/item/clothing/under/suit/white/skirt = 2,
				/obj/item/clothing/under/rank/captain/suit/skirt = 2,
				/obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt = 2,
				/obj/item/clothing/under/rank/civilian/bartender/purple = 2,
				/obj/item/clothing/suit/jacket/miljacket = 1,
			),
		),

		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/sneakers/black = 4,
				/obj/item/clothing/shoes/sandal = 2,
				/obj/item/clothing/shoes/laceup = 2,
				/obj/item/clothing/shoes/winterboots = 2,
				/obj/item/clothing/shoes/cowboy = 2,
				/obj/item/clothing/shoes/cowboy/white = 2,
				/obj/item/clothing/shoes/cowboy/black = 2,
			),
		),

		list(
			"name" = "Специальное",
			"icon" = "star",
			"products" = list(
				/obj/item/clothing/head/football_helmet = 6,
				/obj/item/clothing/under/costume/football_suit = 6,
				/obj/item/clothing/suit/costume/football_armor = 6,
				/obj/item/clothing/suit/mothcoat = 3,
				/obj/item/clothing/suit/mothcoat/winter = 3,
				/obj/item/clothing/head/mothcap = 3,
				/obj/item/clothing/suit/ianshirt = 1,
				/obj/item/clothing/head/irs = 20,
				/obj/item/clothing/head/tmc = 20,
				/obj/item/clothing/head/deckers = 20,
				/obj/item/clothing/head/yuri = 20,
				/obj/item/clothing/head/allies = 20,
				/obj/item/clothing/glasses/osi = 20,
				/obj/item/clothing/glasses/phantom = 20,
				/obj/item/clothing/mask/gas/driscoll = 20,
				/obj/item/clothing/under/costume/yuri = 20,
				/obj/item/clothing/under/costume/dutch = 20,
				/obj/item/clothing/under/costume/osi = 20,
				/obj/item/clothing/under/costume/tmc = 20,
				/obj/item/clothing/suit/costume/deckers = 20,
				/obj/item/clothing/suit/costume/soviet = 20,
				/obj/item/clothing/suit/costume/yuri = 20,
				/obj/item/clothing/suit/costume/tmc = 20,
				/obj/item/clothing/suit/costume/pg = 20,
				/obj/item/clothing/shoes/jackbros = 20,
				/obj/item/clothing/shoes/saints = 20,
			),
		),
	)
	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool = 1,
		/obj/item/clothing/under/syndicate/tacticool/skirt = 1,
		/obj/item/clothing/mask/balaclava = 1,
		/obj/item/clothing/head/ushanka = 1,
		/obj/item/clothing/under/costume/soviet = 1,
		/obj/item/storage/belt/fannypack/black = 2,
		/obj/item/clothing/suit/jacket/letterman_syndie = 1,
		/obj/item/clothing/under/costume/jabroni = 1,
		/obj/item/clothing/suit/vapeshirt = 1,
		/obj/item/clothing/under/costume/geisha = 1,
		/obj/item/clothing/under/rank/centcom/officer/replica = 1,
		/obj/item/clothing/under/rank/centcom/officer_skirt/replica = 1
	)
	premium = list(
		/obj/item/clothing/under/suit/checkered = 1,
		/obj/item/clothing/head/mailman = 1,
		/obj/item/clothing/under/misc/mailman = 1,
		/obj/item/clothing/suit/jacket/leather = 1,
		/obj/item/clothing/suit/jacket/leather/overcoat = 1,
		/obj/item/clothing/under/pants/mustangjeans = 1,
		/obj/item/clothing/neck/necklace/dope = 3,
		/obj/item/clothing/suit/jacket/letterman_nanotrasen = 1,
		/obj/item/instrument/piano_synth/headphones/spacepods = 1
	)
	refill_canister = /obj/item/vending_refill/clothing
	default_price = PAYCHECK_ASSISTANT * 0.7
	extra_price = PAYCHECK_HARD
	payment_department = NO_FREEBIES
	light_mask = "wardrobe-light-mask"
	light_color = LIGHT_COLOR_ELECTRIC_GREEN

/obj/machinery/vending/clothing/canLoadItem(obj/item/I,mob/user)
	return (I.type in products)

/obj/item/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"
