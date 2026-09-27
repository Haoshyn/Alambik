extends RefCounted

const Modeles = preload("res://tools/statistiques/modeles.gd")
const Simulation = preload("res://tools/statistiques/simulation_augments.gd")
const REPARTITION := {"force": 40, "vitalite": 50, "agilite": 25, "intelligence": 30}

# Un compte fictif paie chaque achat. Les anciens objets conservent leur forge :
# changer de modele ne transfere ni pierres ni rangs gratuitement.
var rng := RandomNumberGenerator.new()
var niveau := 1
var xp := 0
var gouttes := 0
var pierres := 0
var campagne_vaincue := 0
var epreuve_debloquee := 1
var objets: Array[String] = []
var coeurs: Array[int] = []
var rangs_passifs := {}
var maitrises := {}
var forge := {}
var equipement := {"arme": "standard", "familier": "homoncule_encre", "bijoux": {}, "passifs": {}}
var echecs_objets := {}
var echecs_passifs := {}
var echecs_coeurs := {}
var recus := {"gouttes": 0, "pierres": 0, "xp": 0}
var depenses := {"gouttes": 0, "pierres": 0}
var achats: Array[Dictionary] = []
var politique := "equilibre"
var proteger_survie := false
var tout_offensif := false

func _init(graine := 20260927) -> void:
	rng.seed = graine

func attributs() -> Dictionary:
	var resultat := {}
	var points := Personnage.points_totaux(niveau)
	if tout_offensif:
		return {"force": points}
	for i in points:
		var meilleur := "force"
		var retard_max := -INF
		for id: String in REPARTITION:
			var retard := float(REPARTITION[id]) * float(i + 1) / 145.0 - float(resultat.get(id, 0))
			if retard > retard_max:
				meilleur = id
				retard_max = retard
		resultat[meilleur] = int(resultat.get(meilleur, 0)) + 1
	return resultat

func configuration() -> Dictionary:
	var arme := str(equipement["arme"])
	var familier := str(equipement["familier"])
	return {"niveau": niveau, "attributs": attributs(), "arme": arme,
		"forge_arme": int(forge.get(arme, 0)), "familier": familier,
		"forge_familier": int(forge.get(familier, 0)), "bijoux": equipement["bijoux"].duplicate(),
		"forge_bijoux": forge.duplicate(), "maitrises": maitrises.duplicate(),
		"passifs": equipement["passifs"].duplicate(), "coeurs": coeurs.size(), "conditions": false,
		"politique_compte": politique, "tout_offensif": tout_offensif}

