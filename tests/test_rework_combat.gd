extends RefCounted

func test_coups_de_depart_et_soins_bornes(v: Verif) -> void:
	var stats := Stats.depuis_reglages()
	var degats := Reglages.DEGATS_COUP_REFERENCE * ProgressionStatistiques.facteur_degats(0)
	var coups := ceili(stats.pv_max / degats)
	v.vrai(coups >= 25, "le chapitre un pardonne de nombreuses erreurs")
	for coup in coups-1: stats.blesser(degats)
	v.presque(stats.pv, stats.pv_max - float(coups-1)*degats, "une derniere chance avant le coup fatal")
	stats.blesser(Reglages.DEGATS_COUP_REFERENCE * ProgressionStatistiques.facteur_degats(0))
	v.vrai(stats.est_mort(), "le dernier coup est fatal sans protection")
	stats.pv = stats.pv_max * 0.20
	stats.soin_restant = stats.pv_max * Reglages.SOIN_COMBAT_PAR_SALLE
	for impact in 100: stats.soigner(4.0)
	v.presque(stats.pv, stats.pv_max * 0.25, "les soins cumules ne rendent pas immortel")
	stats.soigner_garanti(stats.pv_max * Reglages.SOIN_AVANT_BOSS)
	v.presque(stats.pv, stats.pv_max * 0.55, "le boss rend trente pour cent des PV meme apres epuisement du soin")
	stats.soigner_garanti(50.0)
	v.presque(stats.pv, stats.pv_max, "le soin de halte ne depasse pas le maximum")

func test_une_defaite_precoce_finance_une_maitrise(v: Verif) -> void:
	var gain := Recompenses.gouttes_progression(4, 0)
	v.vrai(gain >= ArbreCompetences.cout("force"), "perdre au premier miniboss paie un premier achat")
	v.egal(Recompenses.gouttes_progression(0, 0), 0, "quitter immediatement ne rapporte rien")
	v.vrai(ArbreCompetences.cout("force", 9) > gain * 3, "les rangs tardifs demandent plusieurs tentatives")

func test_les_armes_echangent_cadence_et_impact(v: Verif) -> void:
	var base := Tir.de_base(Stats.depuis_reglages())
	var lourd := CatalogueProjectiles.appliquer("lourd", base)
	var rapide := CatalogueProjectiles.appliquer("veloce", base)
	v.vrai(lourd.degats > base.degats and lourd.cadence < base.cadence, "le sceptre frappe fort et lentement")
	v.vrai(rapide.degats < base.degats and rapide.cadence > base.cadence, "l'aiguille inverse le compromis")
	for arme in [lourd, rapide]:
		var ratio: float = arme.degats * arme.cadence / (base.degats * base.cadence)
		v.vrai(ratio > 0.8 and ratio < 1.2, "la puissance brute reste comparable avec la perforation du sceptre")
	v.egal(lourd.perforations,2,"le sceptre traverse deux ennemis")
	v.presque(base.degats, Reglages.TIR_DEGATS, "le choix ne mute pas les stats permanentes")
