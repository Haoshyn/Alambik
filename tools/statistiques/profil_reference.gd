extends RefCounted

const Modeles = preload("res://tools/statistiques/modeles.gd")

# Ce panier fixe represente dix choix sans legendaire bonus. La recherche optimise seulement
# l'equipement actif, pour une cible frontale et un tir continu sans deplacement.
const AUGMENTS_CLASSIQUES := [
	"salve", "tir_multiple", "peau_cuivre", "baume_profond", "sceau_garde", "cadence_febrile",
	"trait_transpercant", "peau_de_pierre", "encre_mordante", "courageux",
]

static var _configuration_cache: Dictionary = {}
static var _combinaisons_evaluees := 0

static func construire() -> Dictionary:
	if _configuration_cache.is_empty():
		_chercher_equipement()
	# L'attribution des sources retire des familles dans ses propres copies.
	# Aucune de ces variantes ne doit contaminer la reference mise en cache.
	return _configuration_cache.duplicate(true)

static func nombre_combinaisons() -> int:
	if _configuration_cache.is_empty():
		_chercher_equipement()
	return _combinaisons_evaluees

static func _chercher_equipement() -> void:
	var candidat := Modeles.complet()
	candidat["conditions"] = true
	candidat["augments"] = AUGMENTS_CLASSIQUES.duplicate()
	var armes := CatalogueProjectiles.disponibles(Chapitres.nombre())
	var familiers := CatalogueFamiliers.disponibles(Chapitres.nombre())
	var anneaux := _bijoux_actifs("anneau")
	var bracelets := _bijoux_actifs("bracelet")
	var colliers := _bijoux_actifs("collier")
	var meilleur_dps := -INF
	_combinaisons_evaluees = 0
	for arme: String in armes:
		candidat["arme"] = arme
		for familier: String in familiers:
			candidat["familier"] = familier
			for anneau: String in anneaux:
				for bracelet: String in bracelets:
					for collier: String in colliers:
						candidat["bijoux"] = {"anneau": anneau, "bracelet": bracelet, "collier": collier}
						candidat["forge_bijoux"] = {anneau: Reglages.FORGE_NIVEAU_MAX,
							bracelet: Reglages.FORGE_NIVEAU_MAX, collier: Reglages.FORGE_NIVEAU_MAX}
						var mesure := Modeles.mesurer(candidat)
						var dps := float(mesure["dps"])
						_combinaisons_evaluees += 1
						if dps > meilleur_dps:
							meilleur_dps = dps
							_configuration_cache = candidat.duplicate(true)

static func _bijoux_actifs(slot: String) -> Array[String]:
	var resultat: Array[String] = []
	for id: String in CatalogueObjets.OBJETS:
		var objet: Dictionary = CatalogueObjets.OBJETS[id]
		var monde := int(objet["monde"])
		if str(objet["slot"]) == slot and monde >= 0 and monde < Chapitres.MONDES.size():
			resultat.append(id)
	return resultat
