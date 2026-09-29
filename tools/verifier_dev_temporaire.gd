extends Node

const PROFIL := preload("res://dev_temporaire/profil.gd")
const SESSION := preload("res://dev_temporaire/session.gd")
const MENU := preload("res://scenes/menu.tscn")
const Modeles = preload("res://tools/statistiques/modeles.gd")
const Parcours = preload("res://tools/statistiques/parcours_progression.gd")
const RythmeBoss = preload("res://tools/statistiques/rythme_boss.gd")
var _erreurs: Array[String] = []
var _controles := 0

func _ready() -> void:
	if "verification_dev_temporaire" not in OS.get_user_data_dir().to_lower():
		push_error("Ce controle exige un APPDATA verification_dev_temporaire isole.")
		get_tree().quit(1)
		return
	if "--preparer-reprise-dev" in OS.get_cmdline_user_args():
		_preparer_reprise()
		_terminer()
		return
	if "--verifier-reprise-dev" in OS.get_cmdline_user_args():
		_verifier_reprise()
		_terminer()
		return
	ReglagesJoueur.volume_musique = 0.0
	ReglagesJoueur.volume_effets = 0.0
	Sons.appliquer_reglages()
	if SESSION.active():
		_exiger(SESSION.restaurer().is_empty(), "Restauration du precedent controle")
	var niveau_precedent := 0
	for monde in range(1, Chapitres.MONDES.size() + 1):
		var compte := PROFIL.construire(monde)
		_verifier_profil(compte, monde)
		_exiger(compte.niveau_compte >= niveau_precedent, "Niveau croissant")
		niveau_precedent = compte.niveau_compte
		print("Profil monde %d : niveau %d, %d gouttes, %d pierres, %d bijoux, %d passifs, %d coeurs, %d runs." % [
			monde, compte.niveau_compte, compte.gouttes, compte.pierres_forge, compte.objets.size(),
			compte.rangs_passifs.size(), compte.nombre_coeurs_mana(), compte.runs])
		compte.free()
	_verifier_combat_monde_trois()
	_verifier_session()
	for format: Vector2i in [Vector2i(720, 1280), Vector2i(1080, 2340)]:
		get_tree().root.size = format
		await _verifier_interface()
	_terminer()

func _terminer() -> void:
	Sons.arreter()
	for erreur: String in _erreurs:
		push_error(erreur)
	print("Dev temporaire : %d controles, %d erreurs." % [_controles, _erreurs.size()])
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, contexte: String) -> void:
	_controles += 1
	if not condition:
		_erreurs.append(contexte)

