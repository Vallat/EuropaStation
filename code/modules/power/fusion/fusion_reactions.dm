#define REACTANT_BORON         "boron"
#define REACTANT_HYDROGEN      "hydrogen"
#define REACTANT_EXOTIC_MATTER "exotic matter"
#define REACTANT_MHYDROGEN     "metallic hydrogen"
#define REACTANT_IRON          "iron"
#define REACTANT_GOLD          "gold"
#define REACTANT_SILVER        "silver"
#define REACTANT_PLATINUM      "platinum"
#define REACTANT_DEUTERIUM     "deuterium"
#define REACTANT_TRITIUM       "tritium"
#define REACTANT_LITHIUM       "lithium"
#define REACTANT_HELIUM        "helium"
#define REACTANT_OXYGEN        "oxygen"

var/list/fusion_reactions

/decl/fusion_reaction
	var/p_react = "" // Primary reactant.
	var/s_react = "" // Secondary reactant.
	var/minimum_energy_level = 1
	var/energy_consumption = 0
	var/energy_production = 0
	var/radiation = 0
	var/instability = 0
	var/list/products = list()
	var/minimum_reaction_temperature = 100

/decl/fusion_reaction/proc/handle_reaction_special(var/obj/effect/fusion_em_field/holder)
	return 0

proc/get_fusion_reaction(var/p_react, var/s_react, var/m_energy)
	if(!fusion_reactions)
		fusion_reactions = list()
		for(var/rtype in typesof(/decl/fusion_reaction) - /decl/fusion_reaction)
			var/decl/fusion_reaction/cur_reaction = new rtype()
			if(!fusion_reactions[cur_reaction.p_react])
				fusion_reactions[cur_reaction.p_react] = list()
			fusion_reactions[cur_reaction.p_react][cur_reaction.s_react] = cur_reaction
			if(!fusion_reactions[cur_reaction.s_react])
				fusion_reactions[cur_reaction.s_react] = list()
			fusion_reactions[cur_reaction.s_react][cur_reaction.p_react] = cur_reaction

	if(fusion_reactions.Find(p_react))
		var/list/secondary_reactions = fusion_reactions[p_react]
		if(secondary_reactions.Find(s_react))
			return fusion_reactions[p_react][s_react]

// Basic power production reactions.
// This is not necessarily realistic, but it makes a basic failure more spectacular.
/decl/fusion_reaction/hydrogen_hydrogen
	p_react = REACTANT_HYDROGEN
	s_react = REACTANT_HYDROGEN
	energy_consumption = 1
	energy_production = 2
	products = list(REACTANT_HELIUM = 1)

/decl/fusion_reaction/deuterium_deuterium
	p_react = REACTANT_DEUTERIUM
	s_react = REACTANT_DEUTERIUM
	energy_consumption = 1
	energy_production = 2

// Advanced production reactions (todo)
/decl/fusion_reaction/deuterium_helium
	p_react = REACTANT_DEUTERIUM
	s_react = REACTANT_HELIUM
	energy_consumption = 1
	energy_production = 5
	radiation = 2

/decl/fusion_reaction/deuterium_tritium
	p_react = REACTANT_DEUTERIUM
	s_react = REACTANT_TRITIUM
	energy_consumption = 1
	energy_production = 1
	products = list(REACTANT_HELIUM = 1)
	instability = 0.5
	radiation = 3

/decl/fusion_reaction/deuterium_lithium
	p_react = REACTANT_DEUTERIUM
	s_react = REACTANT_LITHIUM
	energy_consumption = 2
	energy_production = 0
	radiation = 3
	products = list(REACTANT_TRITIUM= 1)
	instability = 1

// Unideal/material production reactions
/decl/fusion_reaction/oxygen_oxygen
	p_react = REACTANT_OXYGEN
	s_react = REACTANT_OXYGEN
	energy_consumption = 10
	energy_production = 0
	instability = 5
	radiation = 5
	products = list(REACTANT_SILICON= 1)

/decl/fusion_reaction/iron_iron
	p_react = REACTANT_IRON
	s_react = REACTANT_IRON
	products = list(REACTANT_SILVER = 1, REACTANT_GOLD = 1, REACTANT_PLATINUM = 1) // Not realistic but w/e
	energy_consumption = 10
	energy_production = 0
	instability = 2
	minimum_reaction_temperature = 10000

/decl/fusion_reaction/phoron_hydrogen
	p_react = REACTANT_HYDROGEN
	s_react = REACTANT_EXOTIC_MATTER
	energy_consumption = 10
	energy_production = 0
	instability = 5
	products = list(REACTANT_MHYDROGEN = 1)
	minimum_reaction_temperature = 8000

// VERY UNIDEAL REACTIONS.
/decl/fusion_reaction/phoron_supermatter
	p_react = REACTANT_EXOTIC_MATTER
	s_react = REACTANT_EXOTIC_MATTER
	energy_consumption = 0
	energy_production = 5
	radiation = 20
	instability = 20

/decl/fusion_reaction/phoron_supermatter/handle_reaction_special(var/obj/effect/fusion_em_field/holder)

	wormhole_event()

	var/turf/origin = get_turf(holder)
	holder.Rupture()
	qdel(holder)

	// Copied from the SM for proof of concept.
	for(var/mob/living/mob in living_mob_list_)
		var/turf/T = get_turf(mob)
		if(T && (holder.z == T.z))
			if(istype(mob, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = mob
				H.hallucination += rand(100,150)
			mob.apply_effect(rand(100,200), IRRADIATE)

	for(var/obj/machinery/fusion_fuel_injector/I in range(world.view, origin))
		if(I.cur_assembly && I.cur_assembly.fuel_type == REACTANT_EXOTIC_MATTER)
			explosion(get_turf(I), 1, 2, 3)
			spawn(5)
				if(I && I.loc)
					qdel(I)

	sleep(5)
	explosion(origin, 1, 2, 5)

	return 1


// High end reactions.
/decl/fusion_reaction/boron_hydrogen
	p_react = REACTANT_BORON
	s_react = REACTANT_HYDROGEN
	minimum_energy_level = FUSION_HEAT_CAP * 0.5
	energy_consumption = 3
	energy_production = 15
	radiation = 3
	instability = 3

#undef REACTANT_BORON
#undef REACTANT_HYDROGEN
#undef REACTANT_EXOTIC_MATTER
#undef REACTANT_MHYDROGEN
#undef REACTANT_IRON
#undef REACTANT_GOLD
#undef REACTANT_SILVER
#undef REACTANT_PLATINUM
#undef REACTANT_DEUTERIUM
#undef REACTANT_TRITIUM
#undef REACTANT_LITHIUM
#undef REACTANT_HELIUM
#undef REACTANT_OXYGEN