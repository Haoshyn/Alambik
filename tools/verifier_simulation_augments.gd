extends SceneTree

const Simulation = preload("res://tools/statistiques/simulation_augments.gd")
const Modeles = preload("res://tools/statistiques/modeles.gd")

var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	var nombre_runs := Simulation.NOMBRE_RUNS
	var configuration := {}
	var sortie := "res://tmp/verification_simulation_augments/resultat.json"
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--runs="):
			nombre_runs = maxi(1, argument.trim_prefix("--runs=").to_int())
		elif argument == "--complet":
			configuration = Modeles.complet()
		elif argument.begins_with("--sortie="):
			sortie = argument.trim_prefix("--sortie=")
	_verifier_calendrier()
	_verifier_tirages()
	_verifier_parcours(configuration)
	var resultat := Simulation.simuler(configuration, nombre_runs)
	_verifier_distributions(resultat)
	_ecrire_resultat(resultat, sortie)
	_afficher(resultat)
	for erreur: String in _erreurs:
		push_error(erreur)
	print("Simulation augments : %d contrôles, %d erreurs ; %d runs par politique." % [_controles, _erreurs.size(), nombre_runs])
	quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition:
		_erreurs.append(message)

func _verifier_calendrier() -> void:
	var calendrier := Simulation.calendrier()
	_exiger(ProgressionAugments.niveau_max() == 10 and calendrier.size() == ProgressionAugments.niveau_max(),
		"Le calendrier ne contient pas exactement dix choix de niveau")
	_exiger(ProgressionAugments.NIVEAU_LEGENDAIRE == 5 and ProgressionAugments.NOMBRE_EPIQUES == 3,
		"La garantie du niveau cinq ou les trois épiques ont changé")
	_exiger(is_equal_approx(ProgressionAugments.CHANCE_LEGENDAIRE_BONUS, 0.10), "La probabilité du bonus doit être exactement 10 % par run")
	var niveaux: Array[int] = []
	for evenement: Dictionary in calendrier:
		niveaux.append(int(evenement["salle"]))
		_exiger(str(evenement["nature"]) == "niveau" and int(evenement["niveau"]) == niveaux.size(),
			"Un choix supplémentaire remplace un niveau")
		_exiger(str(evenement["moment"]) == "sortie", "Niveau acquis avant le combat")
	_exiger(niveaux == ProgressionAugments.SALLES_NIVEAUX, "Les niveaux ne suivent pas le plafond réel des salles")
	_exiger(niveaux[ProgressionAugments.NIVEAU_LEGENDAIRE - 1] == 8, "La garantie du niveau cinq arrive après la mauvaise salle")

func _verifier_budget(raretes: Array, autoriser_bonus: bool) -> void:
	_exiger(raretes.size() == ProgressionAugments.niveau_max(), "Le planning n'a pas dix choix")
	_exiger(raretes[ProgressionAugments.NIVEAU_LEGENDAIRE - 1] == Reactif.LEGENDAIRE, "La garantie du niveau cinq a disparu")
	var legendaires := raretes.count(Reactif.LEGENDAIRE)
	var epiques := raretes.count(Reactif.EPIQUE)
	var rares := raretes.count(Reactif.RARE)
	_exiger(legendaires >= 1 and legendaires <= (2 if autoriser_bonus else 1), "Plus d'un légendaire bonus")
	_exiger(epiques == ProgressionAugments.NOMBRE_EPIQUES or (legendaires == 2 and epiques == ProgressionAugments.NOMBRE_EPIQUES - 1),
		"Le remplacement légendaire retire le mauvais nombre d'épiques")
	_exiger(rares + epiques + legendaires == raretes.size(), "Un choix commun ou inconnu reste dans le planning")