func _verifier_profil(compte: Node, monde: int) -> void:
	var vaincus := monde * Chapitres.CHAPITRES_PAR_MONDE
	_exiger(not compte.mode_dev, "Pas de bonus debug dans le profil")
	_exiger(compte.meilleures_par_chapitre.size() == vaincus, "Exactement les mondes choisis termines")
	for chapitre in Chapitres.nombre():
		_exiger(compte.meilleure_du_chapitre(chapitre) == (Chapitres.salles(chapitre) if chapitre < vaincus else 0), "Record campagne exact")
		_exiger(compte.chapitre_debloque(chapitre) == (chapitre <= vaincus), "Acces campagne exact")
	_exiger(compte.chapitre_choisi == mini(vaincus, Chapitres.nombre() - 1), "Chapitre suivant selectionne")
	_exiger(compte.points_attributs_disponibles() == 0, "Attributs repartis")
	_exiger(Personnage.points_depenses(compte.attributs) == Personnage.points_totaux(compte.niveau_compte), "Budget attributs legal")
	_exiger(compte.gouttes > 0 and compte.pierres_forge > 0, "Reserve disponible")
	_exiger(compte.passifs_equipes.size() <= Passifs.EMPLACEMENTS and not compte.passifs_equipes.is_empty(), "Passifs equipes")
	for id: String in compte.rangs_passifs:
		_exiger(compte.rang_passif(id) <= Passifs.rang_max(id) and Epreuves.campagne_requise(Epreuves.niveau_pour(id)) <= compte.niveau_campagne_atteint(), "Passif accessible et rang legal")
	for id: String in compte.passifs_equipes:
		_exiger(int(compte.rangs_passifs.get(id, 0)) > 0, "Passif equipe possede")
	for id: String in compte.objets:
		var donnees: Dictionary = CatalogueObjets.OBJETS[id]
		_exiger(int(donnees["chapitre"]) < vaincus, "Bijou issu d'un chapitre termine")
	var gouttes_depensees := 0
	for id: String in compte.rangs_competences:
		_exiger(ArbreCompetences.prerequis_atteint(id, compte.rangs_competences), "Prerequis maitrise")
		_exiger(compte.rang_competence(id) <= ArbreCompetences.rangs(id), "Rang maitrise legal")
		for rang in int(compte.rangs_competences[id]):
			gouttes_depensees += ArbreCompetences.cout(id, rang)
	var pierres_depensees := 0
	for id: String in compte.forge_niveaux:
		_exiger(id in compte.objets or id in compte.projectiles_disponibles() or id in compte.familiers_disponibles(), "Forge d'un objet accessible")
		_exiger(int(compte.forge_niveaux[id]) <= Reglages.FORGE_NIVEAU_MAX, "Rang forge legal")
		for rang in int(compte.forge_niveaux[id]):
			pierres_depensees += Reglages.cout_forge(rang)
	_exiger(compte.gouttes + gouttes_depensees == int(compte.get_meta("gouttes_recues")), "Gouttes et achats finances par les vrais gains")
	_exiger(compte.pierres_forge + pierres_depensees == int(compte.get_meta("pierres_recues")), "Forge financee par les vrais gains")
	var bis := PROFIL.construire(monde)
	_exiger(SESSION.capturer(compte) == SESSION.capturer(bis), "Profil reproductible")
	bis.free()

func _configuration_combat(compte: Node) -> Dictionary:
	return {"niveau": compte.niveau_compte, "attributs": compte.attributs.duplicate(true),
		"maitrises": compte.rangs_competences.duplicate(true), "passifs": compte.passifs_equipes_effectifs(),
		"arme": compte.projectile_equipe, "forge_arme": compte.niveau_arme(compte.projectile_equipe),
		"familier": compte.familier_equipe, "forge_familier": compte.niveau_familier(compte.familier_equipe),
		"bijoux": compte.equipements.duplicate(true), "forge_bijoux": compte.forge_niveaux.duplicate(true),
		"coeurs": compte.nombre_coeurs_mana()}

