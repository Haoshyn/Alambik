class_name CatalogueFamiliers
extends RefCounted

# Le familier combat avec sa propre Attaque. Sa forge ne modifie jamais les
# statistiques du heros ; seul son petit passif equipe le fait.
const TYPES := {
	"homoncule_encre": {"nom": "Homoncule d’encre", "niveau": 1, "attaque": 5.0,
		"intervalle": 2.0, "passif": {"critique": 0.02},
		"description": "Perle cyan · héros : chance critique +2 %"},
	"salamandre": {"nom": "Salamandre de braise", "niveau": 8, "attaque": 7.0,
		"intervalle": 2.3, "passif": {"attaque_mult": 0.03},
		"description": "Perle lourde · héros : attaque +3 %"},
	"ondine": {"nom": "Ondine de givre", "niveau": 15, "attaque": 5.5,
		"intervalle": 1.9, "passif": {"degats_sorts": 0.04},
		"description": "Perle fluide · héros : dégâts des sorts +4 %"},
	"sylphe": {"nom": "Sylphe des orages", "niveau": 22, "attaque": 4.5,
		"intervalle": 1.7, "passif": {"vitesse": 0.04},
		"description": "Perle vive · héros : vitesse +4 %"},
	"golem": {"nom": "Golem de forge", "niveau": 29, "attaque": 10.0,
		"intervalle": 2.6, "passif": {"defense_base": 2.0},
		"description": "Perle dense · héros : Défense brute +2"},
}

const FORGE_ATTAQUE_PAR_NIVEAU := 1.0

static func contient(id: String) -> bool:
	return TYPES.has(id)

static func niveau_deblocage(id: String) -> int:
	return int(TYPES.get(id, TYPES["homoncule_encre"]).get("niveau", 1))

static func disponibles(niveau_campagne: int) -> Array[String]:
	var resultat: Array[String] = []
	for id in TYPES:
		if niveau_campagne >= niveau_deblocage(str(id)):
			resultat.append(str(id))
	return resultat

static func attaque(id: String, niveau_forge: int) -> float:
	var donnees: Dictionary = TYPES.get(id, TYPES["homoncule_encre"])
	var croissance := pow(Reglages.EQUIPEMENT_CROISSANCE_PAR_PALIER, niveau_deblocage(id) - 1)
	return (float(donnees["attaque"]) + float(clampi(niveau_forge, 0, Reglages.FORGE_NIVEAU_MAX)) \
		* FORGE_ATTAQUE_PAR_NIVEAU) * croissance

static func bonus_heros(id: String) -> Dictionary:
	if not contient(id):
		return {}
	return (TYPES[id]["passif"] as Dictionary).duplicate()
