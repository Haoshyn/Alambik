extends RefCounted

const Modeles = preload("res://tools/statistiques/modeles.gd")
const Simulation = preload("res://tools/statistiques/simulation_augments.gd")
const Compte = preload("res://tools/statistiques/compte_simule.gd")
const ProfilReference = preload("res://tools/statistiques/profil_reference.gd")
const GRAINE_BASE := 20260927
const COHORTE := 8
const TIR_UTILE := 0.65
const TIR_UTILE_BOSS := 0.70
const SECONDES_CHOIX := 4.0
const SECONDES_TRANSITION := 2.0
const BOSS_LIMITE := 120.0
const CONTACTS_MIN := 3.0
const LOT_MINE := 3
const LOT_EPREUVES := 3
const LOT_REPLAYS := 2
const LOTS_MAX_PAR_MUR := 20
const ALERTE_BLOC_MINUTES := 40.0
const GRAINE_EVALUATION := 20261101
const HYPOTHESES := [
	"Les temps sont des estimations de débit, pas des mesures de joueurs : 65 % du DPS théorique sert aux vagues et 70 % au boss ; sensibilité affichée à 50 % et 80 %.",
	"Les PV et dégâts viennent des catalogues, des vraies Vagues et des courbes fixes du runtime. Le DPS inclut le familier et tous les tirs frontaux ; utilité multicible, invocations, dégâts perdus et soins ne sont pas simulés séparément.",
	"Les vagues sont nettoyées successivement : annonce d'apparition et délai de nettoyage réels. Les départs forcés de vagues peuvent les faire se chevaucher dans le jeu ; ce petit temps d'attente constitue ici une borne prudente.",
	"Les élites sont tirés avec la graine de salle réelle, au plus un par vague nettoyée. Les renforts invoqués ne donnent aucune récompense inventée.",
	"Un choix prend 4 secondes et une transition 2 secondes. Marcher jusqu'aux portails, lire les menus et faire les achats ne sont pas chronométrés.",
	"Un mur du modèle signifie qu'un boss demande plus de 120 secondes de tir utile ou que la réserve entière supporte moins de trois contacts d'un Encrier rampant de la salle. Il ne prédit ni mort humaine ni nombre d'essais nécessaire.",
	"Le parcours commence par une défaite imposée en salle 9 : seules huit salles et un boss paient. Le retry réutilise le compte amélioré mais repart sans augment.",
	"Chaque victoire de parcours est une décision du modèle selon ces seuils ; les coffres utilisent ensuite le vrai booléen victoire et les seules salles validées. Les tirages, garanties, accès et coûts sont ceux du jeu.",
	"Les lots adaptatifs contiennent trois Mines, trois Épreuves ou deux replays d'un chapitre déjà terminé. Le comparatif mixte impose trois replays, trois Mines puis trois Épreuves avant de réessayer. Un bloc dépassant 40 minutes est signalé ; vingt cycles servent de limite de diagnostic, sans inventer une victoire.",
	"La Mine dure réellement 300 secondes avant son boss. Un modèle continu de dégâts abat sa file de monstres, respecte son plafond, ramasse leur XP et choisit les offres légales ; les blessures ne sont pas simulées.",
	"L'allocation progressive vise 40 Force, 50 Vitalité, 25 Agilité et 30 Intelligence. Les achats maximisent le gain logarithmique par coût, avec un poids explicite pour les ressources. Aucun objet manquant ni rang de forge n'est offert.",
	"Une défaite conventionnelle dure la moitié du combat concerné, plafonnée à 120 secondes ; ce temps d'échec est une hypothèse et n'est pas une mesure de survie. Les contacts des Épreuves utilisent leur boss, ceux de la campagne et de la Mine utilisent l'Encrier rampant.",
	"Les Épreuves proposent exactement quatre augments, après leurs quatre premiers boss. Leur XP ne donne pas d'autres choix dans le runtime.",
	"La référence de campagne et de Mine désactive le légendaire bonus : elle conserve un légendaire garanti au niveau prévu, trois épiques et les autres choix rares. Les offres restent aléatoires. Le bonus réel est réservé aux distributions d'augments ; il ne finance pas les critères de progression.",
	"Les Gouttes issues des cœurs inutilisés ne sont pas créditées : sans blessures ni trajets simulés, le modèle ne peut pas savoir lesquels seront convertis à PV pleins.",
	"Le comparatif adaptatif passe aux choix et achats défensifs après un mur de contacts ; après un mur de durée, il reprend les poids équilibrés. Cette réaction utilise seulement l'échec passé, jamais les offres ou le coffre futurs.",
	"Après un premier échec par manque de contacts supportés, les remplacements d'équipement et de passifs doivent préserver les PV effectifs du build avant le choix. Les ensembles de passifs sont comparés complets. Les poids équilibrés restent 55 % DPS et 45 % PV effectifs ; Audace peut être refusée malgré un meilleur score.",
]

