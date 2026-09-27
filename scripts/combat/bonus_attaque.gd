class_name BonusAttaque
extends RefCounted

static func attaque(stats: Stats, mods_liste: Array, bonus_conditionnel := 0.0) -> float:
	return stats.attaque_reelle(bonus_conditionnel) * Mods.facteur_attaque_run(mods_liste)
