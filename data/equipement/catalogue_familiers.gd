class_name CatalogueFamiliers
extends RefCounted

# La forge du familier renforce sa base propre. Les bonus permanents d'attaque
# sont partages une seule fois, sans recevoir les critiques ni la cadence du heros.
static var TYPES := _avec_descriptions({
	"homoncule_encre": {"nom": "Homoncule d’encre", "niveau": 1, "attaque": 6.0,
		"intervalle": 2.0, "passif": {"critique": 0.05},
		"forme": "Goutte spectrale"},
	"salamandre": {"nom": "Salamandre de braise", "niveau": 8, "attaque": 8.0,
		"intervalle": 2.1, "passif": {"attaque_mult": 0.08},
		"forme": "Orbe cerclé"},
	"ondine": {"nom": "Ondine de givre", "niveau": 15, "attaque": 7.0,
		"intervalle": 1.9, "passif": {"cadence": 0.08},
		"forme": "Larme de givre"},
	"sylphe": {"nom": "Sylphe des orages", "niveau": 22, "attaque": 6.0,
		"intervalle": 1.8, "passif": {"vitesse": 0.08, "attaque_mult": 0.05},
		"forme": "Éclair fin"},
	"golem": {"nom": "Golem de forge", "niveau": 29, "attaque": 10.0,
		"intervalle": 1.8, "passif": {"defense_base": 4.0, "attaque_mult": 0.05},
		"forme": "Galet de forge"},
})

static func _avec_descriptions(types: Dictionary) -> Dictionary:
	var libelles := {"critique": ["chance critique", 100.0, " %"],
		"attaque_mult": ["attaque", 100.0, " %"], "cadence": ["cadence", 100.0, " %"],
		"vitesse": ["vitesse", 100.0, " %"], "defense_base": ["Défense brute", 1.0, ""]}
	for id: String in types:
		var donnees: Dictionary = types[id]
		var passif: Dictionary = donnees["passif"]
		var morceaux: Array[String] = []
		for champ: String in passif:
			var regle: Array = libelles[champ]
			var valeur := String.num(float(passif[champ]) * float(regle[1]), 2).trim_suffix(".0").replace(".", ",")
			morceaux.append("%s +%s%s" % [str(regle[0]), valeur, str(regle[2])])
		donnees["description"] = str(donnees["forme"]) + " · héros : " + ", ".join(morceaux)
	return types

const FORGE_ATTAQUE_PAR_NIVEAU := 2.0
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
		facteur_attaque_run := 1.0) -> float:
	# Chaque rang paye reste utile, meme avec une arme peu forgee. Le familier
	# partage l'attaque de run, sans recevoir les critiques ou salves du heros.
	return attaque(id, niveau_forge) * maxf(Reglages.MODS_PLANCHER, 1.0 + bonus_attaque_permanent) \
		* maxf(0.0, facteur_attaque_run)

static func bonus_heros(id: String) -> Dictionary:
	if not contient(id):
		return {}
	return (TYPES[id]["passif"] as Dictionary).duplicate()
