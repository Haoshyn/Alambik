class_name ProgressionStatistiques
extends RefCounted

# Hypothese non mesuree : 3 a 5 tentatives par chapitre, farm compris.
# La courbe reste fixe : mieux s'equiper doit aider, sans relever les ennemis.
const PALIERS := [0, 6, 13, 20, 27, 34]
const MULTIPLICATEURS_PV := [1.2, 5.0, 12.0, 25.0, 45.0, 80.0]
const MULTIPLICATEURS_DEGATS := [0.65, 1.3, 2.5, 4.5, 7.0, 10.0]

static func _courbe(palier: int, valeurs: Array) -> float:
	var p := maxi(0, palier)
	var droite := PALIERS.size() - 1
	for index in range(1, PALIERS.size()):
		if p <= int(PALIERS[index]):
			droite = index
			break
	var gauche := droite - 1
	var progression := float(p - int(PALIERS[gauche])) / float(int(PALIERS[droite]) - int(PALIERS[gauche]))
	var depart := float(valeurs[gauche])
	return depart * pow(float(valeurs[droite]) / depart, progression)

static func facteur_pv(palier: int) -> float:
	return _courbe(palier, MULTIPLICATEURS_PV)

static func facteur_degats(palier: int) -> float:
	return _courbe(palier, MULTIPLICATEURS_DEGATS)

static func facteur_miniboss(_palier: int) -> float:
	return Reglages.MINIBOSS_PV_MULT
