extends RefCounted

const FinDeRun = preload("res://ui/fin_de_run.gd")

func test_qualite_evolue_aux_quatre_paliers(v: Verif) -> void:
	v.egal(Recompenses.coffre_pour(4)["palier"], 0, "aucun coffre avant cinq salles")
	v.egal(Recompenses.coffre_pour(5)["nom"], "Mini coffre", "palier cinq")
	v.egal(Recompenses.coffre_pour(10)["nom"], "Petit coffre", "palier dix")
	v.egal(Recompenses.coffre_pour(18)["nom"], "Coffre moyen", "mourir salle 19 garde le palier quinze")
	v.egal(Recompenses.coffre_pour(20)["nom"], "Grand coffre", "clear complet")

func test_garantie_du_grand_coffre(v: Verif) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var grand := Recompenses.coffre_pour(20)
	v.vrai(Recompenses.donne_objet(grand, Recompenses.GARANTIE_APRES_GRANDS_COFFRES - 1, rng),
		"le cinquieme grand coffre sans objet est garanti")

func test_les_gouttes_accelerent_sur_les_trente_chapitres(v: Verif) -> void:
	var grand := Recompenses.coffre_pour(20)
	var debut := RandomNumberGenerator.new()
	debut.seed = 17
	var fin := RandomNumberGenerator.new()
	fin.seed = 17
	var gouttes_debut := Recompenses.tirer_gouttes_coffre(grand, 0, debut)
	var gouttes_fin := Recompenses.tirer_gouttes_coffre(grand, Chapitres.nombre() - 1, fin)
	var ratio := float(gouttes_fin) / float(gouttes_debut)
	v.vrai(ratio >= 190.0 and ratio <= 205.0,
		"le dernier chapitre paie environ deux cents fois le premier")

func test_l_economie_suit_les_jalons_de_maitrise_sans_farm(v: Verif) -> void:
	var grand := Recompenses.coffre_pour(20)
	var moyenne_base := (float(grand["gouttes_min"]) + float(grand["gouttes_max"])) * 0.5
	var revenus := []
	var cumul := 0.0
	for chapitre in Chapitres.nombre():
		cumul += moyenne_base * pow(Reglages.GOUTTES_MULT_PAR_CHAPITRE, chapitre)
		if chapitre in [14, 20, 29]:
			revenus.append(cumul)
	v.vrai(float(revenus[0]) >= 950.0 and float(revenus[0]) <= 1100.0,
		"a 50 pour cent du jeu, le revenu couvre environ 30 pour cent des premiers rangs")
	v.vrai(float(revenus[1]) >= 2900.0 and float(revenus[1]) <= 3300.0,
		"a 70 pour cent du jeu, le revenu approche 50 pour cent des premiers rangs")
	v.vrai(float(revenus[2]) >= 15500.0 and float(revenus[2]) <= 17500.0,
		"la premiere fin couvre environ 80 pour cent des premiers rangs")

func test_l_ouverture_separe_impact_et_revelation(v: Verif) -> void:
	v.presque(FinDeRun.progression_ouverture(0.5), 0.0, "le coffre reste ferme pendant son arrivee")
	v.vrai(FinDeRun.progression_ouverture(1.35) > 0.0, "le couvercle s'ouvre apres l'impact")
	v.presque(FinDeRun.progression_ouverture(2.0), 1.0, "le coffre finit completement ouvert")
	v.presque(FinDeRun.progression_revelation(1.2), 0.0, "la recompense ne devance pas le coffre")
	v.presque(FinDeRun.progression_revelation(2.2), 1.0, "la recompense devient entierement lisible")
