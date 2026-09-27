class_name DetailsReactif
extends RefCounted

# Les cartes et les exports lisent les memes valeurs que le combat.
static func lignes(reactif: Reactif, copies := 1) -> Array[String]:
	if reactif == null:
		return []
	var resultat: Array[String] = []
	var nombre := maxi(1, copies)
	var poids := float(nombre)
	var mods: Dictionary = reactif.mods
	var libelles := {
		"attaque_mult": "Attaque", "cadence_mult": "Cadence",
		"vitesse_mult": "Vitesse des projectiles", "portee_mult": "Portée",
		"pv_max_mult": "PV max", "defense_mult": "Défense",
		"deplacement_mult": "Déplacement", "soin_mult": "Soins reçus",
		"degats_subis_mult": "Dégâts subis",
		"experience_mult": "XP de la partie", "gouttes_mult": "Gouttes",
		"degats_projectile_mult": "Dégâts des projectiles",
	}
	for cle: String in libelles:
		_ajouter_multiplicateur(resultat, mods, cle, str(libelles[cle]), nombre)
	if mods.has("pv_max_final_mult"):
		resultat.append("PV max totaux ×%s, après les autres bonus de PV" % _nombre(pow(float(mods["pv_max_final_mult"]), nombre)))
	if mods.has("salves_add"):
		var salves := int(mods["salves_add"]) * nombre
		resultat.append("+%d salve%s par attaque" % [salves, "s" if salves > 1 else ""])
	for cle: String in ["degats_salve_mult", "degats_finaux_projectile_mult"]:
		if mods.has(cle):
			resultat.append("Dégâts de chaque projectile ×%s" % _nombre(pow(float(mods[cle]), nombre), 4))
	if mods.has("critique_add"):
		resultat.append("Chance critique +%s points" % _nombre(float(mods["critique_add"]) * 100.0 * poids))
	if mods.has("degats_critiques_add"):
		resultat.append("Dégâts critiques +%s points" % _nombre(float(mods["degats_critiques_add"]) * 100.0 * poids))
	if mods.has("conversion_critique"):
		resultat.append("%s %% de la chance critique au-delà de 100 %% devient des dégâts critiques" % _nombre(float(mods["conversion_critique"]) * 100.0 * poids))
	if mods.has("invulnerabilite_add"):
		resultat.append("Invulnérabilité après un coup +%s s" % _nombre(float(mods["invulnerabilite_add"]) * poids))
	if mods.has("boucliers_salle_add"):
		var boucliers := int(mods["boucliers_salle_add"]) * nombre
		resultat.append("%d bouclier%s par salle · un coup bloqué chacun" % [boucliers, "s" if boucliers > 1 else ""])
	if mods.has("soin_part"):
		resultat.append("Soin immédiat : %s %% des PV max" % _nombre(float(mods["soin_part"]) * 100.0))
	if mods.has("projectiles_lateraux_add"):
		resultat.append("+%d projectiles en diagonale par salve" % (int(mods["projectiles_lateraux_add"]) * nombre))
		resultat.append("Puissance des diagonales : %s %%" % _nombre(ReglagesAugments.PROJECTILE_LATERAL_PART * 100.0))
	elif mods.has("nb_projectiles_add"):
		var projectiles := int(mods["nb_projectiles_add"]) * nombre
		resultat.append("+%d projectile%s %s parallèle%s par salve" % [projectiles,
			"s" if projectiles > 1 else "", "frontaux" if projectiles > 1 else "frontal", "s" if projectiles > 1 else ""])
	if mods.has("rebonds_add"):
		resultat.append("+%d rebonds · −%s %% de dégâts par rebond" % [int(mods["rebonds_add"]) * nombre, _nombre(Reglages.REBOND_PERTE * 100.0)])
	if mods.has("perforations_add"):
		resultat.append("Traverse %d ennemis de plus · −%s %% de dégâts par traversée" % [int(mods["perforations_add"]) * nombre, _nombre(Reglages.PERFORATION_PERTE * 100.0)])
	if "homing" in mods.get("drapeaux", []):
		resultat.append("Projectiles guidés")
	if "perfore_tout" in mods.get("drapeaux", []):
		resultat.append("Traverse tous les ennemis sans perte ; avec Ricochet, rebonds illimités sans perte. Un impact maximum par ennemi et projectile.")
	if "indelebile" in mods.get("drapeaux", []):
		resultat.append("Poursuit la cible à travers les murs et les autres ennemis")
	if "egide" in mods.get("drapeaux", []):
		resultat.append("Rend tous les PV à l'acquisition, une seule fois")
	if "courageux" in mods.get("drapeaux", []):
		resultat.append("Une seconde vie à 100 % des PV, une seule fois par tentative")
	if "elan_vital" in mods.get("drapeaux", []):
		resultat.append("Après %s s de déplacement, la prochaine attaque gagne +%s %% de dégâts sur toutes ses salves" % [_nombre(ReglagesAugments.ELAN_VITAL_CHARGE), _nombre(ReglagesAugments.ELAN_VITAL_BONUS_DEGATS * 100.0)])
	return resultat

static func texte(reactif: Reactif, copies := 1) -> String:
	return "\n".join(lignes(reactif, copies))

static func _ajouter_multiplicateur(resultat: Array[String], mods: Dictionary,
		cle: String, nom: String, copies: int) -> void:
	if not mods.has(cle):
		return
	var exemplaires: Array = []
	for _copie in maxi(1, copies):
		exemplaires.append(mods)
	var pourcentage := (Mods.facteur_heros(exemplaires, cle) - 1.0) * 100.0
	resultat.append("%s %s%s %%" % [nom, "+" if pourcentage >= 0.0 else "−", _nombre(absf(pourcentage))])

static func _nombre(valeur: float, decimales := 2) -> String:
	if is_equal_approx(valeur, roundf(valeur)):
		return str(roundi(valeur))
	var texte := String.num(valeur, decimales)
	if texte.contains("."):
		while texte.ends_with("0"):
			texte = texte.trim_suffix("0")
		texte = texte.trim_suffix(".")
	return texte.replace(".", ",")
