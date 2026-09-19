class_name ProgressionStatistiques
extends RefCounted

# Courbe fixe des 35 chapitres, pour une premiere campagne autour de douze heures
# avec reprises et annexes. Aucun coefficient ne lit le build reel du joueur.
# La puissance permanente attendue en fin de campagne vaut environ x12 a x18 ;
# les motifs et les terrains apportent le reste de la difficulte.
const PV_DEPART := .75
const DEGATS_DEPART := .50
const FIN_CAMPAGNE := Chapitres.MONDES.size() * Chapitres.CHAPITRES_PAR_MONDE - 1
const PV_FIN := 15.0
const DEGATS_FIN := 15.0
const EXPOSANT_PROGRESSION := 1.15

static func _courbe(palier: int, depart: float, fin: float) -> float:
	var progression := float(maxi(0, palier)) / maxf(1.0, float(FIN_CAMPAGNE))
	return depart * pow(fin / depart, pow(progression, EXPOSANT_PROGRESSION))

static func facteur_pv(palier: int) -> float:
	return _courbe(palier, PV_DEPART, PV_FIN)

static func facteur_degats(palier: int) -> float:
	return _courbe(palier, DEGATS_DEPART, DEGATS_FIN)

# Les premieres victoires doivent etre possibles sans Sort ni Ultime ; le
# budget de vie des miniboss accompagne ensuite l'acquisition de cet arsenal.
static func facteur_miniboss(palier: int) -> float:
	var progression := clampf(float(palier) / maxf(1.0, float(FIN_CAMPAGNE)), 0.0, 1.0)
	return lerpf(Reglages.MINIBOSS_PV_MULT_DEPART, Reglages.MINIBOSS_PV_MULT, pow(progression, EXPOSANT_PROGRESSION))
