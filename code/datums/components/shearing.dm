/**
 * Udder component; for farm animals to generate milk.
 *
 * Used for cows, goats, gutlunches. neat!
 */
/datum/component/wool
	///abstract item for managing reagents (further down in this file)
	var/obj/item/wool/wool
	///optional proc to callback to when the udder is milked
	var/datum/callback/on_shear_callback

//udder_type and reagent_produced_typepath are typepaths, not reference
/datum/component/wool/Initialize(wool_type = /obj/item/wool, on_shear_callback, on_generate_callback, item_produced_typepath = /obj/item/shard)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	wool = new wool_type(null, parent, on_generate_callback, item_produced_typepath)
	src.on_shear_callback = on_shear_callback

/datum/component/wool/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)

/datum/component/wool/UnregisterFromParent()
	QDEL_NULL(wool)
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_PARENT_ATTACKBY))
//alldone above this point
///signal called on parent being examined
/datum/component/wool/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/mob/living/sheared = parent
	if(sheared.stat != CONSCIOUS)
		return //come on now

	var/wool_fullness_percentage = PERCENT(wool.total_growth / wool.maximum_growth) //renamed from udder_filled_percentage, changed udder.reagents.total_volume too
	switch(wool_fullness_percentage)
		if(0 to 15)
			examine_list += span_notice("[parent]'s [wool] is completely sheared.")
		if(16 to 50)
			examine_list += span_notice("[parent]'s [wool] is growing back in patches.")
		if(51 to 99)
			examine_list += span_notice("[parent]'s [wool] is almost regrown and ready to be sheared off.")
		if(100)
			examine_list += span_notice("[parent]'s [wool] is thick and full, and can be sheared if you have a razor.")


///signal called on parent being attacked with an item
/datum/component/wool/proc/on_attackby(datum/source, obj/item/shearing_tool, mob/user)
	SIGNAL_HANDLER

	var/mob/living/sheared = parent
	if(sheared.stat == CONSCIOUS && istype(shearing_tool, /obj/item/razor))
		wool.shear(shearing_tool, user)
		if(on_shear_callback)
			on_shear_callback.Invoke(udder.reagents.total_volume, udder.reagents.maximum_volume)
		return COMPONENT_NO_AFTERATTACK

/**
 * # udder item
 *
 * Abstract item that is held in nullspace and manages reagents. Created by udder component.
 * While perhaps reagents created by udder component COULD be managed in the mob, it would be somewhat finnicky and I actually like the abstract udders.
 */
/obj/item/udder
	name = "udder"
	///typepath of reagent produced by the udder
	var/reagent_produced_typepath = /datum/reagent/consumable/milk
	///how much the udder holds
	var/size = 50
	///mob that has the udder component
	var/mob/living/udder_mob
	///optional proc to callback to when the udder generates milk
	var/datum/callback/on_generate_callback

/obj/item/udder/Initialize(mapload, udder_mob, on_generate_callback, reagent_produced_typepath = /datum/reagent/consumable/milk)
	src.udder_mob = udder_mob
	src.on_generate_callback = on_generate_callback
	create_reagents(size, REAGENT_HOLDER_ALIVE)
	src.reagent_produced_typepath = reagent_produced_typepath
	initial_conditions()
	. = ..()

/obj/item/udder/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	udder_mob = null

/obj/item/udder/process(delta_time)
	if(udder_mob.stat != DEAD)
		generate() //callback is on generate() itself as sometimes generate does not add new reagents, or is not called via process

/**
 * Proc called on creation separate from the reagent datum creation to allow for signalled milk generation instead of processing milk generation
 * also useful for changing initial amounts in reagent holder (cows start with milk, gutlunches start empty)
 */
/obj/item/udder/proc/initial_conditions()
	reagents.add_reagent(reagent_produced_typepath, 20)
	START_PROCESSING(SSobj, src)

/**
 * Proc called every 2 seconds from SSMobs to add whatever reagent the udder is generating.
 */
/obj/item/udder/proc/generate()
	if(prob(5))
		reagents.add_reagent(reagent_produced_typepath, rand(5, 10))
		if(on_generate_callback)
			on_generate_callback.Invoke(reagents.total_volume, reagents.maximum_volume)

/**
 * Proc called from attacking the component parent with the correct item, moves reagents into the glass basically.
 *
 * Arguments:
 * * obj/item/reagent_containers/glass/milk_holder - what we are trying to transfer the reagents to
 * * mob/user - who is trying to do this
 */
/obj/item/udder/proc/milk(obj/item/reagent_containers/glass/milk_holder, mob/user)
	if(milk_holder.reagents.total_volume >= milk_holder.volume)
		to_chat(user, span_warning("[milk_holder] is full."))
		return
	var/transfered = reagents.trans_to(milk_holder, rand(5,10))
	if(transfered)
		user.visible_message(span_notice("[user] milks [src] using \the [milk_holder]."), span_notice("You milk [src] using \the [milk_holder]."))
	else
		to_chat(user, span_warning("The udder is dry. Wait a bit longer..."))
