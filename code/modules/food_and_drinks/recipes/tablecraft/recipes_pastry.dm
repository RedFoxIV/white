
// see code/module/crafting/table.dm

////////////////////////////////////////////////ПОНЧИКИ////////////////////////////////////////////////

/datum/crafting_recipe/food/donut
	time = 15
	name = "Пончик"
	reqs = list(
		/datum/reagent/consumable/sugar = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/plain
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/donut/chaos
	name = "Пончик хаоса"
	reqs = list(
		/datum/reagent/consumable/frostoil = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/chaos

/datum/crafting_recipe/food/donut/meat
	time = 15
	name = "Мясной пончик"
	reqs = list(
		/obj/item/food/meat/rawcutlet = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/meat

/datum/crafting_recipe/food/donut/jelly
	name = "Желейный пончик"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/jelly/plain

/datum/crafting_recipe/food/donut/slimejelly
	name = "Слизневый пончик"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/plain


/datum/crafting_recipe/food/donut/berry
	name = "Ягодный пончик"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/berry

/datum/crafting_recipe/food/donut/trumpet
	name = "Пончик космонавтов"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/plain = 1
	)

	result = /obj/item/food/donut/trumpet

/datum/crafting_recipe/food/donut/apple
	name = "Яблочный пончик"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/apple

/datum/crafting_recipe/food/donut/caramel
	name = "Карамельный пончик"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/caramel

/datum/crafting_recipe/food/donut/choco
	name = "Шоколадный пончик"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/choco

/datum/crafting_recipe/food/donut/blumpkin
	name = "Синетыквенный пончик"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/blumpkin

/datum/crafting_recipe/food/donut/bungo
	name = "Бунго пончик"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/bungo

/datum/crafting_recipe/food/donut/matcha
	name = "Матчавый пончик"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/matcha

/datum/crafting_recipe/food/donut/laugh
	name = "Пончик из душистого горошка"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/laugh

////////////////////////////////////////////////////ПОНЧИКИ С ЖЕЛЕ///////////////////////////////////////////////////////

/datum/crafting_recipe/food/donut/jelly/berry
	name = "Пончик с ягодным желе"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/berry

/datum/crafting_recipe/food/donut/jelly/trumpet
	name = "Желейный пончик космонавта"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

	result = /obj/item/food/donut/jelly/trumpet

/datum/crafting_recipe/food/donut/jelly/apple
	name = "Пончик с яблочным желе"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/apple

/datum/crafting_recipe/food/donut/jelly/caramel
	name = "Карамальный желейный пончик"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/caramel

/datum/crafting_recipe/food/donut/jelly/choco
	name = "Шоколадный желейный пончик"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/choco

/datum/crafting_recipe/food/donut/jelly/blumpkin
	name = "Пончик с синетыквенным желе"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/blumpkin

/datum/crafting_recipe/food/donut/jelly/bungo
	name = "Пончик с желе Бунго"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/bungo

/datum/crafting_recipe/food/donut/jelly/matcha
	name = "Матчавый желейный пончик"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/matcha

/datum/crafting_recipe/food/donut/jelly/laugh
	name = "Пончик с желе из душистого горошка"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/laugh

////////////////////////////////////////////////////СЛАЙМОВЫЕ ПОНЧИКИ///////////////////////////////////////////////////////

/datum/crafting_recipe/food/donut/slimejelly/berry
	name = "Ягодный слаймовый пончик"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/berry

/datum/crafting_recipe/food/donut/slimejelly/trumpet
	name = "Слаймовый пончик космонавта"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

	result = /obj/item/food/donut/jelly/slimejelly/trumpet

/datum/crafting_recipe/food/donut/slimejelly/apple
	name = "Яблочный слаймовый пончик"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/apple

/datum/crafting_recipe/food/donut/slimejelly/caramel
	name = "Карамельный слаймовый пончик"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/caramel

/datum/crafting_recipe/food/donut/slimejelly/choco
	name = "Шоколадный слаймовый пончик"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/choco

/datum/crafting_recipe/food/donut/slimejelly/blumpkin
	name = "Синетыквенный слаймовый пончик"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/blumpkin

/datum/crafting_recipe/food/donut/slimejelly/bungo
	name = "Бунго слаймовый пончик"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/bungo

/datum/crafting_recipe/food/donut/slimejelly/matcha
	name = "Матчавый слаймовый пончик"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/matcha

/datum/crafting_recipe/food/donut/slimejelly/laugh
	name = "Слаймовый пончик с желе из душистого горошка"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/laugh

////////////////////////////////////////////////WAFFLES////////////////////////////////////////////////

/datum/crafting_recipe/food/waffles
	time = 15
	name = "Вафли"
	reqs = list(
		/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/waffles
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/soylenviridians
	name = "Soylent viridians"
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/soylenviridians
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/soylentgreen
	name = "Зеленый сойлент"
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/meat/slab/human = 2
	)
	result = /obj/item/food/soylentgreen
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/rofflewaffles
	name = "Нарк-вафли"
	reqs = list(
		/datum/reagent/drug/mushroomhallucinogen = 5,
		/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/rofflewaffles
	subcategory = CAT_PASTRY

////////////////////////////////////////////////DONKPOCCKETS////////////////////////////////////////////////

/datum/crafting_recipe/food/donkpocket
	time = 15
	name = "Донк-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/meatball = 1
	)
	result = /obj/item/food/donkpocket
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/dankpocket
	time = 15
	name = "Нарк-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/cannabis = 1
	)
	result = /obj/item/food/dankpocket
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/spicy
	time = 15
	name = "Острый-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/chili
	)
	result = /obj/item/food/donkpocket/spicy
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/teriyaki
	time = 15
	name = "Терияки-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/meatball = 1,
		/datum/reagent/consumable/soysauce = 3
	)
	result = /obj/item/food/donkpocket/teriyaki
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/pizza
	time = 15
	name = "Пицца-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/donkpocket/pizza
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/honk
	time = 15
	name = "Хонк-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/banana = 1,
		/datum/reagent/consumable/sugar = 3
	)
	result = /obj/item/food/donkpocket/honk
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/berry
	time = 15
	name = "Ягод-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/donkpocket/berry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/gondola
	time = 15
	name = "Гондола-покет"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/meatball = 1,
		/datum/reagent/tranquility = 5
	)
	result = /obj/item/food/donkpocket/gondola
	subcategory = CAT_PASTRY

