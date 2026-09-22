class_name Recompenses
extends RefCounted

const GARANTIE_APRES_GRANDS_COFFRES := 3

# Un seul coffre suit toute la run. Sa qualite est celle du dernier palier
# vaincu, meme lorsque la tentative se termine ensuite sur une defaite.
const COFFRES := [
	{"palier": 0, "nom": "Coffre de voyage", "gouttes_min": 0, "gouttes_max": 0, "chance_objet": 0.0},
	{"palier": 5, "nom": "Coffre de bronze", "gouttes_min": 2, "gouttes_max": 3, "chance_objet": 1.0 / 30.0},
	{"palier": 10, "nom": "Coffre d’argent", "gouttes_min": 4, "gouttes_max": 6, "chance_objet": 1.0 / 20.0},
	{"palier": 15, "nom": "Coffre d’or", "gouttes_min": 7, "gouttes_max": 10, "chance_objet": 1.0 / 10.0},
	{"palier": 20, "nom": "Grand coffre", "gouttes_min": 12, "gouttes_max": 16, "chance_objet": 1.0 / GARANTIE_APRES_GRANDS_COFFRES},
]
const GOUTTES_EPREUVE_MIN := 1
const GOUTTES_EPREUVE_MAX := 2

static func coffre_pour(salles_vaincues: int) -> Dictionary:
	var resultat: Dictionary = COFFRES[0]
	for coffre in COFFRES:
		if salles_vaincues >= int(coffre["palier"]):
			resultat = coffre
	return resultat

static func tirer_gouttes_coffre(coffre: Dictionary, chapitre: int, rng: RandomNumberGenerator) -> int:
	if int(coffre.get("palier", 0)) <= 0:
		return 0
	var base := rng.randi_range(int(coffre["gouttes_min"]), int(coffre["gouttes_max"]))
	return maxi(1, roundi(float(base) * pow(Reglages.GOUTTES_MULT_PAR_CHAPITRE,
		clampi(chapitre, 0, Chapitres.nombre() - 1))))

static func donne_objet(coffre: Dictionary, grands_coffres_sans_objet: int,
		rng: RandomNumberGenerator) -> bool:
	return rng.randf() < chance_objet(coffre, grands_coffres_sans_objet)

static func chance_objet(coffre: Dictionary, grands_coffres_sans_objet: int) -> float:
	if int(coffre.get("palier", 0)) < Reglages.SALLES_PAR_RUN:
		return float(coffre.get("chance_objet", 0.0))
	return chance_garantie(GARANTIE_APRES_GRANDS_COFFRES, grands_coffres_sans_objet)

static func chance_garantie(essais: int, echecs: int) -> float:
	return 1.0 if echecs >= maxi(1,essais)-1 else 1.0 / float(maxi(1,essais))

static func tirer_epreuve(rng: RandomNumberGenerator, rangs: Dictionary, niveau_epreuve: int, echecs := 0) -> Dictionary:
	var candidats := Epreuves.candidats(niveau_epreuve, rangs)
	var chance := chance_garantie(Reglages.EPREUVE_GARANTIE_CAPACITE, echecs)
	if candidats.is_empty() or rng.randf() >= chance:
		return {"type": "gouttes", "quantite": rng.randi_range(GOUTTES_EPREUVE_MIN, GOUTTES_EPREUVE_MAX)}
	var id := candidats[rng.randi_range(0, candidats.size() - 1)]
	return {"type": "ultime" if Sorts.ULTIMES.has(id) else "actif" if Sorts.ACTIFS.has(id) else "passif", "id": id}

static func gouttes_progression(salles: int, chapitre: int) -> int:
	return roundi(float(maxi(0, salles) * Reglages.GOUTTES_PAR_SALLE) * pow(Reglages.GOUTTES_MULT_PAR_CHAPITRE, clampi(chapitre, 0, Chapitres.nombre()-1)))