func _verifier_combat_monde_trois() -> void:
	var compte := PROFIL.construire(2)
	var equilibre := _configuration_combat(compte)
	var stats_equilibres := Modeles.mesurer(equilibre)
	var butin_equilibre: int = compte.gain_gouttes(100)
	compte.reinitialiser_attributs()
	while compte.points_attributs_disponibles() > 0: compte.augmenter_attribut("force")
	compte.reinitialiser_arbre()
	# Concentrer le meme budget sur les rangs qui donnent le plus de DPS.
	while true:
		var choix := ""
		var rendement := -INF
		var configuration := _configuration_combat(compte)
		var dps := float(Modeles.mesurer(configuration)["dps"])
		for id: String in ArbreCompetences.BRANCHES["Offensif"]:
			if not compte.peut_acheter_competence(id): continue
			var essai := configuration.duplicate(true)
			essai["maitrises"][id] = compte.rang_competence(id) + 1
			var gain := (float(Modeles.mesurer(essai)["dps"]) / dps - 1.0) / float(compte.cout_competence(id))
			if gain > rendement:
				choix = id
				rendement = gain
		if choix.is_empty(): break
		compte.acheter_competence(choix)
	var offensif := _configuration_combat(compte)
	var stats_offensifs := Modeles.mesurer(offensif)
	_exiger(float(stats_offensifs["dps"]) >= float(stats_equilibres["dps"]) * 1.2, "Le focus offensif conserve un avantage sensible de degats")
	_exiger(float(stats_offensifs["pv_effectifs"]) <= float(stats_equilibres["pv_effectifs"]) * 0.8, "Le focus offensif reste moins resistant")
	_exiger(compte.gain_gouttes(100) <= float(butin_equilibre) * 0.9, "Le focus offensif recolte moins sans Sagesse et maitrises utilitaires")
	var sans_passifs := offensif.duplicate(true)
	sans_passifs["passifs"] = {}
	var sans_soins := Stats.depuis_reglages(sans_passifs["maitrises"], {}, Modeles.bonus_equipement(sans_passifs),
		int(sans_passifs["niveau"]), sans_passifs["attributs"])
	var avec_soins := Stats.depuis_reglages(equilibre["maitrises"], equilibre["passifs"], Modeles.bonus_equipement(equilibre),
		int(equilibre["niveau"]), equilibre["attributs"])
	_exiger(sans_soins.pv_max * sans_soins.soin_mult < avec_soins.pv_max * avec_soins.soin_mult * 0.75, "Le budget de soins du profil sans defense reste faible")
	_exiger(is_zero_approx(ArbreCompetences.soin_par_salle(sans_passifs["maitrises"])) and is_zero_approx(Passifs.soin_moisson(sans_passifs["passifs"])), "Aucune regeneration passive offerte au profil pur offensif")
	var chapitre := 2 * Chapitres.CHAPITRES_PAR_MONDE
	var boss_equilibres := RythmeBoss.mesurer(equilibre, chapitre)
	for salle: Dictionary in boss_equilibres["salles"]:
		var mediane := float(salle["duree"]["mediane"])
		_exiger(mediane >= float(salle["cible_min"]) and mediane <= float(salle["cible_max"]),
			"Chaque boss DEV equilibre du monde trois doit rejoindre la cible : salle " + str(salle["salle"]))
	for paire: Array in [["equilibre", equilibre], ["offensif", offensif], ["sans_passifs", sans_passifs]]:
		var configuration: Dictionary = paire[1]
		var mesure := Modeles.mesurer(configuration)
		for id: String in ["encrier_rampant", "plume_sentinelle", "tache_veloce"]:
			var ennemi := Parcours.ennemi("grimoire", chapitre, 1, id)
			var attaques := ceili(float(ennemi["pv"]) / float(mesure["tir_normal"]))
			_exiger(attaques >= 2 and attaques <= 4, "Entree du monde trois sans banaliser les OS ni imposer trop de coups : " + str(paire[0]) + " " + id)
		var cohorte := Parcours.cohorte(configuration, chapitre, 8, PROFIL.GRAINE,
			{"politique": "equilibre" if str(paire[0]) == "equilibre" else "tout_offensif"})
		var boss: Dictionary = cohorte["boss_final"]
		if str(paire[0]) != "equilibre":
			_exiger(float(boss["mediane"]) < float(boss_equilibres["salles"].back()["duree"]["mediane"]),
				"Le boss doit tomber plus vite avec le focus offensif : " + str(paire[0]))
		print("Combat DEV monde 3 %s : %.1f degats, %.1f DPS, %.1f PV effectifs, boss %.1f s [P10 %.1f ; P90 %.1f]." % [str(paire[0]), float(mesure["tir_normal"]), float(mesure["dps"]), float(mesure["pv_effectifs"]), float(boss["mediane"]), float(boss["p10"]), float(boss["p90"])])
	var plume := Parcours.ennemi("grimoire", chapitre, 1, "plume_sentinelle")
	_exiger(float(stats_offensifs["pv_effectifs"]) / float(plume["degats"]) <= 3.5, "Le full offensif encaisse trop au monde trois")
	_exiger(float(stats_equilibres["pv_effectifs"]) / float(plume["degats"]) >= 4.0, "Le profil equilibre doit conserver une marge de survie")
	compte.free()