static var _rapport_cache: Dictionary = {}

static func rapport() -> Dictionary:
	if not _rapport_cache.is_empty(): return _rapport_cache
	var sans := parcours(false)
	var equilibre := parcours(true)
	var adaptatif := parcours(true, {"adapter_au_mur": true})
	var mixte := parcours(true, {"strategie_lots": "mixte", "adapter_au_mur": true})
	var premier_retry: Dictionary = sans["actions"][1]
	var config_retry: Dictionary = premier_retry["avant"]["configuration"]
	var classique := ProfilReference.construire()
	var stats_classiques := Modeles.mesurer(classique)
	var dernier := Chapitres.nombre() - 1
	var boss := ennemi("grimoire", dernier, Reglages.SALLES_PAR_RUN, str(Chapitres.par_index(dernier)["boss"]))
	var sensibilite: Array[Dictionary] = []
	for utile: float in [0.50, 0.80]:
		var options := {"tir_utile": utile, "tir_utile_boss": utile}
		sensibilite.append({"tir_utile": utile, "depart": cohorte({}, 0, COHORTE, GRAINE_BASE, options),
			"retry": cohorte(config_retry, 0, COHORTE, GRAINE_BASE, options),
			"complet": cohorte(Modeles.complet(), dernier, COHORTE, GRAINE_BASE, options)})
	var murs: Array[float] = []
	var premiers_murs: Array[Dictionary] = []
	for index in COHORTE:
		var graine := GRAINE_BASE + index * 1009
		var cas := sans if index == 0 else parcours(false, {"graine": graine})
		var mur: Dictionary = cas["premier_mur"]
		murs.append(float(mur.get("chapitre", Chapitres.nombre() + 1)))
		premiers_murs.append({"graine": graine, "chapitres_valides": cas["chapitres_valides"], "mur": mur})
	var comptes: Array[Dictionary] = [equilibre]
	for index in range(1, 3):
		comptes.append(parcours(true, {"graine": GRAINE_BASE + index * 1009}))
	_rapport_cache = {"hypotheses": HYPOTHESES.duplicate(), "graine": GRAINE_BASE, "cohorte": COHORTE,
		"depart": cohorte({}, 0), "retry": cohorte(config_retry, 0), "complet": cohorte(Modeles.complet(), dernier),
		"classique": {"configuration": classique, "mesure": stats_classiques, "pv_boss": boss["pv"],
			"boss_final": float(boss["pv"]) / (float(stats_classiques["dps"]) * TIR_UTILE_BOSS)},
		"sensibilite": sensibilite, "premiers_murs": premiers_murs, "distribution_murs": Simulation.distribution(murs),
		"sans_annexes": sans, "equilibre": equilibre, "adaptatif": adaptatif, "mixte": mixte, "cohorte_comptes": comptes,
		"seuil_90": parcours(false, {"boss_limite": 90.0})}
	return _rapport_cache

