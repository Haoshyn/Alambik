extends RefCounted

static func halo(noeud: Node2D, centre: Vector2, rayon: float, couleur: Color) -> void:
	for i in range(6, 0, -1):
		var part := float(i) / 6.0
		noeud.draw_circle(centre, rayon * part, Color(couleur, couleur.a * (1.0 - part * .8) * .22))

static func goutte(noeud: Node2D, centre: Vector2, angle: float, taille: float, couleur: Color) -> void:
	var direction := Vector2.from_angle(angle)
	var cote := direction.orthogonal()
	halo(noeud, centre, taille * 2.2, Color(couleur, .30))
	for couche in 3:
		var points := PackedVector2Array()
		var facteur := 1.0 - couche * .18
		var decalage := Vector2(-.14, -.20) * taille * couche
		for i in 24:
			var a := TAU * i / 24.0
			var ventre := .72 + .28 * cos(a)
			points.append(centre + decalage + (direction * cos(a) * 1.18 + cote * sin(a) * ventre) * taille * facteur)
		var teinte := couleur.darkened(.56) if couche == 0 else (couleur if couche == 1 else couleur.lightened(.48))
		noeud.draw_colored_polygon(points, teinte)
	noeud.draw_circle(centre + Vector2(-.18, -.24) * taille, taille * .23, couleur.lightened(.88))
