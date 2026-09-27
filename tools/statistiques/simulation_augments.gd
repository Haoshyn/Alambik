extends RefCounted

const Modeles = preload("res://tools/statistiques/modeles.gd")
const NOMBRE_RUNS := 384
const GRAINE_BASE := 20260927
const POLITIQUES := {
	"tout_offensif": {"poids_dps": 1.0, "poids_ehp": 0.0},
	"offensif": {"poids_dps": 0.85, "poids_ehp": 0.15},
	"equilibre": {"poids_dps": 0.55, "poids_ehp": 0.45},
	"defensif": {"poids_dps": 0.20, "poids_ehp": 0.80},
}
const HYPOTHESES := [
	"Chaque run commence sans augment, avec le même équipement permanent. Les graines sont consécutives à partir de la graine indiquée.",
	"Le calendrier des raretés et les offres viennent de ProgressionAugments et DraftLogique ; aucune relance ni augment précis imposé dans les offres. Le bonus légendaire suit la loi réelle, sauf désactivation explicite pour comparer des parcours ordinaires.",
	"Chaque niveau donne exactement un choix. Les niveaux sont acquis après les salles plafonds, comme le garantit le rattrapage ; aucun choix supplémentaire ne précède les boss.",
	"Chaque choix maximise poids_DPS × ln(DPS après / DPS avant) + poids_EHP × ln(PV effectifs après / PV effectifs avant), sans connaître les offres futures.",
	"En cas d'égalité, le premier choix de l'offre est conservé. Les politiques utilisent les mêmes graines initiales, avec un générateur réservé aux offres ; leurs inventaires peuvent ensuite faire diverger les tirages. Tout offensif ne valorise aucune défense ; une offre sans gain de DPS peut néanmoins en donner.",
	"La graine reproduit ce parcours de simulation. Une partie jouée peut consommer d'autres tirages aléatoires entre les choix et proposer des offres différentes.",
	"Le DPS est monocible idéal : tous les projectiles frontaux touchent, critiques moyens et familier inclus. Les diagonales, rebonds et perforations ne donnent aucun dégât supplémentaire gratuit sur la même cible.",
	"Les PV effectifs représentent la réserve de vie et la réduction des dégâts. Blessures, soins immédiats, seconde vie de Courage, boucliers, esquives, mobilité et utilité multicible ne sont pas simulés et ne reçoivent aucun bonus de score fictif. La charge après déplacement d’Élan vital n’est pas incluse dans ce DPS de tir continu.",
	"Avant/après encadrent les choix de la salle ; le combat utilise l'inventaire d'entrée, sans le niveau acquis à sa sortie.",
	"P10, médiane et P90 utilisent une interpolation linéaire entre les observations triées. Les statistiques sont relatives au même profil permanent sans augment.",
]

static func calendrier(total_salles := Reglages.SALLES_PAR_RUN) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var niveau_precedent := 0
	for salle in range(1, total_salles + 1):
		if salle >= total_salles:
			continue
		var plafond := ProgressionAugments.plafond_salle(salle, total_salles)
		for niveau in range(niveau_precedent + 1, plafond + 1):
			resultat.append({"salle": salle, "moment": "sortie", "nature": "niveau", "niveau": niveau, "rarete": ""})
		niveau_precedent = plafond
	return resultat

