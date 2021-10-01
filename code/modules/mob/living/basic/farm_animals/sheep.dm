/mob/living/basic/sheep
	name = "sheep"
	desc = "A large, passive herbivorous mammal known for its soft wool."
	icon = 'icons/mob/sheep.dmi'
	icon_state = "sheep_white"
	icon_living = "sheep_white"
	icon_dead = "sheep_white_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = "baas"
	speed = 1.1
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 40
	maxHealth = 40
	var/body_color
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/cow

/mob/living/basic/sheep/Initialize()
	AddElement(/datum/element/pet_bonus, "baas happily!")
	. = ..()

	//if(body_color == black)
		//src.recolor
	//if(prob(20) & body_color != white)
		//src.recolor
/mob/living/basic/sheep/black
	body_color = black

/mob/living/basic/sheep/white
	body_color = white
