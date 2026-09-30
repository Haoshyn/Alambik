extends RefCounted

const Parcours = preload("res://tools/statistiques/parcours_progression.gd")
const Modeles = preload("res://tools/statistiques/modeles.gd")
const Simulation = preload("res://tools/statistiques/simulation_augments.gd")
const NOMBRE_COMPTES := 24
const CHAPITRES := [1, 2, 3, 6]
static var _rapport_cache: Dictionary = {}

# Six repetitions constituent un sur-farm volontaire. Les deux entrees du
# monde suivant conservent une avance ; le milieu du monde reprend sa marge.
static func limite_retour_farm(chapitre: int) -> float:
	if chapitre <= Chapitres.CHAPITRES_PAR_MONDE: return 0.20
	if chapitre <= Chapitres.CHAPITRES_PAR_MONDE + 2: return 0.25
	return 0.05

# La victoire annoncee par le scenario est supposee, jamais deduite d'un taux
# de survie. Les recompenses restent celles des vraies salles validees.
static func scenario(graine: int, epreuves_successives: bool) -> Dictionary:
	var compte := Parcours.Compte.new(graine)
	compte.tout_offensif = true
	compte.politique = "tout_offensif"
	var options := {"politique": "tout_offensif", "contacts_min": 0.0, "boss_limite": 1.0e9}
	var actions: Array[Dictionary] = []
	actions.append(Parcours._tenter(compte, "grimoire", 0, 1, graine, options, 9))
	actions.append(Parcours._tenter(compte, "grimoire", 0, 1, graine + 1, options))
	var configurations := {0: compte.configuration()}
	var etats := {0: compte.etat()}
	for index in 6:
		var niveau := index + 1 if epreuves_successives else 1
		if not compte.mode_autorise("epreuves", 0, niveau):
			break
		actions.append(Parcours._tenter(compte, "epreuves", 0, niveau, graine + 2 + index, options))
		if index >= 4:
			configurations[index + 1] = compte.configuration()
			etats[index + 1] = compte.etat()
	var suite: Array[Dictionary] = []
	if configurations.has(6):
		# Un joueur offensif accepte sa fragilite : ce second parcours cherche
		# seulement le premier boss trop long, avec achats entre les chapitres.
		for chapitre in range(1, Chapitres.nombre()):
			var essai := Parcours._tenter(compte, "grimoire", chapitre, 1, graine + 99 + chapitre,
				{"politique": "tout_offensif", "contacts_min": 0.0})
			suite.append(essai)
			if not bool(essai["victoire"]): break
	return {"graine": graine, "successives": epreuves_successives, "actions": actions,
		"configurations": configurations, "etats": etats, "suite": suite}

