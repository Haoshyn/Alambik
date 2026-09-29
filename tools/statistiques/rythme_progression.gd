extends RefCounted

const Parcours = preload("res://tools/statistiques/parcours_progression.gd")
const Modeles = Parcours.Modeles
const Simulation = Parcours.Simulation
const NOMBRE_COMPTES := 4
const REPRISES := {13: 1, 20: 2, 27: 3, 33: 5}
static var _cache: Dictionary = {}

# Reproduction prudente du retour du proprietaire : les points d'attribut
# restent non depenses pour ne pas masquer une entree trop dure sans augment.
static func profil_entree() -> Dictionary:
	return {"niveau": 4, "arme": "standard", "forge_arme": 1,
		"maitrises": {"force": 6}, "conditions": false}

static func entree(configuration: Dictionary, chapitre: int, graine: int) -> Dictionary:
	var config := configuration.duplicate(true)
	config["augments"] = []
	var mesure := Modeles.mesurer(config)
	var critique_moyen := 1.0 + float(mesure["critique"]) * (float(mesure["coefficient_critique"]) - 1.0)
	var attaque := float(mesure["dps_heros"]) / (float(mesure["cadence"]) * critique_moyen * float(mesure["impact_moyen"]))
	var attaques: Array[float] = []
	var durees: Array[float] = []
	var contacts: Array[float] = []
	var especes := {}
	# Les quatre premieres salles sont mesurees sans compter sur un tirage utile.
	for salle in range(1, 5):
		for vague: Array in Vagues.pour_salle(salle, chapitre, graine, "grimoire"):
			for id: String in vague:
				var ennemi := Parcours.ennemi("grimoire", chapitre, salle, id)
				if bool(ennemi["boss"]): continue
				var pv := float(ennemi["pv"])
				attaques.append(float(ceili(pv / attaque)))
				durees.append(pv / (float(mesure["dps"]) * Parcours.TIR_UTILE))
				contacts.append(float(mesure["pv_effectifs"]) / float(ennemi["degats"]))
				if salle == 1:
					especes[id] = {"pv": pv, "attaques": ceili(pv / attaque)}
	return {"attaque": attaque, "dps": mesure["dps"], "pv_effectifs": mesure["pv_effectifs"],
		"attaques": Simulation.distribution(attaques), "secondes": Simulation.distribution(durees),
		"contacts": Simulation.distribution(contacts), "especes": especes}

static func achats() -> Array[Dictionary]:
	var config := profil_entree()
	var base := Modeles.mesurer(config)
	var resultat: Array[Dictionary] = []
	for changement: Dictionary in [{"nom": "Arme 1 → 2", "forge": 2},
			{"nom": "Arme 1 → 5", "forge": 5}, {"nom": "Force maîtrisée 6 → 10", "force": 10}]:
		var essai := config.duplicate(true)
		var prix := 0
		if changement.has("forge"):
			var rang := int(changement["forge"])
			essai["forge_arme"] = rang
			for niveau in range(1, rang): prix += Reglages.cout_forge(niveau)
		else:
			var rang := int(changement["force"])
			essai["maitrises"]["force"] = rang
			for niveau in range(6, rang): prix += ArbreCompetences.cout("force", niveau)
		var mesure := Modeles.mesurer(essai)
		resultat.append({"nom": changement["nom"], "prix": prix,
			"tir": mesure["tir_normal"], "gain_tir": float(mesure["tir_normal"]) / float(base["tir_normal"]) - 1.0,
			"gain_dps": float(mesure["dps"]) / float(base["dps"]) - 1.0})
	return resultat

