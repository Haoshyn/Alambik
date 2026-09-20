class_name DetailsReactif
extends RefCounted

# Traduit les donnees de combat en chiffres destines au joueur. Cette couche
# evite d'afficher les noms techniques des mods ("cadence_mult", etc.) dans
# les interfaces et garde les valeurs affichees liees aux reglages reels.

static func lignes(reactif: Reactif, copies := 1) -> Array[String]:
	if reactif == null:
		return []
	var resultat: Array[String] = []
	var poids := float(maxi(1, copies))
	var mods := reactif.mods
	_ajouter_multiplicateur(resultat, mods, "attaque_mult", "Attaque", copies)
	_ajouter_multiplicateur(resultat, mods, "cadence_mult", "Cadence de tir", copies)
	_ajouter_multiplicateur(resultat, mods, "vitesse_mult", "Vitesse des projectiles", copies)
	_ajouter_multiplicateur(resultat, mods, "portee_mult", "Portée", copies)
	_ajouter_multiplicateur(resultat, mods, "pv_max_mult", "PV maximum", copies)
	_ajouter_multiplicateur(resultat, mods, "deplacement_mult", "Déplacement", copies)
	_ajouter_multiplicateur(resultat, mods, "attaque_sorts_mult", "Attaque des sorts", copies)
	_ajouter_multiplicateur(resultat, mods, "recharge_sorts_mult", "Récupération des sorts", copies)
	_ajouter_multiplicateur(resultat, mods, "rayon_sorts_mult", "Rayon du sort actif", copies)
	if mods.has("soin_part"):
		resultat.append("Soin immédiat : %s %% des PV max" % _nombre(float(mods["soin_part"]) * 100.0))
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

static func _ajouter_multiplicateur(resultat: Array[String], mods: Dictionary,
		cle: String, nom: String, copies: int) -> void:
	if not mods.has(cle):
		return
	var facteur := float(mods[cle])
	var total := 1.0 + (facteur - 1.0) * float(maxi(1, copies))
	if facteur < 1.0:
		total = pow(facteur, maxi(1, copies))
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
		"braise": return "Brûlure proportionnelle aux dégâts"
		"givre": return "Ralentit la cible"
		"acide": return "Rend la cible vulnérable"
	return effet.capitalize()

static func _detail_drapeau(drapeau: String) -> String:
	match drapeau:
		"rafale": return "Rafale de %d tirs, intervalle %s s" % [Reglages.RAFALE_NOMBRE, _nombre(Reglages.RAFALE_INTERVALLE)]
		"homing": return "Les projectiles se dirigent vers les ennemis"
		"perfore_tout": return "Traverse tous les ennemis ; dégâts −%s %% à chaque traversée" % _nombre(Reglages.PERFORATION_PERTE * 100.0)
		"egide": return "Annule la première attaque de chaque salle"
		"regeneration": return "Entre les salles : soin de %s %% des PV max, dans le budget partagé des soins" % _nombre(Reglages.REGENERATION_PART * 100.0)
		"avidite": return "XP +%s %% · Gouttes +%s %%" % [_nombre((Reglages.AVIDITE_XP_MULT-1.0)*100.0),_nombre((Reglages.AVIDITE_GOUTTES_MULT-1.0)*100.0)]
		"courageux": return "Jusqu’à +%s %% d’attaque à très faibles PV" % _nombre(Reglages.COURAGEUX_BONUS_MAX*100.0)
		"mannequin": return "Après %s s immobile : attaque +%s %% · cadence +%s %%" % [_nombre(Reglages.MANNEQUIN_DELAI),_nombre((Reglages.MANNEQUIN_DEGATS_MULT-1.0)*100.0),_nombre((Reglages.MANNEQUIN_CADENCE_MULT-1.0)*100.0)]
		"elan_vital": return "Après un déplacement : attaque +%s %% pendant %s s" % [_nombre((Reglages.ELAN_VITAL_DEGATS_MULT-1.0)*100.0),_nombre(Reglages.ELAN_VITAL_DUREE)]
		"soif_de_sang": return "Par élimination : soin de %s %% des PV max, dans le budget partagé des soins" % _nombre(Reglages.SOIF_DE_SANG_PART*100.0)
		"peau_de_pierre": return "Dégâts subis −%s %%" % _nombre(Reglages.PEAU_DE_PIERRE_REDUCTION*100.0)
		"sceau_garde": return "Dégâts subis −%s %%" % _nombre(Reglages.SCEAU_GARDE_REDUCTION*100.0)
		"sceau_ruine": return "Dégâts subis +%s %%" % _nombre((Reglages.SCEAU_RUINE_VULNERABILITE - 1.0) * 100.0)
		"familier_tireur": return "Familier : %s %% des dégâts d’attaque toutes les %s s" % [_nombre(Reglages.FAMILIER_TIR_PART_DEGATS * 100.0), _nombre(Reglages.FAMILIER_TIR_INTERVALLE)]
		"meteores": return "Météore : %s %% des dégâts d’attaque toutes les %s s · rayon %s" % [_nombre(Reglages.METEORE_PART_DEGATS * 100.0), _nombre(Reglages.METEORE_INTERVALLE), _nombre(Reglages.METEORE_RAYON)]
		"zone_heros": return "Zone : %s %% des dégâts d’attaque toutes les %s s · rayon %s" % [_nombre(Reglages.ZONE_HEROS_PART_DEGATS * 100.0), _nombre(Reglages.ZONE_HEROS_INTERVALLE), _nombre(Reglages.ZONE_HEROS_RAYON)]
		"familier_gardien": return "Gardien : %s %% des dégâts d’attaque toutes les %s s · revient après %s s" % [_nombre(Reglages.GARDIEN_PART_DEGATS * 100.0), _nombre(Reglages.GARDIEN_INTERVALLE), _nombre(Reglages.GARDIEN_REAPPARITION)]
		"orbes_chargees": return "Une orbe toutes les %s s, jusqu’à %d · %s %% des dégâts d’attaque par orbe" % [_nombre(Reglages.ORBE_INTERVALLE), Reglages.ORBE_MAX, _nombre(Reglages.ORBE_PART_DEGATS * 100.0)]
		"chaine_alchimique": return "Arc : %s %% des dégâts d’attaque par cible toutes les %s s · jusqu’à %d ennemis" % [_nombre(Reglages.CHAINE_PART_DEGATS * 100.0), _nombre(Reglages.CHAINE_INTERVALLE), Reglages.CHAINE_CIBLES]
		"onde_de_choc": return "Onde : %s %% des dégâts d’attaque toutes les %s s · rayon %s et repoussement" % [_nombre(Reglages.ONDE_CHOC_PART_DEGATS * 100.0), _nombre(Reglages.ONDE_CHOC_INTERVALLE), _nombre(Reglages.ONDE_CHOC_RAYON)]
	return drapeau.replace("_", " ").capitalize()

static func _nombre(valeur: float) -> String:
	if is_equal_approx(valeur, roundf(valeur)):
		return str(roundi(valeur))
	return ("%.2f" % valeur).trim_suffix("0").trim_suffix("0").trim_suffix(".").replace(".", ",")
