class_name ProgressionStatistiques
extends RefCounted

# Reperes fixes calcules hors combat sur deux a trois victoires par chapitre.
# Aucun coefficient ne lit l'equipement reel du joueur.
const PV_DEPART := 0.14
const DEGATS_DEPART := 0.15
const ENTREE_MONDE_TROIS := 6
const FIN_CAMPAGNE := 29
const PV_MONDE_TROIS := 3.0
const DEGATS_MONDE_TROIS := 8.0
# Conserve le dernier palier existant pour ne pas multiplier toute la fin de jeu.
const PV_FIN := 4475.831861
const DEGATS_FIN := 1259.356719

static func _courbe(palier: int, depart: float, monde_trois: float, fin: float) -> float:
	var p := maxi(0,palier)
	if p <= ENTREE_MONDE_TROIS:
		return depart * pow(monde_trois/depart,float(p)/ENTREE_MONDE_TROIS)
	return monde_trois * pow(fin/monde_trois,float(p-ENTREE_MONDE_TROIS)/float(FIN_CAMPAGNE-ENTREE_MONDE_TROIS))

static func facteur_pv(palier: int) -> float:
	return _courbe(palier,PV_DEPART,PV_MONDE_TROIS,PV_FIN)

static func facteur_degats(palier: int) -> float:
	return _courbe(palier,DEGATS_DEPART,DEGATS_MONDE_TROIS,DEGATS_FIN)
