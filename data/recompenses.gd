class_name Recompenses
extends RefCounted

const GARANTIE_APRES_GRANDS_COFFRES := 5

# Un seul coffre suit toute la run. Sa qualite est celle du dernier palier
# vaincu, meme lorsque la tentative se termine ensuite sur une defaite.
const COFFRES := [
	{"palier": 0, "nom": "Aucun coffre", "gouttes_min": 0, "gouttes_max": 0, "chance_objet": 0.0},
	{"palier": 5, "nom": "Mini coffre", "gouttes_min": 2, "gouttes_max": 3, "chance_objet": 0.02},
	{"palier": 10, "nom": "Petit coffre", "gouttes_min": 4, "gouttes_max": 6, "chance_objet": 0.05},
	{"palier": 15, "nom": "Coffre moyen", "gouttes_min": 7, "gouttes_max": 10, "chance_objet": 0.10},
	{"palier": 20, "nom": "Grand coffre", "gouttes_min": 12, "gouttes_max": 16, "chance_objet": 0.25},
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
	if int(coffre.get("palier", 0)) <= 0:
		return false
	if int(coffre["palier"]) >= Reglages.SALLES_PAR_RUN \
			and grands_coffres_sans_objet >= GARANTIE_APRES_GRANDS_COFFRES - 1:
		return true
	return rng.randf() < float(coffre["chance_objet"])

static func tirer_epreuve(rng: RandomNumberGenerator, rangs: Dictionary,
		niveau_campagne: int) -> Dictionary:
	var candidats: Array[Dictionary] = []
	for source in [
		{"type": "ultime", "catalogue": Sorts.ULTIMES},
		{"type": "actif", "catalogue": Sorts.ACTIFS},
		{"type": "passif", "catalogue": Sorts.PASSIFS},
	]:
		var catalogue: Dictionary = source["catalogue"]
		for id in catalogue:
			if Sorts.disponible_au_niveau(str(id), niveau_campagne) \
					and int(rangs.get(id, 0)) < Reglages.CAPACITE_RANG_MAX:
				candidats.append({"type": source["type"], "id": id})
	# Un jet rate paie seulement un petit repli : l'Epreuve reste le farm des
	# capacites et ne devient jamais la meilleure route pour les Maitrises.
	if candidats.is_empty() or rng.randf() >= Reglages.EPREUVE_CHANCE_CAPACITE:
		return {"type": "gouttes", "quantite": rng.randi_range(GOUTTES_EPREUVE_MIN, GOUTTES_EPREUVE_MAX)}
	return candidats[rng.randi_range(0, candidats.size() - 1)]
