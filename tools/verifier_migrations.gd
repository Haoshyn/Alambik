extends SceneTree

var _erreurs: Array[String] = []
var _controles := 0
var _reglages: Node

func _init() -> void:
	call_deferred("_executer")

func _verifier(condition: bool, contexte: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(contexte)

func _executer() -> void:
	_reglages = get_root().get_node("ReglagesJoueur")
	_verifier_catalogue()
	_verifier_conversion()
	_verifier_acquisitions()
	# Le singleton ecrit volontairement une ancienne sauvegarde pour tester sa
	# migration complete. Seul le profil temporaire du lanceur est autorise.
	var profil := OS.get_user_data_dir().replace("\\", "/")
	if profil.contains("/tmp/verification_") and profil.contains("/profil/"):
		_verifier_sauvegarde()
	else:
		_verifier(false, "Lancer via tools/verifier.ps1 : profil temporaire requis pour la migration")
	for erreur: String in _erreurs: push_error(erreur)
	print("Verification migrations : %d controles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier_catalogue() -> void:
	_verifier(Passifs.CATALOGUE.size() == 16, "Seize passifs disponibles")
	_verifier(Passifs.EMPLACEMENTS == 4 and Passifs.RANG_MAX == 2, "Quatre emplacements, deux rangs")
	var vus := {}
	for niveau in range(1, Epreuves.nombre() + 1):
		for id: String in Epreuves.passifs(niveau):
			_verifier(Passifs.contient(id) and not vus.has(id), "Une provenance par passif : " + id)
			vus[id] = true
			_verifier(Epreuves.niveau_pour(id) == niveau, "Provenance correcte : " + id)
	_verifier(vus.size() == Passifs.CATALOGUE.size(), "Chaque passif appartient a une Epreuve")
	for id: String in Passifs.CATALOGUE:
		_verifier(not Passifs.resume_rang(id, 1).is_empty() and not Passifs.resume_rang(id, 2).is_empty(), "Deux rangs lisibles : " + id)
		var base := Passifs.bonus_stats({id: 1})
		var double := Passifs.bonus_stats({id: 2})
		for cle: String in base:
			_verifier(is_equal_approx(float(double[cle]), 2.0 * float(base[cle])), "Bonus double : " + id)
	_verifier(Epreuves.candidats(1, {"vigueur": 1}) == ["vitalite"], "Priorite aux acquisitions manquantes")
	_verifier(Epreuves.candidats(1, {"vigueur": 2, "vitalite": 2}).is_empty(), "Aucun passif maximal dans le tirage")

func _verifier_conversion() -> void:
	var anciens := {"onde_alchimique": 5, "grand_oeuvre": 5, "riposte_alchimique": 2,
		"moisson_vitale": 2, "purification_totale": 3, "nova_de_givre": 1, "inconnu_retire": 2}
	var resultat := MigrationPassifs.convertir(anciens,
		["moisson_vitale", "riposte_alchimique", "onde_alchimique", "grand_oeuvre", "purification_totale"])
	_verifier(resultat["rangs"] == {"carapace": 2, "vigueur": 2, "moisson_vitale": 2, "vitalite": 2}, "Rangs anciens convertis et plafonnes")
	_verifier(resultat["equipes"] == ["moisson_vitale", "vigueur", "carapace", "vitalite"], "Selection dedupliquee et limitee a quatre")
	_verifier(int(resultat["gouttes"]) == 12 * MigrationPassifs.GOUTTES_PAR_RANG_EXCEDENTAIRE, "Copies excedentaires toutes compensees")
	var vide := MigrationPassifs.convertir({}, [])
	_verifier((vide["rangs"] as Dictionary).is_empty() and int(vide["gouttes"]) == 0, "Nouveau compte sans acquisition offerte")

func _verifier_acquisitions() -> void:
	var objets: Array[String] = []
	for mode in ["grimoire", "mine"]:
		var offre := ButinsRun.offre(mode, 0, Reglages.SALLES_PAR_RUN, 4, true, 1, {}, objets, 0)
		_verifier((offre["passifs"] as Array).is_empty() and is_zero_approx(float(offre["chance_passif"])), "Aucun passif hors Epreuve : " + mode)
	var defaite := ButinsRun.offre("epreuves", 0, 4, 4, false, 1, {}, objets, 0)
	_verifier((defaite["passifs"] as Array).is_empty(), "Une defaite ne donne pas de passif")
	var garantie := ButinsRun.offre("epreuves", 0, 5, 5, true, 1, {}, objets, 0, Reglages.EPREUVE_GARANTIE_CAPACITE - 1)
	_verifier(is_equal_approx(float(garantie["chance_passif"]), 1.0), "Garantie d'Epreuve respectee")
	var rng := RandomNumberGenerator.new()
	rng.seed = 87216
	var butin := ButinsRun.tirer(garantie, rng)
	_verifier(str(butin["passif"]) in Epreuves.passifs(1), "Garantie donne un passif local")

func _verifier_sauvegarde() -> void:
	var existait := FileAccess.file_exists(_reglages.FICHIER)
	var contenu_original := FileAccess.get_file_as_bytes(_reglages.FICHIER) if existait else PackedByteArray()
	var sauvegarde_active := bool(_reglages.sauvegarde_active)
	_reglages.sauvegarde_active = true
	var objets: Array = CatalogueObjets.IDS_PAR_MONDE[0]
	var equipements := {"anneau": str(objets[0]), "bracelet": str(objets[1]), "collier": str(objets[2])}
	var forge := {str(objets[0]): 7, "standard": 3, "homoncule_encre": 2}
	var config := ConfigFile.new()
	config.set_value("campagne", "version", _reglages.VERSION_CAMPAGNE)
	config.set_value("resultats", "par_chapitre", {"0": Reglages.SALLES_PAR_RUN})
	config.set_value("resultats", "victoires", 12)
	config.set_value("resultats", "runs", 30)
	config.set_value("monnaie", "gouttes", 1200)
	config.set_value("maitrise", "version", Reglages.MAITRISE_VERSION)
	config.set_value("maitrise", "rangs", {"puissance": 3})
	config.set_value("compte", "niveau", 20)
	config.set_value("compte", "experience", 321)
	config.set_value("compte", "attributs", {"force": 5})
	config.set_value("stuff", "objets", objets)
	config.set_value("stuff", "equipements", equipements)
	config.set_value("stuff", "forge", forge)
	config.set_value("stuff", "version_forge", Reglages.FORGE_VERSION)
	config.set_value("stuff", "pierres_forge", 444)
	config.set_value("sorts", "rangs", {"onde_alchimique": 5, "grand_oeuvre": 3, "moisson_vitale": 2})
	config.set_value("sorts", "debloques", ["sang_froid"])
	config.set_value("sorts", "passifs", ["moisson_vitale"])
	config.set_value("sorts", "actif", "onde_alchimique")
	config.set_value("sorts", "ultime", "grand_oeuvre")
	config.set_value("options", "mode_run", "epreuve_sorts")
	config.set_value("epreuves", "debloque", 4)
	config.set_value("epreuves", "choisi", 3)
	config.set_value("epreuves", "pities", {"3": 2})
	config.set_value("epreuves", "pities_coeur", {"3": 4})
	config.set_value("epreuves", "coeurs_mana", {"1": true, "2": true, "99": true})
	_verifier(config.save(_reglages.FICHIER) == OK, "Ancien profil temporaire sauvegarde")
	_reglages.charger()
	var compensation := 4 * MigrationPassifs.GOUTTES_PAR_RANG_EXCEDENTAIRE
	_verifier(_reglages.gouttes == 1200 + compensation, "Monnaie conservee et compensation ajoutee")
	_verifier(_reglages.pierres_forge == 444, "Pierres conservees")
	_verifier(_reglages.objets == objets and _reglages.equipements == equipements, "Equipement conserve")
	_verifier(_reglages.forge_niveaux == forge, "Forge conservee")
	_verifier(_reglages.rangs_competences == {"puissance": 3}, "Maitrises conservees")
	_verifier(_reglages.niveau_compte == 20 and _reglages.experience_compte == 321 and _reglages.rang_attribut("force") == 5, "Compte et attributs conserves")
	_verifier(_reglages.victoires == 12 and _reglages.runs == 30, "Resultats conserves")
	_verifier(_reglages.rangs_passifs == {"carapace": 2, "vigueur": 2, "moisson_vitale": 2, "sang_froid": 1}, "Rangs sauvegardes et anciens deblocages convertis")
	_verifier(_reglages.passifs_equipes == ["moisson_vitale", "carapace", "vigueur"], "Equipement actif et ultime converti")
	_verifier(_reglages.mode_run_choisi == "epreuves" and _reglages.niveau_epreuve_choisi == 3, "Ancien mode et niveau conserves")
	_verifier(_reglages.niveau_epreuve_debloque == 4 and _reglages.niveau_epreuve_accessible() == 1,
		"Ancien record conserve mais acces limite a la campagne")
	_verifier(_reglages.epreuves_ratees(3) == 2 and _reglages.epreuves_sans_coeur_mana(3) == 4, "Compteurs de garantie conserves")
	_verifier(_reglages.nombre_coeurs_mana() == 2, "Coeurs valides conserves, borne du catalogue respectee")
	_reglages.charger()
	_verifier(_reglages.gouttes == 1200 + compensation and _reglages.rang_passif("vigueur") == 2, "Rechargement sans compensation double")
	var migree := ConfigFile.new()
	_verifier(migree.load(_reglages.FICHIER) == OK, "Profil migre relisible")
	_verifier(int(migree.get_value("passifs", "version", 0)) == MigrationPassifs.VERSION and not migree.has_section("sorts"), "Format passifs versionne sans anciens circuits")
	_reglages.basculer_passif("sang_froid")
	_verifier(_reglages.passifs_equipes.size() == Passifs.EMPLACEMENTS, "Quatrieme emplacement disponible")
	_reglages.rangs_passifs["vitalite"] = 1
	_verifier(_reglages.basculer_passif("vitalite") == "plein", "Cinquieme emplacement refuse")
	if existait:
		var fichier := FileAccess.open(_reglages.FICHIER, FileAccess.WRITE)
		fichier.store_buffer(contenu_original)
		fichier.close()
		_reglages.charger()
	else:
		_reglages.reinitialiser_progression()
	_reglages.sauvegarde_active = sauvegarde_active
