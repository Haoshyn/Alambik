extends RefCounted

const Rendu = preload("res://data/presentation/animations_projectiles.gd")

static func remplir(mesh: ImmediateMesh, matiere: Material, points: Array[Vector2],
		origine: Vector3, couleur: Color, silhouette: String, reduit: bool, hostile := false) -> void:
	mesh.clear_surfaces()
	var nombre := mini(points.size(), Rendu.POINTS_TRAINEE_REDUITS if reduit else Rendu.POINTS_TRAINEE)
	if nombre < 2: return
	var largeur := float(Rendu.profil(silhouette)["trainee"])
	if hostile: largeur = maxf(largeur, Rendu.TRAINEE_HOSTILE_LARGEUR_MIN)
	var parcouru := 0.0
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, matiere)
	for i in nombre - 1:
		var fin_logique := points[i + 1]
		var longueur := points[i].distance_to(fin_logique)
		if hostile:
			var restant := Rendu.TRAINEE_HOSTILE_LONGUEUR_MAX - parcouru
			if restant <= 0.0: break
			if longueur > restant:
				fin_logique = points[i].move_toward(fin_logique, restant)
				longueur = restant
		var a := Pont3D.vers_monde(points[i], .13) - origine
		var b := Pont3D.vers_monde(fin_logique, .13) - origine
		var cote := (b - a).cross(Vector3.UP).normalized()
		if cote.is_zero_approx(): continue
		var debut := 1.0 - float(i) / (nombre - 1)
		var fin := 1.0 - float(i + 1) / (nombre - 1)
		if hostile:
			debut = minf(debut, 1.0 - parcouru / Rendu.TRAINEE_HOSTILE_LONGUEUR_MAX)
			fin = minf(fin, 1.0 - (parcouru + longueur) / Rendu.TRAINEE_HOSTILE_LONGUEUR_MAX)
		parcouru += longueur
		var reflet := Rendu.REFLET_HOSTILE if hostile else .62
		var opacite := Rendu.TRAINEE_HOSTILE_OPACITE if hostile else .70
		var chaud_a := Color(couleur.lerp(Rendu.REFLET, reflet), pow(debut, 1.5) * opacite)
		var chaud_b := Color(couleur.lerp(Rendu.REFLET, reflet), pow(fin, 1.5) * opacite)
		if hostile:
			var sombre_a := Color(Rendu.CONTOUR_HOSTILE, debut * Rendu.TRAINEE_HOSTILE_CONTOUR_OPACITE)
			var sombre_b := Color(Rendu.CONTOUR_HOSTILE, fin * Rendu.TRAINEE_HOSTILE_CONTOUR_OPACITE)
			_bande(mesh, a - cote * largeur * debut * Rendu.TRAINEE_HOSTILE_CONTOUR, a + cote * largeur * debut * Rendu.TRAINEE_HOSTILE_CONTOUR,
				b - cote * largeur * fin * Rendu.TRAINEE_HOSTILE_CONTOUR, b + cote * largeur * fin * Rendu.TRAINEE_HOSTILE_CONTOUR, sombre_a, sombre_a, sombre_b, sombre_b)
		_bande(mesh, a - cote * largeur * debut, a, b - cote * largeur * fin, b, Color(couleur, 0), chaud_a, Color(couleur, 0), chaud_b)
		_bande(mesh, a, a + cote * largeur * debut, b, b + cote * largeur * fin, chaud_a, Color(couleur, 0), chaud_b, Color(couleur, 0))
		if not reduit and not hostile:
			var reflet_a := Color(Rendu.REFLET, pow(debut, 2.0) * .62)
			var reflet_b := Color(Rendu.REFLET, pow(fin, 2.0) * .62)
			_bande(mesh, a - cote * largeur * debut * .18, a + cote * largeur * debut * .18,
				b - cote * largeur * fin * .18, b + cote * largeur * fin * .18, reflet_a, reflet_a, reflet_b, reflet_b)
	mesh.surface_end()

static func _bande(mesh: ImmediateMesh, a: Vector3, b: Vector3, c: Vector3, d: Vector3,
		ca: Color, cb: Color, cc: Color, cd: Color) -> void:
	for sommet: Array in [[a, ca], [b, cb], [d, cd], [a, ca], [d, cd], [c, cc]]:
		mesh.surface_set_color(sommet[1])
		mesh.surface_add_vertex(sommet[0])