static func simuler(configuration: Dictionary = {}, nombre_runs := NOMBRE_RUNS, graine_base := GRAINE_BASE,
		autoriser_legendaire_bonus := true) -> Dictionary:
	var permanente := configuration.duplicate(true)
	permanente.erase("augments")
	var cache := {}
	var reference := _mesurer(permanente, [], cache)
	var parcours := calendrier()
	var resultat := {"runs_par_politique": maxi(1, nombre_runs), "graine_base": graine_base,
		"configuration": permanente, "reference": reference, "calendrier": parcours,
		"autoriser_legendaire_bonus": autoriser_legendaire_bonus, "hypotheses": HYPOTHESES.duplicate(), "politiques": {}}
	var politiques: Dictionary = resultat["politiques"]
	for politique: String in POLITIQUES:
		var echantillons: Array[Dictionary] = []
		for salle in range(1, Reglages.SALLES_PAR_RUN + 1):
			echantillons.append({"salle": salle, "avant": [], "combat": [], "apres": []})
		var choix := {}
		var legendaires := _legendaires_vides()
		var runs_avec_bonus := 0
		for index in maxi(1, nombre_runs):
			var run := _une_run(permanente, politique, graine_base + index, cache, parcours, false, autoriser_legendaire_bonus)
			var raretes: Array = run["raretes_niveaux"]
			if raretes.count(Reactif.LEGENDAIRE) > 1:
				runs_avec_bonus += 1
			var salles: Array = run["salles"]
			for index_salle in salles.size():
				var etat: Dictionary = salles[index_salle]
				for phase: String in ["avant", "combat", "apres"]:
					var valeurs: Array = echantillons[index_salle][phase]
					valeurs.append(etat[phase])
			var evenements: Array = run["evenements"]
			for evenement: Dictionary in evenements:
				var id := str(evenement["choix"])
				choix[id] = int(choix.get(id, 0)) + 1
				if str(evenement["rarete"]) != Reactif.LEGENDAIRE:
					continue
				for offert: String in evenement["offre"]:
					var compteur: Dictionary = legendaires[offert]
					compteur["offres"] = int(compteur["offres"]) + 1
				var choisi: Dictionary = legendaires[id]
				choisi["choix"] = int(choisi["choix"]) + 1
		var resumes: Array[Dictionary] = []
		for echantillon: Dictionary in echantillons:
			var salle := int(echantillon["salle"])
			var moments: Array[String] = []
			for evenement: Dictionary in parcours:
				if int(evenement["salle"]) == salle and str(evenement["moment"]) not in moments:
					moments.append(str(evenement["moment"]))
			var ligne := {"salle": salle, "moments_choix": moments}
			for phase: String in ["avant", "combat", "apres"]:
				ligne[phase] = _resumer(echantillon[phase], reference)
			resumes.append(ligne)
		for id: String in legendaires:
			var compteur: Dictionary = legendaires[id]
			compteur["frequence_offres"] = float(compteur["offres"]) / float(maxi(1, nombre_runs))
			compteur["frequence_choix"] = float(compteur["choix"]) / float(maxi(1, nombre_runs))
		politiques[politique] = {"poids": POLITIQUES[politique].duplicate(), "salles": resumes,
			"legendaires": legendaires, "choix": choix, "runs_avec_bonus": runs_avec_bonus}
	resultat["configurations_mesurees"] = cache.size()
	return resultat

static func une_run(configuration: Dictionary = {}, politique := "equilibre", graine := GRAINE_BASE,
		autoriser_legendaire_bonus := true) -> Dictionary:
	assert(POLITIQUES.has(politique), "Politique d'augments inconnue")
	var permanente := configuration.duplicate(true)
	permanente.erase("augments")
	return _une_run(permanente, politique, graine, {}, calendrier(), true, autoriser_legendaire_bonus)

