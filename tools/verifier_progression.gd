extends SceneTree

const ProfilCampagne = preload("res://tools/statistiques/profil_campagne.gd")

var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_verifier_courbes()
	_verifier_accueil()
	_verifier_classes()
	_verifier_maitrises()
	_verifier_equipement()
	_verifier_familiers()
	_verifier_statistiques()
	_verifier_campagne_fin()
	_verifier_experience_mine()
	for erreur: String in _erreurs:
		push_error(erreur)
	print("Progression : %d contrôles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier(condition: bool, contexte: String) -> void:
	_controles += 1
	if not condition:
		_erreurs.append(contexte)

func _verifier_courbes() -> void:
	var dernier := Chapitres.nombre() - 1
	_verifier(ProgressionStatistiques.palier_borne(-1) == 0, "Palier négatif borné")
	_verifier(ProgressionStatistiques.palier_borne(dernier + 1) == dernier, "Palier supérieur borné")
	_verifier(is_equal_approx(ProgressionStatistiques.facteur_pv(-10), 1.0), "PV de départ")
	_verifier(is_equal_approx(ProgressionStatistiques.facteur_degats(-10), 1.0), "Dégâts de départ")
	_verifier(is_equal_approx(ProgressionStatistiques.facteur_pv(dernier + 100),
		ProgressionStatistiques.facteur_pv(dernier)), "PV hors campagne")
	_verifier(is_equal_approx(ProgressionStatistiques.facteur_degats(dernier + 100),
		ProgressionStatistiques.facteur_degats(dernier)), "Dégâts hors campagne")
	var pv_precedents := 0.0
	var degats_precedents := 0.0
	var ratio_degats_precedent := 1.0
	for chapitre in Chapitres.nombre():
		var pv := ProgressionStatistiques.facteur_pv(chapitre)
		var degats := ProgressionStatistiques.facteur_degats(chapitre)
		_verifier(is_finite(pv) and pv > pv_precedents, "Croissance PV chapitre %d" % chapitre)
		_verifier(is_finite(degats) and degats > degats_precedents, "Croissance dégâts chapitre %d" % chapitre)
		if chapitre > 0:
			var ratio_pv := pv / pv_precedents
			var ratio_degats := degats / degats_precedents
			_verifier(ratio_pv > 1.0 and ratio_degats >= ratio_degats_precedent, "PV croissants et acceleration des degats")
			ratio_degats_precedent = ratio_degats
		pv_precedents = pv
		degats_precedents = degats
		var pv_salle_precedents := 0.0
		var degats_salle_precedents := 0.0
		for salle in range(1, Chapitres.salles(chapitre) + 1):
			var pv_salle := Chapitres.facteur_pv(chapitre, salle)
			var degats_salle := Chapitres.facteur_degats(chapitre, salle)
			_verifier(is_finite(pv_salle) and pv_salle >= pv_salle_precedents,
				"PV chapitre %d salle %d" % [chapitre, salle])
			_verifier(is_finite(degats_salle) and degats_salle >= degats_salle_precedents,
				"Dégâts chapitre %d salle %d" % [chapitre, salle])
			if salle > 1:
				_verifier(is_equal_approx(pv_salle / pv_salle_precedents, Reglages.CAMPAGNE_PV_PAR_SALLE * float(Reglages.CAMPAGNE_PV_PALIERS.get(salle, 1.0))), "Marche PV appliquee exactement une fois")
				_verifier(is_equal_approx(degats_salle / degats_salle_precedents, Reglages.CAMPAGNE_DEGATS_PAR_SALLE * float(Reglages.CAMPAGNE_DEGATS_PALIERS.get(salle, 1.0))), "Marche degats appliquee exactement une fois")
			pv_salle_precedents = pv_salle
			degats_salle_precedents = degats_salle
		_verifier(is_equal_approx(Chapitres.facteur_pv(chapitre, -1),
			Chapitres.facteur_pv(chapitre, 1)), "Salle négative bornée")
		_verifier(is_equal_approx(Chapitres.facteur_degats(chapitre, 100),
			Chapitres.facteur_degats(chapitre, Chapitres.salles(chapitre))), "Salle supérieure bornée")
	_verifier(is_equal_approx(Chapitres.facteur_pv(0, 1), 1.0) and is_equal_approx(Chapitres.facteur_degats(0, 1), 1.0), "Salle initiale normalisee a un")
	_verifier(Chapitres.facteur_pv(1, 1) >= 2.0 and Chapitres.facteur_pv(1, 1) <= 3.0, "La marche initiale suit les petits gains permanents")
	_verifier(Chapitres.facteur_pv(0, 19) >= 4.0 and Chapitres.facteur_pv(0, 19) <= 5.0, "Courbe de run moderee apres reduction des augments")

func _verifier_accueil() -> void:
	var stats := Stats.depuis_reglages({}, {}, {"attaque_base": CatalogueProjectiles.attaque_base("standard", 0)})
	for id: String in ["encrier_rampant", "plume_sentinelle", "tache_veloce"]:
		var d := CatalogueEnnemis.par_id(id)
		var tirs := ceili(float(d["pv"]) / stats.degats)
		_verifier(tirs >= 3 and tirs <= 4, "Trois ou quatre tirs initiaux : " + id)
		var accueil := EvolutionEnnemis.appliquer(d, 0)
		var normal := EvolutionEnnemis.appliquer(d, EvolutionEnnemis.CHAPITRES_ACCUEIL - 1)
		_verifier(float(accueil["vitesse"]) <= float(normal["vitesse"]), "Mouvement initial plus lisible")
		if d.has("vitesse_projectile"):
			_verifier(float(accueil["vitesse_projectile"]) < float(normal["vitesse_projectile"]), "Projectiles initiaux ralentis")
	var fragile := CatalogueEnnemis.par_id("encrier_rampant")
	var pv_effectifs := stats.pv_max * (1.0 + stats.defense / Reglages.DEFENSE_REFERENCE)
	var coups_debut := pv_effectifs / float(fragile["degats"])
	var coups_fin := coups_debut / Chapitres.facteur_degats(0, 19)
	_verifier(coups_debut >= 7.0 and coups_debut < 8.0, "Environ sept contacts initiaux")
	_verifier(coups_fin >= 4.0 and coups_fin <= 5.0, "Sans aucun progres defensif, quatre a cinq contacts equivalents en fin du premier niveau")
	for salle in range(1, 5):
		for graine in range(4):
			var vagues := Vagues.pour_salle(salle, 0, graine)
			var origine := Vagues.pour_salle(salle, 0, graine, "grimoire", false)
			_verifier(vagues == origine, "Premier niveau sans renfort supplementaire dans les premieres salles")

func _verifier_classes() -> void:
	for classe: String in Personnage.SPECIALISATIONS:
		_verifier(Personnage.bonus_classe(classe).is_empty(), "Classe sans bonus : " + classe)
		for source: String in ["baguette", "augment", "familier"]:
			_verifier(is_equal_approx(Personnage.multiplicateur_source(classe, source), 1.0),
				"Source neutre : " + classe + "/" + source)
		_verifier(is_equal_approx(Personnage.multiplicateur_classe(classe, "cadence"), 1.0),
			"Cadence neutre : " + classe)

func _verifier_maitrises() -> void:
	for id: String in ArbreCompetences.NOEUDS:
		var donnees: Dictionary = ArbreCompetences.NOEUDS[id]
		var maximum := ArbreCompetences.rangs(id)
		_verifier(maximum >= 1 and maximum <= Reglages.MAITRISE_RANG_MAX, "Rangs : " + id)
		if bool(donnees.get("fort", false)):
			_verifier(maximum == 1, "Majeur à achat unique : " + id)
		var prix_precedent := 0
		for rang in maximum:
			var prix := ArbreCompetences.cout(id, rang)
			_verifier(prix > 0 and prix >= prix_precedent, "Prix : %s rang %d" % [id, rang])
			prix_precedent = prix
		var compte_champs := 0
		for champ: String in ArbreCompetences.CHAMPS_LISIBLES:
			if donnees.has(champ):
				compte_champs += 1
		if compte_champs > 0:
			_verifier(ArbreCompetences.valeur_au_rang(id, maximum).split(" · ").size() == compte_champs,
				"Tous les effets sont lisibles : " + id)
		if donnees.has("requis"):
			var prerequis := str(donnees["requis"])
			_verifier(ArbreCompetences.NOEUDS.has(prerequis), "Prérequis connu : " + id)
			_verifier(not ArbreCompetences.prerequis_atteint(id, {}), "Prérequis vide : " + id)
			_verifier(ArbreCompetences.prerequis_atteint(id, {prerequis: 1}), "Prérequis acquis : " + id)

func _verifier_equipement() -> void:
	for id: String in CatalogueObjets.OBJETS:
		var precedent: Dictionary = {}
		for niveau in range(Reglages.FORGE_NIVEAU_MAX + 1):
			var bonus := CatalogueObjets.bonus_objet(id, niveau)
			for champ: String in bonus:
				var valeur := float(bonus[champ])
				_verifier(is_finite(valeur) and valeur >= float(precedent.get(champ, 0.0)),
					"Bijou %s forge %d champ %s" % [id, niveau, champ])
			precedent = bonus
		_verifier(CatalogueObjets.bonus_objet(id, -1) == CatalogueObjets.bonus_objet(id, 0),
			"Bijou forge négative : " + id)
		_verifier(CatalogueObjets.bonus_objet(id, 100) == precedent, "Bijou forge supérieure : " + id)
	for id: String in CatalogueProjectiles.TYPES:
		var precedent := 0.0
		for niveau in range(Reglages.FORGE_NIVEAU_MAX + 1):
			var attaque := CatalogueProjectiles.attaque_base(id, niveau)
			_verifier(is_finite(attaque) and attaque >= precedent, "Arme %s forge %d" % [id, niveau])
			precedent = attaque
		_verifier(is_equal_approx(CatalogueProjectiles.attaque_base(id, -1),
			CatalogueProjectiles.attaque_base(id, 0)), "Arme forge négative : " + id)
		_verifier(is_equal_approx(CatalogueProjectiles.attaque_base(id, 100), precedent),
			"Arme forge supérieure : " + id)
	for id: String in CatalogueFamiliers.TYPES:
		var precedent := 0.0
		for niveau in range(Reglages.FORGE_NIVEAU_MAX + 1):
			var attaque := CatalogueFamiliers.attaque(id, niveau)
			_verifier(is_finite(attaque) and attaque >= precedent, "Familier %s forge %d" % [id, niveau])
			precedent = attaque
		_verifier(is_equal_approx(CatalogueFamiliers.attaque(id, -1),
			CatalogueFamiliers.attaque(id, 0)), "Familier forge négative : " + id)
		_verifier(is_equal_approx(CatalogueFamiliers.attaque(id, 100), precedent),
			"Familier forge supérieure : " + id)
	var cout_precedent := 0
	for niveau in Reglages.FORGE_NIVEAU_MAX:
		var cout := Reglages.cout_forge(niveau)
		_verifier(cout > 0 and cout >= cout_precedent, "Prix forge %d" % niveau)
		cout_precedent = cout

func _verifier_statistiques() -> void:
	var rangs := {}
	for id: String in ArbreCompetences.NOEUDS:
		rangs[id] = ArbreCompetences.rangs(id)
	var passifs := {"vigueur": 2, "vitalite": 2, "carapace": 2, "celerite": 2}
	var attributs := {"force": 45, "vitalite": 45, "agilite": 20, "intelligence": 35}
	var equipements := {"anneau": "aiguille_venin", "bracelet": "peau_antidote", "collier": "crochet_basilic"}
	var forge := {}
	for id: String in equipements.values():
		forge[id] = Reglages.FORGE_NIVEAU_MAX
	var bonus := CatalogueObjets.bonus_effectifs(equipements, forge)
	bonus["attaque_base"] = float(bonus["attaque_base"]) + CatalogueProjectiles.attaque_base("royal", Reglages.FORGE_NIVEAU_MAX)
	var debut := Stats.depuis_reglages()
	var equipe := Stats.depuis_reglages(rangs, passifs, bonus, Personnage.NIVEAU_MAX, attributs, "sorcier")
	var moine := Stats.depuis_reglages(rangs, passifs, bonus, Personnage.NIVEAU_MAX, attributs, "moine")
	var champs := ["pv", "pv_max", "soin_mult", "vitesse", "cadence", "attaque_base", "bonus_attaque",
		"degats", "defense", "critique", "critique_excedentaire", "degats_critiques", "vitesse_projectile", "portee"]
	for champ: String in champs:
		var base := float(debut.get(champ))
		var valeur := float(equipe.get(champ))
		_verifier(is_finite(base) and base >= 0.0, "Stat initiale : " + champ)
		_verifier(is_finite(valeur) and valeur >= base, "Stat équipée : " + champ)
		_verifier(is_equal_approx(valeur, float(moine.get(champ))), "Même stat pour les classes : " + champ)
	_verifier(equipe.critique >= 0.0 and equipe.critique <= 1.0, "Chance critique bornée")
	_verifier(is_equal_approx(debut.pv, debut.pv_max), "PV initiaux remplis")
	_verifier(is_equal_approx(equipe.pv, equipe.pv_max), "PV équipés remplis")
	_verifier(is_equal_approx(equipe.degats, equipe.attaque_reelle()), "Attaque calculée cohérente")
	var intellect := Stats.depuis_reglages({}, {}, {}, 1, {"intelligence": 1})
	_verifier(intellect.degats > debut.degats and intellect.cadence > debut.cadence,
		"Intelligence utile aux tirs normaux")
	_verifier(is_equal_approx(Stats.base_pv(Personnage.NIVEAU_MAX), Reglages.HEROS_PV * (1.0 + 29.0 * Reglages.NIVEAU_PV_PAR_NIVEAU)), "Petit socle PV du niveau")
	_verifier(is_equal_approx(Stats.base_degats(Personnage.NIVEAU_MAX), Reglages.TIR_DEGATS * (1.0 + 29.0 * Reglages.NIVEAU_DEGATS_PAR_NIVEAU)), "Petit socle ATK du niveau")
	_verifier(Personnage.points_depenses(attributs) == Personnage.points_totaux(Personnage.NIVEAU_MAX),
		"Exemple équipé dans le budget des attributs")

func _verifier_familiers() -> void:
	var attaque_depart := Reglages.TIR_DEGATS + CatalogueProjectiles.attaque_base("standard", 0)
	var premier := CatalogueFamiliers.attaque_combat("homoncule_encre", 0, 0.0, attaque_depart)
	var premiere_forge := CatalogueFamiliers.attaque_combat("homoncule_encre", 1, 0.0, attaque_depart)
	_verifier(premiere_forge > premier and premiere_forge < attaque_depart,
		"La première forge du familier apporte un gain sans dépasser le héros")
	for id: String in CatalogueFamiliers.TYPES:
		var donnees: Dictionary = CatalogueFamiliers.TYPES[id]
		_verifier(float(donnees["intervalle"]) > 0.0, "Intervalle du familier positif : " + id)
		var forge_complete := CatalogueFamiliers.attaque_combat(id, Reglages.FORGE_NIVEAU_MAX, 0.0, attaque_depart)
		_verifier(forge_complete <= attaque_depart * Reglages.FAMILIER_DEGATS_MAX_PART_HEROS,
			"La forge seule respecte le plafond du héros : " + id)
		var sans_bonus := CatalogueFamiliers.attaque(id, 0)
		var partage := CatalogueFamiliers.attaque_combat(id, 0, 1.0, sans_bonus * 10.0)
		_verifier(is_equal_approx(partage, sans_bonus * 2.0),
			"Les bonus permanents sont partagés une seule fois : " + id)
		_verifier(is_zero_approx(CatalogueFamiliers.attaque_combat(id, 0, 1.0, 0.0)),
			"Aucun dégât familier lorsque son plafond est nul : " + id)

func _verifier_campagne_fin() -> void:
	var ressources := ProfilCampagne.budget()
	var configuration := ProfilCampagne.construire()
	var maitrises: Dictionary = configuration["maitrises"]
	var attributs: Dictionary = configuration["attributs"]
	_verifier(int(ressources["cout_maitrises"]) <= int(ressources["gouttes_min"]),
		"Scénario campagne : maîtrises financées même avec les coffres minimum")
	_verifier(int(ressources["cout_forge"]) <= int(ressources["pierres"]),
		"Scénario campagne : forges financées")
	_verifier(Personnage.points_depenses(attributs) <= int(ressources["points_attributs"]),
		"Scénario campagne : attributs financés par les niveaux acquis")
	for id: String in maitrises:
		_verifier(int(maitrises[id]) <= ArbreCompetences.rangs(id), "Scénario campagne : rangs " + id)
		_verifier(ArbreCompetences.prerequis_atteint(id, maitrises), "Scénario campagne : prérequis " + id)
	var passifs: Dictionary = configuration["passifs"]
	_verifier(passifs.is_empty() and int(configuration["coeurs"]) == 0,
		"Scénario campagne : aucun butin réservé aux Épreuves")

func _verifier_experience_mine() -> void:
	var objets: Array[String] = []
	var precedent := -1
	for secondes: float in [-10.0, 0.0, Reglages.MINE_DUREE * 0.5, Reglages.MINE_DUREE, Reglages.MINE_DUREE * 2.0]:
		var offre := ButinsRun.offre("mine", 0, 0, 0, false, 1, {}, objets, 0, 0, 0, secondes)
		var xp := int(offre["xp"])
		_verifier(xp >= precedent and xp <= ButinsRun.XP_MINE_SURVIE, "XP Mine de défaite monotone et plafonnée")
		if secondes <= 0.0: _verifier(xp == 0, "Aucune XP Mine sans temps de survie")
		if is_equal_approx(secondes, Reglages.MINE_DUREE * 0.5):
			_verifier(xp == ButinsRun.XP_MINE_SURVIE / 2, "Une demi-Mine paie la moitié de l'XP, même sans salle validée")
		precedent = xp
	var victoire := ButinsRun.offre("mine", 0, 1, 1, true, 1, {}, objets, 0, 0, 0, Reglages.MINE_DUREE)
	_verifier(int(victoire["xp"]) == ButinsRun.XP_MINE_SURVIE + ButinsRun.XP_MINE_BOSS, "Le boss ajoute son XP une fois à la survie")
