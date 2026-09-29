class_name Geometrie
extends RefCounted

# Intersection segment / rectangle, algorithme de Liang-Barsky.
#
# Pourquoi ne pas interroger le moteur physique : un raycast lance sur les blocs
# de la salle renvoyait "libre" alors qu'un bloc coupait bel et bien la ligne,
# et le bot tirait dans la pierre pendant deux minutes. Un calcul explicite se
# teste, lui.

static func segment_coupe_rect(a: Vector2, b: Vector2, rect: Rect2) -> bool:
	var d := b - a
	var t0 := 0.0
	var t1 := 1.0
	var bords := [
		[-d.x, a.x - rect.position.x],
		[d.x, rect.end.x - a.x],
		[-d.y, a.y - rect.position.y],
		[d.y, rect.end.y - a.y],
	]
	for bord in bords:
		var p: float = bord[0]
		var q: float = bord[1]
		if absf(p) < 0.00001:
			# Segment parallele a ce bord : hors de la bande, aucune intersection.
			if q < 0.0:
				return false
			continue
		var r := q / p
		if p < 0.0:
			if r > t1:
				return false
			t0 = maxf(t0, r)
		else:
			if r < t0:
				return false
			t1 = minf(t1, r)
	return t0 <= t1

# La marge compte : un projectile a un rayon, donc une ligne qui frole un bloc
# de quelques pixels est en realite bouchee.
static func ligne_libre(a: Vector2, b: Vector2, obstacles: Array, marge := 0.0, contour := PackedVector2Array()) -> bool:
	for rect in obstacles:
		if segment_coupe_rect(a, b, (rect as Rect2).grow(marge)):
			return false
	return contour.is_empty() or segment_dans_contour(a, b, contour, marge)

static func segment_dans_contour(a: Vector2, b: Vector2, contour: PackedVector2Array, marge := 0.0) -> bool:
	if not Geometry2D.is_point_in_polygon(a, contour) or not Geometry2D.is_point_in_polygon(b, contour): return false
	var cadre := Rect2(a, b - a).abs().grow(marge + .01)
	var seuil := maxf(0.0, marge - .01)
	for i in contour.size():
		var c := contour[i]
		var d := contour[(i + 1) % contour.size()]
		if maxf(c.x, d.x) < cadre.position.x or minf(c.x, d.x) > cadre.end.x \
				or maxf(c.y, d.y) < cadre.position.y or minf(c.y, d.y) > cadre.end.y: continue
		# Deux extremites dans le sol peuvent etre separees par le mur d'une alcove.
		if Geometry2D.segment_intersects_segment(a, b, c, d) != null: return false
		if marge <= 0.0: continue
		var distance := minf(a.distance_to(Geometry2D.get_closest_point_to_segment(a, c, d)),
			b.distance_to(Geometry2D.get_closest_point_to_segment(b, c, d)))
		distance = minf(distance, c.distance_to(Geometry2D.get_closest_point_to_segment(c, a, b)))
		distance = minf(distance, d.distance_to(Geometry2D.get_closest_point_to_segment(d, a, b)))
		if distance < seuil: return false
	return true

# Une limite d'arene decrit le bord du sol, mais un personnage est un disque.
# Contraindre son centre sans son rayon lui laisse visuellement la moitie du
# corps dans le mur.
static func contraindre_dans_rect(position: Vector2, rect: Rect2, rayon: float) -> Vector2:
	var interieur := rect.grow(-maxf(0.0, rayon))
	if interieur.size.x < 0.0 or interieur.size.y < 0.0:
		return rect.get_center()
	return Vector2(clampf(position.x, interieur.position.x, interieur.end.x),
		clampf(position.y, interieur.position.y, interieur.end.y))

# Les tirs de bord entrent depuis le vrai contour, y compris dans les coins
# arrondis. Une voie bouchee est omise, sans traverser un obstacle au depart.
static func origine_projectile(origine: Vector2, direction: Vector2, limites: Rect2,
		contour: PackedVector2Array, obstacles: Array, marge: float, degagement: float) -> Vector2:
	if direction.is_zero_approx() or contour.size() < 3: return Vector2.INF
	var avance := direction.normalized()
	var resultat := Vector2.INF
	if FormesSalles.contient_disque(origine, contour, marge):
		resultat = origine
	else:
		var fin := origine + avance * (limites.size.length() + origine.distance_to(limites.get_center()))
		var distance_min := INF
		for interieur: PackedVector2Array in Geometry2D.offset_polygon(contour, -marge, Geometry2D.JOIN_MITER):
			for i in interieur.size():
				var intersection: Variant = Geometry2D.segment_intersects_segment(origine, fin,
					interieur[i], interieur[(i + 1) % interieur.size()])
				if intersection is not Vector2: continue
				var candidat: Vector2 = intersection + avance
				var distance := origine.distance_squared_to(candidat)
				if distance < distance_min and FormesSalles.contient_disque(candidat, contour, marge):
					resultat = candidat
					distance_min = distance
	if not resultat.is_finite(): return resultat
	var sortie := resultat + avance * degagement
	if not FormesSalles.contient_disque(sortie, contour, marge): return Vector2.INF
	if not ligne_libre(resultat, sortie, obstacles, marge, contour): return Vector2.INF
	return resultat

# Ou viser pour toucher une cible en mouvement. L'anticipation est bornee : au
# dela, une creature qui change d'avis fait rater tous les tirs au lieu de
# quelques-uns. Partagee par le heros et le familier, qui tiraient chacun leur
# propre version — celle du familier partait en plus du mauvais point.
static func point_anticipe(position_cible: Vector2, vitesse_cible: Vector2,
		origine: Vector2, vitesse_tir: float) -> Vector2:
	var vol := minf(Reglages.ANTICIPATION_DUREE_MAX,
		origine.distance_to(position_cible) / maxf(80.0, vitesse_tir))
	return position_cible + vitesse_cible * vol * Reglages.ANTICIPATION_PART
