class_name ButinsRun
extends RefCounted

const GOUTTES_SALLE := 2.0
const BONUS_PAR_BOSS := 0.10
const XP_SALLE := 2
const XP_VICTOIRE := 20
const XP_BOSS_EPREUVE := 2

# La meme offre alimente l'aperçu et le tirage ; seules les salles validees paient.
static func offre(mode: String, chapitre: int, salles: int, boss: int, victoire: bool,
		niveau_epreuve: int, rangs: Dictionary, objets: Array[String], echecs: int, echecs_sorts := 0,
		palier_mine := 0, temps_mine := 0.0) -> Dictionary:
	var rang := clampi(boss, 0, Recompenses.COFFRES.size() - 1)
	var resultat := {"nom": Recompenses.COFFRES[rang]["nom"], "rang": rang, "gouttes_min": 0, "gouttes_max": 0,
		"xp": 0, "pierres": 0, "objets": [], "chance_objet": 0.0, "sorts": [], "chance_sort": 0.0, "cadeaux": []}
	if mode == "mine":
		# La survie finance un nouvel essai meme si le boss reste hors de portee.
		var progression := clampf(temps_mine / Reglages.MINE_DUREE, 0.0, 1.0)
		var part := 1.0 if victoire else progression * Reglages.MINE_PIERRES_PART_SURVIE
		resultat["pierres"] = floori(float(Reglages.pierres_mine(palier_mine)) * part)
	if salles <= 0: return resultat
	if mode == "grimoire":
		var progression_forge := 1.0 + float(clampi(chapitre, 0, Chapitres.nombre() - 1)) * Reglages.PIERRES_CAMPAGNE_CROISSANCE
		resultat["pierres"] = roundi((float(salles) * Reglages.PIERRES_CAMPAGNE_PAR_SALLE \
			+ (Reglages.PIERRES_CAMPAGNE_VICTOIRE if victoire else 0.0)) * progression_forge)
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
				resultat["chance_objet"] = 1.0 if chapitre == 0 else Recompenses.chance_garantie(Recompenses.GARANTIE_APRES_GRANDS_COFFRES,echecs)
	elif mode == "epreuve_sorts":
		resultat["gouttes_min"] = boss
		resultat["gouttes_max"] = boss * Recompenses.GOUTTES_EPREUVE_MAX
		resultat["xp"] = boss * XP_BOSS_EPREUVE
		if victoire:
			resultat["sorts"] = Epreuves.candidats(niveau_epreuve, rangs)
			if not resultat["sorts"].is_empty():
				resultat["chance_sort"] = 1.0 if Epreuves.nouvelle_capacite_disponible(niveau_epreuve, rangs) \
					else Recompenses.chance_garantie(Reglages.EPREUVE_GARANTIE_CAPACITE, echecs_sorts)
	elif mode == "mine":
		resultat["xp"] = salles * XP_SALLE
	return resultat

static func tirer(offre_: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var resultat := {"gouttes": rng.randi_range(int(offre_["gouttes_min"]), int(offre_["gouttes_max"])),
		"xp": int(offre_["xp"]), "pierres": int(offre_["pierres"]), "objet": "", "sort": "", "nom": offre_["nom"], "rang": offre_["rang"], "cadeaux": offre_["cadeaux"].duplicate()}
	for type in ["objet", "sort"]:
		var candidats_: Array = offre_[type + "s"]
		if not candidats_.is_empty() and rng.randf() < float(offre_["chance_" + type]):
			resultat[type] = candidats_[rng.randi_range(0, candidats_.size() - 1)]
	return resultat
