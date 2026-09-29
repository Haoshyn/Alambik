extends RefCounted

const Parcours = preload("res://tools/statistiques/parcours_progression.gd")
const Listes = preload("res://tools/statistiques/listes.gd")

static func n(valeur: float, decimales := 1) -> String:
	return Listes.nombre(valeur, decimales)

static func ajouter(lignes: Array[String]) -> void:
	var rapport := Parcours.rapport()
	lignes.append_array(["## Durée des runs, reprises et progression d’un compte neuf", "",
		"Ces parcours appliquent les offres d’augments, les vagues, les coûts et les coffres du jeu. La référence utilise %d choix sans légendaire bonus : %d rares, %d épiques et le légendaire garanti au niveau %d. Le bonus de %s %% par run reste inclus dans les distributions de puissance précédentes ; la progression de référence ne compte jamais sur deux légendaires. Les Épreuves gardent leurs quatre choix après boss." % [ProgressionAugments.niveau_max(), ProgressionAugments.niveau_max() - ProgressionAugments.NOMBRE_EPIQUES - 1, ProgressionAugments.NOMBRE_EPIQUES, ProgressionAugments.NIVEAU_LEGENDAIRE, n(ProgressionAugments.CHANCE_LEGENDAIRE_BONUS * 100.0)], "",
		"Ils mesurent un modèle de puissance et de temps, sans simuler les déplacements ni prédire les victoires d’un joueur. Les 35 chapitres restent conditionnels aux critères de confort définis ci-dessous.", "",
		"### Durée d’une run complète", "",
		"Huit graines fixes servent à décrire la dispersion des offres. Le compte du retry reçoit seulement le butin de huit salles et d’un boss après une défaite imposée en salle 9, puis paie ses améliorations. Chaque run reprend sans augment.", ""])
	var temps: Array = []
	for entree: Array in [["depart", "Compte neuf, chapitre 1"], ["retry", "Même chapitre après la première défaite"], ["complet", "Permanent maximum, chapitre 35"]]:
		var mesure: Dictionary = rapport[str(entree[0])]
		temps.append([str(entree[1]), _intervalle(mesure["duree"], 60.0), _intervalle(mesure["boss_final"]), _intervalle(mesure["contacts_min"])])
	Listes.tableau(lignes, ["Situation", "Run : médiane [P10–P90], min", "Boss final : secondes", "Contacts minimum équivalents"], temps)
	var classique: Dictionary = rapport["classique"]
	lignes.append("Avec le panier classique fixe au maximum, le boss final du chapitre 35 représente **%s secondes** à 70 %% de tir utile, pour %s DPS théoriques. La cohorte ci-dessus utilise les vrais choix proposés au fil des runs, donc peut obtenir d’autres résultats." % [n(float(classique["boss_final"])), n(float(classique["mesure"]["dps"]))])
	lignes.append("")
	var sensibilites: Array = []
	for ligne: Dictionary in rapport["sensibilite"]:
		sensibilites.append([n(float(ligne["tir_utile"]) * 100.0, 0) + " %", _intervalle(ligne["depart"]["duree"], 60.0), _intervalle(ligne["retry"]["duree"], 60.0), _intervalle(ligne["complet"]["duree"], 60.0)])
	Listes.tableau(lignes, ["Tir utile, vagues et boss", "Compte neuf, min", "Retry, min", "Maximum chapitre 35, min"], sensibilites)
	_comparaisons(lignes, rapport)
	_chapitres(lignes, rapport["equilibre"])
	_blocs(lignes, rapport["equilibre"])
	lignes.append_array(["### Hypothèses et limites", ""])
	for hypothese: String in rapport["hypotheses"]: lignes.append("- " + hypothese)
	lignes.append("")

static func _comparaisons(lignes: Array[String], rapport: Dictionary) -> void:
	lignes.append_array(["### Parcours et premier besoin de renforcement", ""])
	var murs: Dictionary = rapport["distribution_murs"]
	lignes.append("Sans annexe ni replay volontaire après la première défaite, huit comptes rencontrent leur premier seuil de confort au chapitre médian **%s [P10 %s ; P90 %s]**. Ces rangs de chapitre décrivent les huit exemples ; ils ne sont pas une probabilité de défaite." % [n(float(murs["mediane"])), n(float(murs["p10"])), n(float(murs["p90"]))])
	lignes.append("")
	var comparaisons: Array = []
	for entree: Array in [["sans_annexes", "Sans farm"], ["equilibre", "Lots selon le gain attendu, choix équilibrés"], ["adaptatif", "Choix défensifs après un manque de survie"], ["mixte", "Comparatif imposé : 3 replays + 3 Mines + 3 Épreuves"]]:
		var cas: Dictionary = rapport[str(entree[0])]
		comparaisons.append([str(entree[1]), str(cas["chapitres_valides"]), str(cas["etat_final"]["niveau"]),
			_nombre_modes(cas), n(float(cas["duree"]) / 60.0), n(_maximum(cas["blocs"], "farm") / 60.0), n(_maximum(cas["blocs"], "avant_succes") / 60.0)])
	Listes.tableau(lignes, ["Méthode", "Chapitres validés par le modèle", "Niveau du compte", "Runs campagne / Mine / Épreuve", "Temps total, min", "Plus long farm, min", "Plus long farm + échecs, min"], comparaisons)
	lignes.append("Le comparatif de neuf runs impose volontairement un gros lot : il ne constitue pas une obligation de jeu. La politique équilibrée reste la référence ; toutes les victoires et défaites du tableau pilotent réellement les coffres reçus.")
	lignes.append("")
	var comptes: Array = []
	for cas: Dictionary in rapport["cohorte_comptes"]:
		comptes.append([str(cas["options"].get("graine", Parcours.GRAINE_BASE)), str(cas["chapitres_valides"]),
			str(cas["etat_final"]["niveau"]), n(_maximum(cas["blocs"], "farm") / 60.0), n(_maximum(cas["blocs"], "avant_succes") / 60.0)])
	Listes.tableau(lignes, ["Graine du compte équilibré", "Chapitres", "Niveau final", "Farm maximum, min", "Farm + échecs maximum, min"], comptes)
	var strict: Dictionary = rapport["seuil_90"]["premier_mur"]
	lignes.append("Avec le seuil fixe de sensibilité à 90 secondes, plus permissif que les cibles de campagne, le compte de référence sans farm rencontre ce critère dès le chapitre %s. Le choix du seuil change le diagnostic ; aucune formule ne garantit une réussite en deux essais." % str(strict.get("chapitre", "aucun")))
	lignes.append("")

