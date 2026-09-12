class_name DetailsReactif
extends RefCounted

# Traduit les donnees de combat en chiffres destines au joueur. Cette couche
# evite d'afficher les noms techniques des mods ("cadence_mult", etc.) dans
# les interfaces et garde les valeurs affichees liees aux reglages reels.

static func lignes(reactif: Reactif, copies := 1) -> Array[String]:
	if reactif == null:
		return []
	var resultat: Array[String] = []
	var poids := _poids_copies(maxi(1, copies))
	var mods := reactif.mods
	_ajouter_multiplicateur(resultat, mods, "degats_mult", "Dégâts", copies)
	_ajouter_multiplicateur(resultat, mods, "cadence_mult", "Cadence de tir", copies)
	_ajouter_multiplicateur(resultat, mods, "vitesse_mult", "Vitesse des projectiles", copies)
	_ajouter_multiplicateur(resultat, mods, "portee_mult", "Portée", copies)
	_ajouter_entier(resultat, mods, "nb_projectiles_add", "projectile", copies)
	_ajouter_entier(resultat, mods, "rebonds_add", "rebond", copies)
	_ajouter_entier(resultat, mods, "perforations_add", "ennemi traversé", copies)
	_ajouter_entier(resultat, mods, "fragments_add", "fragment à l'impact", copies)
	if mods.has("angle_eventail_add"):
		resultat.append("Angle de l’éventail +%s°" % _nombre(rad_to_deg(float(mods["angle_eventail_add"])) * poids))
	if mods.has("ecart_lateral_add"):
		resultat.append("Écart latéral +%s" % _nombre(float(mods["ecart_lateral_add"]) * poids))
	for effet in mods.get("effets", []):
		resultat.append(_detail_effet(effet))
	for drapeau in mods.get("drapeaux", []):
		resultat.append(_detail_drapeau(drapeau))
	return resultat

static func texte(reactif: Reactif, copies := 1) -> String:
	return "\n".join(lignes(reactif, copies))

static func _poids_copies(copies: int) -> float:
	var total := 0.0
	for index in copies:
		total += Mods.rendement(index)
	return total

static func _ajouter_multiplicateur(resultat: Array[String], mods: Dictionary,
		cle: String, nom: String, copies: int) -> void:
	if not mods.has(cle):
		return
	var facteur := float(mods[cle])
	var total := 1.0 + (facteur - 1.0) * _poids_copies(maxi(1,copies))
	if facteur < 1.0:
		total = 1.0
		for index in maxi(1,copies):
			total *= 1.0 + (facteur - 1.0) * Mods.rendement(index)
	var pourcentage := (maxf(Reglages.MODS_PLANCHER,total) - 1.0) * 100.0
	resultat.append("%s %s%s %%" % [nom, "+" if pourcentage >= 0.0 else "", _nombre(pourcentage)])

static func _ajouter_entier(resultat: Array[String], mods: Dictionary,
		cle: String, singulier: String, copies: int) -> void:
	if not mods.has(cle):
		return
	var valeur := int(mods[cle]) * maxi(1, copies)
	resultat.append("+%d %s%s" % [valeur, singulier, "s" if valeur > 1 else ""])

static func _detail_effet(effet: String) -> String:
	match effet:
		"feu": return "Brûlures cumulatives proportionnelles aux dégâts"
		"eau": return "Mouillé : cible ralentie et vulnérable"
		"terre": return "Impact lourd : retarde la prochaine attaque"
		"lumiere": return "Rend une part des dégâts sous forme de vie"
	return effet.capitalize()

static func _detail_drapeau(drapeau: String) -> String:
	match drapeau:
		"rafale": return "Rafale de %d tirs, intervalle %s s" % [Reglages.RAFALE_NOMBRE, _nombre(Reglages.RAFALE_INTERVALLE)]
		"egide": return "Annule la première attaque de chaque salle"
		"regeneration": return "Récupère %s %% des PV max entre les salles" % _nombre(Reglages.REGENERATION_PART * 100.0)
		"avidite": return "XP +%s %% · Gouttes +%s %%" % [_nombre((Reglages.AVIDITE_XP_MULT-1.0)*100.0),_nombre((Reglages.AVIDITE_GOUTTES_MULT-1.0)*100.0)]
		"courageux": return "Jusqu’à +%s %% de dégâts à très faibles PV" % _nombre(Reglages.COURAGEUX_BONUS_MAX*100.0)
		"mannequin": return "Après %s s immobile : dégâts +%s %% · cadence +%s %%" % [_nombre(Reglages.MANNEQUIN_DELAI),_nombre((Reglages.MANNEQUIN_DEGATS_MULT-1.0)*100.0),_nombre((Reglages.MANNEQUIN_CADENCE_MULT-1.0)*100.0)]
		"elan_vital": return "Après un déplacement : dégâts +%s %% pendant %s s" % [_nombre((Reglages.ELAN_VITAL_DEGATS_MULT-1.0)*100.0),_nombre(Reglages.ELAN_VITAL_DUREE)]
		"soif_de_sang": return "Chaque élimination rend %s %% des PV max" % _nombre(Reglages.SOIF_DE_SANG_PART*100.0)
		"peau_de_pierre": return "Dégâts subis −%s %%" % _nombre(Reglages.PEAU_DE_PIERRE_REDUCTION*100.0)
		"sceau_garde": return "Dégâts subis −%s %%" % _nombre(Reglages.SCEAU_GARDE_REDUCTION*100.0)
	return drapeau.replace("_", " ").capitalize()

static func _nombre(valeur: float) -> String:
	if is_equal_approx(valeur, roundf(valeur)):
		return str(roundi(valeur))
	return ("%.2f" % valeur).trim_suffix("0").trim_suffix("0").trim_suffix(".")
