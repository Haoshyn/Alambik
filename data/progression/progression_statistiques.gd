class_name ProgressionStatistiques
extends RefCounted

# Les annexes utilisent la meme courbe et la meme limite que la campagne.
# Seuls les catalogues et le chapitre choisi fixent les ennemis rencontres.
static func palier_borne(palier: int) -> int:
	return clampi(palier, 0, Chapitres.MONDES.size() * Chapitres.CHAPITRES_PAR_MONDE - 1)

static func facteur_pv(palier: int) -> float:
	var p := float(palier_borne(palier))
	var transition := pow(p, Reglages.CAMPAGNE_PV_TRANSITION_EXPOSANT)
	var renfort := 1.0 + Reglages.CAMPAGNE_PV_RENFORT_INITIAL * (1.0 - pow(Reglages.CAMPAGNE_PV_TRANSITION, transition))
	# Le premier monde demande peu de repetitions. Les achats et le farm
	# prennent davantage de place ensuite, sans lire le build du joueur.
	var debut := mini(int(p), Reglages.CAMPAGNE_PV_CHAPITRES_INITIAUX)
	var suite := maxi(0, int(p) - debut)
	return _courbe_chapitre(debut, Reglages.CAMPAGNE_PV_PAR_CHAPITRE, Reglages.CAMPAGNE_PV_ACCELERATION) \
		* pow(Reglages.CAMPAGNE_PV_PAR_CHAPITRE_TARDIF, suite) * renfort

static func facteur_degats(palier: int) -> float:
	var suite := maxi(0, palier_borne(palier) - Reglages.CAMPAGNE_PV_CHAPITRES_INITIAUX)
	var renfort := 1.0 + Reglages.CAMPAGNE_DEGATS_RENFORT_TARDIF \
		* (1.0 - pow(Reglages.CAMPAGNE_DEGATS_TRANSITION_TARDIVE, suite))
	return _courbe_chapitre(palier, Reglages.CAMPAGNE_DEGATS_PAR_CHAPITRE, Reglages.CAMPAGNE_DEGATS_ACCELERATION) * renfort

static func facteur_boss(palier: int) -> float:
	var suite := maxi(0, palier_borne(palier) - Reglages.CAMPAGNE_PV_CHAPITRES_INITIAUX)
	return 1.0 + Reglages.CAMPAGNE_PV_BOSS_RENFORT_TARDIF \
		* (1.0 - pow(Reglages.CAMPAGNE_PV_BOSS_TRANSITION_TARDIVE, suite))

static func _courbe_chapitre(palier: int, croissance: float, acceleration: float) -> float:
	var p := float(palier_borne(palier))
	return pow(croissance, p) * pow(acceleration, p * (p - 1.0) / 2.0)

static func facteur_salle(salle: int, croissance: float, paliers: Dictionary,
		croissance_tardive := 0.0, premiere_salle_tardive := 0) -> float:
	var numero := clampi(salle, 1, Reglages.SALLES_PAR_RUN)
	var salles_tardives := maxi(0, numero - premiere_salle_tardive + 1) \
		if croissance_tardive > 0.0 and premiere_salle_tardive > 1 else 0
	var facteur := pow(croissance, numero - 1 - salles_tardives)
	if salles_tardives > 0: facteur *= pow(croissance_tardive, salles_tardives)
	for palier: int in paliers:
		if numero >= palier:
			facteur *= float(paliers[palier])
	return facteur

static func facteur_miniboss(_palier: int) -> float:
	return Reglages.MINIBOSS_PV_MULT
