class_name Personnage
extends RefCounted

const NIVEAU_MAX := 30
const POINTS_PAR_NIVEAU := 5
const SPECIALISATION_DEFAUT := "sorcier"

# Les attributs construisent la base que les maitrises et les passifs
# multiplient ensuite ; chaque point reste utile quel que soit l'equipement.
const FORCE_ATTAQUE_PAR_POINT := 0.80
const AGILITE_CRITIQUE_PAR_POINT := 0.004
const AGILITE_DEGATS_CRITIQUES_PAR_POINT := 0.008
const INTELLIGENCE_ATTAQUE_PAR_POINT := 0.24
const INTELLIGENCE_CADENCE_PAR_POINT := 0.004
const PUISSANCE_INITIALE := 0.25
const POINTS_RENDEMENT := 40.0
const CHAMPS_OFFENSIFS := ["attaque_base", "critique", "degats_critiques", "cadence"]
const ATTRIBUTS := {
	"force": {"nom": "Force", "attaque_base": FORCE_ATTAQUE_PAR_POINT,
		"description": "Attaque brute ; gains progressifs avec le niveau et les points."},
	"vitalite": {"nom": "Vitalité", "pv_base": 1.0, "defense_base": 0.10,
		"description": "+1 PV brut et +0,1 Défense brute par point"},
	"agilite": {"nom": "Agilité", "critique": AGILITE_CRITIQUE_PAR_POINT, "degats_critiques": AGILITE_DEGATS_CRITIQUES_PAR_POINT,
		"description": "Chance et dégâts critiques ; gains progressifs avec le niveau et les points."},
	"intelligence": {"nom": "Intelligence", "attaque_base": INTELLIGENCE_ATTAQUE_PAR_POINT, "cadence": INTELLIGENCE_CADENCE_PAR_POINT,
		"description": "Attaque brute et cadence ; gains progressifs avec le niveau et les points."},
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

static func facteur_progression(niveau: int, initial: float) -> float:
	var progression := float(clampi(niveau, 1, NIVEAU_MAX) - 1) / float(NIVEAU_MAX - 1)
	return lerpf(initial, 1.0, progression * progression)

static func poids_points(points: int) -> float:
	# Repartir les points offensifs reste utile : concentrer tout en Force
	# ne doit pas effacer les autres attributs ni les combats de campagne.
	return 2.0 * POINTS_RENDEMENT * float(maxi(0, points)) / (POINTS_RENDEMENT + float(maxi(0, points)))

static func bonus(attributs: Dictionary, niveau := NIVEAU_MAX) -> Dictionary:
	var resultat := {"attaque_base": 0.0, "pv_base": 0.0, "defense_base": 0.0,
		"critique": 0.0, "degats_critiques": 0.0, "attaque_mult": 0.0,
		"cadence": 0.0, "butin": 0.0}
	for id in ATTRIBUTS:
		var rang := maxi(0, int(attributs.get(id, 0)))
		var donnees: Dictionary = ATTRIBUTS[id]
		for champ in resultat:
			var poids := float(rang)
			if champ in CHAMPS_OFFENSIFS:
				poids = poids_points(rang) * facteur_progression(niveau, PUISSANCE_INITIALE)
			resultat[champ] = float(resultat[champ]) + float(donnees.get(champ, 0.0)) * poids
	return resultat

static func specialisation_valide(id: String) -> String:
	return id if SPECIALISATIONS.has(id) else SPECIALISATION_DEFAUT

static func multiplicateur_source(specialisation: String, source: String) -> float:
	if source == "augment":
		return multiplicateur_classe(specialisation, "effet_augments")
	return multiplicateur_classe(specialisation, "degats_" + source)
