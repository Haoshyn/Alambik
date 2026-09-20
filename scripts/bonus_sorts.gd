class_name BonusSorts
extends RefCounted

static func attaque(stats: Stats, mods_liste: Array, bonus_conditionnel := 0.0,
		pour_sort := false) -> float:
	return stats.attaque_reelle(Mods.bonus_attaque(mods_liste, pour_sort) + bonus_conditionnel)

static func degats(stats: Stats, mods_liste: Array) -> float:
	return attaque(stats, mods_liste, 0.0, true)

static func rayon(base: float, mods_liste: Array) -> float:
	return base * Mods.facteur_heros(mods_liste, "rayon_sorts_mult")