static func ennemi(mode: String, chapitre: int, salle: int, id: String, niveau_annexe := 1, temps_mine := 0.0) -> Dictionary:
	var base := CatalogueEnnemis.par_id(id)
	var boss := str(base["cerveau"]) == "boss"
	var pv := float(base["pv"])
	var degats := float(base["degats"])
	if mode == "grimoire":
		pv *= Chapitres.facteur_pv(chapitre, salle)
		degats *= Chapitres.facteur_degats(chapitre, salle)
		if boss:
			var signature := str(base.get("rang_boss", "miniboss")) == "signature"
			pv *= Reglages.BOSS_SIGNATURE_PV_MULT if signature else ProgressionStatistiques.facteur_miniboss(Chapitres.palier(chapitre))
			degats *= Reglages.BOSS_SIGNATURE_DEGATS_MULT if signature else Reglages.MINIBOSS_DEGATS_MULT
	elif mode == "epreuves":
		var progression := clampf(float(salle - 1) / 4.0, 0.0, 1.0)
		pv *= Reglages.facteur_annexe_pv(Epreuves.palier(niveau_annexe)) * Reglages.DEFI_PV_BASE * pow(1.0 + Reglages.DEFI_MONTEE_PV, progression)
		degats *= Reglages.facteur_annexe_degats(Epreuves.palier(niveau_annexe)) * Reglages.DEFI_DEGATS_BASE * pow(1.0 + Reglages.DEFI_MONTEE_DEGATS, progression)
	else:
		var progression := clampf(temps_mine / Reglages.MINE_DUREE, 0.0, 1.0)
		pv *= Reglages.facteur_annexe_pv(Mine.palier(niveau_annexe)) * Reglages.MINE_PV_MULT * pow(1.0 + Reglages.MINE_MONTEE_PV, progression)
		degats *= Reglages.facteur_annexe_degats(Mine.palier(niveau_annexe)) * Reglages.MINE_DEGATS_MULT * pow(1.0 + Reglages.MINE_MONTEE_DEGATS, progression)
		if boss:
			pv *= Reglages.MINE_BOSS_PV_MULT
			degats *= Reglages.MINE_BOSS_DEGATS_MULT
	if boss:
		pv *= Reglages.BOSS_ENDURANCE_MULT * (1.0 if mode == "grimoire" else EvolutionEnnemis.ANNEXE_PV_BOSS)
	else:
		degats *= Reglages.ENNEMI_DEGATS_MULT
	return {"id": id, "pv": pv, "degats": degats, "boss": boss, "experience": int(base.get("experience", 0))}

static func campagne(configuration: Dictionary, chapitre: int, graine := GRAINE_BASE, options: Dictionary = {}) -> Dictionary:
	var run := Simulation.une_run(configuration, str(options.get("politique", "equilibre")), graine,
		bool(options.get("autoriser_legendaire_bonus", false)))
	var salles: Array = run["salles"]
	var resultat: Array[Dictionary] = []
	for etat: Dictionary in salles:
		var numero := int(etat["salle"])
		var mesure: Dictionary = etat["combat"]
		var vagues := Vagues.pour_salle(numero, chapitre, graine, "grimoire")
		var pv_total := 0.0
		var elites := 0
		var rng := RandomNumberGenerator.new()
		rng.seed = graine + chapitre * 104729 + numero * 7919
		var boss := Chapitres.est_boss(chapitre, numero)
		for vague: Array in vagues:
			var index_elite := -1
			if not boss and chapitre >= RangsEnnemis.PREMIER_CHAPITRE_ELITES and numero >= RangsEnnemis.PREMIERE_SALLE_ELITES:
				if rng.randf() < RangsEnnemis.CHANCE_ELITE_PAR_VAGUE:
					index_elite = rng.randi_range(0, vague.size() - 1)
					rng.randf()
					elites += 1
			for index in vague.size():
				pv_total += float(ennemi("grimoire", chapitre, numero, str(vague[index]))["pv"]) * (RangsEnnemis.ELITE_PV if index == index_elite else 1.0)
		var utile := float(options.get("tir_utile_boss", TIR_UTILE_BOSS) if boss else options.get("tir_utile", TIR_UTILE))
		var combat := pv_total / (float(mesure["dps"]) * utile)
		var choix := 0
		for evenement: Dictionary in run["evenements"]:
			if int(evenement["salle"]) == numero: choix += 1
		var attente := float(vagues.size()) * (Reglages.APPARITION_BOSS_ANNONCE if boss else Reglages.APPARITION_ANNONCE) \
			+ float(maxi(0, vagues.size() - 1)) * Reglages.DELAI_VAGUE_NETTOYEE
		var duree := combat + attente + choix * SECONDES_CHOIX + (SECONDES_TRANSITION if numero > 1 else 0.0)
		resultat.append({"salle": numero, "boss": boss, "pv_ennemis": pv_total, "vagues": vagues.size(), "elites": elites,
			"dps": mesure["dps"], "pv_effectifs": mesure["pv_effectifs"], "temps_combat": combat, "duree": duree,
			"contacts": float(mesure["pv_effectifs"]) / float(ennemi("grimoire", chapitre, numero, "encrier_rampant")["degats"]),
			"inventaire": etat["inventaire_combat"], "inventaire_apres": etat["inventaire_apres"]})
	return _resumer_rencontres(resultat, run["evenements"], options)

