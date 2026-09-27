class_name CatalogueProjectiles
extends RefCounted

# Une arme forgeable apporte de l'attaque de base a toutes les attaques.
# Son coefficient de tir ne concerne que sa forme de projectile.
const ATTAQUE_BASE := 4.0
const FORGE_ATTAQUE_PAR_NIVEAU := 0.35
const TYPES := {
	"standard": {"nom": "Baguette d’acier", "description": "Un trait simple à 100 % de l’ATK.", "monde": 1, "niveau": 1, "coefficient_tir": 1.0},
	"veloce": {"nom": "Aiguille vive", "description": "Tir 80 %, cadence +20 %, portée −10 %.", "monde": 2, "niveau": 4, "coefficient_tir": 0.80, "cadence_mult": 1.20, "portee_mult": 0.90},
	"lourd": {"nom": "Sceptre de cuivre", "description": "Tir 150 %, cadence −30 %.", "monde": 3, "niveau": 7, "coefficient_tir": 1.50, "cadence_mult": 0.70},
	"chercheur": {"nom": "Branche astrale", "description": "Tir 105 %, traverse un ennemi.", "monde": 4, "niveau": 10, "coefficient_tir": 1.05, "perforations": 1},
	"explosif": {"nom": "Bâton à étincelles", "description": "Tir 110 %, chance critique +3 %.", "monde": 5, "niveau": 13, "coefficient_tir": 1.10, "critique": 0.03},
	"prisme": {"nom": "Prisme jumeau", "description": "Deux traits parallèles de 65 %, soit 130 % au total, à cadence normale.", "monde": 6, "niveau": 16, "coefficient_tir": 0.65, "nb_projectiles": 1, "ecart_lateral": 30.0, "part_projectiles_supplementaires": 1.0},
	"resonant": {"nom": "Diapason de verre", "description": "Tir 90 %, cadence +40 %.", "monde": 7, "niveau": 19, "coefficient_tir": 0.90, "cadence_mult": 1.40},
	"draconique": {"nom": "Cornue draconique", "description": "Tir 110 %, cadence +10 %, attaque +5 %.", "monde": 8, "niveau": 22, "coefficient_tir": 1.10, "cadence_mult": 1.10, "attaque_mult": 0.05},
	"neant": {"nom": "Aiguille du néant", "description": "Tir 125 %, cadence +10 %, traverse un ennemi.", "monde": 9, "niveau": 25, "coefficient_tir": 1.25, "cadence_mult": 1.10, "perforations": 1},
	"royal": {"nom": "Alambic souverain", "description": "Tir 130 %, cadence +15 %.", "monde": 10, "niveau": 28, "coefficient_tir": 1.30, "cadence_mult": 1.15},
}

static func contient(id: String) -> bool:
	return TYPES.has(id)

static func attaque_base(id: String, niveau_forge: int) -> float:
	if not contient(id):
		return 0.0
	var croissance := pow(Reglages.EQUIPEMENT_CROISSANCE_PAR_PALIER, niveau_deblocage(id) - 1)
	return (ATTAQUE_BASE + FORGE_ATTAQUE_PAR_NIVEAU
		* float(clampi(niveau_forge, 0, Reglages.FORGE_NIVEAU_MAX))) * croissance

static func niveau_deblocage(id: String) -> int:
	return int(TYPES.get(id, TYPES["standard"]).get("niveau", 1))

static func debloque(id: String, niveau_campagne: int) -> bool:
	return contient(id) and niveau_campagne >= niveau_deblocage(id)

static func disponibles(niveau_campagne: int) -> Array[String]:
	var resultat: Array[String] = []
	for id in TYPES:
		if debloque(str(id), niveau_campagne):
			resultat.append(str(id))
	return resultat

static func appliquer(id: String, source: Tir) -> Tir:
	var type_id := id if contient(id) else "standard"
	var donnees: Dictionary = TYPES[type_id]
	var tir := source.copie()
	tir.arme = type_id
	for champ in ["nb_projectiles", "rebonds"]:
		tir.set(champ,int(tir.get(champ))+int(donnees.get(champ,0)))
	tir.ecart_lateral += float(donnees.get("ecart_lateral",0.0))
	tir.perforations += int(donnees.get("perforations",0))
	tir.cadence *= float(donnees.get("cadence_mult", 1.0))
	tir.degats *= float(donnees.get("coefficient_tir", 1.0))
	tir.vitesse *= float(donnees.get("vitesse_mult", 1.0))
	var portee_mult := float(donnees.get("portee_mult", 1.0))
	tir.portee *= portee_mult
	if portee_mult < 1.0:
		tir.portee_limitee = true
	if donnees.has("part_projectiles_supplementaires"):
		tir.degats_projectiles_supplementaires = float(donnees["part_projectiles_supplementaires"])
	return tir

static func bonus_heros(id: String) -> Dictionary:
	var donnees: Dictionary = TYPES.get(id, TYPES["standard"])
	return {"attaque_mult": float(donnees.get("attaque_mult", 0.0)),
		"critique": float(donnees.get("critique", 0.0))}
