class_name CatalogueProjectiles
extends RefCounted

# Une arme forgeable apporte de l'attaque de base a tous les coups et sorts.
# Son coefficient de tir ne concerne que sa forme de projectile.
const ATTAQUE_BASE := 4.0
const FORGE_ATTAQUE_PAR_NIVEAU := 0.5
const TYPES := {
	"standard": {"nom": "Baguette d’acier", "description": "Un trait régulier, précis et de bonne portée.", "monde": 1, "niveau": 1, "coefficient_tir": 1.0, "portee_mult": 1.1},
	"veloce": {"nom": "Aiguille vive", "description": "Traits rapides et longs. Moins de dégâts par seconde, mais une trajectoire facile à placer.", "monde": 2, "niveau": 4, "coefficient_tir": 0.80, "cadence_mult": 1.2, "vitesse_mult": 1.55, "portee_mult": 1.25},
	"lourd": {"nom": "Sceptre de cuivre", "description": "Traverse trois ennemis à pleine puissance. Impacts lourds, cadence lente.", "monde": 3, "niveau": 7, "coefficient_tir": 1.65, "cadence_mult": 0.7, "perforations": 2, "vitesse_mult": 0.9, "portee_mult": 1.1, "drapeaux": ["perforation_sans_perte"]},
	"chercheur": {"nom": "Branche astrale", "description": "Des traits puissants corrigent leur trajectoire vers la cible.", "monde": 4, "niveau": 10, "coefficient_tir": 1.35, "cadence_mult": 0.9, "drapeaux": ["homing"]},
	"explosif": {"nom": "Bâton à étincelles", "description": "Chaque impact frappe aussi les ennemis autour de la cible.", "monde": 5, "niveau": 13, "coefficient_tir": 1.4, "cadence_mult": 0.9, "rayon_explosion": 150.0, "degats_zone_mult": 0.45},
	"prisme": {"nom": "Prisme jumeau", "description": "Deux traits parallèles à chaque attaque.", "monde": 6, "niveau": 16, "coefficient_tir": 0.9, "cadence_mult": 0.95, "nb_projectiles": 1, "ecart_lateral": 30.0},
	"resonant": {"nom": "Diapason de verre", "description": "Un trait lourd rebondit sur deux ennemis supplémentaires.", "monde": 7, "niveau": 19, "coefficient_tir": 1.85, "cadence_mult": 0.9, "rebonds": 2},
	"draconique": {"nom": "Cornue draconique", "description": "Un impact massif éclate en trois fragments.", "monde": 8, "niveau": 22, "coefficient_tir": 2.1, "cadence_mult": 0.85, "fragments": 3},
	"neant": {"nom": "Aiguille du néant", "description": "Un trait guidé traverse tous les ennemis sans perdre de puissance.", "monde": 9, "niveau": 25, "coefficient_tir": 2.3, "cadence_mult": 0.9, "drapeaux": ["homing", "perfore_tout", "perforation_sans_perte"]},
	"royal": {"nom": "Alambic souverain", "description": "Un projectile dévastateur explose puis rebondit vers une seconde cible.", "monde": 10, "niveau": 28, "coefficient_tir": 3.0, "cadence_mult": 0.85, "rebonds": 1, "rayon_explosion": 180.0, "degats_zone_mult": 0.7},
}

static func contient(id: String) -> bool:
	return TYPES.has(id)

static func attaque_base(id: String, niveau_forge: int) -> float:
	if not contient(id):
		return 0.0
	return ATTAQUE_BASE + FORGE_ATTAQUE_PAR_NIVEAU * float(clampi(niveau_forge, 0, Reglages.FORGE_NIVEAU_MAX))

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
	for champ in ["nb_projectiles","rebonds","fragments"]:
		tir.set(champ,int(tir.get(champ))+int(donnees.get(champ,0)))
	tir.ecart_lateral += float(donnees.get("ecart_lateral",0.0))
	tir.perforations += int(donnees.get("perforations",0))
	tir.cadence *= float(donnees.get("cadence_mult", 1.0))
	tir.degats *= float(donnees.get("coefficient_tir", 1.0))
	tir.vitesse *= float(donnees.get("vitesse_mult", 1.0))
	tir.portee *= float(donnees.get("portee_mult", 1.0))
	tir.rayon_explosion = float(donnees.get("rayon_explosion", 0.0))
	tir.degats_zone_mult = float(donnees.get("degats_zone_mult", 0.0))
	for drapeau in donnees.get("drapeaux", []):
		var nom := str(drapeau)
		if not nom in tir.drapeaux:
			tir.drapeaux.append(nom)
	return tir
