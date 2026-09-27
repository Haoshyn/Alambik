extends RefCounted

# Scenarios de lecture, sans influence sur le jeu. Les stats proviennent des
# calculateurs du runtime ; les hypotheses de tir et de conditions sont explicites.
static func toutes_maitrises() -> Dictionary:
	var resultat := {}
	for id: String in ArbreCompetences.NOEUDS:
		resultat[id] = ArbreCompetences.rangs(id)
	return resultat

static func complet() -> Dictionary:
	var bijoux := {}
	var forge := {}
	for id: String in CatalogueObjets.IDS_PAR_MONDE[Chapitres.MONDES.size() - 1]:
		var objet: Dictionary = CatalogueObjets.OBJETS[id]
		bijoux[str(objet["slot"])] = id
		forge[id] = Reglages.FORGE_NIVEAU_MAX
	return {"arme": "royal", "forge_arme": Reglages.FORGE_NIVEAU_MAX,
		"familier": "golem", "forge_familier": Reglages.FORGE_NIVEAU_MAX,
		"bijoux": bijoux, "forge_bijoux": forge,
		"niveau": Personnage.NIVEAU_MAX,
		"attributs": {"force": 40, "vitalite": 50, "agilite": 25, "intelligence": 30},
		"maitrises": toutes_maitrises(),
		"passifs": {"vigueur": 2, "celerite": 2, "oeil_precis": 2, "vitalite": 2},
		"coeurs": Epreuves.nombre()}

static func bonus_equipement(configuration: Dictionary) -> Dictionary:
	var bijoux: Dictionary = configuration.get("bijoux", {})
	var forge: Dictionary = configuration.get("forge_bijoux", {})
	var arme := str(configuration.get("arme", "standard"))
	var familier := str(configuration.get("familier", "homoncule_encre"))
	var bonus := CatalogueObjets.bonus_effectifs(bijoux, forge)
	bonus["attaque_base"] = float(bonus.get("attaque_base", 0.0)) + CatalogueProjectiles.attaque_base(arme, int(configuration.get("forge_arme", 0)))
	for source: Dictionary in [CatalogueProjectiles.bonus_heros(arme), CatalogueFamiliers.bonus_heros(familier)]:
		for cle: String in source:
			bonus[cle] = float(bonus.get(cle, 0.0)) + float(source[cle])
	return bonus

