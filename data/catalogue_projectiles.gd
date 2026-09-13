class_name CatalogueProjectiles
extends RefCounted

# Les armes transforment le rythme et la trajectoire, sans niveau ni bonus permanent.
const TYPES := {
	"standard": {
		"nom": "Baguette d’atelier",
		"description": "Projectile standard sans compromis.",
		"niveau": 1,
		"degats_mult": 1.0,
		"vitesse_mult": 1.0,
		"portee_mult": 1.0,
	},
	"veloce": {
		"nom": "Aiguille vive",
		"description": "Tirs fréquents et rapides, chaque impact est plus léger.",
		"niveau": 2,
		"degats_mult": 0.75,
		"cadence_mult": 1.35,
		"vitesse_mult": 1.55,
		"portee_mult": 1.10,
	},
	"lourd": {
		"nom": "Sceptre de cuivre",
		"description": "Lent et court, mais nettement plus destructeur.",
		"niveau": 1,
		"degats_mult": 1.50,
		"cadence_mult": 0.70,
		"vitesse_mult": 0.68,
		"portee_mult": 0.90,
	},
	"chercheur": {
		"nom": "Branche astrale",
		"description": "Corrige sa trajectoire vers les ennemis au prix de dégâts.",
		"niveau": 3,
		"degats_mult": 0.88,
		"vitesse_mult": 0.95,
		"portee_mult": 1.10,
		"drapeaux": ["homing"],
	},
	"explosif": {
		"nom": "Bâton à étincelles",
		"description": "Faible sur une cible, mais son impact frappe la zone proche.",
		"niveau": 4,
		"degats_mult": 0.85,
		"vitesse_mult": 0.82,
		"portee_mult": 0.95,
		"rayon_explosion": 150.0,
		"degats_zone_mult": 0.65,
	},
}

static func contient(id: String) -> bool:
	return TYPES.has(id)

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
	tir.cadence *= float(donnees.get("cadence_mult", 1.0))
	tir.degats *= float(donnees.get("degats_mult", 1.0))
	tir.vitesse *= float(donnees.get("vitesse_mult", 1.0))
	tir.portee *= float(donnees.get("portee_mult", 1.0))
	tir.rayon_explosion = float(donnees.get("rayon_explosion", 0.0))
	tir.degats_zone_mult = float(donnees.get("degats_zone_mult", 0.0))
	for drapeau in donnees.get("drapeaux", []):
		var nom := str(drapeau)
		if not nom in tir.drapeaux:
			tir.drapeaux.append(nom)
	return tir
