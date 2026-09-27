class_name Personnage
extends RefCounted

const NIVEAU_MAX := 30
const POINTS_PAR_NIVEAU := 5
const SPECIALISATION_DEFAUT := "sorcier"

# Les attributs construisent la base que les maitrises et les passifs
# multiplient ensuite ; chaque point reste utile quel que soit l'equipement.
const ATTRIBUTS := {
	"force": {"nom": "Force", "attaque_base": 0.20,
		"description": "+0,2 Attaque brute par point"},
	"vitalite": {"nom": "Vitalité", "pv_base": 1.0, "defense_base": 0.10,
		"description": "+1 PV brut et +0,1 Défense brute par point"},
	"agilite": {"nom": "Agilité", "critique": 0.001, "degats_critiques": 0.002,
		"description": "+0,1 point de chance critique et +0,2 point de dégâts critiques par point"},
	"intelligence": {"nom": "Intelligence", "attaque_base": 0.06, "cadence": 0.001,
		"description": "+0,06 Attaque brute et +0,1 % de cadence par point"},
	"sagesse": {"nom": "Sagesse", "butin": 0.007,
		"description": "+0,7 % de butin par point"},
}

const SPECIALISATIONS := {
	"sorcier": {"nom": "Sorcier", "couleur": Color("ffb283"),
		"degats_baguette": 1.0, "cadence": 1.0},
	"moine": {"nom": "Moine", "couleur": Color("86edbc"),
		"effet_augments": 1.0},
}

const LIBELLES_BONUS := {
	"degats_baguette": "Dégâts des attaques de base",
	"cadence": "Cadence des attaques de base",
	"effet_augments": "Effets des augments",
}

static func bonus_classe(specialisation: String) -> Array[Dictionary]:
	var lignes: Array[Dictionary] = []
	var donnees: Dictionary = SPECIALISATIONS.get(specialisation, {})
	for cle: String in LIBELLES_BONUS:
		if donnees.has(cle) and not is_equal_approx(float(donnees[cle]), 1.0):
			lignes.append({"nom": LIBELLES_BONUS[cle], "valeur": float(donnees[cle]) - 1.0})
	return lignes

static func multiplicateur_classe(specialisation: String, cle: String) -> float:
	var donnees: Dictionary = SPECIALISATIONS.get(specialisation, {})
	return float(donnees.get(cle, 1.0))

static func points_totaux(niveau: int) -> int:
	return maxi(0, clampi(niveau, 1, NIVEAU_MAX) - 1) * POINTS_PAR_NIVEAU

static func points_depenses(attributs: Dictionary) -> int:
	var total := 0
	for id in ATTRIBUTS:
		total += maxi(0, int(attributs.get(id, 0)))
	return total

static func bonus(attributs: Dictionary) -> Dictionary:
	var resultat := {"attaque_base": 0.0, "pv_base": 0.0, "defense_base": 0.0,
		"critique": 0.0, "degats_critiques": 0.0, "attaque_mult": 0.0,
		"cadence": 0.0, "butin": 0.0}
	for id in ATTRIBUTS:
		var rang := maxi(0, int(attributs.get(id, 0)))
		var donnees: Dictionary = ATTRIBUTS[id]
		for champ in resultat:
			resultat[champ] = float(resultat[champ]) + float(donnees.get(champ, 0.0)) * float(rang)
	return resultat

static func specialisation_valide(id: String) -> String:
	return id if SPECIALISATIONS.has(id) else SPECIALISATION_DEFAUT

static func multiplicateur_source(specialisation: String, source: String) -> float:
	if source == "augment":
		return multiplicateur_classe(specialisation, "effet_augments")
	return multiplicateur_classe(specialisation, "degats_" + source)
