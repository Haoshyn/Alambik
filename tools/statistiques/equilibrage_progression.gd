extends RefCounted

const Retour = preload("res://tools/statistiques/retour_campagne.gd")
const Parcours = Retour.Parcours
const Modeles = Retour.Modeles
const Simulation = Retour.Simulation
const NOMBRE_COMPTES := 24
const SCENARIOS := ["equilibre", "offensif", "retour_epreuves", "surfarm"]
static var _cache: Dictionary = {}

# Les victoires sont supposees pour isoler la courbe economique. Chaque achat
# reste paye avec les vraies recompenses, sans doter le joueur d'un build maximal.
static func rapport(nombre := NOMBRE_COMPTES) -> Dictionary:
	if nombre == NOMBRE_COMPTES and not _cache.is_empty(): return _cache
	var groupes := {}
	var annexes := {}
	var exemples: Array[Dictionary] = []
	for scenario: String in SCENARIOS:
		groupes[scenario] = {}
		if scenario in ["equilibre", "offensif"]: annexes[scenario] = {}
		if scenario == "offensif": groupes["offensif_deux_defenses"] = {}
		for index in nombre:
			var graine := Parcours.GRAINE_BASE + index * 1009
			var compte := Parcours.Compte.new(graine)
			compte.tout_offensif = scenario != "equilibre"
			compte.politique = "tout_offensif" if compte.tout_offensif else "equilibre"
			var options := {"politique": compte.politique, "contacts_min": 0.0, "boss_limite": 1.0e9}
			var actions: Array[Dictionary] = []
			actions.append(Parcours._tenter(compte, "grimoire", 0, 1, graine, options, 9))
			actions.append(Parcours._tenter(compte, "grimoire", 0, 1, graine + 1, options))
			if annexes.has(scenario):
				_ajouter_annexe(annexes[scenario], "epreuve", Parcours.epreuve(compte.configuration(), 1, graine + 2, options))
			var nombre_epreuves := 6 if scenario == "retour_epreuves" else (5 if scenario == "surfarm" else 0)
			for repetition in nombre_epreuves:
				actions.append(Parcours._tenter(compte, "epreuves", 0, 1, graine + 2 + repetition, options))
			if scenario == "surfarm":
				for repetition in 6:
					actions.append(Parcours._tenter(compte, "grimoire", 0, 1, graine + 20 + repetition, options))
			if index == 0: exemples.append({"scenario": scenario, "actions": actions, "avant_campagne": compte.etat()})
			for chapitre in range(1, Chapitres.nombre()):
				var config := compte.configuration()
				var mesure := Retour.mesurer(config, chapitre, graine + 99 + chapitre, compte.politique)
				_ajouter(groupes[scenario], chapitre + 1, mesure)
				if scenario == "offensif":
					_ajouter(groupes["offensif_deux_defenses"], chapitre + 1,
						Retour.mesurer(config, chapitre, graine + 99 + chapitre, compte.politique, true))
				Parcours._tenter(compte, "grimoire", chapitre, 1, graine + 99 + chapitre, options)
				if chapitre == Reglages.MINE_NIVEAU_DEBLOCAGE - 2 and annexes.has(scenario):
					_ajouter_annexe(annexes[scenario], "mine", Parcours.mine(compte.configuration(), 1, graine + 200, options))
	var resultat := {"nombre": nombre, "scenarios": {}, "annexes": {}, "exemples": exemples, "augments": _augments()}
	for scenario: String in annexes:
		resultat["annexes"][scenario] = {}
		for mode: String in annexes[scenario]:
			var mesure: Dictionary = annexes[scenario][mode]
			resultat["annexes"][scenario][mode] = {"boss": _distribution(mesure["boss"]), "contacts": _distribution(mesure["contacts"])}
	for scenario: String in groupes:
		var chapitres := {}
		for chapitre: int in groupes[scenario]:
			var donnees: Dictionary = groupes[scenario][chapitre]
			var ligne := {}
			for cle: String in donnees: ligne[cle] = _distribution(donnees[cle])
			chapitres[chapitre] = ligne
		resultat["scenarios"][scenario] = chapitres
	if nombre == NOMBRE_COMPTES: _cache = resultat
	return resultat

static func _ajouter_annexe(groupe: Dictionary, mode: String, mesure: Dictionary) -> void:
	if not groupe.has(mode): groupe[mode] = {"boss": [], "contacts": []}
	groupe[mode]["boss"].append(float(mesure["boss_final"]))
	groupe[mode]["contacts"].append(float(mesure["contacts_min"]))

static func _ajouter(groupe: Dictionary, chapitre: int, mesure: Dictionary) -> void:
	if not groupe.has(chapitre):
		groupe[chapitre] = {"un_projectile": [], "une_attaque": [], "avec_critiques": [],
			"attaques": [], "contacts": [], "contacts_min": [], "boss": [],
			"rares_projectile": [], "rares_attaque": [], "rares_critique": [], "rares_coups": []}
	var ligne: Dictionary = groupe[chapitre]
	var nombre := float(mesure["monstres"])
	ligne["un_projectile"].append(float(mesure["un_projectile"]) / nombre)
	ligne["une_attaque"].append(float(mesure["une_attaque"]) / nombre)
	ligne["avec_critiques"].append(float(mesure["une_attaque_critique"]) / nombre)
	ligne["attaques"].append(float(_distribution(mesure["attaques"])["mediane"]))
	ligne["contacts"].append(float(_distribution(mesure["contacts"])["mediane"]))
	ligne["contacts_min"].append(float(mesure["contacts_min"]))
	ligne["boss"].append(float(mesure["boss_secondes"].back()))
	var nombre_rares := float(maxi(1, int(mesure["monstres_rares"])))
	ligne["rares_projectile"].append(float(mesure["projectiles_rares"]) / nombre_rares)
	ligne["rares_attaque"].append(float(mesure["attaques_rares"]) / nombre_rares)
	ligne["rares_critique"].append(float(mesure["critiques_rares"]) / nombre_rares)
	ligne["rares_coups"].append(float(_distribution(mesure["coups_rares"])["mediane"]))

static func _distribution(valeurs: Array) -> Dictionary:
	var nombres: Array[float] = []
	nombres.assign(valeurs)
	return Simulation.distribution(nombres)

static func _augments() -> Dictionary:
	var resultat := {}
	for nom: String in ["debut", "complet"]:
		var config := {} if nom == "debut" else Modeles.complet()
		var base := Modeles.mesurer(config)
		var mesures := {}
		for id: String in ["cadence_febrile", "sceau_ruine", "sceau_garde", "noyau_pesant", "peau_de_pierre", "frappe_lourde", "egide"]:
			config["augments"] = [id]
			var mesure := Modeles.mesurer(config)
			mesures[id] = {"dps": float(mesure["dps_heros"]) / float(base["dps_heros"]),
				"survie": float(mesure["pv_effectifs"]) / float(base["pv_effectifs"])}
		config["augments"] = ["egide", "peau_de_pierre"]
		var deux := Modeles.mesurer(config)
		mesures["deux_defenses"] = {"survie": float(deux["pv_effectifs"]) / float(base["pv_effectifs"])}
		resultat[nom] = mesures
	return resultat
