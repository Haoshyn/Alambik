extends RefCounted

const Modeles = preload("res://tools/statistiques/modeles.gd")
const ProfilReference = preload("res://tools/statistiques/profil_reference.gd")
const Listes = preload("res://tools/statistiques/listes.gd")
const EMPLACEMENTS := ["arme", "familier", "anneau", "bracelet", "collier"]

# Un retrait garde les autres achats identiques. Ces pertes se chevauchent :
# elles mesurent l'utilite d'un emplacement, pas un partage des synergies.
static func sans_emplacement(configuration: Dictionary, emplacement: String) -> Dictionary:
	var copie := configuration.duplicate(true)
	if emplacement in ["arme", "familier"]:
		copie[emplacement] = ""
	else:
		var bijoux: Dictionary = copie.get("bijoux", {})
		bijoux.erase(emplacement)
	return copie

static func equipement(configuration: Dictionary) -> Array[Dictionary]:
	var total := Modeles.mesurer(configuration)
	var resultat: Array[Dictionary] = []
	for emplacement: String in EMPLACEMENTS:
		var sans := Modeles.mesurer(sans_emplacement(configuration, emplacement))
		resultat.append({"emplacement": emplacement, "dps_sans": sans["dps"],
			"perte_dps": 1.0 - float(sans["dps"]) / float(total["dps"]),
			"perte_survie": 1.0 - float(sans["pv_effectifs"]) / float(total["pv_effectifs"])})
	return resultat

static func augments(configuration: Dictionary, inventaire: Array = []) -> Array[Dictionary]:
	var copie := configuration.duplicate(true)
	copie["augments"] = inventaire.duplicate()
	var avant := Modeles.mesurer(copie)
	var resultat: Array[Dictionary] = []
	for id: String in CatalogueReactifs.ids():
		var reactif := CatalogueReactifs.par_id(id)
		if inventaire.count(id) >= reactif.copies_permises(): continue
		copie["augments"] = inventaire.duplicate() + [id]
		var apres := Modeles.mesurer(copie)
		resultat.append({"id": id, "rarete": reactif.rarete,
			"gain_dps": float(apres["dps"]) / float(avant["dps"]) - 1.0,
			"gain_survie": float(apres["pv_effectifs"]) / float(avant["pv_effectifs"]) - 1.0})
	return resultat

static func ajouter(lignes: Array[String]) -> void:
	var profil := ProfilReference.construire()
	profil.erase("augments")
	var nu := Modeles.mesurer({"arme": "", "familier": ""})
	var depart := Modeles.mesurer({})
	var fin := Modeles.mesurer(profil)
	lignes.append_array(["## Progression des impacts et valeur de chaque investissement", "",
		"Les dégâts ci-dessous sont ceux d’un impact normal, sans critique ni augment. Le héros nu commence à %s ; la baguette de départ ajoute %s ATK brute. La fin utilise le compte complet décrit plus haut, avec ses achats et conditions d’anneau." % [Listes.nombre(float(nu["tir_normal"])), Listes.nombre(CatalogueProjectiles.attaque_base("standard", 0))], ""])
	Listes.tableau(lignes, ["Profil sans augment", "Impact normal", "Impact critique", "DPS total"], [
		["Héros nu, niveau 1", Listes.nombre(float(nu["tir_normal"])), Listes.nombre(float(nu["tir_critique"])), Listes.nombre(float(nu["dps"]))],
		["Départ équipé, forge 0", Listes.nombre(float(depart["tir_normal"])), Listes.nombre(float(depart["tir_critique"])), Listes.nombre(float(depart["dps"]))],
		["Compte complet de référence", Listes.nombre(float(fin["tir_normal"])), Listes.nombre(float(fin["tir_critique"])), Listes.nombre(float(fin["dps"]))]])
	lignes.append("L’impact normal de ce compte complet représente **×%s** celui du héros nu et **×%s** celui du départ équipé. Ce repère n’est pas un plafond : un build spécialisé ou une arme lente change l’impact et la cadence." % [Listes.nombre(float(fin["tir_normal"]) / float(nu["tir_normal"])), Listes.nombre(float(fin["tir_normal"]) / float(depart["tir_normal"]))])
	lignes.append("")
	var avec_augments := profil.duplicate(true)
	avec_augments["augments"] = ProfilReference.AUGMENTS_CLASSIQUES.duplicate()
	var retraits_run := equipement(avec_augments)
	var retraits := equipement(profil)
	var objets: Array = []
	for index in retraits.size():
		var retrait: Dictionary = retraits[index]
		objets.append([str(retrait["emplacement"]).capitalize(), Listes.nombre(float(retrait["dps_sans"])),
			_pourcentage(float(retrait["perte_dps"])), _pourcentage(float(retraits_run[index]["perte_dps"])),
			_pourcentage(float(retrait["perte_survie"]))])
	lignes.append_array(["### Utilité des cinq emplacements", "",
		"On enlève un seul objet et on garde tous les autres choix identiques. Les pertes se chevauchent et ne s’additionnent pas. Le familier inclut son tir et son bonus au héros ; les PV effectifs excluent Sursis, les soins et les esquives.", ""])
	Listes.tableau(lignes, ["Objet retiré", "DPS permanent restant", "DPS permanent perdu", "DPS perdu avec augments classiques", "PV effectifs perdus"], objets)
	var forges: Array = []
	for emplacement: String in EMPLACEMENTS:
		var sans_forge := profil.duplicate(true)
		if emplacement in ["arme", "familier"]:
			sans_forge["forge_" + emplacement] = 0
		else:
			var bijoux: Dictionary = sans_forge["bijoux"]
			var forge: Dictionary = sans_forge["forge_bijoux"]
			forge[str(bijoux[emplacement])] = 0
		var mesure := Modeles.mesurer(sans_forge)
		forges.append([emplacement.capitalize(), Listes.nombre(float(fin["dps"]) - float(mesure["dps"])),
			_pourcentage(float(fin["dps"]) / float(mesure["dps"]) - 1.0),
			_pourcentage(float(fin["pv_effectifs"]) / float(mesure["pv_effectifs"]) - 1.0)])
	lignes.append_array(["### Ce que paie la forge de chaque objet", "",
		"Comparaison de forge 0 au maximum sur le même compte complet. Tous les autres objets restent au maximum. Les effets débloqués par la forge sont inclus ; la survie de Sursis reste décrite séparément dans la liste des items.", ""])
	Listes.tableau(lignes, ["Objet forgé", "DPS ajouté", "Gain de DPS total", "Gain de PV effectifs"], forges)
	_ajouter_augments(lignes, profil)