func recevoir(mode: String, chapitre: int, salles: int, boss: int, victoire: bool,
		niveau_annexe := 1, duree_mine := Reglages.MINE_DUREE, inventaire: Array = [], elites := 0) -> Dictionary:
	assert(mode_autorise(mode, chapitre, niveau_annexe), "Recompense d'un mode verrouille")
	assert(not victoire or salles == (Reglages.SALLES_PAR_RUN if mode == "grimoire" else (5 if mode == "epreuves" else 1)),
		"Victoire sans toutes les salles validees")
	var offre := ButinsRun.offre(mode, chapitre, salles, boss, victoire, niveau_annexe,
		rangs_passifs, objets, int(echecs_objets.get(chapitre, 0)),
		int(echecs_passifs.get(niveau_annexe, 0)), Mine.palier(niveau_annexe), duree_mine,
		niveau_annexe in coeurs, int(echecs_coeurs.get(niveau_annexe, 0)))
	if mode == "grimoire":
		var bonus_elites := RangsEnnemis.bonus_gouttes(chapitre, elites)
		offre["gouttes_min"] = int(offre["gouttes_min"]) + bonus_elites
		offre["gouttes_max"] = int(offre["gouttes_max"]) + bonus_elites
	var butin := ButinsRun.tirer(offre, rng)
	var config := configuration()
	var bonus := Modeles.bonus_equipement(config)
	var attrs := Personnage.bonus(config["attributs"])
	var passifs: Dictionary = config["passifs"]
	var brut := roundi(float(butin["gouttes"]) * ArbreCompetences.multiplicateur_coffre(maitrises)
		* Mods.facteur_heros(Mods.depuis_l_inventaire(inventaire), "gouttes_mult"))
	var gain_gouttes := roundi(float(brut) * ArbreCompetences.multiplicateur_collecte(maitrises)
		* (1.0 + float(bonus.get("butin", 0.0)) + float(attrs["butin"]))
		* Passifs.multiplicateur_gouttes(passifs))
	var gain_pierres := roundi(float(butin["pierres"]) * ArbreCompetences.multiplicateur_pierres(maitrises))
	var gain_xp := roundi(float(butin["xp"]) * ArbreCompetences.multiplicateur_experience(maitrises)
		* Passifs.multiplicateur_experience(passifs)) if niveau < Personnage.NIVEAU_MAX else 0
	gouttes += gain_gouttes
	pierres += gain_pierres
	xp += gain_xp
	for cle: String in recus:
		recus[cle] = int(recus[cle]) + int({"gouttes": gain_gouttes, "pierres": gain_pierres, "xp": gain_xp}[cle])
	while niveau < Personnage.NIVEAU_MAX and xp >= Reglages.experience_compte_requise(niveau):
		xp -= Reglages.experience_compte_requise(niveau)
		niveau += 1
	if niveau == Personnage.NIVEAU_MAX: xp = 0
	var objet := str(butin["objet"])
	if not objet.is_empty() and objet not in objets: objets.append(objet)
	var passif := str(butin["passif"])
	if not passif.is_empty(): rangs_passifs[passif] = mini(Passifs.rang_max(passif), int(rangs_passifs.get(passif, 0)) + 1)
	if mode == "grimoire" and victoire:
		campagne_vaincue = maxi(campagne_vaincue, chapitre + 1)
		if not (offre["objets"] as Array).is_empty():
			echecs_objets[chapitre] = int(echecs_objets.get(chapitre, 0)) + 1 if objet.is_empty() else 0
	if mode == "epreuves" and victoire:
		epreuve_debloquee = maxi(epreuve_debloquee, mini(Epreuves.nombre(), niveau_annexe + 1))
		if not (offre["passifs"] as Array).is_empty():
			echecs_passifs[niveau_annexe] = int(echecs_passifs.get(niveau_annexe, 0)) + 1 if passif.is_empty() else 0
		if niveau_annexe not in coeurs:
			if bool(butin["coeur_mana"]):
				coeurs.append(niveau_annexe)
			else:
				echecs_coeurs[niveau_annexe] = int(echecs_coeurs.get(niveau_annexe, 0)) + 1
	acheter()
	return {"gouttes": gain_gouttes, "pierres": gain_pierres, "xp": gain_xp,
		"objet": objet, "passif": passif, "coeur": bool(butin["coeur_mana"]), "offre": offre, "tirage": butin}

func niveau_campagne() -> int:
	return mini(Chapitres.nombre(), campagne_vaincue + 1)

func mine_debloquee() -> int:
	return clampi(niveau_campagne() - Reglages.MINE_NIVEAU_DEBLOCAGE + 1, 0, Mine.nombre())

func epreuve_accessible() -> int:
	return Epreuves.niveau_accessible(niveau_campagne(), epreuve_debloquee)

func mode_autorise(mode: String, chapitre := 0, niveau_annexe := 1) -> bool:
	if mode == "grimoire":
		return chapitre >= 0 and chapitre < niveau_campagne()
	if mode == "epreuves":
		return niveau_annexe >= 1 and niveau_annexe <= epreuve_accessible()
	return mode == "mine" and niveau_annexe >= 1 and niveau_annexe <= mine_debloquee()

func etat() -> Dictionary:
	return {"niveau": niveau, "xp": xp, "gouttes": gouttes, "pierres": pierres,
		"campagne_vaincue": campagne_vaincue, "epreuve_debloquee": epreuve_debloquee,
		"objets": objets.duplicate(), "coeurs": coeurs.duplicate(), "passifs": rangs_passifs.duplicate(),
		"recus": recus.duplicate(), "depenses": depenses.duplicate(), "configuration": configuration(),
		"achats": achats.duplicate(true), "proteger_survie": proteger_survie}

