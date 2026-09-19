class_name FormesSalles
extends RefCounted

# Ordre des coins : haut gauche, haut droit, bas droit, bas gauche.
# Les proportions ne reduisent pas les passages des compositions existantes.
const PROFILS := [
	{"nom":"Cour ouverte", "taille":Vector2.ONE, "coins":[Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO], "segments":1},
	{"nom":"Angles biseautés", "taille":Vector2(1.03,1.0), "coins":[Vector2(.06,.04),Vector2(.06,.04),Vector2(.06,.04),Vector2(.06,.04)], "segments":1},
	{"nom":"Bord adouci", "taille":Vector2(1.0,1.04), "coins":[Vector2(.08,.05),Vector2.ZERO,Vector2.ZERO,Vector2(.08,.05)], "segments":3},
	{"nom":"Cour large", "taille":Vector2(1.07,1.0), "coins":[Vector2(.04,.03),Vector2(.04,.03),Vector2.ZERO,Vector2.ZERO], "segments":1},
	{"nom":"Angles décalés", "taille":Vector2(1.02,1.03), "coins":[Vector2(.08,.04),Vector2(.03,.02),Vector2(.07,.05),Vector2.ZERO], "segments":1},
	{"nom":"Bord arrondi", "taille":Vector2(1.04,1.01), "coins":[Vector2.ZERO,Vector2(.07,.04),Vector2(.07,.04),Vector2.ZERO], "segments":3},
	{"nom":"Cour longue", "taille":Vector2(1.0,1.06), "coins":[Vector2(.04,.03),Vector2.ZERO,Vector2(.06,.04),Vector2(.03,.02)], "segments":1},
	{"nom":"Cour arrondie", "taille":Vector2(1.04,1.03), "coins":[Vector2(.15,.10),Vector2(.15,.10),Vector2(.15,.10),Vector2(.15,.10)], "segments":6},
	{"nom":"Angles souples", "taille":Vector2(1.03,1.02), "coins":[Vector2(.16,.10),Vector2(.06,.04),Vector2(.14,.09),Vector2(.06,.04)], "segments":5},
]
const MARGE_APPARITION := 70.0

static func indice(numero: int, chapitre: int, _graine: int, mode: String) -> int:
	if mode != "grimoire":
		return 0
	return TerrainsMondes.forme(numero, chapitre)

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
