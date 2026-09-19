class_name Mods
extends RefCounted

# Un reactif ne contient pas de logique : il decrit ce qu'il change.
#
# Les bonus positifs s'additionnent au lieu de se composer : deux fois +45 %
# donnent +90 %, pas +110 %. En produit, quatre reactifs de degats faisaient
# une main six fois plus forte que la moyenne — c'est la definition d'une
# combinaison cassee. La somme reste commutative, donc l'ordre d'acquisition
# ne change toujours rien au resultat.

const CHAMPS_ADD := {
	"nb_projectiles_add": "nb_projectiles",
	"projectiles_lateraux_add": "projectiles_lateraux",
	"rebonds_add": "rebonds",
	"perforations_add": "perforations",
	"fragments_add": "fragments",
	"angle_eventail_add": "angle_eventail",
	"ecart_lateral_add": "ecart_lateral",
}

const CHAMPS_MULT := {
	"degats_mult": "degats",
	"cadence_mult": "cadence",
	"vitesse_mult": "vitesse",
	"portee_mult": "portee",
}

# Un bonus annonce reste identique a chaque choix ; les bonus se cumulent
# sur la base de depart. Les pouvoirs de projectile, eux, restent uniques.
static func rendement(_copie: int) -> float:
	return 1.0

# Les champs entiers ne se ponderent pas : un demi-projectile n'existe pas.
# Les reactifs qui en donnent sont plafonnes plus bas, dans leur catalogue.
static func pondere(mod: Dictionary, facteur: float) -> Dictionary:
	if facteur >= 0.999:
		return mod
	var resultat := {}
	for cle in mod:
		if CHAMPS_MULT.has(cle) or cle in ["pv_max_mult", "deplacement_mult"]:
			resultat[cle] = 1.0 + (float(mod[cle]) - 1.0) * facteur
		elif cle in ["angle_eventail_add", "ecart_lateral_add"]:
			resultat[cle] = float(mod[cle]) * facteur
		else:
			resultat[cle] = mod[cle]
	return resultat

# La liste de mods d'un inventaire, doublons compris et ponderes.
static func depuis_l_inventaire(inventaire: Array) -> Array:
	var vus := {}
	var liste: Array = []
	for id in inventaire:
		var reactif := CatalogueReactifs.par_id(id)
		if reactif == null:
			reactif = CatalogueElements.creer_fusion(CatalogueElements.element_de_fusion(id),
				CatalogueElements.augment_de_fusion(id))
		if reactif == null:
			continue
		var deja: int = vus.get(id, 0)
		vus[id] = deja + 1
		liste.append(pondere(reactif.mods, rendement(deja)))
	return liste

static func facteur_heros(mods_liste: Array, cle: String) -> float:
	var bonus := 0.0
	var penalite := 1.0
	for mod: Dictionary in mods_liste:
		var facteur := float(mod.get(cle, 1.0))
		if facteur < 1.0:
			penalite *= facteur
		else:
			bonus += facteur - 1.0
	return maxf(Reglages.MODS_PLANCHER, (1.0 + bonus) * penalite)

static func appliquer(base: Tir, mods_liste: Array) -> Tir:
	var t := base.copie()
	var cumuls := {}
	var penalites := {}
	for mod in mods_liste:
		for cle in CHAMPS_ADD:
			if mod.has(cle):
				t.set(CHAMPS_ADD[cle], t.get(CHAMPS_ADD[cle]) + mod[cle])
		for cle in CHAMPS_MULT:
			if mod.has(cle):
				var champ: String = CHAMPS_MULT[cle]
				var facteur := float(mod[cle])
				if facteur < 1.0:
					penalites[champ] = float(penalites.get(champ, 1.0)) * facteur
				else:
					cumuls[champ] = float(cumuls.get(champ, 0.0)) + facteur - 1.0
		for liste in ["effets", "drapeaux"]:
			if mod.has(liste):
				for valeur in mod[liste]:
					if not valeur in t.get(liste):
						t.get(liste).append(valeur)
	# Les bonus restent additifs ; les couts se composent pour ne jamais
	# s'annuler entre eux ni etre effaces par un simple bonus de puissance.
	for champ in CHAMPS_MULT.values():
		var facteur := (1.0 + float(cumuls.get(champ, 0.0))) * float(penalites.get(champ, 1.0))
		t.set(champ, t.get(champ) * maxf(Reglages.MODS_PLANCHER, facteur))
	return t
