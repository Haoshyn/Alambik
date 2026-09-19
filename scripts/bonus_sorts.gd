class_name BonusSorts
extends RefCounted

static func attaque(stats: Stats, mods_liste: Array) -> float:
	# Les divisions par projectile et le ratio de la baguette ne changent pas
	# l'attaque magique. Seuls les gains d'attaque s'ajoutent a la base equipee.
	var bonus := 0.0
	for mod: Dictionary in mods_liste:
		bonus += maxf(0.0, float(mod.get("degats_mult", 1.0)) - 1.0)
	return stats.degats * (1.0 + bonus)

static func degats(stats: Stats, mods_liste: Array) -> float:
	return attaque(stats, mods_liste) * Mods.facteur_heros(mods_liste, "degats_sorts_mult")

static func recharge(base: float, mods_liste: Array) -> float:
	return base * Mods.facteur_heros(mods_liste, "recharge_sorts_mult")

static func rayon(base: float, mods_liste: Array) -> float:
	return base * Mods.facteur_heros(mods_liste, "rayon_sorts_mult")
