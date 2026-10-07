extends RefCounted

const Formes = preload("res://data/presentation/formes_tirs.gd")
const Rendu = preload("res://data/presentation/animations_projectiles.gd")

static func dessiner(projectile: Node2D) -> void:
	var tir: Tir = projectile.tir
	var couleur: Color = Rendu.profil(tir.silhouette)["couleur"]
	var hostile: bool = projectile.hostile
	var familier := "trait_familier" in tir.drapeaux
	if hostile: couleur = Rendu.couleur_hostile(tir.silhouette, tir.variante_visuelle)
	var points := Formes.contour(tir.silhouette)
	var direction: Vector2 = projectile.direction
	var trainee: Array[Vector2] = projectile._trainee
	if trainee.size() > 1 and trainee[0].distance_squared_to(trainee[1]) > .01:
		direction = trainee[1].direction_to(trainee[0])
	var bout := direction * maxf(0.0, tir.longueur * .5 - tir.rayon)
	if hostile or not familier or not ReglagesJoueur.effets_reduits:
		projectile.draw_line(-bout, bout, Color(couleur, .20), tir.rayon * 2.0, true)
		for centre in [-bout, bout]: projectile.draw_circle(centre, tir.rayon, Color(couleur, .20))
	for i in points.size():
		points[i] = direction.orthogonal() * points[i].x * tir.rayon + direction * points[i].y * tir.longueur * .5
	if hostile:
		projectile.draw_colored_polygon(points, Rendu.CONTOUR_HOSTILE)
		for i in points.size(): points[i] *= Rendu.INTERIEUR_HOSTILE
		projectile.draw_colored_polygon(points, couleur)
		projectile.draw_circle(Vector2.ZERO, tir.rayon * .3, Color("fff0b9"))
	elif familier:
		# Le volume froid et sa nervure restent reconnaissables dans le secours 2D.
		var couleurs := PackedColorArray()
		for point in points:
			var lumiere := clampf(.30 - point.dot(direction.orthogonal()) / tir.rayon * .32, .0, .80)
			couleurs.append(couleur.darkened(.18).lerp(Rendu.FAMILIER_IVOIRE, lumiere))
		projectile.draw_polygon(points, couleurs)
		var nervure := PackedVector2Array()
		for i in 9:
			var t := float(i) / 8.0
			var courbe := sin(t * PI) * sin(t * PI * 2.0) * tir.rayon * .16
			nervure.append(direction * lerpf(-.68, .68, t) * tir.longueur * .5 + direction.orthogonal() * courbe)
		projectile.draw_polyline(nervure, Rendu.FAMILIER_IVOIRE, maxf(1.0, tir.rayon * .12), true)
	else:
		projectile.draw_colored_polygon(points, couleur)
		points.append(points[0])
		projectile.draw_polyline(points, couleur.lightened(.5), 2.0, true)
		projectile.draw_circle(Vector2.ZERO, tir.rayon * .3, Color("fff0b9"))
