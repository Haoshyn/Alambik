class_name CatalogueObjets
extends RefCounted

# Trois bijoux par monde, reproposes en cycle sur ses sept chapitres.
# Les bijoux des mondes retires restent utilisables dans les anciennes sauvegardes.
#
# La forge augmente la base avant les bonus en pourcentage du build.
# Les mondes se distinguent par leurs pouvoirs, pas par un bonus cache aux statistiques.
const PROFILS := [
	{"pv_base": 15.0},
	{"pv_base": 15.0},
	{"attaque_base": 3.0},
]
const FORGE_PAR_STAT := {"attaque_base": 0.5, "pv_base": 2.0}

const IDS_PAR_MONDE := [
	["plume_encres", "robe_enluminee", "sceau_scribe"],
	["sceptre_braises", "manteau_cendre", "charbon_eternel"],
	["baguette_givre", "cape_givre", "cristal_hiver"],
	["paratonnerre", "habit_orages", "eclair_fiole"],
	["aiguille_venin", "peau_antidote", "crochet_basilic"],
	["diapason_echos", "robe_resonance", "cloche_muette"],
	["lame_ombres", "voile_nocturne", "lune_noire"],
	["burin_runique", "armure_runes", "tablette_ancienne"],
	["orbe_neant", "manteau_vide", "fragment_neant"],
	["alambic_royal", "robe_grand_oeuvre", "pierre_philosophale"],
]

static var OBJETS := _construire()

static func _construire() -> Dictionary:
	var resultat := {}
	var identites := Chapitres.MONDES + Chapitres.MONDES_RETIRES
	for monde in IDS_PAR_MONDE.size():
		var donnees_monde: Dictionary = identites[monde]
		for index in 3:
			var slot := "anneau" if index < 2 else "collier"
			var nom_slot := ("Anneau" if index == 0 else "Bague") if slot == "anneau" else "Collier"
			var profil: Dictionary = PROFILS[index].duplicate()
			resultat[IDS_PAR_MONDE[monde][index]] = {
				"nom": "%s · %s" % [nom_slot, donnees_monde["nom"]],
				"slot": slot,
				"monde": monde,
				"chapitre_monde": index + 1,
				"chapitre": monde * Chapitres.CHAPITRES_PAR_MONDE + index,
				"profil": profil,
				"effets": EffetsBijoux.parcours(monde,index),
				"teinte": donnees_monde["teinte"],
			}
	return resultat

static func du_chapitre(chapitre: int) -> Array[String]:
	if chapitre < 0 or chapitre >= Chapitres.nombre():
		return []
	var donnees := Chapitres.par_index(chapitre)
	var monde := int(donnees["monde"])
	var bijoux: Array = IDS_PAR_MONDE[monde]
	var index := (int(donnees["chapitre_monde"]) - 1) % bijoux.size()
	var resultat: Array[String] = [str(bijoux[index])]
	return resultat

static func objet_du_chapitre(chapitre: int) -> String:
	var candidats := du_chapitre(chapitre)
	return "" if candidats.is_empty() else candidats[0]

static func manquants(chapitre: int, inventaire: Array[String]) -> Array[String]:
	var resultat := du_chapitre(chapitre)
	return resultat.filter(func(id: String) -> bool: return id not in inventaire)

static func tirer_manquant(chapitre: int, inventaire: Array[String], _rng: RandomNumberGenerator) -> String:
	var candidats := manquants(chapitre, inventaire)
	return "" if candidats.is_empty() else candidats[0]

static func compatible(slot: String, id: String) -> bool:
	if not OBJETS.has(id):
		return false
	return (slot in ["anneau_gauche", "anneau_droit"] and OBJETS[id]["slot"] == "anneau") \
		or (slot == "collier" and OBJETS[id]["slot"] == "collier")

static func bonus_objet(id: String, niveau: int, _monde_reference := -1) -> Dictionary:
	var resultat := {}
	if not OBJETS.has(id):
		return resultat
	var donnees: Dictionary = OBJETS[id]
	var forge := clampi(niveau, 0, Reglages.FORGE_NIVEAU_MAX)
	var profil: Dictionary = donnees["profil"]
	for champ in profil:
		resultat[champ] = float(profil[champ]) + float(FORGE_PAR_STAT[champ]) * float(forge)
	return resultat

static func description_bonus(id: String, niveau: int) -> String:
	var bonus := bonus_objet(id, niveau)
	if bonus.has("attaque_base"):
		return "Attaque de base +%s" % String.num(float(bonus["attaque_base"]), 1).trim_suffix(".0").replace(".", ",")
	return "PV de base +%d" % roundi(float(bonus.get("pv_base", 0.0)))

static func bonus_effectifs(equipements: Dictionary, forge_niveaux: Dictionary, monde_reference := -1) -> Dictionary:
	var bonus := {"attaque_base": 0.0, "pv_base": 0.0}
	for slot in ["anneau_gauche", "anneau_droit", "collier"]:
		var id := str(equipements.get(slot, ""))
		if not compatible(slot, id):
			continue
		var part := bonus_objet(id, int(forge_niveaux.get(id, 0)), monde_reference)
		for champ in part:
			bonus[champ] = float(bonus.get(champ, 0.0)) + float(part[champ])
	return bonus

static func effets_objet(id: String, niveau: int) -> Array[String]:
	var resultat: Array[String] = []
	if not OBJETS.has(id): return resultat
	var parcours: Array = OBJETS[id]["effets"]
	for i in EffetsBijoux.PALIERS.size():
		if niveau >= EffetsBijoux.PALIERS[i]: resultat.append(str(parcours[i]))
	return resultat

static func effets_equipes(equipements: Dictionary, forge: Dictionary) -> Array[String]:
	var resultat: Array[String] = []
	for slot in ["anneau_gauche", "anneau_droit", "collier"]:
		var id := str(equipements.get(slot,""))
		if not compatible(slot,id): continue
		for effet in effets_objet(id,int(forge.get(id,0))):
			if effet not in resultat: resultat.append(effet)
	return resultat

static func avec_effets(inventaire: Array, equipements: Dictionary, forge: Dictionary) -> Array:
	var resultat := inventaire.duplicate()
	for effet in effets_equipes(equipements,forge):
		# Un pouvoir identique ne cree pas deux familiers ou deux boucliers.
		if effet not in resultat: resultat.append(effet)
	return resultat

static func description_effets(id: String, niveau: int) -> String:
	if not OBJETS.has(id): return ""
	var lignes: Array[String] = []
	var parcours: Array = OBJETS[id]["effets"]
	for i in EffetsBijoux.PALIERS.size():
		var palier: int = EffetsBijoux.PALIERS[i]
		var effet := CatalogueReactifs.par_id(str(parcours[i]))
		lignes.append("Niv. %d · %s · %s\n%s" % [palier, "Débloqué" if niveau >= palier else "Verrouillé", effet.nom, effet.description])
	return "\n\n".join(lignes)