func _verifier_session() -> void:
	ReglagesJoueur.reinitialiser_progression()
	ReglagesJoueur.gouttes = 123
	ReglagesJoueur.specialisation = "moine"
	ReglagesJoueur.niveau_mine_choisi = 1
	ReglagesJoueur.sauvegarder()
	var origine := SESSION.capturer(ReglagesJoueur)
	_exiger(not SESSION.appliquer(0).is_empty() and not SESSION.active(), "Monde invalide refuse sans sauvegarde")
	_exiger(SESSION.appliquer(5).is_empty(), "Application monde 5")
	var sauvegarde_originale := FileAccess.get_file_as_bytes(SESSION.ORIGINAL)
	# Une reprise de run ancienne ne doit pas contourner la regression.
	Jeu.nouvelle_tentative = {"chapitre": Chapitres.nombre() - 1}
	_exiger(SESSION.appliquer(2).is_empty(), "Regression monde 5 vers monde 2")
	_exiger(Jeu.nouvelle_tentative.is_empty(), "Destination de reprise effacee")
	var attendu := PROFIL.construire(2, "moine")
	_exiger(SESSION.capturer(ReglagesJoueur) == SESSION.capturer(attendu), "Tous les gains superieurs retires")
	attendu.free()
	_exiger(FileAccess.get_file_as_bytes(SESSION.ORIGINAL) == sauvegarde_originale, "Original jamais remplace en changeant de monde")
	ReglagesJoueur.ajouter_gouttes(1234)
	ReglagesJoueur.charger()
	_exiger(SESSION.active(), "Session conservee apres rechargement")
	_exiger(SESSION.appliquer(2).is_empty(), "Reapplication remet le profil")
	ReglagesJoueur.charger()
	_exiger(SESSION.restaurer().is_empty() and not SESSION.active(), "Desactivation et restauration")
	_exiger(SESSION.capturer(ReglagesJoueur) == origine, "Compte original entierement restaure")
	ReglagesJoueur.charger()
	_exiger(SESSION.capturer(ReglagesJoueur) == origine, "Restauration persistante")
	_exiger(ReglagesJoueur.volume_musique == 0.0 and ReglagesJoueur.volume_effets == 0.0, "Reglages audio preserves")
	ReglagesJoueur.definir_mode_dev(true)
	for id: String in CatalogueObjets.OBJETS:
		if CatalogueObjets.compatible("anneau", id):
			ReglagesJoueur.equiper_objet("anneau", id)
			break
	var debug_origine := SESSION.capturer(ReglagesJoueur)
	_exiger(SESSION.appliquer(1).is_empty() and not ReglagesJoueur.mode_dev, "Debug historique desactive pendant le profil")
	_exiger(SESSION.restaurer().is_empty(), "Restauration d'un compte utilisant le debug historique")
	_exiger(SESSION.capturer(ReglagesJoueur) == debug_origine, "Selections debug d'origine preservees")
	ReglagesJoueur.definir_mode_dev(false)
	# Une copie endommagee doit bloquer l'outil avant toute mutation du compte.
	var copie := ConfigFile.new()
	_exiger(copie.save(SESSION.ORIGINAL) == OK, "Preparation copie incomplete")
	var avant_refus := SESSION.capturer(ReglagesJoueur)
	_exiger(not SESSION.appliquer(2).is_empty(), "Copie incomplete refusee")
	_exiger(SESSION.capturer(ReglagesJoueur) == avant_refus, "Compte intact apres refus")
	_exiger(DirAccess.remove_absolute(SESSION.ORIGINAL) == OK, "Retrait copie du controle isole")