static func cohorte(configuration: Dictionary, chapitre: int, nombre := COHORTE, graine := GRAINE_BASE, options: Dictionary = {}) -> Dictionary:
	var durees: Array[float] = []
	var boss: Array[float] = []
	var finals: Array[float] = []
	var contacts: Array[float] = []
	var dps: Array[float] = []
	for index in maxi(1, nombre):
		var run := campagne(configuration, chapitre, graine + index, options)
		durees.append(float(run["duree"]))
		boss.append(float(run["boss_max"]))
		finals.append(float(run["boss_final"]))
		contacts.append(float(run["contacts_min"]))
		var salles: Array = run["salles"]
		dps.append(float(salles.back()["dps"]))
	return {"nombre": maxi(1, nombre), "graine": graine, "chapitre": chapitre,
		"duree": Simulation.distribution(durees), "boss_max": Simulation.distribution(boss),
		"boss_final": Simulation.distribution(finals), "contacts_min": Simulation.distribution(contacts),
		"dps_final": Simulation.distribution(dps)}

static func _resumer_rencontres(salles: Array[Dictionary], evenements: Array, options: Dictionary) -> Dictionary:
	var duree := 0.0
	var boss_max := 0.0
	var contacts_min := INF
	var mur := 0
	var raison := ""
	for salle: Dictionary in salles:
		duree += float(salle["duree"])
		contacts_min = minf(contacts_min, float(salle["contacts"]))
		if bool(salle["boss"]): boss_max = maxf(boss_max, float(salle["temps_combat"]))
		if mur == 0:
			if float(salle["contacts"]) < float(options.get("contacts_min", CONTACTS_MIN)):
				mur = int(salle["salle"])
				raison = "contacts"
			elif bool(salle["boss"]) and float(salle["temps_combat"]) > float(options.get("boss_limite", BOSS_LIMITE)):
				mur = int(salle["salle"])
				raison = "duree_boss"
	return {"salles": salles, "evenements": evenements, "duree": duree,
		"boss_max": boss_max, "boss_final": salles.back()["temps_combat"], "contacts_min": contacts_min,
		"mur": mur, "raison": raison, "victoire_modele": mur == 0}

static func epreuve(configuration: Dictionary, niveau: int, graine: int, options: Dictionary = {}) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var inventaire: Array[String] = []
	var evenements: Array[Dictionary] = []
	var salles: Array[Dictionary] = []
	for numero in range(1, 6):
		var config := configuration.duplicate(true)
		config["augments"] = inventaire.duplicate()
		var mesure := Modeles.mesurer(config)
		var vague: Array = Vagues.pour_salle(numero, 0, graine, "epreuves")[0]
		var cible := ennemi("epreuves", 0, numero, str(vague[0]), niveau)
		var combat := float(cible["pv"]) / (float(mesure["dps"]) * float(options.get("tir_utile_boss", TIR_UTILE_BOSS)))
		var inv_combat := inventaire.duplicate()
		var choix := 0
		if numero < 5:
			_choisir_annexe(configuration, inventaire, rng, evenements, numero, "", 0,
				str(options.get("politique", "equilibre")))
			choix += 1
		salles.append({"salle": numero, "boss": true, "pv_ennemis": cible["pv"], "elites": 0,
			"dps": mesure["dps"], "pv_effectifs": mesure["pv_effectifs"], "temps_combat": combat,
			"duree": combat + Reglages.APPARITION_BOSS_ANNONCE + choix * SECONDES_CHOIX + (SECONDES_TRANSITION if numero > 1 else 0.0),
			"contacts": float(mesure["pv_effectifs"]) / float(cible["degats"]),
			"inventaire": inv_combat, "inventaire_apres": inventaire.duplicate()})
	return _resumer_rencontres(salles, evenements, options)

static func _choisir_annexe(configuration: Dictionary, inventaire: Array[String], rng: RandomNumberGenerator,
		evenements: Array[Dictionary], salle: int, rarete := "", niveau_run := 0, politique := "equilibre") -> void:
	var offre := DraftLogique.proposer(inventaire, rng, ProgressionAugments.NOMBRE_CHOIX, rarete, niveau_run)
	var choix := ""
	var meilleur := -INF
	for id: String in offre:
		var config := configuration.duplicate(true)
		config["augments"] = inventaire.duplicate()
		config["augments"].append(id)
		var m := Modeles.mesurer(config)
		var poids: Dictionary = Simulation.POLITIQUES[politique]
		var score := float(poids["poids_dps"]) * log(float(m["dps"])) + float(poids["poids_ehp"]) * log(float(m["pv_effectifs"]))
		if score > meilleur:
			meilleur = score
			choix = id
	if not choix.is_empty():
		inventaire.append(choix)
		evenements.append({"salle": salle, "offre": offre, "choix": choix, "niveau": niveau_run,
			"rarete": CatalogueReactifs.par_id(choix).rarete})

