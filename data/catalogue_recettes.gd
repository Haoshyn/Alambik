class_name CatalogueRecettes
extends RefCounted

# Les recettes sont des comportements composes, pas 180 variantes nominales.
# Les anciens Elements restent lisibles pour les sauvegardes et outils existants.
const PREFIXE := "recette__"
const VITESSE_CHARGE_MIN := 0.1
const PARTENAIRES := {"feu":"eau", "eau":"feu"}
const TOUS := {
	"braises": {"nom":"Braises en chaîne", "element":"feu", "familles":["projectile"], "description":"Trois impacts sur une cible préparent une explosion. Une réaction d’eau peut la déclencher plus tôt.", "seuil":3, "delai":0.7, "part":0.85, "rayon":150.0},
	"perles": {"nom":"Perles de rupture", "element":"eau", "familles":["projectile"], "description":"Tous les quatre impacts, une bulle éclate et mouille les ennemis proches. Sur des braises : explosion de vapeur.", "seuil":4, "part":0.75, "rayon":165.0, "recharge":0.8},
	"retour": {"nom":"Retour de souffle", "element":"air", "familles":["projectile"], "description":"Trois lancers préparent deux échos guidés. Les échos portent les braises et les perles de vos autres fusions.", "seuil":3, "part":0.45, "angle":0.32, "recharge":0.65},
	"rosee": {"nom":"Pas de rosée", "element":"eau", "familles":["heros"], "description":"Courir prépare jusqu’à trois perles. Votre prochain lancer les libère : elles mouillent les cibles et font réagir les braises.", "charge":0.7, "maximum":3, "part":0.45, "angle":0.20},
	"secours": {"nom":"Souffle de secours", "element":"air", "familles":["heros"], "description":"Un coup reçu ou une Égide brisée repousse les ennemis et dissipe les tirs proches. Se recharge en six secondes.", "recharge":6.0, "rayon":240.0, "poussee":180.0, "part":0.5},
	"fournaise": {"nom":"Cœur de fournaise", "element":"feu", "familles":["heros"], "description":"Quatre lancers sans repartir en course font éclore une flamme sous votre cible. Elle amorce aussi les réactions de vapeur.", "seuil":4, "part":1.1, "rayon":140.0},
	"failles": {"nom":"Jardin de failles", "element":"terre", "familles":["phenomene"], "description":"Une faille germe sous un ennemi, puis éclate après un court délai. Mouiller la cible aide à la garder dans la zone.", "recharge":3.0, "delai":0.75, "part":1.5, "rayon":155.0},
	"constellation": {"nom":"Constellation liquide", "element":"eau", "familles":["phenomene"], "description":"Un courant relie jusqu’à trois ennemis proches, les mouille et déclenche leurs braises. Chaque cible n’est frappée qu’une fois.", "recharge":3.2, "maximum":3, "part":0.5, "portee":360.0},
	"distillation": {"nom":"Cercle de distillation", "element":"feu", "familles":["sceau"], "description":"Toutes les deux secondes, les ennemis proches reçoivent une braise. Approchez-vous pour préparer une réaction, puis reprenez vos distances.", "recharge":2.0, "rayon":260.0},
	"reserve": {"nom":"Réserve lumineuse", "element":"lumiere", "familles":["sceau"], "description":"Toutes les quatre éliminations : récupérez 3 % de vie. À pleine vie, préparez plutôt une perle offensive pour votre prochain lancer.", "seuil":4, "soin":0.03, "part":1.2, "maximum":2},
}
const REACTION := {"part":1.25, "rayon":175.0, "recharge":1.0, "duree_marque":4.0, "maximum_marques":32}

static func id_fusion(recette: String, augment: String) -> String:
	return "%s%s__%s" % [PREFIXE,recette,augment]

static func est_fusion(id: String) -> bool:
	return id.begins_with(PREFIXE) and id.split("__").size() == 3

static func recette_de(id: String) -> String:
	return id.split("__")[1] if est_fusion(id) else ""

static func augment_de(id: String) -> String:
	return id.split("__")[2] if est_fusion(id) else ""

static func compatibles(augment: String) -> Array[String]:
	var resultat: Array[String] = []
	var base := CatalogueReactifs.par_id(augment)
	if base == null: return resultat
	for id in TOUS:
		if base.famille in TOUS[id]["familles"]: resultat.append(id)
	return resultat

static func creer(id: String) -> Reactif:
	var recette := recette_de(id)
	var augment := augment_de(id)
	if recette not in compatibles(augment): return null
	var r: Dictionary = TOUS[recette]
	var element := CatalogueElements.par_id(r["element"])
	return Reactif.creer(id,r["nom"],r["description"],{},true,element["teinte"],element["glyphe"],1,CatalogueReactifs.par_id(augment).famille)

static func proposer(inventaire: Array, rng: RandomNumberGenerator) -> Array[String]:
	var deja: Array[String] = []
	var recettes: Array[String] = []
	for id in inventaire:
		if est_fusion(id):
			deja.append(augment_de(id))
			recettes.append(recette_de(id))
		elif CatalogueElements.est_fusion(id): deja.append(CatalogueElements.augment_de_fusion(id))
	var candidats: Array[String] = []
	for augment in inventaire:
		if augment in deja: continue
		for recette in compatibles(augment):
			if recette not in recettes: candidats.append(id_fusion(recette,augment))
	var resultat: Array[String] = []
	while resultat.size() < 3 and not candidats.is_empty():
		var affinites: Array[String] = []
		if resultat.is_empty():
			for id in candidats:
				var element: String = TOUS[recette_de(id)]["element"]
				for acquise in recettes:
					if PARTENAIRES.get(TOUS[acquise]["element"],"") == element:
						affinites.append(id)
						break
		var pool := candidats if affinites.is_empty() else affinites
		var choix: String = pool[rng.randi_range(0,pool.size()-1)]
		resultat.append(choix)
		# Une proposition par recette : les trois cartes doivent offrir des comportements differents.
		var restants: Array[String] = []
		for id in candidats:
			if recette_de(id) != recette_de(choix): restants.append(id)
		candidats = restants
	return resultat
