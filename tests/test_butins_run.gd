extends RefCounted

func test_chaque_salle_remplit_le_coffre_et_boss_augmente_le_rang(v: Verif) -> void:
	var precedent := 0
	for salle in 21:
		var offre := ButinsRun.offre("grimoire", 0, salle, salle / 5, salle == 20, 1, {}, [], 0)
		v.vrai(int(offre["gouttes_min"]) >= precedent, "gain monotone salle %d" % salle)
		v.egal(int(offre["rang"]), salle / 5, "rang du dernier boss")
		if salle > 0: v.vrai(int(offre["gouttes_min"]) > precedent, "chaque salle apporte un gain")
		else: v.egal(int(offre["xp"]), 0, "aucune XP pour abandon immediat")
		precedent = int(offre["gouttes_min"])
		if salle < 20: v.vrai((offre["objets"] as Array).is_empty(), "pas d'objet sans victoire finale")
	var final := ButinsRun.offre("grimoire", 0, 20, 4, true, 1, {}, [], 0)
	v.egal(final["gouttes_min"], 72, "economie finale preservee")
	v.egal(final["gouttes_max"], 76, "economie finale preservee")

func test_les_niveaux_d_epreuve_localisent_tout_l_arsenal(v: Verif) -> void:
	var vus: Array[String] = []
	for niveau in range(1, Epreuves.nombre() + 1):
		for id in Epreuves.sorts(niveau):
			v.vrai(Sorts.contient(id), "sort existant")
			v.vrai(not vus.has(id), "pas de pool cumulative cachee")
			vus.append(id)
			v.egal(Epreuves.niveau_pour(id), niveau, "provenance exacte")
	v.egal(vus.size(), Sorts.ACTIFS.size() + Sorts.PASSIFS.size() + Sorts.ULTIMES.size(), "aucun sort sans voie d'obtention")
	v.egal(Epreuves.sorts(1), ["onde_alchimique", "rempart_initial"], "premier duo demande")
	v.egal(Epreuves.sorts(2), ["nova_de_givre", "heritage_reactif"], "second duo demande")
	v.vrai(Sorts.ULTIMES.has(Epreuves.sorts(3)[0]), "premier ultime au niveau trois")

func test_tirage_conforme_a_l_apercu_et_sans_loot_anticipe(v: Verif) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 31415
	for mode in ["grimoire", "epreuve_sorts", "mine"]:
		for victoire in [false, true]:
			var offre := ButinsRun.offre(mode, 0, 20 if mode == "grimoire" else 5, 4, victoire, 2, {}, [], 0)
			for i in 100:
				var tirage := ButinsRun.tirer(offre, rng)
				v.vrai(int(tirage["gouttes"]) >= int(offre["gouttes_min"]) and int(tirage["gouttes"]) <= int(offre["gouttes_max"]), "tirage dans les bornes affichees")
				for type in ["objet", "sort"]:
					v.vrai(str(tirage[type]).is_empty() or tirage[type] in offre[type + "s"], "tirage dans les loots affiches")
					if not victoire: v.egal(tirage[type], "", "aucun loot permanent de victoire sur abandon")
	var rangs := {"nova_de_givre": Reglages.CAPACITE_RANG_MAX}
	var offre := ButinsRun.offre("epreuve_sorts", 0, 5, 5, true, 2, rangs, [], 0)
	v.egal(offre["sorts"], ["heritage_reactif"], "le sort maxe sort de la pool")
	v.presque(float(offre["chance_sort"]), 0.8, "la chance restante est annoncee correctement")
	var garanti := ButinsRun.offre("grimoire", 0, 20, 4, true, 1, {}, [], 4)
	v.presque(float(garanti["chance_objet"]), 1.0, "la garantie est dans l'offre affichee")

func test_recharges_sans_avantage_cache_de_cadence(v: Verif) -> void:
	for catalogue in [Sorts.ACTIFS, Sorts.ULTIMES]:
		for id in catalogue:
			var base := Sorts.recharge(id, {}, {}, "standard")
			v.vrai(base > 0.0, "recharge temporelle positive")
			v.presque(Sorts.recharge(id, {}, {}, "veloce"), base * 0.9, "seul le passif explicite de l'aiguille reduit le delai")
			v.presque(Sorts.recharge(id, {}, {}, "lourd"), base, "la cadence lente ne penalise pas les sorts")
			var maximal := Sorts.recharge(id, {"sang_froid": 100.0, "reserve_ultime": 100.0}, {"elan": 10}, "veloce")
			v.vrai(maximal >= base * Reglages.RECHARGE_PLANCHER, "la combinaison des reductions reste bornee")
	v.vrai(ArbreCompetences.multiplicateur_recharge({"elan": 1}) < 1.0, "la maitrise utilitaire reduit le delai")
