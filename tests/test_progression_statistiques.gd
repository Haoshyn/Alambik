extends RefCounted

func test_sources_fortes_et_rangs_lisibles(v: Verif) -> void:
	v.presque(ArbreCompetences.multiplicateur_degats({"force":7}), 1.70, "Force 7 vaut +70 %")
	v.egal(ArbreCompetences.valeur_au_rang("force",7), "+70 %", "affichage conforme au combat")
	var id: String = CatalogueObjets.IDS_PAR_MONDE[0][0]
	var initial := CatalogueObjets.bonus_objet(id,0,0)
	var maximal := CatalogueObjets.bonus_objet(id,Reglages.FORGE_NIVEAU_MAX,9)
	v.presque(float(initial["degats"]), .50, "anneau utile des son obtention")
	v.vrai(float(maximal["degats"]) >= 10.0, "anneau maximal au-dela de mille pour cent")
	v.vrai(not maximal.has("cadence"), "aucun bijou ne donne de cadence")
	for niveau in range(Reglages.FORGE_NIVEAU_MAX):
		var courant := CatalogueObjets.bonus_objet(id,niveau,0)
		var suivant := CatalogueObjets.bonus_objet(id,niveau+1,0)
		v.vrai(float(suivant["degats"]) > float(courant["degats"]), "chaque rang de Forge apporte un gain")
	v.egal(CatalogueObjets.bonus_objet(id,999,9),maximal,"Forge bornee dans le calcul aussi")
	var pauvre := Stats.depuis_reglages()
	var equipe := Stats.depuis_reglages({}, {}, initial)
	v.vrai(equipe.degats > pauvre.degats*1.49, "s'equiper renforce effectivement le heros")

func test_depart_accessible_et_montee_exponentielle(v: Verif) -> void:
	var coup := Reglages.DEGATS_COUP_REFERENCE * Chapitres.facteur_degats(0, 1)
	v.vrai(Reglages.HEROS_PV / coup >= 12.0, "un debutant peut encaisser douze impacts de reference")
	var monde_trois := Reglages.DEGATS_COUP_REFERENCE * Chapitres.facteur_degats(6, 1)
	v.vrai(monde_trois >= 110.0 and monde_trois <= 130.0, "monde trois calibre sur le parcours economique")
	for palier in range(1, 30):
		v.vrai(Chapitres.facteur_pv(palier, 1) > Chapitres.facteur_pv(palier-1, 1)*1.3, "PV exponentiels")
		v.vrai(Chapitres.facteur_degats(palier, 1) > Chapitres.facteur_degats(palier-1, 1)*1.20, "les degats suivent la defense")
		v.presque(Reglages.facteur_annexe_pv(palier), Chapitres.facteur_pv(palier, 1), "annexes sur la meme echelle")

func test_bijoux_alternatifs_et_forge_apres_dix(v: Verif) -> void:
	for profil in 3:
		var budget := float(CatalogueObjets.PROFILS[profil]["degats"]) + float(CatalogueObjets.PROFILS[profil]["pv"])
		for monde in 10:
			var id: String = CatalogueObjets.IDS_PAR_MONDE[monde][profil]
			var bonus := CatalogueObjets.bonus_objet(id, 0)
			v.presque(float(bonus["degats"])+float(bonus["pv"]), budget, "budget identique, allocation differente")
			v.egal(bonus, CatalogueObjets.bonus_objet(id, 0, 9), "aucun bonus cache lie au monde atteint")
	v.vrai(Reglages.cout_forge(20) > Reglages.cout_forge(10)*5, "le cout s'accelere apres le pouvoir")
	v.egal(CatalogueObjets.effets_objet("plume_encres", 100), CatalogueObjets.effets_objet("plume_encres", 10), "forge tardive : statistiques seules")

