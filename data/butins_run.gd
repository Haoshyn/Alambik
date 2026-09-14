class_name ButinsRun
extends RefCounted

const GOUTTES_SALLE := 2.0
const BONUS_PAR_BOSS := 0.125
const XP_SALLE := 2
const XP_VICTOIRE := 20
const XP_BOSS_EPREUVE := 2

# La meme offre alimente l'aperçu et le tirage ; seules les salles validees paient.
static func offre(mode: String, chapitre: int, salles: int, boss: int, victoire: bool,
		niveau_epreuve: int, rangs: Dictionary, objets: Array[String], echecs: int) -> Dictionary:
	var rang := clampi(boss, 0, Recompenses.COFFRES.size() - 1)
	var resultat := {"nom": Recompenses.COFFRES[rang]["nom"], "rang": rang, "gouttes_min": 0, "gouttes_max": 0,
		"xp": 0, "objets": [], "chance_objet": 0.0, "sorts": [], "chance_sort": 0.0, "cadeaux": []}
	if salles <= 0: return resultat
	if mode == "grimoire":
		var croissance := pow(Reglages.GOUTTES_MULT_PAR_CHAPITRE, clampi(chapitre, 0, Chapitres.nombre() - 1))
		var progression := float(salles) * GOUTTES_SALLE * (1.0 + float(boss) * BONUS_PAR_BOSS)
		var coffre: Dictionary = Recompenses.COFFRES[mini(rang, Recompenses.COFFRES.size() - 1)]
		resultat["gouttes_min"] = roundi((progression + float(coffre["gouttes_min"])) * croissance)
		resultat["gouttes_max"] = roundi((progression + float(coffre["gouttes_max"])) * croissance)
		resultat["xp"] = salles * XP_SALLE + (XP_VICTOIRE if victoire else 0)
		if victoire:
			for niveau in Sorts.RECOMPENSES_CAMPAGNE:
				var cadeau := str(Sorts.RECOMPENSES_CAMPAGNE[niveau])
				if int(niveau) <= chapitre + 2 and int(rangs.get(cadeau, 0)) == 0:
					resultat["cadeaux"].append(cadeau)
			resultat["objets"] = CatalogueObjets.manquants(chapitre, objets)
			if not resultat["objets"].is_empty():
				resultat["chance_objet"] = 1.0 if echecs >= Recompenses.GARANTIE_APRES_GRANDS_COFFRES - 1 else float(coffre["chance_objet"])
	elif mode == "epreuve_sorts":
		resultat["gouttes_min"] = boss
		resultat["gouttes_max"] = boss * Recompenses.GOUTTES_EPREUVE_MAX
		resultat["xp"] = boss * XP_BOSS_EPREUVE
		if victoire:
			resultat["sorts"] = Epreuves.candidats(niveau_epreuve, rangs)
			if not resultat["sorts"].is_empty(): resultat["chance_sort"] = Reglages.EPREUVE_CHANCE_CAPACITE
	elif mode == "mine":
		resultat["xp"] = salles * XP_SALLE
	return resultat

static func tirer(offre_: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var resultat := {"gouttes": rng.randi_range(int(offre_["gouttes_min"]), int(offre_["gouttes_max"])),
		"xp": int(offre_["xp"]), "objet": "", "sort": "", "nom": offre_["nom"], "rang": offre_["rang"], "cadeaux": offre_["cadeaux"].duplicate()}
	for type in ["objet", "sort"]:
		var candidats_: Array = offre_[type + "s"]
		if not candidats_.is_empty() and rng.randf() < float(offre_["chance_" + type]):
			resultat[type] = candidats_[rng.randi_range(0, candidats_.size() - 1)]
	return resultat