static func mine(configuration: Dictionary, niveau: int, graine: int, options: Dictionary = {}) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var raretes_niveaux := ProgressionAugments.tirer_raretes_niveaux(rng,
		bool(options.get("autoriser_legendaire_bonus", false)))
	var inventaire: Array[String] = []
	var evenements: Array[Dictionary] = []
	var ennemis: Array[Dictionary] = []
	var config := configuration.duplicate(true)
	var mesure := Modeles.mesurer(config)
	var temps := 0.0
	var prochain := Reglages.MINE_INTERVALLE_DEBUT
	var xp := 0
	var niveau_run := 0
	var contacts_min := INF
	var mur := false
	for i in Reglages.MINE_PLAFOND_DEBUT:
		ennemis.append(ennemi("mine", 0, 1, Vagues.ennemi_mine(rng, 0.0), niveau, 0.0))
	# Le pas ne simule que le debit de la file, jamais des trajectoires humaines.
	var pas := 0.25
	while temps < Reglages.MINE_DUREE:
		temps = minf(Reglages.MINE_DUREE, temps + pas)
		var progression := temps / Reglages.MINE_DUREE
		var degats := float(mesure["dps"]) * float(options.get("tir_utile", TIR_UTILE)) * pas
		while degats > 0.0 and not ennemis.is_empty():
			var pv := float(ennemis[0]["pv"])
			if degats < pv:
				ennemis[0]["pv"] = pv - degats
				break
			degats -= pv
			xp += maxi(1, roundi(float(ennemis[0]["experience"]) * Mods.facteur_heros(Mods.depuis_l_inventaire(inventaire), "experience_mult")))
			ennemis.pop_front()
			while niveau_run < Reglages.XP_RUN_SEUILS.size() and xp >= int(Reglages.XP_RUN_SEUILS[niveau_run]):
				niveau_run += 1
				_choisir_annexe(configuration, inventaire, rng, evenements, 1,
					ProgressionAugments.rarete_niveau(niveau_run, raretes_niveaux), niveau_run,
					str(options.get("politique", "equilibre")))
				config["augments"] = inventaire.duplicate()
				mesure = Modeles.mesurer(config)
		var contact := float(mesure["pv_effectifs"]) / float(ennemi("mine", 0, 1, "encrier_rampant", niveau, temps)["degats"])
		contacts_min = minf(contacts_min, contact)
		if contact < float(options.get("contacts_min", CONTACTS_MIN)):
			mur = true
			break
		prochain -= pas
		if prochain <= 0.0:
			var plafond := roundi(lerpf(float(Reglages.MINE_PLAFOND_DEBUT), float(Reglages.MINE_PLAFOND_FIN), progression))
			if ennemis.size() < plafond:
				ennemis.append(ennemi("mine", 0, 1, Vagues.ennemi_mine(rng, progression), niveau, temps))
			prochain += lerpf(Reglages.MINE_INTERVALLE_DEBUT, Reglages.MINE_INTERVALLE_FIN, progression)
	var boss := ennemi("mine", 0, 1, Vagues.boss_mine(graine), niveau, Reglages.MINE_DUREE)
	var ttk := float(boss["pv"]) / (float(mesure["dps"]) * float(options.get("tir_utile_boss", TIR_UTILE_BOSS)))
	var victoire := not mur and ttk <= float(options.get("boss_limite", BOSS_LIMITE))
	var duree := temps + evenements.size() * SECONDES_CHOIX
	if not mur: duree += Reglages.APPARITION_BOSS_ANNONCE + minf(ttk, float(options.get("boss_limite", BOSS_LIMITE)))
	return {"salles": [], "evenements": evenements, "duree": duree, "temps_mine": temps,
		"boss_max": ttk, "boss_final": ttk, "contacts_min": contacts_min, "inventaire": inventaire,
		"mur": 0 if victoire else 1, "raison": "contacts" if mur else ("" if victoire else "duree_boss"), "victoire_modele": victoire}

