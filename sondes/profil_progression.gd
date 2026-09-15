extends RefCounted

# Parcours de comparaison fixe, jamais lu par le combat ni par la sauvegarde.
const PALIERS_ACHAT := [1, 2, 3, 5, 7, 10, 13, 17, 22, 27]

static func au_palier(palier: int) -> Dictionary:
	var rangs := {}
	for branche in ["Offensif", "Défensif"]:
		var ids: Array = ArbreCompetences.BRANCHES[branche]
		for i in ids.size():
			var achat: int = PALIERS_ACHAT[i]
			if palier >= achat:
				rangs[ids[i]] = 1 + floori(7.0 * float(palier-achat) / 29.0)
	var equipements := {}
	var forge := {}
	var slots := ["anneau_gauche", "anneau_droit", "collier"]
	for i in mini(palier, 3):
		var id: String = CatalogueObjets.IDS_PAR_MONDE[0][i]
		equipements[slots[i]] = id
		forge[id] = roundi(30.0 * palier / 29.0)
	var bonus := CatalogueObjets.bonus_effectifs(equipements, forge, palier / 3)
	var stats := Stats.depuis_reglages(rangs, {}, bonus)
	var arme: String = CatalogueProjectiles.disponibles(palier+1).back()
	var tir := CatalogueProjectiles.appliquer(arme, Tir.de_base(stats))
	return {"rangs": rangs, "forge": forge, "degats": stats.degats,
		"cadence": stats.cadence, "dps": tir.degats*tir.cadence*tir.nb_projectiles,
		"pv": stats.pv_max, "resistance": stats.pv_max/(1.0-ArbreCompetences.reduction_degats(rangs))}
