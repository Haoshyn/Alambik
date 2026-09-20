class_name Mods
extends RefCounted

# Un reactif ne contient pas de logique : il decrit ce qu'il change.
#
# Les pourcentages d'attaque rejoignent ceux des maitrises dans une meme somme.
# Les coefficients de tir et les deblocages magiques interviennent ensuite.

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
	"cadence_mult": "cadence",
	"vitesse_mult": "vitesse",
	"portee_mult": "portee",
}

# Chaque copie applique son bonus complet ; les doublons restent dans la liste.
static func depuis_l_inventaire(inventaire: Array) -> Array:
	var liste: Array = []
	for id in inventaire:
		var reactif := CatalogueReactifs.par_id(id)
		if reactif != null:
			liste.append(reactif.mods)
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

static func bonus_attaque(mods_liste: Array, pour_sort := false) -> float:
	var bonus := 0.0
	for mod: Dictionary in mods_liste:
		bonus += float(mod.get("attaque_mult", 1.0)) - 1.0
		if pour_sort:
			bonus += float(mod.get("attaque_sorts_mult", 1.0)) - 1.0
	return bonus

static func appliquer(base: Tir, mods_liste: Array) -> Tir:
	var t := base.copie()
	t.bonus_attaque += bonus_attaque(mods_liste)
	if t.attaque_base > 0.0:
		t.degats = t.attaque_base * maxf(Reglages.MODS_PLANCHER, 1.0 + t.bonus_attaque)
	else:
		t.degats *= maxf(Reglages.MODS_PLANCHER, 1.0 + bonus_attaque(mods_liste))
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