static func parcours(avec_annexes := false, options: Dictionary = {}) -> Dictionary:
	var compte := Compte.new(int(options.get("graine", GRAINE_BASE)))
	var actions: Array[Dictionary] = []
	var lots: Array[Dictionary] = []
	var graine := int(options.get("graine", GRAINE_BASE))
	var options_run := options.duplicate()
	var debut_run := _tenter(compte, "grimoire", 0, 1, graine, options_run, 9)
	debut_run["role"] = "defaite_imposee"
	debut_run["mur_chapitre"] = 1
	actions.append(debut_run)
	var premier_mur := {}
	var chapitre := 0
	while chapitre < Chapitres.nombre():
		var succes := false
		var temps_bloc := 0.0
		for tentative in range(int(options.get("lots_max", LOTS_MAX_PAR_MUR)) + 1 if avec_annexes else 1):
			var action := _tenter(compte, "grimoire", chapitre, 1, graine + actions.size(), options_run)
			action["role"] = "tentative"
			action["mur_chapitre"] = chapitre + 1
			actions.append(action)
			if bool(action["victoire"]):
				succes = true
				break
			if premier_mur.is_empty():
				premier_mur = {"chapitre": chapitre + 1, "salle": action["salle_echec"], "raison": action["raison"],
					"boss_max": action["boss_max"], "contacts_min": action["contacts_min"], "niveau": action["niveau_avant"]}
			if bool(options.get("adapter_au_mur", false)):
				options_run["politique"] = "defensif" if str(action["raison"]) == "contacts" else "equilibre"
			if not avec_annexes or tentative >= int(options.get("lots_max", LOTS_MAX_PAR_MUR)): break
			var avant := Modeles.mesurer(compte.configuration())
			var debut := actions.size()
			var mixte := str(options.get("strategie_lots", "greedy")) == "mixte"
			var modes: Array[String] = []
			modes.assign(["grimoire", "mine", "epreuves"] if mixte else [""])
			var noms: Array[String] = []
			for mode: String in modes:
				var choix := _choisir_lot(compte, graine + actions.size(), options, mode)
				noms.append(str(choix["mode"]))
				for i in (3 if mixte else int(choix["nombre"])):
					var annexe := _tenter(compte, str(choix["mode"]), int(choix["chapitre"]), int(choix["niveau"]), graine + actions.size(), options)
					annexe["role"] = "farm"
					annexe["mur_chapitre"] = chapitre + 1
					actions.append(annexe)
					temps_bloc += float(annexe["duree"])
			var apres := Modeles.mesurer(compte.configuration())
			lots.append({"chapitre": chapitre + 1, "mode": "+".join(noms), "nombre": actions.size() - debut,
				"minutes_bloc": temps_bloc / 60.0, "alerte": temps_bloc / 60.0 > ALERTE_BLOC_MINUTES,
				"dps_avant": avant["dps"], "dps_apres": apres["dps"], "ehp_avant": avant["pv_effectifs"], "ehp_apres": apres["pv_effectifs"]})
		if not succes: break
		chapitre += 1
	var duree := 0.0
	var duree_annexes := 0.0
	for action: Dictionary in actions:
		duree += float(action["duree"])
		if str(action["mode"]) != "grimoire": duree_annexes += float(action["duree"])
	return {"avec_annexes": avec_annexes, "options": options.duplicate(), "actions": actions, "lots": lots,
		"premier_mur": premier_mur, "chapitres_valides": compte.campagne_vaincue, "etat_final": compte.etat(),
		"duree": duree, "duree_annexes": duree_annexes, "termine": compte.campagne_vaincue == Chapitres.nombre(),
		"blocs": blocs(actions, lots)}

static func blocs(actions: Array[Dictionary], lots: Array[Dictionary]) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var chapitres: Array[int] = []
	for lot: Dictionary in lots:
		var chapitre := int(lot["chapitre"])
		if chapitre not in chapitres: chapitres.append(chapitre)
	for chapitre: int in chapitres:
		var bloc := {"chapitre": chapitre, "farm": 0.0, "echecs": 0.0, "victoire": 0.0,
			"mines": 0, "epreuves": 0, "replays": 0, "tentatives_echouees": 0, "resolu": false}
		for action: Dictionary in actions:
			if int(action["mur_chapitre"]) != chapitre: continue
			if str(action["role"]) == "farm":
				bloc["farm"] = float(bloc["farm"]) + float(action["duree"])
				var cle := "mines" if str(action["mode"]) == "mine" else ("epreuves" if str(action["mode"]) == "epreuves" else "replays")
				bloc[cle] = int(bloc[cle]) + 1
			elif not bool(action["victoire"]):
				bloc["echecs"] = float(bloc["echecs"]) + float(action["duree"])
				bloc["tentatives_echouees"] = int(bloc["tentatives_echouees"]) + 1
			else:
				bloc["victoire"] = float(action["duree"])
				bloc["resolu"] = true
		bloc["avant_succes"] = float(bloc["farm"]) + float(bloc["echecs"])
		bloc["alerte"] = float(bloc["farm"]) > ALERTE_BLOC_MINUTES * 60.0
		resultat.append(bloc)
	return resultat

