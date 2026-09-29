extends SceneTree

const Equilibrage = preload("res://tools/statistiques/equilibrage_progression.gd")
var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_verifier.call_deferred()

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)

func _verifier() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Profil de verification isole requis.")
		quit(1)
		return
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var nombre := Equilibrage.NOMBRE_COMPTES
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--comptes="): nombre = maxi(1, argument.trim_prefix("--comptes=").to_int())
	var rapport := Equilibrage.rapport(nombre)
	_verifier_courbes(rapport)
	_verifier_annexes(rapport)
	_verifier_budgets(rapport)
	_verifier_critiques()
	_verifier_remplacements()
	for scenario: String in rapport["scenarios"]:
		for chapitre: int in rapport["scenarios"][scenario]:
			var ligne: Dictionary = rapport["scenarios"][scenario][chapitre]
			if chapitre not in [2, 3, 7, 8, 14, 21, 28, 35]: continue
			print("%s C%d : 1 projectile %.1f %%, 1 attaque %.1f %% [P90 %.1f], critiques inclus %.1f %%, attaques %.1f, contacts %.1f (min %.1f), boss %.1f s" % [
				scenario, chapitre, float(ligne["un_projectile"]["mediane"]) * 100.0,
				float(ligne["une_attaque"]["mediane"]) * 100.0, float(ligne["une_attaque"]["p90"]) * 100.0,
				float(ligne["avec_critiques"]["mediane"]) * 100.0, float(ligne["attaques"]["mediane"]),
				float(ligne["contacts"]["mediane"]), float(ligne["contacts_min"]["mediane"]), float(ligne["boss"]["mediane"])])
	var dossier := "res://tmp/verification_equilibrage_compact"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dossier))
	var fichier := FileAccess.open(dossier + "/mesures.json", FileAccess.WRITE)
	_exiger(fichier != null, "Impossible d'ecrire les mesures")
	if fichier != null: fichier.store_string(JSON.stringify(rapport, "\t") + "\n")
	for erreur: String in _erreurs: push_error(erreur)
	print("Equilibrage progression : %d controles, %d erreurs, %d comptes par scenario." % [_controles, _erreurs.size(), nombre])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier_courbes(rapport: Dictionary) -> void:
	for scenario: String in ["equilibre", "offensif", "offensif_deux_defenses"]:
		for chapitre: int in rapport["scenarios"][scenario]:
			var ligne: Dictionary = rapport["scenarios"][scenario][chapitre]
			var contexte := "%s chapitre %d" % [scenario, chapitre]
			_exiger(float(ligne["un_projectile"]["p90"]) <= 0.01, "Projectiles eliminant trop souvent en un coup : " + contexte)
			# Le repere de 5 % accepte un demi-point de dispersion de la cohorte.
			_exiger(float(ligne["une_attaque"]["mediane"]) <= 0.055, "Attaques eliminant trop souvent en un coup : " + contexte)
			_exiger(float(ligne["avec_critiques"]["mediane"]) <= 0.08, "Les critiques banalisent les eliminations instantanees : " + contexte)
			_exiger(float(ligne["avec_critiques"]["p90"]) <= 0.20,
				"Le haut de distribution elimine trop facilement : " + contexte)
			_exiger(float(ligne["attaques"]["mediane"]) >= 2.0, "Le monstre median ne tient pas deux attaques : " + contexte)
			_exiger(float(ligne["boss"]["mediane"]) >= 12.0, "Le boss fond sur une progression ordinaire : " + contexte)
			# La campagne directe ne contient aucun renforcement ajoute. Le debut
			# doit avancer ; les besoins de farm tardifs sont mesures par Rythme.
			if scenario == "equilibre" and chapitre <= Chapitres.CHAPITRES_PAR_MONDE:
				_exiger(float(ligne["boss"]["mediane"]) <= 90.0, "Boss median trop long dans le premier monde : " + contexte)
	for chapitre: int in rapport["scenarios"]["retour_epreuves"]:
		var ligne: Dictionary = rapport["scenarios"]["retour_epreuves"][chapitre]
		var limite := 0.20 if chapitre <= Chapitres.CHAPITRES_PAR_MONDE else 0.05
		_exiger(float(ligne["une_attaque"]["mediane"]) <= limite, "Les six Epreuves effacent les combats : " + str(chapitre))
		_exiger(float(ligne["attaques"]["mediane"]) >= 2.0, "Le retour d'Epreuves efface le monstre median : " + str(chapitre))
	var surfarm: Dictionary = rapport["scenarios"]["surfarm"]
	_exiger(float(surfarm[3]["une_attaque"]["mediane"]) <= 0.50 and float(surfarm[3]["attaques"]["mediane"]) >= 2.0,
		"Le chapitre trois ne reprend pas de marge apres le sur-farm du premier")
	_exiger(float(surfarm[7]["une_attaque"]["mediane"]) <= 0.10 and float(surfarm[7]["attaques"]["mediane"]) >= 2.0,
		"Le sur-farm efface encore la fin du premier monde")
	for base: String in rapport["augments"]:
		var augment: Dictionary = rapport["augments"][base]
		_exiger(float(augment["deux_defenses"]["survie"]) <= 2.3, "Deux defenses rendent le build trop resistant : " + base)
		for paire: Array in [["sceau_ruine", "sceau_garde"], ["noyau_pesant", "peau_de_pierre"], ["frappe_lourde", "egide"]]:
			var attaque := float(augment[paire[0]]["dps"]) - 1.0
			var defense := float(augment[paire[1]]["survie"]) - 1.0
			_exiger(defense >= attaque * 0.85 and defense <= attaque * 1.15, "Gains offensif et defensif disproportionnes : " + str(paire))

