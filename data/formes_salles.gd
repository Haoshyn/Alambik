class_name FormesSalles
extends RefCounted

# Ordre des coins : haut gauche, haut droit, bas droit, bas gauche.
# Les proportions ne reduisent pas les passages des compositions existantes.
const PROFILS := [
	{"nom": "Alcoves", "taille": Vector2.ONE, "coins": [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO], "segments": 1},
	{"nom": "Rotonde", "taille": Vector2(1.12, 1.0), "coins": [Vector2(.28,.20), Vector2(.28,.20), Vector2(.28,.20), Vector2(.28,.20)], "segments": 6},
	{"nom": "Galerie", "taille": Vector2(1.0, 1.24), "coins": [Vector2(.12,.07), Vector2(.12,.07), Vector2(.12,.07), Vector2(.12,.07)], "segments": 4},
	{"nom": "Cour large", "taille": Vector2(1.30, 1.0), "coins": [Vector2(.14,.10), Vector2(.14,.10), Vector2(.14,.10), Vector2(.14,.10)], "segments": 1},
	{"nom": "Ovale", "taille": Vector2(1.16, 1.12), "coins": [Vector2(.36,.27), Vector2(.36,.27), Vector2(.36,.27), Vector2(.36,.27)], "segments": 8},
	{"nom": "Cour decalee", "taille": Vector2(1.12, 1.08), "coins": [Vector2(.30,.20), Vector2(.10,.08), Vector2(.28,.18), Vector2(.10,.08)], "segments": 4},
]
const MARGE_APPARITION := 70.0

static func indice(numero: int, chapitre: int, graine: int, mode: String) -> int:
	if mode != "grimoire" or Chapitres.est_boss(chapitre, numero):
		return 0
	return posmod(numero - 1 + chapitre + graine, PROFILS.size())

static func taille(numero: int, chapitre: int, graine: int, mode: String) -> Vector2:
	var facteur: Vector2 = PROFILS[indice(numero, chapitre, graine, mode)]["taille"]
	return Reglages.ARENE_TAILLE * facteur

static func contour(limites: Rect2, profil: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var coins: Array = PROFILS[profil]["coins"]
	var segments: int = PROFILS[profil]["segments"]
	var sommets := [Vector2.ZERO, Vector2.RIGHT, Vector2.ONE, Vector2.DOWN]
	var signes := [Vector2.ONE, Vector2(-1,1), -Vector2.ONE, Vector2(1,-1)]
	for coin in 4:
		var rayon: Vector2 = coins[coin] * limites.size
		var sommet: Vector2 = limites.position + sommets[coin] * limites.size
		if rayon == Vector2.ZERO:
			points.append(sommet)
			continue
		var centre: Vector2 = sommet + signes[coin] * rayon
		for pas in range(segments + 1):
			var angle := PI + coin * PI * .5 + float(pas) / segments * PI * .5
			points.append(centre + Vector2(cos(angle), sin(angle)) * rayon)
	return points

static func contient_disque(point: Vector2, contour_: PackedVector2Array, rayon: float) -> bool:
	if not Geometry2D.is_point_in_polygon(point, contour_):
		return false
	for i in contour_.size():
		var proche := Geometry2D.get_closest_point_to_segment(point, contour_[i], contour_[(i+1)%contour_.size()])
		if point.distance_to(proche) < rayon:
			return false
	return true
