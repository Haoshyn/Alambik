extends RefCounted

func test_sept_coups_et_soins_bornes(v: Verif) -> void:
	var stats := Stats.depuis_reglages()
	for coup in 6: stats.blesser(Reglages.DEGATS_COUP_REFERENCE)
	v.presque(stats.pv, 10.0, "six coups laissent une derniere chance")
	stats.blesser(Reglages.DEGATS_COUP_REFERENCE)
	v.vrai(stats.est_mort(), "le septieme coup est fatal sans protection")
	stats.pv = 20.0
	stats.soin_restant = stats.pv_max * Reglages.SOIN_COMBAT_PAR_SALLE
	for impact in 100: stats.soigner(4.0)
	v.presque(stats.pv, 25.0, "les soins cumules ne rendent pas immortel")
	stats.soigner_garanti(stats.pv_max * Reglages.SOIN_ALAMBIC)
	v.presque(stats.pv, 75.0, "la halte rend cinquante PV meme apres epuisement du soin")
	stats.soigner_garanti(50.0)
	v.presque(stats.pv, 100.0, "le soin de halte ne depasse pas le maximum")

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
		v.vrai(ratio > 0.9 and ratio < 1.1, "la puissance brute reste comparable")
	v.presque(base.degats, Reglages.TIR_DEGATS, "le choix ne mute pas les stats permanentes")