func acheter() -> void:
	_equiper()
	_acheter_maitrises()
	_acheter_forge()
	_equiper()

static func score(config: Dictionary) -> float:
	var m := Modeles.mesurer(config)
	if bool(config.get("tout_offensif", false)):
		return log(float(m["dps"]))
	var poids: Dictionary = Simulation.POLITIQUES[str(config.get("politique_compte", "equilibre"))]
	var rangs: Dictionary = config.get("maitrises", {})
	var passifs: Dictionary = config.get("passifs", {})
	# Les ressources et soins ont un poids explicite, pas des degats inventes.
	return float(poids["poids_dps"]) * log(float(m["dps"])) + float(poids["poids_ehp"]) * log(float(m["pv_effectifs"])) \
		+ 0.08 * log(ArbreCompetences.multiplicateur_collecte(rangs)) \
		+ 0.08 * log(ArbreCompetences.multiplicateur_coffre(rangs) * Passifs.multiplicateur_gouttes(passifs)) \
		+ 0.08 * log(ArbreCompetences.multiplicateur_experience(rangs)) \
		+ 0.08 * log(Passifs.multiplicateur_experience(passifs)) \
		+ 0.08 * log(ArbreCompetences.multiplicateur_pierres(rangs)) \
		+ 0.04 * log(ArbreCompetences.multiplicateur_soin(rangs)) \
		+ 0.01 * ArbreCompetences.nombre_rerolls(rangs) \
		+ Passifs.soin_par_salle(passifs) + Passifs.soin_moisson(passifs)

func _equiper() -> void:
	var config := configuration()
	var niveau_campagne := mini(Chapitres.nombre(), campagne_vaincue + 1)
	for type: String in ["arme", "familier"]:
		var disponibles: Array[String] = CatalogueProjectiles.disponibles(niveau_campagne) if type == "arme" else CatalogueFamiliers.disponibles(niveau_campagne)
		var meilleur := score(config)
		for id: String in disponibles:
			var essai := config.duplicate(true)
			essai[type] = id
			essai["forge_" + type] = int(forge.get(id, 0))
			if not _remplacement_autorise(config, essai): continue
			var gain := score(essai)
			if gain > meilleur:
				meilleur = gain
				equipement[type] = id
				config = essai
	for slot: String in ["anneau", "bracelet", "collier"]:
		var meilleur := score(config)
		for id: String in objets:
			if not CatalogueObjets.compatible(slot, id): continue
			var essai := config.duplicate(true)
			essai["bijoux"][slot] = id
			if not _remplacement_autorise(config, essai): continue
			var gain := score(essai)
			if gain > meilleur:
				meilleur = gain
				equipement["bijoux"][slot] = id
				config = essai
	if proteger_survie:
		_equiper_passifs_prudents(config)
		return
	config["passifs"] = {}
	for place in Passifs.EMPLACEMENTS:
		var meilleur := score(config)
		var selection := ""
		for id: String in rangs_passifs:
			if config["passifs"].has(id): continue
			var essai := config.duplicate(true)
			essai["passifs"][id] = int(rangs_passifs[id])
			var gain := score(essai)
			if gain > meilleur:
				selection = id
				meilleur = gain
		if selection.is_empty(): break
		config["passifs"][selection] = int(rangs_passifs[selection])
	equipement["passifs"] = config["passifs"].duplicate()

func _remplacement_autorise(avant: Dictionary, apres: Dictionary) -> bool:
	return not proteger_survie or survie_preservee(avant, apres)

static func survie_preservee(avant: Dictionary, apres: Dictionary) -> bool:
	var pv_avant := float(Modeles.mesurer(avant)["pv_effectifs"])
	var pv_apres := float(Modeles.mesurer(apres)["pv_effectifs"])
	return pv_apres >= pv_avant or is_equal_approx(pv_apres, pv_avant)

