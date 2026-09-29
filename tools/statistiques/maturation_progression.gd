extends RefCounted

const Parcours = preload("res://tools/statistiques/parcours_progression.gd")
const Simulation = Parcours.Simulation
const NOMBRE_COMPTES := 2
const ETAPES := [0.50, 0.75, 1.0]
const FAMILLES := ["attributs", "equipement", "maitrises", "passifs", "coeurs"]
const STRATEGIES := ["campagne", "mixte"]
const CYCLES_MAX := 160
static var _cache: Dictionary = {}

# Comparer les plafonds sur un meme compte, sans continuer a farmer une monnaie
# dont tous les achats sont termines. Les victoires restent une hypothese.
static func rapport(nombre := NOMBRE_COMPTES) -> Dictionary:
	if nombre == NOMBRE_COMPTES and not _cache.is_empty(): return _cache
	var comptes: Array[Dictionary] = []
	var strategies := {}
	for strategie: String in STRATEGIES:
		var etapes := {}
		for famille: String in FAMILLES:
			etapes[famille] = {"50": [], "75": [], "100": []}
		for index in maxi(1, nombre):
			var resultat := parcours(strategie, Parcours.GRAINE_BASE + index * 1009)
			comptes.append(resultat)
			for famille: String in FAMILLES:
				for etape: String in etapes[famille]:
					if resultat["etapes"][famille].has(etape):
						etapes[famille][etape].append(float(resultat["etapes"][famille][etape]["secondes"]))
		var distributions := {}
		for famille: String in FAMILLES:
			distributions[famille] = {}
			for etape: String in etapes[famille]:
				var temps: Array[float] = []
				temps.assign(etapes[famille][etape])
				var distribution := {"mesures": temps.size()}
				if not temps.is_empty(): distribution.merge(Simulation.distribution(temps))
				distributions[famille][etape] = distribution
		strategies[strategie] = distributions
	var resultat := {"nombre": nombre, "comptes": comptes, "strategies": strategies, "couts": couts_totaux()}
	if nombre == NOMBRE_COMPTES: _cache = resultat
	return resultat

static func couts_totaux() -> Dictionary:
	var xp := 0
	var maitrises := 0
	var forge := 0
	for niveau in range(1, Personnage.NIVEAU_MAX): xp += Reglages.experience_compte_requise(niveau)
	for id: String in ArbreCompetences.NOEUDS: maitrises += ArbreCompetences.cout_total(id)
	for niveau in Reglages.FORGE_NIVEAU_MAX: forge += Reglages.cout_forge(niveau)
	return {"xp": xp, "gouttes": maitrises, "pierres": forge * 5,
		"rangs_passifs": Passifs.CATALOGUE.size() * Passifs.RANG_MAX, "coeurs": Epreuves.nombre()}

static func progression(compte: RefCounted) -> Dictionary:
	var couts := couts_totaux()
	var xp := int(compte.xp)
	for niveau in range(1, compte.niveau): xp += Reglages.experience_compte_requise(niveau)
	var maitrises := 0
	for id: String in compte.maitrises:
		for rang in int(compte.maitrises[id]): maitrises += ArbreCompetences.cout(id, rang)
	var config: Dictionary = compte.configuration()
	var ids: Array[String] = [str(config["arme"]), str(config["familier"])]
	for id: String in config["bijoux"].values(): ids.append(id)
	var forge := 0
	for id: String in ids:
		for niveau in int(compte.forge.get(id, 0)): forge += Reglages.cout_forge(niveau)
	var passifs := 0
	for rang: int in compte.rangs_passifs.values(): passifs += rang
	return {"attributs": minf(1.0, float(xp) / float(couts["xp"])),
		"equipement": float(forge) / float(couts["pierres"]),
		"maitrises": float(maitrises) / float(couts["gouttes"]),
		"passifs": float(passifs) / float(couts["rangs_passifs"]),
		"coeurs": float(compte.coeurs.size()) / float(couts["coeurs"])}

