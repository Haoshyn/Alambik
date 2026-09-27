extends RefCounted

const Formes = preload("res://data/presentation/formes_tirs.gd")
const Rendu = preload("res://data/presentation/animations_projectiles.gd")

static func dessiner(projectile: Node2D) -> void:
	var tir: Tir = projectile.tir
	var couleur: Color = Rendu.profil(tir.silhouette)["couleur"]
	var hostile: bool = projectile.hostile
	if hostile: couleur = Rendu.couleur_hostile(tir.silhouette, tir.variante_visuelle)
	var points := Formes.contour(tir.silhouette)
	var direction: Vector2 = projectile.direction
	var trainee: Array[Vector2] = projectile._trainee
	if trainee.size() > 1 and trainee[0].distance_squared_to(trainee[1]) > .01:
		direction = trainee[1].direction_to(trainee[0])
	var bout := direction * maxf(0.0, tir.longueur * .5 - tir.rayon)
	projectile.draw_line(-bout, bout, Color(couleur, .20), tir.rayon * 2.0, true)
	for centre in [-bout, bout]: projectile.draw_circle(centre, tir.rayon, Color(couleur, .20))
	for i in points.size():
		points[i] = direction.orthogonal() * points[i].x * tir.rayon + direction * points[i].y * tir.longueur * .5
	if hostile:
		projectile.draw_colored_polygon(points, Rendu.CONTOUR_HOSTILE)
		for i in points.size(): points[i] *= Rendu.INTERIEUR_HOSTILE
	projectile.draw_colored_polygon(points, couleur)
	if not hostile:
		points.append(points[0])
		projectile.draw_polyline(points, couleur.lightened(.5), 2.0, true)
	projectile.draw_circle(Vector2.ZERO, tir.rayon * .3, Color("fff0b9"))