func _equiper_passifs_prudents(config: Dictionary) -> void:
	# Comparer des ensembles complets evite de refuser une carte utile parce que
	# les trois autres emplacements ont ete vides pendant la recherche.
	var actifs: Dictionary = config["passifs"]
	for id: String in actifs: actifs[id] = int(rangs_passifs[id])
	while true:
		var meilleur := score(config)
		var selection: Dictionary = {}
		var places: Array = (config["passifs"] as Dictionary).keys()
		if places.size() < Passifs.EMPLACEMENTS: places.append("")
		for id: String in rangs_passifs:
			if config["passifs"].has(id): continue
			for remplacer: String in places:
				var essai := config.duplicate(true)
				essai["passifs"].erase(remplacer)
				essai["passifs"][id] = int(rangs_passifs[id])
				if not _remplacement_autorise(config, essai): continue
				var gain := score(essai)
				if gain > meilleur:
					meilleur = gain
					selection = essai
		if selection.is_empty(): break
		config = selection
	equipement["passifs"] = config["passifs"].duplicate()

func _acheter_maitrises() -> void:
	while true:
		var config := configuration()
		var base := score(config)
		var rendement := 0.0
		var selection := ""
		for id: String in ArbreCompetences.NOEUDS:
			var rang := int(maitrises.get(id, 0))
			var prix := ArbreCompetences.cout(id, rang)
			if rang >= ArbreCompetences.rangs(id) or prix > gouttes or not ArbreCompetences.prerequis_atteint(id, maitrises): continue
			var essai := config.duplicate(true)
			essai["maitrises"][id] = rang + 1
			var gain := (score(essai) - base) / float(prix)
			if gain > rendement:
				rendement = gain
				selection = id
		if selection.is_empty(): break
		var rang := int(maitrises.get(selection, 0))
		var prix := ArbreCompetences.cout(selection, rang)
		gouttes -= prix
		depenses["gouttes"] = int(depenses["gouttes"]) + prix
		maitrises[selection] = rang + 1
		achats.append({"type": "maitrise", "id": selection, "rang": rang + 1, "prix": prix, "niveau_compte": niveau})

func _acheter_forge() -> void:
	while true:
		var config := configuration()
		var base := score(config)
		var candidats := {}
		for id: String in CatalogueProjectiles.disponibles(niveau_campagne()): candidats[id] = "arme"
		for id: String in CatalogueFamiliers.disponibles(niveau_campagne()): candidats[id] = "familier"
		for id: String in objets: candidats[id] = str(CatalogueObjets.OBJETS[id]["slot"])
		var rendement := 0.0
		var selection := ""
		var rang_cible := 0
		for id: String in candidats:
			var rang := int(forge.get(id, 0))
			if rang >= Reglages.FORGE_NIVEAU_MAX or Reglages.cout_forge(rang) > pierres: continue
			var type := str(candidats[id])
			var bijou := type not in ["arme", "familier"]
			var actif := str((config["bijoux"] as Dictionary).get(type, "")) == id if bijou else str(config[type]) == id
			var prix_lot := 0
			for cible in range(rang + 1, Reglages.FORGE_NIVEAU_MAX + 1):
				prix_lot += Reglages.cout_forge(cible - 1)
				if prix_lot > pierres: break
				var essai := config.duplicate(true)
				if bijou:
					essai["bijoux"][type] = id
					essai["forge_bijoux"][id] = cible
				else:
					essai[type] = id
					essai["forge_" + type] = cible
				if not _remplacement_autorise(config, essai): continue
				var gain := (score(essai) - base) / float(prix_lot)
				if gain > rendement:
					rendement = gain
					selection = id
					rang_cible = cible
				if actif: break
		if selection.is_empty(): break
		# Un remplacement doit financer tous ses rangs ; l'ancienne forge reste acquise.
		for rang in range(int(forge.get(selection, 0)), rang_cible):
			var prix := Reglages.cout_forge(rang)
			pierres -= prix
			depenses["pierres"] = int(depenses["pierres"]) + prix
			forge[selection] = rang + 1
			achats.append({"type": "forge", "id": selection, "rang": rang + 1, "prix": prix, "niveau_compte": niveau})
		var type := str(candidats[selection])
		if type in ["arme", "familier"]: equipement[type] = selection
		else: equipement["bijoux"][type] = selection
