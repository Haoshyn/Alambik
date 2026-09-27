extends SceneTree

var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_executer.call_deferred()

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition:
		_erreurs.append(message)

func _executer() -> void:
	var profil := OS.get_user_data_dir().replace("\\", "/")
	if not profil.contains("/tmp/verification_") or not profil.contains("/profil/"):
		push_error("Profil temporaire requis pour les choix de niveau et le coffre")
		quit(1)
		return
	var reglages := root.get_node("ReglagesJoueur")
	reglages.sauvegarde_active = false
	reglages.mode_dev = false
	var jeu := root.get_node("Jeu")
	jeu.mode_auto = false
	_verifier_dix_niveaux(jeu)
	await _verifier_dix_choix(jeu)
	_verifier_coffre_coeurs(jeu, reglages)
	for erreur in _erreurs:
		push_error(erreur)
	print("Niveaux et coeurs : %d controles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier_dix_niveaux(jeu: Node) -> void:
	jeu.demarrer_run(20260927, 1, 0, "grimoire")
	var planning: Array = jeu.raretes_niveaux.duplicate()
	var niveaux := 0
	for salle in range(1, Reglages.SALLES_PAR_RUN + 1):
		jeu.salle_courante = salle
		niveaux += int(jeu.gagner_experience_run(1))
		niveaux += int(jeu.garantir_niveaux_fin_salle())
		_exiger(int(jeu.niveau_run) == ProgressionAugments.plafond_salle(salle, Reglages.SALLES_PAR_RUN),
			"Niveau de sortie incoherent en salle %d" % salle)
		_exiger(int(jeu.garantir_niveaux_fin_salle()) == 0, "Double recompense de rattrapage")
	_exiger(niveaux == 10 and int(jeu.niveau_run) == 10, "La campagne doit accorder exactement dix niveaux")
	_exiger(int(jeu.gagner_experience_run(99999)) == 0, "Un onzieme niveau a ete accorde")
	jeu.rerolls_restants = 3
	_exiger(not bool(jeu.consommer_relance(Reactif.LEGENDAIRE)), "Une legendaire peut etre relancee")
	_exiger(bool(jeu.consommer_relance(Reactif.RARE)), "La relance rare n'est plus disponible")
	_exiger(jeu.raretes_niveaux == planning, "Une relance a change les raretes a venir")
	jeu.demarrer_run(20260927, 1, 0, "mine")
	_exiger(int(jeu.gagner_experience_run(99999)) == 10 and int(jeu.niveau_run) == 10,
		"La Mine doit proposer les memes dix niveaux")

func _verifier_dix_choix(jeu: Node) -> void:
	var scene := load("res://ui/draft.tscn") as PackedScene
	_exiger(scene != null, "Ecran des augments absent")
	if scene == null:
		return
	jeu.demarrer_run(20260927, 1, 0, "grimoire")
	for niveau in range(1, 11):
		jeu.niveau_run = niveau
		var panneau := scene.instantiate()
		panneau.set("campagne", true)
		panneau.set("etage_recompense", niveau)
		root.add_child(panneau)
		var attendue := ProgressionAugments.rarete_niveau(niveau, jeu.raretes_niveaux)
		var propositions: Array = panneau.get("_propositions")
		_exiger(str(panneau.get("_rarete")) == attendue, "Rarete d'ecran differente du planning")
		_exiger(propositions.size() == 3, "Un niveau ne propose pas trois choix")
		for id: String in propositions:
			var reactif := CatalogueReactifs.par_id(id)
			_exiger(reactif.rarete == attendue and reactif.rarete != Reactif.COMMUN,
				"Choix commun ou de mauvaise rarete")
		if niveau == 5:
			_exiger(attendue == Reactif.LEGENDAIRE, "Le niveau cinq n'est pas legendaire")
		if propositions.is_empty():
			panneau.free()
			return
		panneau.call("_sur_choix", propositions[0])
		await panneau.termine
		_exiger(jeu.inventaire.size() == niveau, "Un niveau doit ajouter exactement un augment")
		panneau.queue_free()
		await process_frame
	_exiger(jeu.inventaire.size() == 10, "La run ne termine pas avec dix augments")

func _verifier_coffre_coeurs(jeu: Node, reglages: Node) -> void:
	# Une Mine abandonnee immediatement n'a pas de Gouttes de coffre : les trois
	# coeurs des salles precedentes sont la seule source et restent fixes.
	jeu.demarrer_run(20260927, 1, 0, "mine")
	_exiger(int(jeu.gouttes_coeurs) == 0, "Les coeurs d'une autre tentative ont ete conserves")
	jeu.gouttes_coeurs = 3
	var avant := int(reglages.gouttes)
	var bilan_script := load("res://scripts/progression/bilan_run.gd") as GDScript
	var bilan: Dictionary = bilan_script.finaliser(false, 1)
	_exiger(int(bilan["gouttes_coeurs"]) == 3 and int(bilan["gouttes"]) == 3,
		"Les Gouttes de coeurs ont ete perdues ou multipliees")
	_exiger(int(reglages.gouttes) == avant + 3, "Le portefeuille n'a pas recu les Gouttes des coeurs")
	bilan_script.finaliser(false, 1)
	_exiger(int(reglages.gouttes) == avant + 3, "Le bilan a verse deux fois les Gouttes des coeurs")
	jeu.demarrer_run(20260928, 1, 0, "grimoire")
	_exiger(int(jeu.gouttes_coeurs) == 0, "Une nouvelle tentative garde les Gouttes des coeurs precedents")