static func _une_run(configuration: Dictionary, politique: String, graine: int, cache: Dictionary,
		parcours: Array[Dictionary], conserver_details: bool, autoriser_legendaire_bonus: bool) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var raretes_niveaux := ProgressionAugments.tirer_raretes_niveaux(rng, autoriser_legendaire_bonus)
	var inventaire: Array[String] = []
	var evenements: Array[Dictionary] = []
	var salles: Array[Dictionary] = []
	for salle in range(1, Reglages.SALLES_PAR_RUN + 1):
		var avant := _mesurer(configuration, inventaire, cache)
		var inventaire_avant: Array = inventaire.duplicate() if conserver_details else []
		for plan: Dictionary in parcours:
			if int(plan["salle"]) != salle:
				continue
			var niveau := int(plan["niveau"])
			var rarete := ProgressionAugments.rarete_niveau(niveau, raretes_niveaux)
			var offre := DraftLogique.proposer(inventaire, rng, ProgressionAugments.NOMBRE_CHOIX, rarete, niveau)
			assert(not offre.is_empty(), "Le catalogue ne peut pas fournir de choix")
			var depart := _mesurer(configuration, inventaire, cache)
			var meilleur_id := offre[0]
			var meilleur_score := -INF
			for id: String in offre:
				var suite := inventaire.duplicate()
				suite.append(id)
				var arrivee := _mesurer(configuration, suite, cache)
				var score := score_choix(depart, arrivee, politique)
				if score > meilleur_score:
					meilleur_score = score
					meilleur_id = id
			var evenement := {"salle": salle, "moment": "sortie", "niveau": niveau, "rarete": rarete,
				"offre": offre, "choix": meilleur_id}
			if conserver_details:
				evenement["inventaire_avant"] = inventaire.duplicate()
				evenement["score"] = meilleur_score
			inventaire.append(meilleur_id)
			evenements.append(evenement)
		var apres := _mesurer(configuration, inventaire, cache)
		var etat := {"salle": salle, "avant": avant, "combat": avant, "apres": apres}
		if conserver_details:
			etat["inventaire_avant"] = inventaire_avant
			etat["inventaire_combat"] = inventaire_avant.duplicate()
			etat["inventaire_apres"] = inventaire.duplicate()
		salles.append(etat)
	return {"graine": graine, "politique": politique, "raretes_niveaux": raretes_niveaux,
		"inventaire": inventaire, "evenements": evenements, "salles": salles}

static func score_choix(avant: Dictionary, apres: Dictionary, politique: String) -> float:
	var poids: Dictionary = POLITIQUES[politique]
	return float(poids["poids_dps"]) * log(float(apres["dps"]) / float(avant["dps"])) \
		+ float(poids["poids_ehp"]) * log(float(apres["pv_effectifs"]) / float(avant["pv_effectifs"]))

static func _mesurer(configuration: Dictionary, inventaire: Array, cache: Dictionary) -> Dictionary:
	var tries: Array[String] = []
	tries.assign(inventaire)
	tries.sort()
	var cle := "/".join(tries)
	if not cache.has(cle):
		var complete := configuration.duplicate(true)
		complete["augments"] = tries
		cache[cle] = Modeles.mesurer(complete)
	var mesure: Dictionary = cache[cle]
	return mesure

static func _legendaires_vides() -> Dictionary:
	var resultat := {}
	for id: String in CatalogueReactifs.ids():
		if CatalogueReactifs.par_id(id).rarete == Reactif.LEGENDAIRE:
			resultat[id] = {"offres": 0, "choix": 0}
	return resultat

static func _resumer(mesures: Array, reference: Dictionary) -> Dictionary:
	var resultat := {}
	for cle: String in ["dps", "dps_heros", "dps_familier", "pv_effectifs"]:
		var valeurs: Array[float] = []
		var rapports: Array[float] = []
		for mesure: Dictionary in mesures:
			valeurs.append(float(mesure[cle]))
			if cle in ["dps", "pv_effectifs"]:
				rapports.append(float(mesure[cle]) / float(reference[cle]))
		resultat[cle] = distribution(valeurs)
		if not rapports.is_empty():
			resultat["dps_ratio" if cle == "dps" else "ehp_ratio"] = distribution(rapports)
	return resultat

static func distribution(valeurs: Array[float]) -> Dictionary:
	assert(not valeurs.is_empty(), "Distribution vide")
	var triees := valeurs.duplicate()
	triees.sort()
	return {"p10": _quantile(triees, 0.10), "mediane": _quantile(triees, 0.50), "p90": _quantile(triees, 0.90)}

static func _quantile(triees: Array[float], part: float) -> float:
	var position := clampf(part, 0.0, 1.0) * float(triees.size() - 1)
	var bas := floori(position)
	var haut := mini(bas + 1, triees.size() - 1)
	return lerpf(triees[bas], triees[haut], position - float(bas))