static func _ajouter_augments(lignes: Array[String], profil: Dictionary) -> void:
	lignes.append_array(["### Valeur d’un choix d’augment", "",
		"Chaque ligne ajoute une seule copie à un profil sans augment. Les gains sont relatifs au même profil avant le choix : ils ne s’additionnent pas entre lignes. La seconde copie est comparée à la première déjà acquise. Départ et fin utilisent exactement les mêmes règles de combat.", "",
		"Un 0 % de DPS ou de PV effectifs ne signifie pas un effet absent : les trajectoires, dégâts multicibles, mobilité, soins, boucliers, résurrections et gains économiques sont indiqués dans la colonne d’utilité, sans leur inventer une conversion en DPS monocible.", ""])
	var debut := augments({})
	var fin := augments(profil)
	var donnees: Array = []
	for index in debut.size():
		var premier: Dictionary = debut[index]
		var dernier: Dictionary = fin[index]
		var id := str(premier["id"])
		var reactif := CatalogueReactifs.par_id(id)
		var seconde := "Unique"
		if reactif.copies_permises() > 1:
			for mesure: Dictionary in augments(profil, [id]):
				if str(mesure["id"]) == id:
					seconde = "%s DPS ; %s PV effectifs" % [_pourcentage(float(mesure["gain_dps"])), _pourcentage(float(mesure["gain_survie"]))]
		donnees.append([reactif.nom, reactif.nom_rarete(), _pourcentage(float(premier["gain_dps"])),
			_pourcentage(float(dernier["gain_dps"])), _pourcentage(float(dernier["gain_survie"])), seconde, _utilite(id)])
	Listes.tableau(lignes, ["Augment", "Rareté", "DPS au départ", "DPS au compte complet", "PV effectifs au compte complet", "Gain de la 2e copie au compte complet", "Utilité hors mesure"], donnees)
	var cas: Array = []
	for inventaire: Array in [["battement_triple"], ["tir_multiple"], ["couronne_incisive", "pointe_lucide"]]:
		var id_cible := "salve" if "battement_triple" in inventaire else ("tir_multiple" if "tir_multiple" in inventaire else "pointe_lucide")
		for mesure: Dictionary in augments(profil, inventaire):
			if str(mesure["id"]) != id_cible: continue
			cas.append([", ".join(inventaire), CatalogueReactifs.par_id(id_cible).nom, _pourcentage(float(mesure["gain_dps"]))])
	lignes.append_array(["### Rendements réduits par les cumuls", "",
		"Les bonus d’une même famille s’additionnent et les tirs multiples gardent leur réduction par acquisition. Leur rendement dépend donc des choix déjà faits. Ces cas rendent visible un gain marginal plus faible que le gain de la première acquisition.", ""])
	Listes.tableau(lignes, ["Déjà acquis", "Choix ajouté", "Gain de DPS total"], cas)

static func _pourcentage(valeur: float) -> String:
	return "%s %%" % Listes.nombre(valeur * 100.0)

static func _utilite(id: String) -> String:
	match id:
		"avidite": return "XP de run et Gouttes"
		"homing": return "Suivi des cibles mobiles"
		"ricochet": return "Dégâts sur d’autres cibles"
		"perforation": return "Traverse les ennemis ; synergie avec Ricochet"
		"spirale": return "Dégâts diagonaux sur d’autres cibles"
		"trait_transpercant": return "Traverse murs et ennemis ; poursuite"
		"elan_vital": return "Bonus sur l’attaque chargée après déplacement"
		"pas_brume": return "Mobilité et invulnérabilité après blessure"
		"baume_profond": return "Soins reçus"
		"garde_remanente": return "Un coup bloqué par salle"
		"courageux": return "Une seconde vie complète"
		"egide": return "Soin complet à l’acquisition"
		"encrage_vif": return "Projectiles plus rapides"
	return "—"