func _verifier_tirages() -> void:
	const TAILLE_ECHANTILLON := 100000
	var rng := RandomNumberGenerator.new()
	var rng_ordinaire := RandomNumberGenerator.new()
	var bonus_par_niveau: Array[int] = []
	var epiques_par_niveau: Array[int] = []
	bonus_par_niveau.resize(ProgressionAugments.niveau_max())
	bonus_par_niveau.fill(0)
	epiques_par_niveau.resize(ProgressionAugments.niveau_max())
	epiques_par_niveau.fill(0)
	var remplacements := {Reactif.RARE: 0, Reactif.EPIQUE: 0}
	var runs_avec_bonus := 0
	for index in TAILLE_ECHANTILLON:
		rng.seed = Simulation.GRAINE_BASE + index
		rng_ordinaire.seed = rng.seed
		var raretes := ProgressionAugments.tirer_raretes_niveaux(rng)
		var ordinaires := ProgressionAugments.tirer_raretes_niveaux(rng_ordinaire, false)
		_verifier_budget(raretes, true)
		_verifier_budget(ordinaires, false)
		var differences := 0
		for position in raretes.size():
			if ordinaires[position] == Reactif.EPIQUE:
				epiques_par_niveau[position] += 1
			if raretes[position] == ordinaires[position]:
				continue
			differences += 1
			_exiger(position + 1 != ProgressionAugments.NIVEAU_LEGENDAIRE and raretes[position] == Reactif.LEGENDAIRE,
				"Le bonus modifie une autre rareté que son seul remplacement")
			bonus_par_niveau[position] += 1
			remplacements[ordinaires[position]] = int(remplacements.get(ordinaires[position], 0)) + 1
		_exiger(differences == raretes.count(Reactif.LEGENDAIRE) - 1, "Le bonus retouche plusieurs choix")
		if differences == 1:
			runs_avec_bonus += 1
	var probabilite := ProgressionAugments.CHANCE_LEGENDAIRE_BONUS
	# Six ecarts types couvrent le bruit du tirage sans confondre 10 % par run
	# avec 10 % a chaque niveau, ce qui donnerait beaucoup plus de bonus.
	var attendu := float(TAILLE_ECHANTILLON) * probabilite
	var tolerance := 6.0 * sqrt(float(TAILLE_ECHANTILLON) * probabilite * (1.0 - probabilite))
	_exiger(absf(float(runs_avec_bonus) - attendu) < tolerance, "La fréquence du légendaire bonus ne suit pas 10 % par run")
	for position in bonus_par_niveau.size():
		if position + 1 == ProgressionAugments.NIVEAU_LEGENDAIRE:
			_exiger(bonus_par_niveau[position] == 0 and epiques_par_niveau[position] == 0, "La garantie participe au tirage des autres raretés")
			continue
		var chance_bonus := probabilite / float(ProgressionAugments.niveau_max() - 1)
		var attendu_bonus := float(TAILLE_ECHANTILLON) * chance_bonus
		var tolerance_bonus := 6.0 * sqrt(attendu_bonus * (1.0 - chance_bonus))
		_exiger(bonus_par_niveau[position] > 0 and absf(float(bonus_par_niveau[position]) - attendu_bonus) < tolerance_bonus,
			"Niveau inéligible ou biaisé pour le légendaire bonus : " + str(position + 1))
		var chance_epique := float(ProgressionAugments.NOMBRE_EPIQUES) / float(ProgressionAugments.niveau_max() - 1)
		var attendu_epique := float(TAILLE_ECHANTILLON) * chance_epique
		var tolerance_epique := 6.0 * sqrt(attendu_epique * (1.0 - chance_epique))
		_exiger(absf(float(epiques_par_niveau[position]) - attendu_epique) < tolerance_epique,
			"Le tirage des trois épiques privilégie un niveau : " + str(position + 1))
	_exiger(int(remplacements[Reactif.RARE]) > 0 and int(remplacements[Reactif.EPIQUE]) > 0,
		"Le bonus ne peut pas remplacer à la fois un rare et un épique")
	print("Loi des raretés : %d bonus sur %d runs (%.3f %%), niveaux %s, remplacements %s." % [runs_avec_bonus,
		TAILLE_ECHANTILLON, 100.0 * float(runs_avec_bonus) / float(TAILLE_ECHANTILLON), str(bonus_par_niveau), JSON.stringify(remplacements)])

func _verifier_parcours(configuration: Dictionary) -> void:
	for autoriser_bonus: bool in [false, true]:
		var repartitions := {}
		for politique: String in Simulation.POLITIQUES:
			for index in range(12):
				var run := Simulation.une_run(configuration, politique, Simulation.GRAINE_BASE + index, autoriser_bonus)
				var raretes: Array[String] = run["raretes_niveaux"]
				_verifier_budget(raretes, autoriser_bonus)
				if repartitions.has(index):
					_exiger(raretes == repartitions[index], "Les politiques ne partagent pas les mêmes raretés")
				else:
					repartitions[index] = raretes
				var rng := RandomNumberGenerator.new()
				rng.seed = Simulation.GRAINE_BASE + index
				_exiger(ProgressionAugments.tirer_raretes_niveaux(rng, autoriser_bonus) == raretes, "Le simulateur détourne le planning réel")
				var inventaire: Array[String] = []
				var evenements: Array = run["evenements"]
				_exiger(evenements.size() == ProgressionAugments.niveau_max(), "La run ne possède pas dix choix")
				for evenement: Dictionary in evenements:
					var rarete := str(evenement["rarete"])
					var niveau := int(evenement["niveau"])
					_exiger(rarete == ProgressionAugments.rarete_niveau(niveau, raretes), "Une offre ignore la rareté planifiée")
					var offre: Array = evenement["offre"]
					var id := str(evenement["choix"])
					_exiger(offre.size() == ProgressionAugments.NOMBRE_CHOIX and id in offre, "Choix absent d'une vraie offre")
					_exiger(offre == DraftLogique.proposer(inventaire, rng, ProgressionAugments.NOMBRE_CHOIX, rarete, niveau),
						"L'offre du simulateur diffère du tirage réel")
					_exiger(evenement["inventaire_avant"] == inventaire, "L'inventaire a changé entre deux offres")
					var candidats := DraftLogique.candidats(inventaire, rarete, niveau)
					for offert: String in offre:
						_exiger(offert in candidats and offre.count(offert) == 1, "Offre illégale : " + offert)
					var reactif := CatalogueReactifs.par_id(id)
					_exiger(reactif.rarete == rarete and inventaire.count(id) < reactif.copies_permises(), "Rareté ou copies invalides : " + id)
					inventaire.append(id)
				_exiger(inventaire == run["inventaire"], "L'inventaire final ne correspond pas aux choix")
				var salles: Array = run["salles"]
				_exiger(salles.size() == Reglages.SALLES_PAR_RUN, "Nombre de salles incorrect")
				for index_salle in salles.size():
					var etat: Dictionary = salles[index_salle]
					_exiger(etat["inventaire_combat"] == etat["inventaire_avant"], "Le combat profite d'un choix futur")
					if index_salle > 0:
						var precedent: Dictionary = salles[index_salle - 1]
						_exiger(etat["inventaire_avant"] == precedent["inventaire_apres"], "Inventaire perdu entre les salles")
				if index == 0:
					_exiger(JSON.stringify(run) == JSON.stringify(Simulation.une_run(configuration, politique, Simulation.GRAINE_BASE, autoriser_bonus)),
						"Parcours non reproductible : " + politique)
		var petit_lot := Simulation.simuler(configuration, 8, Simulation.GRAINE_BASE, autoriser_bonus)
		_exiger(JSON.stringify(petit_lot) == JSON.stringify(Simulation.simuler(configuration, 8, Simulation.GRAINE_BASE, autoriser_bonus)),
			"Distributions non reproductibles")
		_verifier_distributions(petit_lot)

