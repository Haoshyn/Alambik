class_name ProgressionStatistiques
extends RefCounted

# Courbe fixe issue des 35 profils achetables de ProfilsProgression. Le jeu ne
# lit jamais l'equipement reel pour choisir ces valeurs : un bon build garde
# donc son avantage et une defaite ne rend pas automatiquement le niveau facile.
const MULTIPLICATEURS_PV := [
	1.00, 2.40, 3.20, 4.20, 5.10, 6.00, 7.00,
	8.00, 9.30, 10.70, 12.20, 13.80, 15.70, 17.80,
	20.00, 22.50, 25.30, 28.40, 31.80, 35.50, 39.50,
	43.80, 48.60, 53.80, 59.50, 65.70, 72.50, 79.90,
	88.00, 96.90, 106.50, 117.00, 128.50, 141.00, 155.00,
]
const MULTIPLICATEURS_DEGATS := [
	1.00, 1.22, 1.45, 1.70, 1.95, 2.20, 2.50,
	2.80, 3.10, 3.45, 3.80, 4.20, 4.60, 5.00,
	5.45, 5.90, 6.40, 6.90, 7.45, 8.00, 8.60,
	9.20, 9.85, 10.50, 11.20, 11.90, 12.65, 13.40,
	14.20, 15.00, 15.80, 16.70, 17.60, 18.50, 19.50,
]

static func _fixe(palier: int, valeurs: Array) -> float:
	return float(valeurs[clampi(palier, 0, valeurs.size() - 1)])

static func facteur_pv(palier: int) -> float:
	return _fixe(palier, MULTIPLICATEURS_PV)

static func facteur_degats(palier: int) -> float:
	return _fixe(palier, MULTIPLICATEURS_DEGATS)

static func facteur_miniboss(_palier: int) -> float:
	return Reglages.MINIBOSS_PV_MULT
