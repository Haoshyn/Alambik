class_name CatalogueProjectiles
extends RefCounted

# Une arme forgeable apporte de l'attaque de base a tous les coups et sorts.
# Son coefficient de tir ne concerne que sa forme de projectile.
const ATTAQUE_BASE := 4.0
const FORGE_ATTAQUE_PAR_NIVEAU := 2.5
const TYPES := {
	"standard": {"nom": "Baguette d’acier", "description": "Un trait simple à 100 % de l’ATK.", "monde": 1, "niveau": 1, "coefficient_tir": 1.0},
	"veloce": {"nom": "Aiguille vive", "description": "Tir 80 %, cadence +20 %, portée −10 %.", "monde": 2, "niveau": 4, "coefficient_tir": 0.80, "cadence_mult": 1.20, "portee_mult": 0.90},
	"lourd": {"nom": "Sceptre de cuivre", "description": "Tir 150 %, cadence −30 %.", "monde": 3, "niveau": 7, "coefficient_tir": 1.50, "cadence_mult": 0.70},
	"chercheur": {"nom": "Branche astrale", "description": "Tir 110 %, dégâts des sorts +20 %, récupération des sorts −20 %.", "monde": 4, "niveau": 10, "coefficient_tir": 1.10, "degats_sorts": 0.20, "recharge_mult": 0.80},
	"explosif": {"nom": "Bâton à étincelles", "description": "Tir 100 %, cadence +10 %, dégâts de zone à l’impact.", "monde": 5, "niveau": 13, "coefficient_tir": 1.0, "cadence_mult": 1.10, "rayon_explosion": 150.0, "degats_zone_mult": 0.45},
	"prisme": {"nom": "Prisme jumeau", "description": "Deux traits parallèles de 70 %, soit 140 % au total, à cadence normale.", "monde": 6, "niveau": 16, "coefficient_tir": 0.70, "nb_projectiles": 1, "ecart_lateral": 30.0, "part_projectiles_supplementaires": 1.0},
	"resonant": {"nom": "Diapason de verre", "description": "Tir 90 %, cadence +50 %.", "monde": 7, "niveau": 19, "coefficient_tir": 0.90, "cadence_mult": 1.50},
	"draconique": {"nom": "Cornue draconique", "description": "Tir 100 %, dégâts des sorts +30 %. Après un sort : dégâts et cadence +20 % pendant 5 s.", "monde": 8, "niveau": 22, "coefficient_tir": 1.0, "degats_sorts": 0.30, "apres_sort_degats": 0.20, "apres_sort_cadence": 0.20, "apres_sort_duree": 5.0},
	"neant": {"nom": "Aiguille du néant", "description": "Tir 150 %, cadence +50 %.", "monde": 9, "niveau": 25, "coefficient_tir": 1.50, "cadence_mult": 1.50},
	"royal": {"nom": "Alambic souverain", "description": "Tir 200 %, cadence +100 %, dégâts des sorts +50 %, récupération des sorts −50 %.", "monde": 10, "niveau": 28, "coefficient_tir": 2.0, "cadence_mult": 2.0, "degats_sorts": 0.50, "recharge_mult": 0.50},
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
	var portee_mult := float(donnees.get("portee_mult", 1.0))
	tir.portee *= portee_mult
	if portee_mult < 1.0:
		tir.portee_limitee = true
	tir.rayon_explosion = float(donnees.get("rayon_explosion", 0.0))
	tir.degats_zone_mult = float(donnees.get("degats_zone_mult", 0.0))
	if donnees.has("part_projectiles_supplementaires"):
		tir.degats_projectiles_supplementaires = float(donnees["part_projectiles_supplementaires"])
	for drapeau in donnees.get("drapeaux", []):
		var nom := str(drapeau)
		if not nom in tir.drapeaux:
			tir.drapeaux.append(nom)
	return tir

static func bonus_heros(id: String) -> Dictionary:
	var donnees: Dictionary = TYPES.get(id, TYPES["standard"])
	return {"degats_sorts": float(donnees.get("degats_sorts", 0.0))}