static func mesurer(configuration: Dictionary) -> Dictionary:
	var bijoux: Dictionary = configuration.get("bijoux", {})
	var forge: Dictionary = configuration.get("forge_bijoux", {})
	var arme := str(configuration.get("arme", "standard"))
	var familier := str(configuration.get("familier", "homoncule_encre"))
	var bonus := bonus_equipement(configuration)
	var maitrises: Dictionary = configuration.get("maitrises", {})
	var passifs: Dictionary = configuration.get("passifs", {})
	var attributs: Dictionary = configuration.get("attributs", {})
	var stats := Stats.depuis_reglages(maitrises, passifs, bonus, int(configuration.get("niveau", 1)), attributs)
	var mods := Mods.depuis_l_inventaire(configuration.get("augments", []))
	var tir := CatalogueProjectiles.appliquer(arme, Mods.appliquer(Tir.de_base(stats), mods))
	var chance_brute := stats.critique + stats.critique_excedentaire + Mods.bonus_heros(mods, "critique_add")
	var critique := clampf(chance_brute, 0.0, 1.0)
	var degats_critiques := Reglages.CRITIQUE_MULT_BASE + stats.degats_critiques + Mods.bonus_degats_critiques(mods, chance_brute)
	var critique_moyen := 1.0 + critique * (degats_critiques - 1.0)
	var effets := CatalogueObjets.effets_equipes(bijoux, forge)
	var bonus_conditionnel := Passifs.bonus_audace(passifs)
	if bool(configuration.get("conditions", false)):
		bonus_conditionnel += Passifs.bonus_reprise(passifs)
		if "elan_offensif" in effets:
			bonus_conditionnel += EffetsBijoux.ELAN_BONUS_PAR_ATTAQUE * EffetsBijoux.ELAN_CUMULS_MAX
	var facteur_coeurs := 1.0 + clampi(int(configuration.get("coeurs", 0)), 0, Epreuves.nombre()) * Reglages.COEUR_MANA_BONUS_FINAL
	var final := (1.0 + bonus_conditionnel) * facteur_coeurs
	var impact_moyen := 1.0
	if "cinquieme_impact" in effets:
		impact_moyen += (EffetsBijoux.IMPACT_MULTIPLICATEUR - 1.0) / float(EffetsBijoux.IMPACT_ATTAQUES)
	var degats_tir := tir.degats * tir.degats_finaux_projectile_mult * critique_moyen * final * impact_moyen
	var frontaux := 0.0
	var tous := 0.0
	for index in tir.nb_projectiles:
		var facteur := tir.facteur_projectile(index)
		tous += facteur
		if index < tir.nb_projectiles - tir.projectiles_lateraux:
			frontaux += facteur
	var dps_heros := degats_tir * frontaux * tir.cadence * tir.salves
	var dps_familier := 0.0
	if CatalogueFamiliers.contient(familier):
		var d: Dictionary = CatalogueFamiliers.TYPES[familier]
		var attaque := CatalogueFamiliers.attaque_combat(familier, int(configuration.get("forge_familier", 0)),
			stats.bonus_attaque, stats.attaque_reelle() * Mods.facteur_attaque_run(mods))
		dps_familier = attaque * final / float(d["intervalle"])
	var pv := stats.pv_max * Mods.facteur_heros(mods, "pv_max_mult")
	var defense := stats.defense * Mods.facteur_heros(mods, "defense_mult")
	var degats_subis := Mods.facteur_heros(mods, "degats_subis_mult") * (1.0 + Passifs.bonus_audace(passifs)) \
		* (1.0 - ArbreCompetences.reduction_degats(maitrises)) * Reglages.DEFENSE_REFERENCE / (Reglages.DEFENSE_REFERENCE + maxf(0.0, defense))
	var donnees_arme: Dictionary = CatalogueProjectiles.TYPES.get(arme, CatalogueProjectiles.TYPES["standard"])
	return {"attaque_brute": stats.attaque_base, "attaque": stats.degats * Mods.facteur_attaque_run(mods),
		"etapes_permanentes": stats.etapes_permanentes.duplicate(true),
		"facteur_attaque_augments": Mods.facteur_attaque_run(mods),
		"facteur_pv_augments": Mods.facteur_heros(mods, "pv_max_mult"),
		"facteur_defense_augments": Mods.facteur_heros(mods, "defense_mult"),
		"facteur_cadence_augments": Mods.facteur_heros(mods, "cadence_mult"),
		"facteur_coeurs": facteur_coeurs, "facteur_conditionnel": 1.0 + bonus_conditionnel,
		"coefficient_arme": float(donnees_arme.get("coefficient_tir", 1.0)),
		"cadence_arme": float(donnees_arme.get("cadence_mult", 1.0)),
		"tir_normal": tir.degats * tir.degats_finaux_projectile_mult * final,
		"tir_critique": tir.degats * tir.degats_finaux_projectile_mult * final * degats_critiques,
		"coefficient_critique": degats_critiques, "impact_moyen": impact_moyen,
		"salves": tir.salves, "projectiles_frontaux": tir.nb_projectiles - tir.projectiles_lateraux,
		"degats_projectile_mult": tir.degats_finaux_projectile_mult,
		"vitesse": stats.vitesse * Mods.facteur_heros(mods, "deplacement_mult"),
		"tir_moyen": degats_tir, "cadence": tir.cadence, "critique": critique,
		"dps_heros": dps_heros, "dps_familier": dps_familier, "dps": dps_heros + dps_familier,
		"dps_tous_projectiles": degats_tir * tous * tir.cadence * tir.salves + dps_familier,
		"pv": pv, "defense": defense, "degats_subis": degats_subis, "pv_effectifs": pv / degats_subis}

static func paliers_sources() -> Array[Dictionary]:
	var cible := complet()
	var resultats: Array[Dictionary] = [{"nom": "Départ : baguette et homoncule, forge 0", "build": {}}]
	resultats.append({"nom": "Même baguette, forge maximum seulement", "build": {"forge_arme": Reglages.FORGE_NIVEAU_MAX}})
	var build: Dictionary = cible.duplicate(true)
	for cle: String in ["attributs", "maitrises", "passifs", "coeurs"]: build.erase(cle)
	build["niveau"] = 1
	resultats.append({"nom": "Équipement complet de fin, forge maximum", "build": build.duplicate(true)})
	for etape: Array in [["attributs", "Puis niveau %d et %d points d’attributs" % [Personnage.NIVEAU_MAX, Personnage.points_totaux(Personnage.NIVEAU_MAX)]], ["maitrises", "Puis toutes les maîtrises"], ["passifs", "Puis quatre passifs de statistiques au rang 2"], ["coeurs", "Puis tous les Cœurs"]]:
		if str(etape[0]) == "attributs": build["niveau"] = int(cible["niveau"])
		build[str(etape[0])] = cible[str(etape[0])]
		resultats.append({"nom": str(etape[1]), "build": build.duplicate(true)})
	build["conditions"] = true
	resultats.append({"nom": "Puis effet d’anneau pleinement actif", "build": build.duplicate(true)})
	return resultats
