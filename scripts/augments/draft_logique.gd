class_name DraftLogique
extends RefCounted

# Une offre partage sa rarete pour comparer des choix de meme budget.
# Sans rarete explicite, les modes annexes piochent parmi les rares et epiques.
static func candidats(inventaire: Array, rarete := "", niveau := 0) -> Array[String]:
	var liste: Array[String] = []
	for id in CatalogueReactifs.ids():
		var reactif := CatalogueReactifs.par_id(id)
		if rarete.is_empty() and reactif.rarete in [Reactif.COMMUN, Reactif.LEGENDAIRE]:
			continue
		if not rarete.is_empty() and reactif.rarete != rarete:
			continue
		if copies(inventaire, id) >= reactif.copies_permises():
			continue
		var incompatible := false
		for autre: String in CatalogueReactifs.INCOMPATIBILITES.get(id, []):
			if autre in inventaire: incompatible = true
		if incompatible: continue
		if niveau > ProgressionAugments.DERNIER_NIVEAU_AVIDITE and id == "avidite":
			continue
		liste.append(id)
	return liste

static func proposer(inventaire: Array, rng: RandomNumberGenerator, nb := ProgressionAugments.NOMBRE_CHOIX,
		rarete := "", niveau := 0, eviter: Array = []) -> Array[String]:
	var restants := candidats(inventaire, rarete, niveau)
	var tirage: Array[String] = []
	var familles: Array[String] = []
	while tirage.size() < nb and not restants.is_empty():
		var nouveaux: Array[String] = []
		for id in restants:
			if id not in eviter:
				nouveaux.append(id)
		var source: Array[String] = nouveaux if not nouveaux.is_empty() else restants
		var varies: Array[String] = []
		# La famille ne favorise aucune legendaire.
		for id in source:
			if rarete != Reactif.LEGENDAIRE and CatalogueReactifs.par_id(id).famille not in familles:
				varies.append(id)
		if varies.is_empty():
			varies = source.duplicate()
		var choix: String = varies[rng.randi_range(0, varies.size() - 1)]
		tirage.append(choix)
		familles.append(CatalogueReactifs.par_id(choix).famille)
		restants.erase(choix)
	return tirage

static func copies(inventaire: Array, id: String) -> int:
	return inventaire.count(id)