static func mesurer(configuration: Dictionary, chapitre: int, graine: int, politique := "tout_offensif", deux_defenses := false) -> Dictionary:
	var run := Simulation.une_run(configuration, politique, graine, false)
	var resultat := {"monstres": 0, "un_projectile": 0, "une_attaque": 0,
		"une_attaque_critique": 0.0, "attaques": [], "contacts": [],
		"monstres_rares": 0, "projectiles_rares": 0,
		"attaques_rares": 0, "critiques_rares": 0.0, "coups_rares": [],
		"premiere_salle": [], "boss_secondes": [], "boss_attaques": [], "contacts_min": INF}
	for etat: Dictionary in run["salles"]:
		var salle := int(etat["salle"])
		var mesure: Dictionary = etat["combat"]
		if deux_defenses:
			# Stress a budget egal : remplacer le legendaire et un epique par les
			# deux defenses les plus fortes, seulement apres leurs niveaux reels.
			var config := configuration.duplicate(true)
			config["augments"] = inventaire_deux_defenses(etat["inventaire_combat"])
			mesure = Modeles.mesurer(config)
		var critique_moyen := 1.0 + float(mesure["critique"]) * (float(mesure["coefficient_critique"]) - 1.0)
		# Les effets periodiques ont leur propre temps ; ils ne font pas partie
		# d'une attaque instantanee du heros.
		var attaque_normale := float(mesure["dps_frontal"]) / (float(mesure["cadence"]) * critique_moyen * float(mesure["impact_moyen"]))
		var avec_puissance_majeure := false
		for id: String in etat["inventaire_combat"]:
			if CatalogueReactifs.par_id(id).rarete in [Reactif.EPIQUE, Reactif.LEGENDAIRE]: avec_puissance_majeure = true
		var vagues := Vagues.pour_salle(salle, chapitre, graine, "grimoire")
		for vague: Array in vagues:
			for id: String in vague:
				var ennemi := Parcours.ennemi("grimoire", chapitre, salle, id)
				var pv := float(ennemi["pv"])
				if bool(ennemi["boss"]):
					resultat["boss_secondes"].append(pv / (float(mesure["dps"]) * Parcours.TIR_UTILE_BOSS))
					resultat["boss_attaques"].append(ceili(pv / attaque_normale))
					continue
				resultat["monstres"] = int(resultat["monstres"]) + 1
				if pv <= float(mesure["tir_normal"]): resultat["un_projectile"] = int(resultat["un_projectile"]) + 1
				if pv <= attaque_normale: resultat["une_attaque"] = int(resultat["une_attaque"]) + 1
				resultat["une_attaque_critique"] = float(resultat["une_attaque_critique"]) + probabilite_une_attaque(pv, attaque_normale, mesure)
				resultat["attaques"].append(float(ceili(pv / attaque_normale)))
				if not avec_puissance_majeure:
					resultat["monstres_rares"] = int(resultat["monstres_rares"]) + 1
					if pv <= float(mesure["tir_normal"]): resultat["projectiles_rares"] = int(resultat["projectiles_rares"]) + 1
					if pv <= attaque_normale: resultat["attaques_rares"] = int(resultat["attaques_rares"]) + 1
					resultat["critiques_rares"] = float(resultat["critiques_rares"]) + probabilite_une_attaque(pv, attaque_normale, mesure)
					resultat["coups_rares"].append(float(ceili(pv / attaque_normale)))
				resultat["contacts"].append(float(mesure["pv_effectifs"]) / float(ennemi["degats"]))
				resultat["contacts_min"] = minf(float(resultat["contacts_min"]), float(mesure["pv_effectifs"]) / float(ennemi["degats"]))
				if salle == 1:
					resultat["premiere_salle"].append({"id": id, "pv": pv, "tir": mesure["tir_normal"],
						"projectiles": ceili(pv / float(mesure["tir_normal"])), "contacts": float(mesure["pv_effectifs"]) / float(ennemi["degats"])})
	return resultat

static func inventaire_deux_defenses(inventaire: Array) -> Array[String]:
	var resultat: Array[String] = []
	var epique_remplace := "peau_de_pierre" in inventaire
	var legendaire_remplace := "egide" in inventaire
	for id: String in inventaire:
		var choix := id
		var rarete := CatalogueReactifs.par_id(id).rarete
		if rarete == Reactif.LEGENDAIRE and not legendaire_remplace:
			choix = "egide"
			legendaire_remplace = true
		elif rarete == Reactif.EPIQUE and not epique_remplace:
			choix = "peau_de_pierre"
			epique_remplace = true
		resultat.append(choix)
	return resultat

static func probabilite_une_attaque(pv: float, attaque: float, mesure: Dictionary) -> float:
	# Chaque salve tire un critique commun a ses projectiles frontaux dans run.gd.
	# Les salves sont independantes ; la somme binomiale conserve cette correlation.
	var salves := int(mesure["salves"])
	var chance := float(mesure["critique"])
	var multiplicateur := float(mesure["coefficient_critique"])
	var probabilite := 0.0
	var combinaisons := 1.0
	for critiques in range(salves + 1):
		if attaque * (1.0 + float(critiques) / float(salves) * (multiplicateur - 1.0)) >= pv:
			probabilite += combinaisons * pow(chance, critiques) * pow(1.0 - chance, salves - critiques)
		combinaisons *= float(salves - critiques) / float(critiques + 1)
	return probabilite

