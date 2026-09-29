class_name FormesSalles
extends RefCounted

# Ordre des coins : haut gauche, haut droit, bas droit, bas gauche.
# Les alcoves restent dans la largeur d'origine ; le couloir central reste ouvert.
const PROFILS := [
	{"nom":"Cour ouverte", "taille":Vector2.ONE, "coins":[Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO], "segments":1},
	{"nom":"Mur en retrait", "taille":Vector2(.91,1.08), "coins":[Vector2(.06,.04),Vector2(.06,.04),Vector2(.06,.04),Vector2(.06,.04)], "segments":1,
		"reliefs":[{"cote":0, "centre":.48, "ouverture":.18, "profondeur":.08, "arrondi":false}]},
	{"nom":"Galerie ondulée", "taille":Vector2(.82,1.19), "coins":[Vector2(.10,.05),Vector2(.06,.03),Vector2(.06,.03),Vector2(.10,.05)], "segments":4,
		"reliefs":[{"cote":0, "centre":.33, "ouverture":.23, "profondeur":.075, "arrondi":true}, {"cote":1, "centre":.66, "ouverture":.22, "profondeur":.075, "arrondi":true}]},
	{"nom":"Galerie étroite", "taille":Vector2(.74,1.29), "coins":[Vector2(.15,.045),Vector2(.15,.045),Vector2(.15,.045),Vector2(.15,.045)], "segments":5},
	{"nom":"Renfoncements décalés", "taille":Vector2(.90,1.14), "coins":[Vector2(.08,.04),Vector2(.03,.02),Vector2(.07,.05),Vector2.ZERO], "segments":2,
		"reliefs":[{"cote":0, "centre":.32, "ouverture":.16, "profondeur":.095, "arrondi":false}, {"cote":1, "centre":.65, "ouverture":.17, "profondeur":.095, "arrondi":false}]},
	{"nom":"Alcôves arrondies", "taille":Vector2(.88,1.23), "coins":[Vector2(.06,.035),Vector2(.06,.035),Vector2(.06,.035),Vector2(.06,.035)], "segments":3, "retrait":.09,
		"reliefs":[{"cote":0, "centre":.34, "ouverture":.22, "profondeur":-.09, "arrondi":true}, {"cote":1, "centre":.69, "ouverture":.22, "profondeur":-.09, "arrondi":true}]},
	{"nom":"Salle allongée", "taille":Vector2(.97,1.38), "coins":[Vector2(.08,.03),Vector2(.08,.03),Vector2(.08,.03),Vector2(.08,.03)], "segments":3,
		"reliefs":[{"cote":0, "centre":.50, "ouverture":.24, "profondeur":.055, "arrondi":true}, {"cote":1, "centre":.50, "ouverture":.24, "profondeur":.055, "arrondi":true}]},
	{"nom":"Cour arrondie", "taille":Vector2(.96,1.09), "coins":[Vector2(.20,.12),Vector2(.20,.12),Vector2(.20,.12),Vector2(.20,.12)], "segments":6},
	{"nom":"Galerie à alcôves", "taille":Vector2(.86,1.25), "coins":[Vector2(.08,.04),Vector2(.08,.04),Vector2(.08,.04),Vector2(.08,.04)], "segments":4, "retrait":.09,
		"reliefs":[{"cote":0, "centre":.29, "ouverture":.18, "profondeur":-.09, "arrondi":false}, {"cote":0, "centre":.71, "ouverture":.18, "profondeur":-.09, "arrondi":true}, {"cote":1, "centre":.49, "ouverture":.22, "profondeur":-.09, "arrondi":true}]},
]
const MARGE_APPARITION := 70.0
const LARGEUR_MIN := .70
const LONGUEUR_MAX := 1.42
const VARIATION_TAILLE := Vector2(.035, .035)
const SEGMENTS_RELIEF := 10

static func _graine(numero: int, chapitre: int) -> int:
	return numero * 7919 + chapitre * 104729 + 41

static func indice(numero: int, chapitre: int, _graine: int, mode: String) -> int:
	if mode != "grimoire":
		return 0
	return TerrainsMondes.forme(numero, chapitre)

static func taille(numero: int, chapitre: int, graine: int, mode: String) -> Vector2:
	var facteur: Vector2 = PROFILS[indice(numero, chapitre, graine, mode)]["taille"]
	if mode == "grimoire":
		var hasard := RandomNumberGenerator.new()
		hasard.seed = _graine(numero, chapitre)
		facteur.x = clampf(facteur.x + hasard.randf_range(-VARIATION_TAILLE.x, VARIATION_TAILLE.x), LARGEUR_MIN, 1.0)
		facteur.y = clampf(facteur.y + hasard.randf_range(-VARIATION_TAILLE.y, VARIATION_TAILLE.y), 1.0, LONGUEUR_MAX)
	return Reglages.ARENE_TAILLE * facteur

static func contour_salle(limites: Rect2, numero: int, chapitre: int, graine: int, mode: String) -> PackedVector2Array:
	var variation := _graine(numero, chapitre) if mode == "grimoire" else -1
	return contour(limites, indice(numero, chapitre, graine, mode), variation)

