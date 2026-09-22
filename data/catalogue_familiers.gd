class_name CatalogueFamiliers
extends RefCounted

# Le familier combat avec sa propre Attaque. Sa forge ne modifie jamais les
# statistiques du heros ; seul son petit passif equipe le fait.
const TYPES := {
	"homoncule_encre": {"nom": "Homoncule d’encre", "niveau": 1, "attaque": 6.0,
		"intervalle": 1.0, "passif": {"critique": 0.02},
		"description": "Trait régulier · héros : chance critique +2 %"},
	"salamandre": {"nom": "Salamandre de braise", "niveau": 8, "attaque": 9.0,
		"intervalle": 1.25, "passif": {"attaque_mult": 0.03},
		"description": "Trait lourd · héros : attaque +3 %"},
	"ondine": {"nom": "Ondine de givre", "niveau": 15, "attaque": 6.5,
		"intervalle": 0.80, "passif": {"degats_sorts": 0.04},
		"description": "Traits rapides · héros : dégâts des sorts +4 %"},
	"sylphe": {"nom": "Sylphe des orages", "niveau": 22, "attaque": 5.0,
		"intervalle": 0.55, "passif": {"vitesse": 0.04},
		"description": "Très rapide · héros : vitesse +4 %"},
	"golem": {"nom": "Golem de forge", "niveau": 29, "attaque": 13.0,
		"intervalle": 1.50, "passif": {"defense_base": 2.0},
		"description": "Impact massif · héros : Défense brute +2"},
}

const FORGE_ATTAQUE_PAR_NIVEAU := 2.0

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