static func rapport(nombre := NOMBRE_COMPTES) -> Dictionary:
	if nombre == NOMBRE_COMPTES and not _rapport_cache.is_empty(): return _rapport_cache
	var cas: Array[Dictionary] = []
	var exemples: Array[Dictionary] = []
	var murs_dps: Array[float] = []
	var murs_observes: Array[float] = []
	var comptes_sans_mur := 0
	var comptes_sans_contact_mortel := 0
	var contacts_mortels: Array[float] = []
	var progression := {}
	for successives: bool in [false, true]:
		var groupes := {}
		for index in nombre:
			var graine := Parcours.GRAINE_BASE + index * 1009
			var compte := scenario(graine, successives)
			if index == 0: exemples.append(compte)
			if not successives:
				var suite: Array = compte["suite"]
				var dernier: Dictionary = suite.back()
				murs_dps.append(float(Chapitres.nombre() + 1 if bool(dernier["victoire"]) else int(dernier["chapitre"])))
				if bool(dernier["victoire"]): comptes_sans_mur += 1
				else: murs_observes.append(float(dernier["chapitre"]))
				var premier_contact_mortel := Chapitres.nombre() + 1
				for action: Dictionary in suite:
					if float(action["contacts_min"]) <= 1.0:
						premier_contact_mortel = mini(premier_contact_mortel, int(action["chapitre"]))
					var chapitre := int(action["chapitre"])
					if chapitre > 8: continue
					if not progression.has(chapitre): progression[chapitre] = []
					progression[chapitre].append(mesurer(action["avant"]["configuration"], chapitre - 1, int(action["graine"])))
				if premier_contact_mortel <= Chapitres.nombre(): contacts_mortels.append(float(premier_contact_mortel))
				else: comptes_sans_contact_mortel += 1
			var configurations: Dictionary = compte["configurations"]
			for nombre_epreuves: int in configurations:
				var configuration: Dictionary = configurations[nombre_epreuves]
				for chapitre: int in CHAPITRES:
					var cle := "%d/%d" % [nombre_epreuves, chapitre]
					if not groupes.has(cle): groupes[cle] = []
					var mesure := mesurer(configuration, chapitre, graine + 100)
					mesure["permanent"] = Modeles.mesurer(configuration)
					mesure["niveau_compte"] = int(configuration["niveau"])
					groupes[cle].append(mesure)
		for cle: String in groupes:
			var mesures: Array = groupes[cle]
			var taux_projectile: Array[float] = []
			var taux_attaque: Array[float] = []
			var boss: Array[float] = []
			var tirs: Array[float] = []
			var dps: Array[float] = []
			var contacts: Array[float] = []
			for mesure: Dictionary in mesures:
				taux_projectile.append(float(mesure["un_projectile"]) / float(mesure["monstres"]))
				taux_attaque.append(float(mesure["une_attaque"]) / float(mesure["monstres"]))
				boss.append(float(mesure["boss_secondes"].back()))
				dps.append(float(mesure["permanent"]["dps"]))
				contacts.append(float(mesure["contacts_min"]))
				for premier: Dictionary in mesure["premiere_salle"]: tirs.append(float(premier["projectiles"]))
			cas.append({"successives": successives, "epreuves": int(cle.get_slice("/", 0)),
				"chapitre": int(cle.get_slice("/", 1)) + 1, "nombre": mesures.size(),
				"un_projectile": Simulation.distribution(taux_projectile), "une_attaque": Simulation.distribution(taux_attaque),
				"boss_final": Simulation.distribution(boss), "tirs_entree": Simulation.distribution(tirs),
				"dps_permanent": Simulation.distribution(dps), "contacts_min": Simulation.distribution(contacts)})
	var resultat := {"nombre": nombre, "cas": cas, "exemples": exemples,
		"premier_boss_trop_long": Simulation.distribution(murs_dps),
		"comptes_sans_mur_dps": comptes_sans_mur,
		"murs_dps_observes": Simulation.distribution(murs_observes) if not murs_observes.is_empty() else {},
		"premier_contact_mortel": Simulation.distribution(contacts_mortels) if not contacts_mortels.is_empty() else {},
		"comptes_sans_contact_mortel": comptes_sans_contact_mortel, "progression": {}}
	for chapitre: int in progression:
		var taux: Array[float] = []
		var taux_rares: Array[float] = []
		var boss: Array[float] = []
		var contacts: Array[float] = []
		for mesure: Dictionary in progression[chapitre]:
			taux.append(float(mesure["une_attaque"]) / float(mesure["monstres"]))
			taux_rares.append(float(mesure["attaques_rares"]) / float(maxi(1, int(mesure["monstres_rares"]))))
			boss.append(float(mesure["boss_secondes"].back()))
			contacts.append(float(mesure["contacts_min"]))
		resultat["progression"][chapitre] = {"une_attaque": Simulation.distribution(taux),
			"rares_attaque": Simulation.distribution(taux_rares),
			"boss_final": Simulation.distribution(boss), "contacts_min": Simulation.distribution(contacts)}
	if nombre == NOMBRE_COMPTES: _rapport_cache = resultat
	return resultat
