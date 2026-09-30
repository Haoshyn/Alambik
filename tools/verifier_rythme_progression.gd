extends SceneTree

const Rythme = preload("res://tools/statistiques/rythme_progression.gd")
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
	var nombre := Rythme.NOMBRE_COMPTES
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--comptes="): nombre = maxi(1, argument.trim_prefix("--comptes=").to_int())
	var rapport := Rythme.rapport(nombre)
	var profil: Dictionary = rapport["profil"]
	_exiger(float(profil["attaques"]["mediane"]) >= 2.0 and float(profil["attaques"]["mediane"]) <= 4.0,
		"Le profil sans attribut doit entrer au niveau deux en deux a quatre attaques sans augment")
	for id: String in profil["especes"]:
		var espece: Dictionary = profil["especes"][id]
		print("Profil niveau 4, C2, %s : %.1f PV, %.1f degats, %d attaques" % [id, float(espece["pv"]), float(profil["attaque"]), int(espece["attaques"])])
	for achat: Dictionary in rapport["achats"]:
		var minimum := 0.03 if str(achat["nom"]) == "Arme 1 → 2" \
			else (0.08 if str(achat["nom"]) == "Force maîtrisée 6 → 10" else 0.10)
		_exiger(float(achat["gain_tir"]) >= minimum, "L'achat ne renforce pas assez le tir : " + str(achat["nom"]))
		print("Achat %s : +%.1f %% par tir, +%.1f %% DPS, cout %d" % [str(achat["nom"]), float(achat["gain_tir"]) * 100.0, float(achat["gain_dps"]) * 100.0, int(achat["prix"])])
	for chapitre: int in rapport["entrees"]:
		var entree: Dictionary = rapport["entrees"][chapitre]
		if chapitre <= 3:
			_exiger(float(entree["attaques"]["p90"]) <= 5.0, "Le debut impose du farm avant les premiers renforcements : " + str(chapitre))
			_exiger(float(entree["boss"]["mediane"]) <= 90.0, "Boss trop long avant les premiers renforcements : " + str(chapitre))
		if chapitre in [2, 7, 14, 21, 28, 35]:
			print("Entree C%d sans augment : %.1f attaques [P90 %.1f], %.1f DPS permanents ; boss final %.1f s" % [chapitre, float(entree["attaques"]["mediane"]), float(entree["attaques"]["p90"]), float(entree["dps"]["mediane"]), float(entree["boss"]["mediane"])])
	# Le compte qui omet Mine, passifs et Coeurs est un stress sous-equipe.
	# L'accessibilite tardive concerne les achats finances du parcours renforce.
	var fin: Dictionary = rapport["entrees_renforcees"][Chapitres.nombre()]
	_exiger(float(fin["attaques"]["p90"]) <= 8.0, "Le renforcement tardif ne rend pas l'entree du dernier niveau accessible")
	_exiger(float(fin["secondes"]["p90"]) <= 3.0, "Les ennemis ordinaires resistent trop longtemps avant les augments au dernier niveau")
	_exiger(float(fin["boss"]["mediane"]) <= Reglages.CAMPAGNE_BOSS_DUREE_SIGNATURE.y, "Le renforcement tardif ne rend pas le dernier boss accessible")
	for chapitre: int in rapport["entrees_renforcees"]:
		var entree: Dictionary = rapport["entrees_renforcees"][chapitre]
		if chapitre <= Chapitres.CHAPITRES_PAR_MONDE:
			_exiger(float(entree["attaques"]["p90"]) <= 6.0 and float(entree["secondes"]["p90"]) <= 5.0,
				"Le renforcement finance ne rend pas l'entree du premier monde accessible : " + str(chapitre))
		print("Entree financee C%d : %.1f attaques, %.1f s sans augment, %.1f DPS ; boss %.1f s" % [chapitre, float(entree["attaques"]["mediane"]), float(entree["secondes"]["mediane"]), float(entree["dps"]["mediane"]), float(entree["boss"]["mediane"])])
	for chapitre: int in rapport["farm"]:
		var farm: Dictionary = rapport["farm"][chapitre]
		var reprises := int(Rythme.REPRISES[chapitre - 1])
		# Les achats sont discrets : un court lot finance quelques rangs ;
		# le lot tardif doit produire un renforcement nettement plus sensible.
		var minimum := 0.15 if reprises == 5 else (0.05 if reprises >= 3 else 0.03)
		_exiger(float(farm["gain_dps"]["mediane"]) >= minimum, "Les reprises ne renforcent pas assez les degats permanents : " + str(chapitre))
		print("Reprises C%d : +%.1f %% DPS, %+.1f %% survie" % [chapitre, float(farm["gain_dps"]["mediane"]) * 100.0, float(farm["gain_survie"]["mediane"]) * 100.0])
	for budget: Dictionary in rapport["budgets"]:
		for cote: String in ["avant", "apres"]:
			var etat: Dictionary = budget[cote]
			for cle: String in ["gouttes", "pierres"]:
				_exiger(int(etat[cle]) >= 0 and int(etat["recus"][cle]) - int(etat["depenses"][cle]) == int(etat[cle]), "Les reprises inventent des ressources")
	var chemin := "res://tmp/verification_rythme_progression/mesures.json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(chemin.get_base_dir()))
	var fichier := FileAccess.open(chemin, FileAccess.WRITE)
	_exiger(fichier != null, "Impossible d'ecrire les mesures de rythme")
	if fichier != null: fichier.store_string(JSON.stringify(rapport, "\t") + "\n")
	for erreur: String in _erreurs: push_error(erreur)
	print("Rythme progression : %d controles, %d erreurs, %d comptes." % [_controles, _erreurs.size(), nombre])
	quit(0 if _erreurs.is_empty() else 1)
