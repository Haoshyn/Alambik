class_name CatalogueObjets
extends RefCounted

# Un anneau, un bracelet et un collier par monde, reproposes en cycle.
# Les bijoux des mondes retires restent utilisables dans les anciennes sauvegardes.
#
# La forge augmente la base avant les bonus en pourcentage du build.
# Les mondes se distinguent par leurs pouvoirs, pas par un bonus cache aux statistiques.
const PROFILS := [
	{"pv_base": 15.0},
	{"defense_base": 3.0},
	{"degats_sorts": 0.08},
]
const FORGE_PAR_STAT := {"pv_base": 10.0, "defense_base": 1.25, "degats_sorts": 0.025}
const STATS_PRINCIPALES := ["pv_base", "defense_base", "degats_sorts"]

# Chaque modele garde le meme petit bonus, quel que soit l'exemplaire obtenu.
const BONUS_SPECIAUX := [
	[{"critique": 0.02}, {"vitesse": 0.03}, {"butin": 0.05}],
	[{"degats_critiques": 0.05}, {"pv_base": 5.0}, {"attaque_mult": 0.03}],
	[{"vitesse": 0.03}, {"degats_sorts": 0.04}, {"critique": 0.02}],
	[{"cadence": 0.03}, {"critique": 0.02}, {"vitesse": 0.03}],
	[{"butin": 0.04}, {"attaque_mult": 0.03}, {"degats_critiques": 0.05}],
	[{"critique": 0.02}, {"cadence": 0.03}, {"butin": 0.05}],
	[{"degats_critiques": 0.05}, {"vitesse": 0.03}, {"critique": 0.02}],
	[{"pv_base": 5.0}, {"attaque_mult": 0.03}, {"degats_sorts": 0.04}],
	[{"vitesse": 0.03}, {"critique": 0.02}, {"butin": 0.05}],
	[{"cadence": 0.03}, {"pv_base": 5.0}, {"attaque_mult": 0.03}],
]

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
			var slot: String = ["anneau", "bracelet", "collier"][index]
			var nom_slot: String = ["Anneau", "Bracelet", "Collier"][index]
			var profil: Dictionary = PROFILS[index].duplicate()
			var special: Dictionary = BONUS_SPECIAUX[monde][index]
			for champ in special:
				profil[champ] = float(profil.get(champ, 0.0)) + float(special[champ])
			resultat[IDS_PAR_MONDE[monde][index]] = {
				"nom": "%s · %s" % [nom_slot, donnees_monde["nom"]],
				"slot": slot,
				"monde": monde,
				"chapitre_monde": index + 1,
				"chapitre": monde * Chapitres.CHAPITRES_PAR_MONDE + index,
				"profil": profil,
				"stat_principale": STATS_PRINCIPALES[index],
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
	return slot == str(OBJETS[id]["slot"])

static func bonus_objet(id: String, niveau: int, _monde_reference := -1) -> Dictionary:
	var resultat := {}
	if not OBJETS.has(id):
		return resultat
	var donnees: Dictionary = OBJETS[id]
	var forge := clampi(niveau, 0, Reglages.FORGE_NIVEAU_MAX)
	var profil: Dictionary = donnees["profil"]
	for champ in profil:
		var forge_par := float(FORGE_PAR_STAT.get(champ, 0.0)) \
			if champ == str(donnees["stat_principale"]) else 0.0
		resultat[champ] = float(profil[champ]) + forge_par * float(forge)
	return resultat

static func description_bonus(id: String, niveau: int) -> String:
	var bonus := bonus_objet(id, niveau)
	var lignes: Array[String] = []
	if bonus.has("pv_base"): lignes.append("PV bruts +%d" % roundi(float(bonus["pv_base"])))
	if bonus.has("defense_base"): lignes.append("Défense brute +%s" % _nombre(float(bonus["defense_base"])))
	if bonus.has("degats_sorts"): lignes.append("Dégâts des sorts +%s %%" % _nombre(float(bonus["degats_sorts"]) * 100.0))
	if bonus.has("critique"): lignes.append("Chance critique +%s %%" % _nombre(float(bonus["critique"]) * 100.0))
	if bonus.has("vitesse"): lignes.append("Vitesse +%s %%" % _nombre(float(bonus["vitesse"]) * 100.0))
	if bonus.has("butin"): lignes.append("Butin +%s %%" % _nombre(float(bonus["butin"]) * 100.0))
	if bonus.has("attaque_mult"): lignes.append("Attaque +%s %%" % _nombre(float(bonus["attaque_mult"]) * 100.0))
	if bonus.has("degats_critiques"): lignes.append("Dégâts critiques +%s %%" % _nombre(float(bonus["degats_critiques"]) * 100.0))
	if bonus.has("cadence"): lignes.append("Vitesse d’attaque +%s %%" % _nombre(float(bonus["cadence"]) * 100.0))
	return " · ".join(lignes)

static func bonus_effectifs(equipements: Dictionary, forge_niveaux: Dictionary, monde_reference := -1) -> Dictionary:
	var bonus := {"pv_base": 0.0, "defense_base": 0.0, "degats_sorts": 0.0,
		"critique": 0.0, "degats_critiques": 0.0, "vitesse": 0.0, "cadence": 0.0,
		"attaque_mult": 0.0, "butin": 0.0}
	for slot in ["anneau", "bracelet", "collier"]:
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
	for slot in ["anneau", "bracelet", "collier"]:
		var id := str(equipements.get(slot,""))
		if not compatible(slot,id): continue
		for effet in effets_objet(id,int(forge.get(id,0))):
			if effet not in resultat: resultat.append(effet)
	return resultat

static func avec_effets(inventaire: Array, _equipements: Dictionary, _forge: Dictionary) -> Array:
	# Les pouvoirs de bijoux sont lus directement par le combat. Ils ne doivent
	# jamais se faire passer pour des augments de run dans Mods.
	return inventaire.duplicate()

static func description_effets(id: String, niveau: int) -> String:
	if not OBJETS.has(id): return ""
	var lignes: Array[String] = []
	var parcours: Array = OBJETS[id]["effets"]
	for i in EffetsBijoux.PALIERS.size():
		var palier: int = EffetsBijoux.PALIERS[i]
		var effet_id := str(parcours[i])
		lignes.append("Niv. %d · %s · %s\n%s" % [palier,
			"Débloqué" if niveau >= palier else "Verrouillé", EffetsBijoux.nom(effet_id),
			EffetsBijoux.description(effet_id)])
	return "\n\n".join(lignes)

static func _nombre(valeur: float) -> String:
	return String.num(valeur, 1).trim_suffix(".0").replace(".", ",")
