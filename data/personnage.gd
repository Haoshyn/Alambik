class_name Personnage
extends RefCounted

const NIVEAU_MAX := 30
const POINTS_PAR_NIVEAU := 5
const COUT_CHANGEMENT_SPECIALISATION := 100
const SPECIALISATION_DEFAUT := "mage"

# Les points de compte renforcent la base sans remplacer les Maitrises, qui
# restent la grande source de pourcentages a long terme.
const ATTRIBUTS := {
	"force": {"nom": "Force", "attaque_base": 0.10,
		"description": "+0,1 Attaque brute par point"},
	"vitalite": {"nom": "Vitalité", "pv_base": 1.0, "defense_base": 0.10,
		"description": "+1 PV brut et +0,1 Défense brute par point"},
	"agilite": {"nom": "Agilité", "critique": 0.0015, "degats_critiques": 0.003,
		"description": "+0,15 % critique et +0,3 % dégâts critiques par point"},
	"intelligence": {"nom": "Intelligence", "degats_sorts": 0.003,
		"recuperation_sorts": 0.001,
		"description": "+0,3 % dégâts des sorts et −0,1 % récupération par point"},
	"sagesse": {"nom": "Sagesse", "butin": 0.007,
		"description": "+0,7 % de butin par point"},
}

const SPECIALISATIONS := {
	"mage": {"nom": "Mage", "description": "Dégâts des sorts +30 % · récupération des sorts −30 %"},
	"sorcier": {"nom": "Sorcier", "description": "Dégâts directs de baguette +20 %"},
	"moine": {"nom": "Moine", "description": "Dégâts des augments et des familiers +20 %"},
}

static func points_totaux(niveau: int) -> int:
	return maxi(0, clampi(niveau, 1, NIVEAU_MAX) - 1) * POINTS_PAR_NIVEAU

static func points_depenses(attributs: Dictionary) -> int:
	var total := 0
	for id in ATTRIBUTS:
		total += maxi(0, int(attributs.get(id, 0)))
	return total

static func bonus(attributs: Dictionary) -> Dictionary:
	var resultat := {"attaque_base": 0.0, "pv_base": 0.0, "defense_base": 0.0,
		"critique": 0.0, "degats_critiques": 0.0, "degats_sorts": 0.0,
		"recuperation_sorts": 0.0, "butin": 0.0}
	for id in ATTRIBUTS:
		var rang := maxi(0, int(attributs.get(id, 0)))
		var donnees: Dictionary = ATTRIBUTS[id]
		for champ in resultat:
			resultat[champ] = float(resultat[champ]) + float(donnees.get(champ, 0.0)) * float(rang)
	return resultat

static func specialisation_valide(id: String) -> String:
	return id if SPECIALISATIONS.has(id) else SPECIALISATION_DEFAUT

static func multiplicateur_source(specialisation: String, source: String) -> float:
	if not SPECIALISATIONS.has(specialisation):
		return 1.0
	var id := specialisation
	if id == "mage" and source == "sort":
		return 1.30
	if id == "sorcier" and source == "baguette":
		return 1.20
	if id == "moine" and source in ["augment", "familier"]:
		return 1.20
	return 1.0

static func multiplicateur_recharge(specialisation: String) -> float:
	return 0.70 if specialisation == "mage" else 1.0