static func _chapitres(lignes: Array[String], cas: Dictionary) -> void:
	lignes.append_array(["### Compte de référence : ce qui finance chaque chapitre", "",
		"Les achats indiquent des rangs de maîtrise / forge effectivement payés pendant le chapitre et ses lots. La durée distingue le farm des tentatives du chapitre. Le tableau donne le temps du boss final et le minimum de contacts équivalents sur l’essai validé par le modèle.", ""])
	var tableau: Array = []
	for chapitre in range(1, int(cas["chapitres_valides"]) + 1):
		var premier := 0
		var final: Dictionary = {}
		var maitrises := 0
		var forge := 0
		var farm := 0.0
		var tentatives := 0.0
		var compteurs := {"mine": 0, "epreuves": 0, "grimoire": 0}
		for action: Dictionary in cas["actions"]:
			if int(action["mur_chapitre"]) != chapitre: continue
			if premier == 0: premier = int(action["niveau_avant"])
			for achat: Dictionary in action["achats"]:
				if str(achat["type"]) == "forge": forge += 1
				else: maitrises += 1
			if str(action["role"]) == "farm":
				farm += float(action["duree"])
				compteurs[str(action["mode"])] = int(compteurs[str(action["mode"])]) + 1
			else:
				tentatives += float(action["duree"])
				if bool(action["victoire"]): final = action
		if final.is_empty(): continue
		tableau.append([chapitre, "%d → %d" % [premier, int(final["niveau_apres"])], "%d / %d" % [maitrises, forge],
			"%d / %d / %d" % [int(compteurs["mine"]), int(compteurs["epreuves"]), int(compteurs["grimoire"])],
			n(farm / 60.0), n(tentatives / 60.0), n(float(final["boss_final"])), n(float(final["contacts_min"]))])
	Listes.tableau(lignes, ["Chapitre", "Niveau", "Achats M / F", "Mines / Épreuves / replays", "Farm, min", "Tentatives, min", "Boss final, s", "Contacts minimum"], tableau)

static func _blocs(lignes: Array[String], cas: Dictionary) -> void:
	lignes.append_array(["### Temps supplémentaire aux seuils de confort", "",
		"Le farm inclut les replays terminés ou ratés du chapitre précédent. Les échecs ci-dessous concernent le chapitre en cours. Leur somme exclut la tentative finalement réussie. Le gain de puissance compare le compte avant le premier lot et après le dernier lot, sans augment.", ""])
	var tableau: Array = []
	for bloc: Dictionary in cas["blocs"]:
		var debut: Dictionary = {}
		var fin: Dictionary = {}
		for lot: Dictionary in cas["lots"]:
			if int(lot["chapitre"]) != int(bloc["chapitre"]): continue
			if debut.is_empty(): debut = lot
			fin = lot
		tableau.append([bloc["chapitre"], "%d / %d / %d" % [int(bloc["mines"]), int(bloc["epreuves"]), int(bloc["replays"])],
			n(float(bloc["farm"]) / 60.0), n(float(bloc["echecs"]) / 60.0), n(float(bloc["avant_succes"]) / 60.0),
			"×%s / ×%s" % [n(float(fin["dps_apres"]) / float(debut["dps_avant"]), 2), n(float(fin["ehp_apres"]) / float(debut["ehp_avant"]), 2)]])
	Listes.tableau(lignes, ["Chapitre", "Mines / Épreuves / replays", "Farm, min", "Échecs, min", "Somme avant succès, min", "Gain DPS / PV effectifs"], tableau)

static func _intervalle(distribution: Dictionary, diviseur := 1.0) -> String:
	return "%s [%s–%s]" % [n(float(distribution["mediane"]) / diviseur), n(float(distribution["p10"]) / diviseur), n(float(distribution["p90"]) / diviseur)]

static func _maximum(blocs: Array, cle: String) -> float:
	var resultat := 0.0
	for bloc: Dictionary in blocs: resultat = maxf(resultat, float(bloc[cle]))
	return resultat

static func _nombre_modes(cas: Dictionary) -> String:
	var comptes := {"grimoire": 0, "mine": 0, "epreuves": 0}
	for action: Dictionary in cas["actions"]: comptes[str(action["mode"])] = int(comptes[str(action["mode"])]) + 1
	return "%d / %d / %d" % [int(comptes["grimoire"]), int(comptes["mine"]), int(comptes["epreuves"])]