func _verifier_budgets(rapport: Dictionary) -> void:
	for exemple: Dictionary in rapport["exemples"]:
		var actions: Array = exemple["actions"]
		var scenario := str(exemple["scenario"])
		_exiger(actions.size() == (13 if scenario == "surfarm" else (8 if scenario == "retour_epreuves" else 2)), "Budget de tentatives incorrect : " + scenario)
		_exiger(not bool(actions[0]["victoire"]) and int(actions[0]["salles_validees"]) == 8, "L'echec initial est perdu")
		for action: Dictionary in actions:
			var etat: Dictionary = action["apres"]
			for cle: String in ["gouttes", "pierres"]:
				_exiger(int(etat[cle]) >= 0 and int(etat["recus"][cle]) - int(etat["depenses"][cle]) == int(etat[cle]),
					"Le scenario invente des ressources : " + scenario + "/" + cle)
			if str(action["mode"]) == "epreuves": _exiger(int(action["niveau_annexe"]) == 1, "Le farm depasse l'Epreuve accessible")

func _verifier_annexes(rapport: Dictionary) -> void:
	for scenario: String in rapport["annexes"]:
		for mode: String in rapport["annexes"][scenario]:
			var mesure: Dictionary = rapport["annexes"][scenario][mode]
			var contacts := float(mesure["contacts"]["mediane"])
			var boss := float(mesure["boss"]["mediane"])
			_exiger(contacts >= 3.0 and contacts <= (8.0 if mode == "epreuve" else 12.0),
				"Resistance initiale en annexe disproportionnee : " + scenario + "/" + mode)
			_exiger(boss >= (8.0 if mode == "epreuve" else 20.0) and boss <= 120.0,
				"Endurance du premier boss d'annexe incorrecte : " + scenario + "/" + mode)
			print("Annexe %s %s : contacts %.1f ; boss %.1f s" % [mode, scenario, contacts, boss])

func _verifier_critiques() -> void:
	var mesure := {"salves": 2, "critique": 0.25, "coefficient_critique": 2.0}
	_exiger(is_equal_approx(Equilibrage.Retour.probabilite_une_attaque(31.0, 20.0, mesure), 0.0625), "Les deux salves ne doivent pas partager un seul tirage critique")
	_exiger(is_equal_approx(Equilibrage.Retour.probabilite_une_attaque(30.0, 20.0, mesure), 0.4375), "Probabilite d'au moins une salve critique incorrecte")
	_exiger(is_equal_approx(Equilibrage.Retour.probabilite_une_attaque(20.0, 20.0, mesure), 1.0), "L'attaque normale n'est pas reconnue")
	_exiger(is_zero_approx(Equilibrage.Retour.probabilite_une_attaque(41.0, 20.0, mesure)), "Une attaque impossible recoit une probabilite")

func _verifier_remplacements() -> void:
	for graine in range(12):
		var run := Equilibrage.Simulation.une_run({}, "tout_offensif", graine, false)
		for salle: Dictionary in run["salles"]:
			var avant: Array = salle["inventaire_combat"]
			var copie := avant.duplicate()
			var apres := Equilibrage.Retour.inventaire_deux_defenses(avant)
			_exiger(avant == copie and avant.size() == apres.size(), "Le stress defensif change le nombre de choix ou modifie la source")
			for index in avant.size():
				var id := apres[index]
				var reactif := CatalogueReactifs.par_id(id)
				_exiger(reactif.rarete == CatalogueReactifs.par_id(str(avant[index])).rarete,
					"Une defense anticipe une rarete future")
				_exiger(apres.count(id) <= reactif.copies_permises(), "Le stress duplique un choix unique")