func _verifier_distributions(resultat: Dictionary) -> void:
	var nombre_runs := int(resultat["runs_par_politique"])
	var politiques: Dictionary = resultat["politiques"]
	for politique: String in politiques:
		var donnees: Dictionary = politiques[politique]
		var salles: Array = donnees["salles"]
		for etat: Dictionary in salles:
			for phase: String in ["avant", "combat", "apres"]:
				var mesures: Dictionary = etat[phase]
				for mesure: String in mesures:
					var distribution: Dictionary = mesures[mesure]
					var bas := float(distribution["p10"])
					var milieu := float(distribution["mediane"])
					var haut := float(distribution["p90"])
					_exiger(is_finite(bas) and is_finite(haut) and bas >= 0.0 and bas <= milieu and milieu <= haut,
						"Quantiles incohérents : " + politique + "/" + mesure)
		var legendaires: Dictionary = donnees["legendaires"]
		var nombre_bonus := int(donnees["runs_avec_bonus"])
		_exiger(nombre_bonus >= 0 and nombre_bonus <= nombre_runs, "Plusieurs bonus dans une même run")
		if not bool(resultat["autoriser_legendaire_bonus"]):
			_exiger(nombre_bonus == 0, "La référence sans bonus reçoit un second légendaire")
		var somme_offres := 0
		var somme_choix := 0
		for id: String in legendaires:
			var compteur: Dictionary = legendaires[id]
			somme_offres += int(compteur["offres"])
			somme_choix += int(compteur["choix"])
			_exiger(int(compteur["choix"]) <= int(compteur["offres"]), "Légendaire choisi sans être proposé : " + id)
			if nombre_runs >= 64:
				_exiger(int(compteur["offres"]) > 0 and int(compteur["offres"]) < nombre_runs,
					"Le légendaire est absent ou garanti dans toutes les offres : " + id)
		_exiger(somme_offres == (nombre_runs + nombre_bonus) * ProgressionAugments.NOMBRE_CHOIX and somme_choix == nombre_runs + nombre_bonus,
			"Le tirage légendaire ne respecte pas trois offres pour chaque choix garanti ou bonus")

func _ecrire_resultat(resultat: Dictionary, sortie: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(sortie.get_base_dir()))
	var fichier := FileAccess.open(sortie, FileAccess.WRITE)
	_exiger(fichier != null, "Impossible d'écrire la sortie de simulation")
	if fichier != null:
		fichier.store_string(JSON.stringify(resultat, "\t") + "\n")

func _afficher(resultat: Dictionary) -> void:
	var politiques: Dictionary = resultat["politiques"]
	for politique: String in politiques:
		var donnees: Dictionary = politiques[politique]
		var salles: Array = donnees["salles"]
		for numero in [1, 4, 5, 9, 10, 15, 19, 20]:
			var salle: Dictionary = salles[numero - 1]
			var combat: Dictionary = salle["combat"]
			var dps: Dictionary = combat["dps_ratio"]
			var ehp: Dictionary = combat["ehp_ratio"]
			print("Simulation %s salle %d combat : DPS %.3f [%.3f ; %.3f], EHP %.3f [%.3f ; %.3f]" % [politique, numero,
				float(dps["mediane"]), float(dps["p10"]), float(dps["p90"]), float(ehp["mediane"]), float(ehp["p10"]), float(ehp["p90"])])
		print("Legendaires %s : %s" % [politique, JSON.stringify(donnees["legendaires"])])