static func _tenter(compte: RefCounted, mode: String, chapitre: int, niveau: int, graine: int,
		options: Dictionary, defaite_imposee := 0) -> Dictionary:
	var config: Dictionary = compte.configuration()
	var avant: Dictionary = compte.etat()
	var mesure := campagne(config, chapitre, graine, options) if mode == "grimoire" else (epreuve(config, niveau, graine, options) if mode == "epreuves" else mine(config, niveau, graine, options))
	var mur := defaite_imposee if defaite_imposee > 0 else int(mesure["mur"])
	var victoire := mur == 0
	var salles_valides := 0
	var boss_valides := 0
	var elites := 0
	var duree := 0.0
	var inventaire: Array = []
	if defaite_imposee == 0 and mur > 0 and str(mesure["raison"]) == "contacts":
		compte.proteger_survie = true
	if bool(options.get("adapter_au_mur", false)) and defaite_imposee == 0 and mur > 0:
		compte.politique = "defensif" if str(mesure["raison"]) == "contacts" else "equilibre"
	if mode == "mine":
		salles_valides = 1 if victoire else 0
		boss_valides = salles_valides
		duree = float(mesure["duree"])
		inventaire = mesure["inventaire"]
	else:
		for salle: Dictionary in mesure["salles"]:
			var numero := int(salle["salle"])
			if numero == mur:
				# Une defaite conventionnelle consomme la moitie de la rencontre,
				# sans valider son XP de compte, son coffre ni ses choix de sortie.
				duree += minf(float(salle["temps_combat"]) * 0.5, float(options.get("boss_limite", BOSS_LIMITE)))
				inventaire = salle["inventaire"]
				break
			duree += float(salle["duree"])
			salles_valides += 1
			if bool(salle["boss"]): boss_valides += 1
			elites += int(salle["elites"])
			inventaire = salle["inventaire_apres"]
	var butin: Dictionary = compte.recevoir(mode, chapitre, salles_valides, boss_valides, victoire, niveau,
		float(mesure.get("temps_mine", 0.0)), inventaire, elites)
	var apres: Dictionary = compte.etat()
	return {"mode": mode, "chapitre": chapitre + 1, "niveau_annexe": niveau, "graine": graine,
		"victoire": victoire, "salles_validees": salles_valides, "boss_valides": boss_valides, "salle_echec": mur,
		"raison": "defaite_imposee" if defaite_imposee > 0 else mesure["raison"], "duree": duree,
		"duree_complete_theorique": mesure["duree"], "boss_max": mesure["boss_max"], "boss_final": mesure["boss_final"],
		"contacts_min": mesure["contacts_min"], "niveau_avant": avant["niveau"], "niveau_apres": apres["niveau"],
		"achats": (apres["achats"] as Array).slice((avant["achats"] as Array).size()), "butin": butin,
		"avant": avant, "apres": apres, "inventaire": inventaire.duplicate()}