static func parcours(strategie: String, graine: int) -> Dictionary:
	var compte := Parcours.Compte.new(graine)
	var etapes := {}
	for famille: String in FAMILLES: etapes[famille] = {}
	var suivi := {"secondes": 0.0, "actions": 0, "modes": {"grimoire": 0, "mine": 0, "epreuves": 0},
		"etapes": etapes, "achats": 0, "victoires": true}
	_action(compte, suivi, "grimoire", 0, 1, graine, 9)
	for chapitre in Chapitres.nombre():
		_action(compte, suivi, "grimoire", chapitre, 1, graine)
		if strategie != "mixte" or (chapitre + 1) % 3 != 0: continue
		if compte.mine_debloquee() > 0: _action(compte, suivi, "mine", 0, compte.mine_debloquee(), graine)
		var epreuve := _epreuve(compte)
		if epreuve > 0: _action(compte, suivi, "epreuves", 0, epreuve, graine)
	var campagne: Dictionary = progression(compte)
	for cycle in CYCLES_MAX:
		if _termine(suivi): break
		# Deux replays, une Mine et trois Epreuves si ces ressources manquent.
		# L'XP reste financable en campagne apres les autres achats.
		for reprise in 2:
			var avance := progression(compte)
			if float(avance["maitrises"]) < 1.0 or (compte.niveau < Personnage.NIVEAU_MAX and _epreuve(compte) == 0):
				_action(compte, suivi, "grimoire", Chapitres.nombre() - 1, 1, graine)
		if float(progression(compte)["equipement"]) < 1.0:
			_action(compte, suivi, "mine", 0, compte.mine_debloquee(), graine)
		for reprise in 3:
			var epreuve := _epreuve(compte)
			if epreuve > 0: _action(compte, suivi, "epreuves", 0, epreuve, graine)
	var final := compte.etat()
	return {"strategie": strategie, "graine": graine, "termine": _termine(suivi),
		"secondes": suivi["secondes"], "modes": suivi["modes"], "etapes": suivi["etapes"],
		"campagne": campagne, "etat_final": final, "achats": suivi["achats"], "victoires": suivi["victoires"]}

static func _epreuve(compte: RefCounted) -> int:
	for niveau in range(compte.epreuve_accessible(), 0, -1):
		if niveau not in compte.coeurs or not Epreuves.candidats(niveau, compte.rangs_passifs).is_empty(): return niveau
	return 0

static func _termine(suivi: Dictionary) -> bool:
	for famille: String in FAMILLES:
		if not suivi["etapes"][famille].has("100"): return false
	return true

static func _action(compte: RefCounted, suivi: Dictionary, mode: String, chapitre: int,
		niveau: int, graine: int, defaite := 0) -> void:
	var action := Parcours._tenter(compte, mode, chapitre, niveau, graine + int(suivi["actions"]),
		{"contacts_min": 0.0, "boss_limite": 1.0e9}, defaite)
	suivi["secondes"] = float(suivi["secondes"]) + float(action["duree"])
	suivi["actions"] = int(suivi["actions"]) + 1
	suivi["modes"][mode] = int(suivi["modes"][mode]) + 1
	suivi["achats"] = int(suivi["achats"]) + (action["achats"] as Array).size()
	if defaite == 0: suivi["victoires"] = bool(suivi["victoires"]) and bool(action["victoire"])
	var avance := progression(compte)
	for famille: String in FAMILLES:
		for seuil: float in ETAPES:
			var cle := str(roundi(seuil * 100.0))
			if float(avance[famille]) < seuil or suivi["etapes"][famille].has(cle): continue
			# Les statistiques des passifs continuent de croitre jusqu'au niveau
			# maximum : une collection complete seule n'est pas leur plafond.
			if famille == "passifs" and seuil == 1.0 and compte.niveau < Personnage.NIVEAU_MAX: continue
			suivi["etapes"][famille][cle] = {"secondes": suivi["secondes"], "actions": suivi["actions"],
				"campagne": compte.campagne_vaincue, "niveau": compte.niveau, "modes": suivi["modes"].duplicate()}