# Ce parcours suppose les victoires pour mesurer l'economie. Les reprises
# utilisent seulement un chapitre deja termine et ses vraies recompenses.
static func rapport(nombre := NOMBRE_COMPTES) -> Dictionary:
	if nombre == NOMBRE_COMPTES and not _cache.is_empty(): return _cache
	var entrees := {}
	var farms := {}
	var budgets: Array[Dictionary] = []
	for index in maxi(1, nombre):
		var graine := Parcours.GRAINE_BASE + index * 1009
		var compte := Parcours.Compte.new(graine)
		var options := {"contacts_min": 0.0, "boss_limite": 1.0e9}
		Parcours._tenter(compte, "grimoire", 0, 1, graine, options, 9)
		for chapitre in Chapitres.nombre():
			var configuration := compte.configuration()
			var entree_chapitre := entree(configuration, chapitre, graine + chapitre)
			var action := Parcours._tenter(compte, "grimoire", chapitre, 1, graine + chapitre + 1, options)
			if not entrees.has(chapitre + 1): entrees[chapitre + 1] = {"attaques": [], "boss": [], "dps": []}
			entrees[chapitre + 1]["attaques"].append(float(entree_chapitre["attaques"]["mediane"]))
			entrees[chapitre + 1]["dps"].append(float(entree_chapitre["dps"]))
			entrees[chapitre + 1]["boss"].append(float(action["boss_final"]))
			if not REPRISES.has(chapitre): continue
			var avant := compte.etat()
			var mesure_avant := Modeles.mesurer(compte.configuration())
			# Le joueur farm ses degats : seuls les prochains choix et achats
			# deviennent offensifs. Ses attributs deja repartis restent identiques.
			compte.politique = "tout_offensif"
			var options_farm := options.duplicate()
			options_farm["politique"] = "tout_offensif"
			for reprise in int(REPRISES[chapitre]):
				Parcours._tenter(compte, "grimoire", chapitre, 1, graine + 100 + chapitre * 7 + reprise, options_farm)
			compte.politique = "equilibre"
			var apres := compte.etat()
			var mesure_apres := Modeles.mesurer(compte.configuration())
			if not farms.has(chapitre + 1): farms[chapitre + 1] = {"gain_dps": [], "gain_survie": []}
			farms[chapitre + 1]["gain_dps"].append(float(mesure_apres["dps"]) / float(mesure_avant["dps"]) - 1.0)
			farms[chapitre + 1]["gain_survie"].append(float(mesure_apres["pv_effectifs"]) / float(mesure_avant["pv_effectifs"]) - 1.0)
			budgets.append({"chapitre": chapitre + 1, "reprises": REPRISES[chapitre], "avant": avant, "apres": apres})
	var resultat := {"nombre": maxi(1, nombre), "profil": entree(profil_entree(), 1, Parcours.GRAINE_BASE),
		"achats": achats(), "entrees": {}, "farm": {}, "budgets": budgets}
	for chapitre: int in entrees:
		resultat["entrees"][chapitre] = _distributions(entrees[chapitre])
	for chapitre: int in farms:
		resultat["farm"][chapitre] = _distributions(farms[chapitre])
	resultat["entrees_renforcees"] = _entrees_renforcees()
	if nombre == NOMBRE_COMPTES: _cache = resultat
	return resultat

static func _entrees_renforcees() -> Dictionary:
	var groupes := {}
	# Le stress campagne seule ignore deux sources permanentes et la Mine.
	# Verifier aussi les comptes qui ont finance leurs annexes face aux murs reels.
	for parcours: Dictionary in Parcours.rapport()["cohorte_comptes"]:
		for action: Dictionary in parcours["actions"]:
			var chapitre := int(action["chapitre"])
			if str(action["mode"]) != "grimoire" or not bool(action["victoire"]) or chapitre not in [14, 21, 28, 35]: continue
			var mesure := entree(action["avant"]["configuration"], chapitre - 1, int(action["graine"]))
			if not groupes.has(chapitre): groupes[chapitre] = {"attaques": [], "secondes": [], "dps": [], "boss": []}
			groupes[chapitre]["attaques"].append(float(mesure["attaques"]["mediane"]))
			groupes[chapitre]["secondes"].append(float(mesure["secondes"]["mediane"]))
			groupes[chapitre]["dps"].append(float(mesure["dps"]))
			groupes[chapitre]["boss"].append(float(action["boss_final"]))
	var resultat := {}
	for chapitre: int in groupes: resultat[chapitre] = _distributions(groupes[chapitre])
	return resultat

static func _distributions(groupe: Dictionary) -> Dictionary:
	var resultat := {}
	for cle: String in groupe:
		var valeurs: Array[float] = []
		valeurs.assign(groupe[cle])
		resultat[cle] = Simulation.distribution(valeurs)
	return resultat
