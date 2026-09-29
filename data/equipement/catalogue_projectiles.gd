class_name CatalogueProjectiles
extends RefCounted

# Une arme forgeable apporte de l'attaque de base a toutes les attaques.
# Son coefficient de tir ne concerne que sa forme de projectile.
const ATTAQUE_BASE := 4.0
const FORGE_ATTAQUE_PAR_NIVEAU := 1.0
const FORGE_RANGS_INITIAUX := 2
const FORGE_ATTAQUE_PAR_NIVEAU_TARDIF := 0.35
static var TYPES := _avec_descriptions({
	"standard": {"nom": "Baguette d’acier", "monde": 1, "niveau": 1, "coefficient_tir": 1.0},
	"veloce": {"nom": "Aiguille vive", "monde": 2, "niveau": 4, "coefficient_tir": 0.85, "cadence_mult": 1.20, "portee_mult": 0.90},
	"lourd": {"nom": "Sceptre de cuivre", "monde": 3, "niveau": 7, "coefficient_tir": 1.50, "cadence_mult": 0.70},
	"chercheur": {"nom": "Branche astrale", "monde": 4, "niveau": 10, "coefficient_tir": 1.05, "perforations": 1},
	"explosif": {"nom": "Bâton à étincelles", "monde": 5, "niveau": 13, "coefficient_tir": 1.10, "critique": 0.03},
	"prisme": {"nom": "Prisme jumeau", "monde": 6, "niveau": 16, "coefficient_tir": 0.60, "nb_projectiles": 1, "ecart_lateral": 30.0, "part_projectiles_supplementaires": 1.0},
	"resonant": {"nom": "Diapason de verre", "monde": 7, "niveau": 19, "coefficient_tir": 0.90, "cadence_mult": 1.30},
	"draconique": {"nom": "Cornue draconique", "monde": 8, "niveau": 22, "coefficient_tir": 1.10, "cadence_mult": 1.10, "attaque_mult": 0.05},
	"neant": {"nom": "Aiguille du néant", "monde": 9, "niveau": 25, "coefficient_tir": 1.15, "cadence_mult": 1.10, "perforations": 1},
	"royal": {"nom": "Alambic souverain", "monde": 10, "niveau": 28, "coefficient_tir": 1.15, "cadence_mult": 1.10},
})

static func _avec_descriptions(types: Dictionary) -> Dictionary:
	for id: String in types:
		var donnees: Dictionary = types[id]
		var coefficient := float(donnees.get("coefficient_tir", 1.0))
		var projectiles := 1 + int(donnees.get("nb_projectiles", 0))
		var morceaux: Array[String] = ["Tir %s %%" % _nombre(coefficient * 100.0)]
		if projectiles > 1:
			morceaux[0] = "%d traits de %s %%, soit %s %% au total" % [projectiles, _nombre(coefficient * 100.0), _nombre(coefficient * projectiles * 100.0)]
		for champ: String in ["cadence_mult", "portee_mult"]:
			var bonus := (float(donnees.get(champ, 1.0)) - 1.0) * 100.0
			if not is_zero_approx(bonus):
				morceaux.append("%s %s%s %%" % ["cadence" if champ == "cadence_mult" else "portée", "+" if bonus > 0.0 else "−", _nombre(absf(bonus))])
		for champ: String in ["critique", "attaque_mult"]:
			if donnees.has(champ):
				morceaux.append("%s +%s %%" % ["chance critique" if champ == "critique" else "attaque", _nombre(float(donnees[champ]) * 100.0)])
		if int(donnees.get("perforations", 0)) > 0:
			morceaux.append("traverse %d ennemi" % int(donnees["perforations"]))
		donnees["description"] = ", ".join(morceaux) + "."
	return types

static func _nombre(valeur: float) -> String:
	return String.num(valeur, 2).trim_suffix(".0").replace(".", ",")

static func contient(id: String) -> bool:
	return TYPES.has(id)

static func attaque_base(id: String, niveau_forge: int) -> float:
	if not contient(id):
		return 0.0
	var croissance := pow(Reglages.EQUIPEMENT_CROISSANCE_PAR_PALIER, niveau_deblocage(id) - 1)
	var forge := clampi(niveau_forge, 0, Reglages.FORGE_NIVEAU_MAX)
	var initial := mini(forge, FORGE_RANGS_INITIAUX)
	# Les premiers achats lancent le build ; les autres familles prennent
	# ensuite leur place sans laisser la forge dominer le compte complet.
	return (ATTAQUE_BASE + FORGE_ATTAQUE_PAR_NIVEAU * float(initial)
		+ FORGE_ATTAQUE_PAR_NIVEAU_TARDIF * float(forge - initial)) * croissance

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
