extends RefCounted

const Parcours = preload("res://tools/statistiques/parcours_progression.gd")
const Simulation = Parcours.Simulation
const TIRAGES := 24
const GRAINE := 20260928

static var _cache: Dictionary = {}

static func mesurer(configuration: Dictionary, chapitre: int, nombre := TIRAGES,
		graine := GRAINE, politique := "equilibre") -> Dictionary:
	var groupes := {}
	for index in maxi(1, nombre):
		var tentative := Parcours.campagne(configuration, chapitre, graine + index, {"politique": politique})
		for salle: Dictionary in tentative["salles"]:
			if not bool(salle["boss"]): continue
			var numero := int(salle["salle"])
			if not groupes.has(numero):
				groupes[numero] = {"salle": numero, "signature": bool(salle["boss_signature"]), "durees": []}
			groupes[numero]["durees"].append(float(salle["temps_combat"]))
	return _resumer(groupes, chapitre, 1, maxi(1, nombre))

static func rapport(parcours: Dictionary = {}) -> Dictionary:
	if not _cache.is_empty(): return _cache
	var source := Parcours.rapport() if parcours.is_empty() else parcours
	var chapitres := {}
	var comptes: Array = source["cohorte_comptes"]
	for compte: Dictionary in comptes:
		var visites := {}
		for action: Dictionary in compte["actions"]:
			var chapitre := int(action["chapitre"]) - 1
			if str(action["mode"]) != "grimoire" or not bool(action["victoire"]) or visites.has(chapitre): continue
			visites[chapitre] = true
			if not bool(Chapitres.par_index(chapitre)["boss_signature"]): continue
			if not chapitres.has(chapitre): chapitres[chapitre] = {"comptes": 0, "salles": {}}
			chapitres[chapitre]["comptes"] += 1
			# Le budget precede la premiere victoire ; les offres de mesure sont
			# tirees separement, sans ne conserver que les combats gagnants.
			for index in TIRAGES:
				var tentative := Parcours.campagne(action["avant"]["configuration"], chapitre, GRAINE + index)
				for salle: Dictionary in tentative["salles"]:
					if not bool(salle["boss"]): continue
					var numero := int(salle["salle"])
					var groupes: Dictionary = chapitres[chapitre]["salles"]
					if not groupes.has(numero):
						groupes[numero] = {"salle": numero, "signature": bool(salle["boss_signature"]), "durees": []}
					groupes[numero]["durees"].append(float(salle["temps_combat"]))
	var cas: Array[Dictionary] = []
	for chapitre: int in chapitres:
		cas.append(_resumer(chapitres[chapitre]["salles"], chapitre, int(chapitres[chapitre]["comptes"]), TIRAGES))
	_cache = {"tirages": TIRAGES, "graine": GRAINE, "comptes": comptes.size(), "cas": cas}
	return _cache

static func _resumer(groupes: Dictionary, chapitre: int, comptes: int, tirages: int) -> Dictionary:
	var salles: Array[Dictionary] = []
	for numero: int in groupes:
		var groupe: Dictionary = groupes[numero]
		var durees: Array[float] = []
		durees.assign(groupe["durees"])
		var distribution := Simulation.distribution(durees)
		durees.sort()
		distribution["p25"] = Simulation._quantile(durees, 0.25)
		distribution["p75"] = Simulation._quantile(durees, 0.75)
		var cible := Reglages.CAMPAGNE_BOSS_DUREE_SIGNATURE if bool(groupe["signature"]) else Reglages.CAMPAGNE_BOSS_DUREE_NORMALE
		salles.append({"salle": numero, "signature": groupe["signature"], "duree": distribution,
			"cible_min": cible.x, "cible_max": cible.y})
	return {"chapitre": chapitre + 1, "comptes": comptes, "tirages": tirages, "salles": salles}