static func contour(limites: Rect2, profil: int, variation := -1) -> PackedVector2Array:
	var points := PackedVector2Array()
	var retrait := float(PROFILS[profil].get("retrait", 0.0)) * limites.size.x
	var cadre := Rect2(limites.position + Vector2(retrait, 0), limites.size - Vector2(retrait * 2.0, 0))
	var coins: Array = PROFILS[profil]["coins"]
	var segments: int = PROFILS[profil]["segments"]
	var hasard := RandomNumberGenerator.new()
	hasard.seed = variation
	var sommets := [Vector2.ZERO, Vector2.RIGHT, Vector2.ONE, Vector2.DOWN]
	var signes := [Vector2.ONE, Vector2(-1,1), -Vector2.ONE, Vector2(1,-1)]
	for coin in 4:
		var rayon: Vector2 = coins[coin] * cadre.size
		if variation >= 0:
			# Les arrondis restent dans l'enveloppe prevue pour les passages et apparitions.
			if rayon == Vector2.ZERO:
				rayon = Vector2(hasard.randf_range(.008, .018), hasard.randf_range(.006, .012)) * cadre.size
			else:
				rayon *= Vector2(hasard.randf_range(.72, 1.0), hasard.randf_range(.72, 1.0))
		var sommet: Vector2 = cadre.position + sommets[coin] * cadre.size
		if rayon == Vector2.ZERO:
			points.append(sommet)
			continue
		var centre: Vector2 = sommet + signes[coin] * rayon
		for pas in range(segments + 1):
			var angle := PI + coin * PI * .5 + float(pas) / segments * PI * .5
			points.append(centre + Vector2(cos(angle), sin(angle)) * rayon)
	return _avec_reliefs(points, limites, profil, hasard, variation >= 0)

static func _avec_reliefs(points: PackedVector2Array, limites: Rect2, profil: int, hasard: RandomNumberGenerator, varier: bool) -> PackedVector2Array:
	var definitions: Array = PROFILS[profil].get("reliefs", [])
	if definitions.is_empty(): return points
	var reliefs: Array[Dictionary] = []
	var miroir := varier and hasard.randi_range(0, 1) == 1
	for definition: Dictionary in definitions:
		var relief := definition.duplicate()
		if miroir: relief["cote"] = 1 - int(relief["cote"])
		if varier:
			relief["centre"] = float(relief["centre"]) + hasard.randf_range(-.02, .02)
			relief["ouverture"] = float(relief["ouverture"]) * hasard.randf_range(.94, 1.06)
			relief["profondeur"] = maxf(-float(PROFILS[profil].get("retrait", 0.0)), float(relief["profondeur"]) * hasard.randf_range(.94, 1.06))
		reliefs.append(relief)
	var resultat := PackedVector2Array()
	for i in points.size():
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		resultat.append(a)
		if absf(a.x - b.x) > .01 or absf(a.y - b.y) < limites.size.y * .40: continue
		var cote := 0 if a.x < limites.get_center().x else 1
		var sens := 1.0 if b.y > a.y else -1.0
		var selection: Array[Dictionary] = []
		for relief in reliefs:
			if int(relief["cote"]) == cote: selection.append(relief)
		selection.sort_custom(func(gauche: Dictionary, droite: Dictionary) -> bool: return float(gauche["centre"]) * sens < float(droite["centre"]) * sens)
		for relief in selection:
			var centre := limites.position.y + float(relief["centre"]) * limites.size.y
			var demi_ouverture := float(relief["ouverture"]) * limites.size.y * .5
			var debut := centre - demi_ouverture * sens
			var fin := centre + demi_ouverture * sens
			if minf(debut, fin) <= minf(a.y, b.y) or maxf(debut, fin) >= maxf(a.y, b.y): continue
			var profondeur := float(relief["profondeur"]) * limites.size.x * (1.0 if cote == 0 else -1.0)
			if bool(relief["arrondi"]):
				for pas in SEGMENTS_RELIEF + 1:
					var t := float(pas) / SEGMENTS_RELIEF
					# La courbe rejoint le mur sans angle au bord de l'alcove.
					var courbe := pow(sin(PI * t), 2.0)
					resultat.append(Vector2(a.x + profondeur * courbe, lerpf(debut, fin, t)))
			else:
				resultat.append(Vector2(a.x, debut))
				resultat.append(Vector2(a.x + profondeur, debut))
				resultat.append(Vector2(a.x + profondeur, fin))
				resultat.append(Vector2(a.x, fin))
	return resultat

static func section_horizontale(contour_: PackedVector2Array, y: float) -> Vector2:
	var section := Vector2(INF, -INF)
	for i in contour_.size():
		var a := contour_[i]
		var b := contour_[(i + 1) % contour_.size()]
		if not (a.y <= y and y < b.y or b.y <= y and y < a.y): continue
		var x := lerpf(a.x, b.x, (y - a.y) / (b.y - a.y))
		section.x = minf(section.x, x)
		section.y = maxf(section.y, x)
	return section

static func contient_disque(point: Vector2, contour_: PackedVector2Array, rayon: float) -> bool:
	if not Geometry2D.is_point_in_polygon(point, contour_):
		return false
	for i in contour_.size():
		var proche := Geometry2D.get_closest_point_to_segment(point, contour_[i], contour_[(i+1)%contour_.size()])
		if point.distance_to(proche) < rayon:
			return false
	return true