func test_majeurs_migration_et_repartition(v: Verif) -> void:
	for branche in ArbreCompetences.BRANCHES.values():
		for i in branche.size():
			v.egal(ArbreCompetences.rangs(branche[i]), 1 if (i+1)%3 == 0 else 10, "un majeur tous les trois noeuds")
	v.presque(ArbreCompetences.multiplicateur_degats({"precision":10}), 2.0, "majeur borne meme avec ancien rang sauvegarde")
	v.presque(ArbreCompetences.multiplicateur_cadence({"cadence":10,"rythme":10,"tempete":10}), 1.45, "cadence des maitrises bornee a +45 pour cent")
	v.presque(ArbreCompetences.multiplicateur_collecte({"celerite":10}), 1.4, "utilitaire donne quarante pour cent de ressources")
	var r: Node = load("res://autoload/reglages_joueur.gd").new()
	r.sauvegarde_active = false
	r.version_maitrises = 1
	r.gouttes = 17
	r.rangs_competences = {"force":3,"savoir":1,"distillation":2}
	var remboursement := 0
	for rang in 3: remboursement += Reglages.cout_maitrise(Reglages.MAITRISE_COUTS[0], rang)
	for rang in 2: remboursement += Reglages.cout_maitrise(Reglages.MAITRISE_COUTS[2], rang)
	remboursement += Reglages.MAITRISE_COUTS[6]
	r._migrer_maitrises()
	v.egal(r.gouttes, 17+remboursement, "anciens achats rembourses exactement")
	v.vrai(r.rangs_competences.is_empty(), "repartition libre dans le nouvel arbre")
	r._migrer_maitrises()
	v.egal(r.gouttes, 17+remboursement, "aucun remboursement double")
	r.free()

func test_dix_baguettes_une_par_monde(v: Verif) -> void:
	v.egal(CatalogueProjectiles.TYPES.size(), 10, "dix baguettes")
	for monde in range(1, 11):
		for chapitre in 3:
			v.egal(CatalogueProjectiles.disponibles((monde-1)*3+chapitre+1).size(), monde, "une baguette par monde et non par chapitre")
	var base := Tir.de_base(Stats.depuis_reglages())
	var rapide := CatalogueProjectiles.appliquer("veloce", base)
	v.vrai(rapide.degats*rapide.cadence <= base.degats*base.cadence, "aiguille : confort de trajectoire sans meilleur DPS brut")
	v.egal(CatalogueProjectiles.appliquer("prisme", base).nb_projectiles, 2, "prisme : deux traits")
	v.egal(CatalogueProjectiles.appliquer("draconique", base).fragments, 3, "cornue : trois fragments")
	v.vrai(CatalogueProjectiles.appliquer("royal", base).degats > base.degats*2.5, "la derniere baguette est plus puissante")
	v.presque(Reglages.CAPACITE_BONUS_PAR_RANG*9, .27, "rangs de sorts : bonus total modere")
	v.presque(Sorts.recharge("grand_oeuvre", {"reserve_ultime":1.0}, {}, "standard"), 75.0*.55, "reserve ultime vraiment utile des le premier rang")

func test_parcours_economique_jusqu_au_monde_trois(v: Verif) -> void:
	for repetitions in [2,3]:
		var profil := preload("res://sondes/economie_monde_trois.gd").simuler(repetitions,1)
		v.egal(int(profil["revenus"]),int(profil["depenses"])+int(profil["solde"]),"achats payes sans monnaie inventee")
		var cout := 0
		var rangs: Dictionary = profil["rangs"]
		for id in rangs:
			v.vrai(int(rangs[id]) <= ArbreCompetences.rangs(id),"rangs accessibles")
			v.vrai(ArbreCompetences.prerequis_atteint(id,rangs),"prerequis achetes")
			for rang in int(rangs[id]): cout += ArbreCompetences.cout(id,rang)
		v.egal(cout,int(profil["depenses"]),"chaque rang comptabilise au vrai prix")
		v.vrai((profil["forge"] as Dictionary).is_empty(),"pas de forge fictive sans Mine")
		if repetitions == 3: v.egal((profil["objets"] as Array).size(),6,"six objets garantis apres trois victoires sur les six chapitres")
		var coups := float(profil["resistance"])/(Reglages.DEGATS_COUP_REFERENCE*Chapitres.facteur_degats(6,1))
		v.vrai(coups >= 7.0 and coups <= 11.0,"sept a onze impacts bruts sur le parcours equilibre")
		var pv_ennemi := float(CatalogueEnnemis.par_id("sceau_belier")["pv"])*Chapitres.facteur_pv(6,1)
		v.vrai(pv_ennemi > float(profil["degats"]),"un ennemi resistant ne meurt pas au premier tir")
		v.vrai(pv_ennemi/float(profil["dps"]) < 2.0,"ennemi commun elimine en moins de deux secondes de tir soutenu")
