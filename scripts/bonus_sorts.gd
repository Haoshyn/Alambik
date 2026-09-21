class_name BonusSorts
extends RefCounted

static func attaque(stats: Stats, mods_liste: Array, bonus_conditionnel := 0.0,
		pour_sort := false) -> float:
	return stats.attaque_reelle(bonus_conditionnel) \
		* Mods.facteur_attaque_run(mods_liste, pour_sort)

static func degats(stats: Stats, mods_liste: Array) -> float:
	return attaque(stats, mods_liste, 0.0, true)

static func rayon(base: float, mods_liste: Array, maitrises: Dictionary) -> float:
	return base * Mods.facteur_heros(mods_liste, "rayon_sorts_mult") \
		* ArbreCompetences.multiplicateur_rayon_sorts(maitrises)