func _verifier_interface() -> void:
	ReglagesJoueur.effets_reduits = true
	var origine := SESSION.capturer(ReglagesJoueur)
	var menu := MENU.instantiate()
	add_child(menu)
	await _attendre()
	var bouton := menu.find_child("DevTemporaire", true, false) as Button
	_exiger(is_instance_valid(bouton) and bouton.is_visible_in_tree(), "Bouton DEV dans l'accueil")
	if not is_instance_valid(bouton):
		menu.queue_free()
		return
	await _cliquer(bouton)
	await _attendre()
	var panneau: Control = menu.get("_superposition")
	_exiger(is_instance_valid(panneau), "Panneau ouvert")
	if not is_instance_valid(panneau):
		menu.queue_free()
		await _attendre()
		return
	var choix := panneau.find_child("MondeDev", true, false) as OptionButton
	_exiger(choix.item_count == Chapitres.MONDES.size(), "Tous les mondes selectionnables")
	choix.select(1)
	choix.item_selected.emit(1)
	var appliquer := panneau.find_child("AppliquerProfilDev", true, false) as Button
	await _cliquer(appliquer)
	await _attendre()
	_exiger(SESSION.active() and ReglagesJoueur.niveau_campagne_atteint() == 2 * Chapitres.CHAPITRES_PAR_MONDE + 1, "Bouton applique le monde choisi")
	var restaurer := panneau.find_child("RestaurerCompteDev", true, false) as Button
	_exiger(restaurer.is_visible_in_tree(), "Restauration accessible")
	var zone := panneau.get_global_rect()
	_exiger(zone.encloses(appliquer.get_global_rect()) and zone.encloses(restaurer.get_global_rect()), "Actions dans le cadre portrait")
	await _cliquer(restaurer)
	_exiger(SESSION.capturer(ReglagesJoueur) == origine, "Restauration depuis le panneau")
	panneau.emit_signal("ferme")
	await _attendre()
	_exiger(menu.get("_superposition") == null, "Retour au menu")
	for page in [0, 1, 3, 4]:
		menu.call("_afficher_page", page, false)
		await _attendre()
		var courante: Control = menu.get("_page_actuelle")
		_exiger(courante.find_child("DevTemporaire", true, false) == null, "Autres onglets inchanges")
	menu.call("_afficher_page", 2, false)
	await _attendre()
	_exiger(is_instance_valid(menu.find_child("DevTemporaire", true, false)), "Bouton recree au retour")
	menu.queue_free()
	await _attendre()

func _attendre() -> void:
	await get_tree().create_timer(0.25).timeout
	await get_tree().process_frame

func _cliquer(controle: Control) -> void:
	var mouvement := InputEventMouseMotion.new()
	mouvement.position = controle.get_global_rect().get_center()
	get_viewport().push_input(mouvement, true)
	var appui := InputEventMouseButton.new()
	appui.position = controle.get_global_rect().get_center()
	appui.button_index = MOUSE_BUTTON_LEFT
	appui.pressed = true
	get_viewport().push_input(appui, true)
	await get_tree().process_frame
	var relachement := appui.duplicate() as InputEventMouseButton
	relachement.pressed = false
	get_viewport().push_input(relachement, true)
	await _attendre()

func _preparer_reprise() -> void:
	_exiger(not SESSION.active(), "Profil de redemarrage vierge")
	ReglagesJoueur.specialisation = "moine"
	ReglagesJoueur.gouttes = 456
	ReglagesJoueur.sauvegarder()
	var attendu := ConfigFile.new()
	attendu.set_value("controle", "origine", SESSION.capturer(ReglagesJoueur))
	_exiger(attendu.save("user://attendu_dev.cfg") == OK, "Original de reference")
	_exiger(SESSION.appliquer(2).is_empty(), "Profil applique avant arret du processus")

func _verifier_reprise() -> void:
	_exiger(SESSION.active(), "Mode dev retrouve dans un nouveau processus")
	var compte := PROFIL.construire(2, "moine")
	_exiger(SESSION.capturer(ReglagesJoueur) == SESSION.capturer(compte), "Profil reellement recharge au demarrage")
	compte.free()
	var attendu := ConfigFile.new()
	_exiger(attendu.load("user://attendu_dev.cfg") == OK, "Reference originale accessible")
	_exiger(SESSION.restaurer().is_empty(), "Restauration apres redemarrage")
	var origine: Dictionary = attendu.get_value("controle", "origine", {})
	_exiger(SESSION.capturer(ReglagesJoueur) == origine and not SESSION.active(), "Original retrouve apres redemarrage")
