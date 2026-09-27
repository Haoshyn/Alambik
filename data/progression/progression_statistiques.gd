class_name ProgressionStatistiques
extends RefCounted

# Les annexes utilisent la meme courbe et la meme limite que la campagne.
# Seuls les catalogues et le chapitre choisi fixent les ennemis rencontres.
static func palier_borne(palier: int) -> int:
	return clampi(palier, 0, Chapitres.MONDES.size() * Chapitres.CHAPITRES_PAR_MONDE - 1)

static func facteur_pv(palier: int) -> float:
	var p := float(palier_borne(palier))
	var renfort := 1.0 + Reglages.CAMPAGNE_PV_RENFORT_INITIAL * (1.0 - pow(Reglages.CAMPAGNE_PV_TRANSITION, p))
	# Les premiers achats arrivent vite ; ensuite, les rangs coutent davantage
	# et les bonus se tassent. La courbe fixe des monstres suit ces deux rythmes.
	var debut := mini(int(p), Reglages.CAMPAGNE_PV_CHAPITRES_INITIAUX)
	var suite := maxi(0, int(p) - debut)
	return _courbe_chapitre(debut, Reglages.CAMPAGNE_PV_PAR_CHAPITRE, Reglages.CAMPAGNE_PV_ACCELERATION) \
		* pow(Reglages.CAMPAGNE_PV_PAR_CHAPITRE_TARDIF, suite) * renfort

static func facteur_degats(palier: int) -> float:
	return _courbe_chapitre(palier, Reglages.CAMPAGNE_DEGATS_PAR_CHAPITRE, Reglages.CAMPAGNE_DEGATS_ACCELERATION)

static func _courbe_chapitre(palier: int, croissance: float, acceleration: float) -> float:
	var p := float(palier_borne(palier))
	return pow(croissance, p) * pow(acceleration, p * (p - 1.0) / 2.0)

static func facteur_salle(salle: int, croissance: float, paliers: Dictionary) -> float:
	var numero := clampi(salle, 1, Reglages.SALLES_PAR_RUN)
	var facteur := pow(croissance, numero - 1)
	for palier: int in paliers:
		if numero >= palier:
			facteur *= float(paliers[palier])
	return facteur

static func facteur_miniboss(_palier: int) -> float:
	return Reglages.MINIBOSS_PV_MULT
