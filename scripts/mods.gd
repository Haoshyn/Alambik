class_name Mods
extends RefCounted

# Un reactif ne contient pas de logique : il decrit ce qu'il change.
#
# Les pourcentages de run forment un budget distinct des Maitrises permanentes.
# Ils s'additionnent entre eux, puis multiplient l'attaque permanente une fois.

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
	"degats_projectile_mult": "degats",
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

static func bonus_heros(mods_liste: Array, cle: String) -> float:
	var bonus := 0.0
	for mod: Dictionary in mods_liste:
		bonus += float(mod.get(cle, 0.0))
	return bonus

static func bonus_attaque(mods_liste: Array, pour_sort := false) -> float:
	var bonus := 0.0
	var annule_malus := _contient_drapeau(mods_liste, "annule_malus_degats")
	for mod: Dictionary in mods_liste:
		var attaque := float(mod.get("attaque_mult", 1.0))
		if attaque >= 1.0 or not annule_malus:
			bonus += attaque - 1.0
		if pour_sort:
			bonus += float(mod.get("attaque_sorts_mult", 1.0)) - 1.0
	return bonus

static func facteur_attaque_run(mods_liste: Array, pour_sort := false) -> float:
	return maxf(Reglages.MODS_PLANCHER, 1.0 + bonus_attaque(mods_liste, pour_sort))

static func appliquer(base: Tir, mods_liste: Array) -> Tir:
	var t := base.copie()
	t.degats *= facteur_attaque_run(mods_liste)
	t.degats_projectiles_supplementaires = Reglages.PROJECTILE_SUPPLEMENTAIRE_PART
	var cumuls := {}
	var penalites := {}
	var annule_malus := _contient_drapeau(mods_liste, "annule_malus_degats")
	if annule_malus:
		t.degats_projectiles_supplementaires = 1.0
	for mod in mods_liste:
		if bool(mod.get("projectiles_pleine_puissance", false)):
			t.degats_projectiles_supplementaires = 1.0
		var malus_final := float(mod.get("degats_finaux_projectile_mult", 1.0))
		if malus_final < 1.0 and not annule_malus:
			t.degats_finaux_projectile_mult *= malus_final
		for cle in CHAMPS_ADD:
			if mod.has(cle):
				t.set(CHAMPS_ADD[cle], t.get(CHAMPS_ADD[cle]) + mod[cle])
		for cle in CHAMPS_MULT:
			if mod.has(cle):
				var champ: String = CHAMPS_MULT[cle]
				var facteur := float(mod[cle])
				if facteur < 1.0:
					if champ == "degats" and annule_malus:
						continue
					penalites[champ] = float(penalites.get(champ, 1.0)) * facteur
				else:
					cumuls[champ] = float(cumuls.get(champ, 0.0)) + facteur - 1.0
		for liste in ["effets", "drapeaux"]:
			if mod.has(liste):
				for valeur in mod[liste]:
					if not valeur in t.get(liste):
						t.get(liste).append(valeur)
	# Les bonus restent additifs et les couts se composent. Seule Frappe
	# cataclysmique retire explicitement les malus de degats.
	for champ in CHAMPS_MULT.values():
		var facteur := (1.0 + float(cumuls.get(champ, 0.0))) * float(penalites.get(champ, 1.0))
		t.set(champ, t.get(champ) * maxf(Reglages.MODS_PLANCHER, facteur))
	if float(penalites.get("portee", 1.0)) < 1.0:
		t.portee_limitee = true
	if "perfore_tout" in t.drapeaux and t.rebonds > 0:
		t.drapeaux.append("ricochet_perforation_infinie")
	return t

static func _contient_drapeau(mods_liste: Array, drapeau: String) -> bool:
	for mod: Dictionary in mods_liste:
		if drapeau in mod.get("drapeaux", []):
			return true
	return false