static func _choisir_lot(compte: RefCounted, _graine: int, options: Dictionary, imposer := "") -> Dictionary:
	# La selection ne connait pas les offres ni le coffre de la prochaine run.
	var graine := GRAINE_EVALUATION
	var chapitre := maxi(0, int(compte.campagne_vaincue) - 1)
	var config: Dictionary = compte.configuration()
	var taux := _rendements_achats(config)
	var replay := campagne(config, chapitre, graine, options)
	var offre := ButinsRun.offre("grimoire", chapitre, Reglages.SALLES_PAR_RUN, 4, true, 1, compte.rangs_passifs, compte.objets, int(compte.echecs_objets.get(chapitre, 0)))
	var gouttes := (float(offre["gouttes_min"]) + float(offre["gouttes_max"])) * 0.5
	var meilleur := (gouttes * float(taux["gouttes"]) + float(offre["pierres"]) * float(taux["pierres"])) / float(replay["duree"])
	var selection := {"mode": "grimoire", "chapitre": chapitre, "niveau": 1, "nombre": LOT_REPLAYS}
	if imposer == "grimoire": return selection
	if not imposer.is_empty(): meilleur = -INF
	var permanent := Modeles.mesurer(config)
	for niveau in range(1, int(compte.mine_debloquee()) + 1):
		# Le choix du palier utilise une borne sans augment, pas le futur tirage.
		var cible := ennemi("mine", 0, 1, Vagues.boss_mine(graine), niveau, Reglages.MINE_DUREE)
		var ttk := float(cible["pv"]) / (float(permanent["dps"]) * float(options.get("tir_utile_boss", TIR_UTILE_BOSS)))
		var contacts := float(permanent["pv_effectifs"]) / float(ennemi("mine", 0, 1, "encrier_rampant", niveau, Reglages.MINE_DUREE)["degats"])
		if ttk > float(options.get("boss_limite", BOSS_LIMITE)) or contacts < float(options.get("contacts_min", CONTACTS_MIN)): continue
		var gain := float(Reglages.pierres_mine(Mine.palier(niveau))) * float(taux["pierres"]) / (Reglages.MINE_DUREE + ttk)
		if gain > meilleur:
			meilleur = gain
			selection = {"mode": "mine", "chapitre": 0, "niveau": niveau, "nombre": LOT_MINE}
	if imposer == "mine": return selection
	if not imposer.is_empty(): meilleur = -INF
	if not bool(compte.mode_autorise("epreuves", 0, 1)): return selection
	for niveau in range(1, int(compte.epreuve_accessible()) + 1):
		var essai := epreuve(config, niveau, graine, options)
		if not bool(essai["victoire_modele"]): continue
		var gain := 0.0
		var candidats := Epreuves.candidats(niveau, compte.rangs_passifs)
		for id: String in candidats:
			gain += _gain_passif(config, id, mini(Passifs.rang_max(id), int(compte.rangs_passifs.get(id, 0)) + 1), bool(compte.proteger_survie)) / float(candidats.size())
		gain *= Recompenses.chance_garantie(Reglages.EPREUVE_GARANTIE_CAPACITE, int(compte.echecs_passifs.get(niveau, 0)))
		if niveau not in compte.coeurs:
			var avec_coeur := config.duplicate(true)
			avec_coeur["coeurs"] = int(config["coeurs"]) + 1
			gain += (Compte.score(avec_coeur) - Compte.score(config)) * Recompenses.chance_garantie(Reglages.EPREUVE_GARANTIE_COEUR, int(compte.echecs_coeurs.get(niveau, 0)))
		gain /= float(essai["duree"])
		if gain > meilleur:
			meilleur = gain
			selection = {"mode": "epreuves", "chapitre": 0, "niveau": niveau, "nombre": LOT_EPREUVES}
	return selection

static func _rendements_achats(config: Dictionary) -> Dictionary:
	var reference := Compte.score(config)
	var maitrises: Dictionary = config["maitrises"]
	var gouttes := 0.0
	for id: String in ArbreCompetences.NOEUDS:
		var rang := int(maitrises.get(id, 0))
		if rang >= ArbreCompetences.rangs(id) or not ArbreCompetences.prerequis_atteint(id, maitrises): continue
		var essai := config.duplicate(true)
		essai["maitrises"][id] = rang + 1
		gouttes = maxf(gouttes, (Compte.score(essai) - reference) / float(ArbreCompetences.cout(id, rang)))
	var pierres := 0.0
	var cibles := {str(config["arme"]): "arme", str(config["familier"]): "familier"}
	for id: String in (config["bijoux"] as Dictionary).values(): cibles[id] = "bijou"
	for id: String in cibles:
		var type := str(cibles[id])
		var rang := int((config["forge_bijoux"] as Dictionary).get(id, 0)) if type == "bijou" else int(config["forge_" + type])
		if rang >= Reglages.FORGE_NIVEAU_MAX: continue
		var essai := config.duplicate(true)
		if type == "bijou": essai["forge_bijoux"][id] = rang + 1
		else: essai["forge_" + type] = rang + 1
		pierres = maxf(pierres, (Compte.score(essai) - reference) / float(Reglages.cout_forge(rang)))
	return {"gouttes": gouttes, "pierres": pierres}

static func _gain_passif(config: Dictionary, id: String, rang: int, proteger_survie := false) -> float:
	var base := Compte.score(config)
	var meilleur := base
	var places: Array = (config["passifs"] as Dictionary).keys()
	if places.size() < Passifs.EMPLACEMENTS or id in places: places.append(id)
	for remplacer: String in places:
		var essai := config.duplicate(true)
		essai["passifs"].erase(remplacer)
		essai["passifs"][id] = rang
		if proteger_survie and not Compte.survie_preservee(config, essai): continue
		meilleur = maxf(meilleur, Compte.score(essai))
	return meilleur - base