////////////////////////////////////////////////MUFFINS////////////////////////////////////////////////

/datum/crafting_recipe/food/muffin
	time = 15
	name = "Маффин"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/muffin
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/berrymuffin
	name = "Ягодный маффин"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/muffin/berry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/booberrymuffin
	name = "Маффин из мрачных ягод"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/ectoplasm = 1
	)
	result = /obj/item/food/muffin/booberry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/chawanmushi
	name = "Тяван-муси"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/boiledegg = 2,
		/obj/item/food/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/food/chawanmushi
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/moffin
	name = "Моффин"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/stack/sheet/cloth = 1,
	)
	result = /obj/item/food/muffin/moffin
	subcategory = CAT_PASTRY

////////////////////////////////////////////OTHER////////////////////////////////////////////

/datum/crafting_recipe/food/hotdog
	name = "Хот-дог"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/sausage = 1
	)
	result = /obj/item/food/hotdog
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/meatbun
	name = "Meat bun"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/cabbage = 1
	)
	result = /obj/item/food/meatbun
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/khachapuri
	name = "Khachapuri"
	reqs = list(
		/datum/reagent/consumable/eggyolk = 5,
		/obj/item/food/cheesewedge = 1,
		/obj/item/food/bread/plain = 1
	)
	result = /obj/item/food/khachapuri
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/sugarcookie
	time = 15
	name = "Sugar cookie"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/cookie/sugar
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/fortunecookie
	time = 15
	name = "Fortune cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/paper = 1
	)
	parts =	list(
		/obj/item/paper = 1
	)
	result = /obj/item/food/fortunecookie
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/poppypretzel
	time = 15
	name = "Poppy pretzel"
	reqs = list(
		/obj/item/seeds/poppy = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/poppypretzel
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/plumphelmetbiscuit
	time = 15
	name = "Plumphelmet biscuit"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/food/plumphelmetbiscuit
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cracker
	time = 15
	name = "Cracker"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/pastrybase = 1,
	)
	result = /obj/item/food/cracker
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/chococornet
	name = "Choco cornet"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chococornet
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oatmealcookie
	name = "Oatmeal cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	result = /obj/item/food/cookie/oatmeal
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/raisincookie
	name = "Raisin cookie"
	reqs = list(
		/obj/item/food/no_raisin = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	result = /obj/item/food/cookie/raisin
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cherrycupcake
	name = "Cherry cupcake"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/cherries = 1
	)
	result = /obj/item/food/cherrycupcake
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/bluecherrycupcake
	name = "Blue cherry cupcake"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/bluecherries = 1
	)
	result = /obj/item/food/cherrycupcake/blue
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/honeybun
	name = "Honey bun"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/food/honeybun
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cannoli
	name = "Cannoli"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/sugar = 3
	)
	result = /obj/item/food/cannoli
	subcategory = CAT_PASTRY
