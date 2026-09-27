class_name CatalogueFamiliers
extends RefCounted

# La forge du familier renforce sa base propre. Les bonus permanents d'attaque
# sont partages une seule fois, sans recevoir les critiques ni la cadence du heros.
const TYPES := {
	"homoncule_encre": {"nom": "Homoncule d’encre", "niveau": 1, "attaque": 5.0,
		"intervalle": 2.0, "passif": {"critique": 0.02},
		"description": "Goutte spectrale · héros : chance critique +2 %"},
	"salamandre": {"nom": "Salamandre de braise", "niveau": 8, "attaque": 7.0,
		"intervalle": 2.1, "passif": {"attaque_mult": 0.03},
		"description": "Orbe cerclé · héros : attaque +3 %"},
	"ondine": {"nom": "Ondine de givre", "niveau": 15, "attaque": 5.5,
		"intervalle": 1.9, "passif": {"cadence": 0.04},
		"description": "Larme de givre · héros : cadence +4 %"},
	"sylphe": {"nom": "Sylphe des orages", "niveau": 22, "attaque": 4.5,
		"intervalle": 1.8, "passif": {"vitesse": 0.04},
		"description": "Éclair fin · héros : vitesse +4 %"},
	"golem": {"nom": "Golem de forge", "niveau": 29, "attaque": 10.0,
		"intervalle": 1.8, "passif": {"defense_base": 2.0},
		"description": "Galet de forge · héros : Défense brute +2"},
}

const FORGE_ATTAQUE_PAR_NIVEAU := 0.75
const DEPLACEMENT_DUREE := 0.75
const VISEE_DUREE := 0.30
const DEPLACEMENT_VITESSE := 245.0
const PAS_PATROUILLE := 160.0
const ANGLE_PATROUILLE := .6
const DIRECTIONS_PATROUILLE := 12
const DISTANCE_COMBAT := 420.0
const RAYON := 24.0
const APPARITION := Vector2(0.5, 0.72)
const PROJECTILES := {
	"homoncule_encre": {"vitesse": 1312.5, "rayon": 10.0, "longueur": 26.0},
	"salamandre": {"vitesse": 1150.0, "rayon": 16.0, "longueur": 32.0},
	"ondine": {"vitesse": 1350.0, "rayon": 9.0, "longueur": 36.0},
	"sylphe": {"vitesse": 1562.5, "rayon": 6.0, "longueur": 40.0},
	"golem": {"vitesse": 1075.0, "rayon": 18.0, "longueur": 36.0},
}

static func configurer_tir(tir: Tir, id: String, taille_salle: Vector2) -> void:
	var p: Dictionary = PROJECTILES[id]
	tir.arme = "familier"
	tir.silhouette = id
	tir.vitesse = float(p["vitesse"])
	tir.rayon = float(p["rayon"])
	tir.longueur = float(p["longueur"])
	tir.traverse_murs = true
	# Une portee finie nettoie aussi les tirs qui franchissent le mur exterieur.
	tir.portee = taille_salle.length() + tir.longueur
	tir.portee_limitee = true
	tir.drapeaux.append("trait_familier")

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

static func attaque_combat(id: String, niveau_forge: int, bonus_attaque_permanent: float,
		attaque_heros_run: float) -> float:
	var puissance := attaque(id, niveau_forge) * maxf(Reglages.MODS_PLANCHER, 1.0 + bonus_attaque_permanent)
	# Forger uniquement le familier ne doit pas remplacer toute l'arme du heros.
	var plafond := maxf(0.0, attaque_heros_run) * Reglages.FAMILIER_DEGATS_MAX_PART_HEROS
	return minf(puissance, plafond)

static func bonus_heros(id: String) -> Dictionary:
	if not contient(id):
		return {}
	return (TYPES[id]["passif"] as Dictionary).duplicate()
