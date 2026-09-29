extends SceneTree

const Maturation = preload("res://tools/statistiques/maturation_progression.gd")
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
	var nombre := Maturation.NOMBRE_COMPTES
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--comptes="): nombre = maxi(1, argument.trim_prefix("--comptes=").to_int())
	var rapport := Maturation.rapport(nombre)
	for compte: Dictionary in rapport["comptes"]:
		var contexte := "%s, graine %d" % [str(compte["strategie"]), int(compte["graine"])]
		_exiger(bool(compte["termine"]), "Tous les plafonds doivent etre atteignables : " + contexte)
		_exiger(bool(compte["victoires"]), "Une victoire economique ne doit pas etre inventee : " + contexte)
		var minimum := INF
		var maximum := 0.0
		for famille: String in Maturation.FAMILLES:
			var etapes: Dictionary = compte["etapes"][famille]
			var precedent := 0.0
			for cle: String in ["50", "75", "100"]:
				_exiger(etapes.has(cle), "Etape absente %s/%s : %s" % [famille, cle, contexte])
				if not etapes.has(cle): continue
				var temps := float(etapes[cle]["secondes"])
				_exiger(temps >= precedent, "Etapes hors ordre : " + contexte)
				precedent = temps
			if not etapes.has("100"): continue
			var fin := float(etapes["100"]["secondes"])
			minimum = minf(minimum, fin)
			maximum = maxf(maximum, fin)
			print("Plafond %s, %s : %.1f min, %d actions" % [famille, contexte, fin / 60.0, int(etapes["100"]["actions"])])
		_exiger(maximum <= minimum * (1.0 + Reglages.PROGRESSION_ECART_PLAFONDS),
			"Les cinq plafonds demandent des temps trop differents : " + contexte)
		var etapes: Dictionary = compte["etapes"]
		if etapes["attributs"].has("100") and etapes["maitrises"].has("100"):
			var heros := float(etapes["attributs"]["100"]["secondes"])
			var maitrises := float(etapes["maitrises"]["100"]["secondes"])
			_exiger(heros >= maitrises * (1.0 - Reglages.PROGRESSION_ECART_HEROS_MAITRISES)
				and heros <= maitrises * (1.0 + Reglages.PROGRESSION_ECART_HEROS_MAITRISES),
				"Le niveau maximum doit rester proche des dernieres maitrises : " + contexte)
		var final: Dictionary = compte["etat_final"]
		_exiger(int(final["niveau"]) == Personnage.NIVEAU_MAX, "Niveau final incomplet : " + contexte)
		for monnaie: String in ["gouttes", "pierres"]:
			_exiger(int(final[monnaie]) >= 0 and int(final["recus"][monnaie]) - int(final["depenses"][monnaie]) == int(final[monnaie]),
				"Budget final invente : " + contexte)
	var chemin := "res://tmp/verification_maturation_progression/mesures.json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(chemin.get_base_dir()))
	var fichier := FileAccess.open(chemin, FileAccess.WRITE)
	_exiger(fichier != null, "Impossible d'ecrire les mesures de maturation")
	if fichier != null: fichier.store_string(JSON.stringify(rapport, "\t") + "\n")
	for erreur: String in _erreurs: push_error(erreur)
	print("Maturation progression : %d controles, %d erreurs, %d comptes par strategie." % [_controles, _erreurs.size(), nombre])
	quit(0 if _erreurs.is_empty() else 1)
