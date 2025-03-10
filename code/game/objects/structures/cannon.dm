/obj/structure/cannon
	name = "cannon"
	desc = "Holemaker Deluxe: A sporty model with a good stop power. Any cannon enthusiast should be expected to start here."
	density = TRUE
	anchored = TRUE
	icon_state = "falconet_patina"
	max_integrity = 300
	var/obj/item/stack/cannonball/loaded_cannonball = null
	var/charge_ignited = FALSE
	var/fire_delay = 15
	var/charge_size = 15
	var/fire_sound = 'sound/weapons/gun/general/cannon.ogg'

/obj/structure/cannon/Initialize(mapload)
	. = ..()
	create_reagents(charge_size)

/obj/structure/cannon/proc/fire()
	for(var/mob/shaken_mob in urange(10, src))
		if(shaken_mob.stat == CONSCIOUS)
			shake_camera(shaken_mob, 3, 1)

		playsound(src, fire_sound, 50, TRUE)
	if(loaded_cannonball)
		var/obj/projectile/fired_projectile = new loaded_cannonball.projectile_type(get_turf(src))
		QDEL_NULL(loaded_cannonball)
		fired_projectile.firer = src
		fired_projectile.fired_from = src
		fired_projectile.fire(dir2angle(dir))
	reagents.remove_all()
	charge_ignited = FALSE

/obj/structure/cannon/attackby(obj/item/W, mob/user, params)
	if(charge_ignited)
		to_chat(user, span_danger("[src] is about to fire!"))
		return
	var/ignition_message = W.ignition_effect(src, user)

	if(istype(W, /obj/item/stack/cannonball))
		if(loaded_cannonball)
			to_chat(user, span_warning("[src] is already loaded!"))
		else
			var/obj/item/stack/cannonball/cannoneers_balls = W
			loaded_cannonball = new cannoneers_balls.type(src, 1)
			loaded_cannonball.copy_evidences(cannoneers_balls)
			to_chat(user, span_notice("You load a [cannoneers_balls.singular_name] into [src]."))
			cannoneers_balls.use(1, transfer = TRUE)
		return

	else if(ignition_message)
		if(!reagents.has_reagent(/datum/reagent/gunpowder,15))
			to_chat(user, span_warning("[src] needs at least 15u of gunpowder to fire!"))
			return
		visible_message(ignition_message)
		log_game("Cannon fired by [key_name(user)] in [AREACOORD(src)]")
		addtimer(CALLBACK(src, .proc/fire), fire_delay)
		charge_ignited = TRUE
		return

	else if(istype(W, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/powder_keg = W
		if(!(powder_keg.reagent_flags & OPENCONTAINER))
			return ..()
		if(istype(powder_keg, /obj/item/reagent_containers/glass/rag))
			return ..()

		if(!powder_keg.reagents.total_volume)
			to_chat(user, span_warning("[powder_keg] is empty!"))
			return
		else if(!powder_keg.reagents.has_reagent(/datum/reagent/gunpowder, charge_size))
			to_chat(user, span_warning("[powder_keg] doesn't have at least 15u of gunpowder to fill [src]!"))
			return
		if(reagents.has_reagent(/datum/reagent/gunpowder, charge_size))
			to_chat(user, span_warning("[src] already contains a full charge of powder! It would be unwise to add more."))
			return
		powder_keg.reagents.trans_id_to(src, /datum/reagent/gunpowder, amount = charge_size)
		to_chat(user, span_notice("You load [src] with a charge of powder from [powder_keg]."))
		return
	if(W.tool_behaviour == TOOL_WRENCH)
		if(default_unfasten_wrench(user, W, time = 2 SECONDS))
			return
	..()

/obj/item/paper/crumpled/muddy/fluff/cannon_instructions
	name = "Mast of Cannon's Past's Cannon Instructions"
	desc = "A quickly written note detailing the basics of firing a cannon. Who wrote this?"
	info = @{"

Ye don't know how to load cannon, and ye call yerself a fearsome pirate? I think ye be more alike a space sailor under the space monarchy's flag! Alas, everyone must learn how to blast holes in enemy ships. And thus:<br>

<br><center><b>HOW YE FIRES A CANNON:</b><br></center>

BE STEP ONE: LOAD THE LEAD BALL O' YE CHOICE!<br>
BE STEP TWO: LOAD 15U PIRATE STANDARD CHARGE O' GUNPOWDER!<br>
BE STEP THREE: LIGHT THE FUSE WITH SOMETHING, AND LET ER' RIP!<br>

<br><center><b>CANNONBALL TYPES:</b><br></center>

REGULAR CANNONBALL: A fine choice for killing landlubbers! Will take off any limb it hits, and most certainly down anyone hit in the chest! If they are not directly hit, they will be at least hurt by the shrapnel!<br>
EXPLOSIVE SHELLBALL: The most elegant in breaching (er killin', if you're good at aimin') tools, ye be packing this shell with many scuppering chemicals! Just make sure to not fire it when ye be close to target!<br>
MALFUNCTION SHOT: A very gentle "cannonball" dart at first glance, but make no mistake: This is their worst nightmare! Enjoy an easy boarding process while all their machines are broken and all their weapons unloaded from an EMP!<br>
THE BIGGEST ONE: A shellball, but much bigger. Ye won't be seein' much of these as they were discontinued for sinkin' the firer's ship as often as it sunk the scallywag's ship. Very big boom! If ye have one, ye have been warned!
	"}

/obj/structure/cannon/trash
	name = "trash cannon"
	desc = "Okay, sure, you could call it a toolbox welded to an opened oxygen tank cabled to a skateboard, but it's a TRASH CANNON to us."
	icon_state = "garbagegun"
	anchored = FALSE
	can_be_unanchored = FALSE
	var/fires_before_deconstruction = 5

/obj/structure/cannon/trash/fire()
	var/explode_chance = 10
	var/used_alt_fuel = reagents.has_reagent(/datum/reagent/fuel, charge_size)
	if(used_alt_fuel)
		explode_chance += 25
	. = ..()
	fires_before_deconstruction--
	if(used_alt_fuel)
		fires_before_deconstruction--
	if(prob(explode_chance))
		visible_message(span_userdanger("[src] explodes!"))
		explosion(src, heavy_impact_range = 1, light_impact_range = 5, flame_range = 5)
		return
	if(fires_before_deconstruction <= 0)
		visible_message(span_warning("[src] falls apart from operation!"))
		qdel(src)

/obj/structure/cannon/trash/Destroy()
	new /obj/item/stack/sheet/iron/five(src.loc)
	new /obj/item/stack/rods(src.loc)
	. = ..()
