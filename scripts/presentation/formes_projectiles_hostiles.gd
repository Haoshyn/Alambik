extends RefCounted

const Rendu = preload("res://data/presentation/animations_projectiles.gd")
const Formes = preload("res://data/presentation/formes_tirs.gd")
static var _formes: Dictionary = {}
static var _matiere: StandardMaterial3D
static var _matiere_halo: StandardMaterial3D

static func construire(silhouette: String, teinte: Color, allongement := 1.0, monde := -1) -> Node3D:
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere.vertex_color_use_as_albedo = true
		_matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
		_matiere_halo = _matiere.duplicate() as StandardMaterial3D
		_matiere_halo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var cle := silhouette + teinte.to_html() + str(allongement) + str(monde)
	if not _formes.has(cle):
		var mesh := ImmediateMesh.new()
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere)
		if silhouette in Formes.BOULES:
			if monde >= 0: _face(mesh, Formes.contour(silhouette), Rendu.CONTOUR_HOSTILE, .02)
			_amande(mesh, Vector3(0, .24, 0), .87, 1.74, .65, teinte.darkened(.55) if silhouette == "devoreur_neant" else teinte, 10, 16)
			match silhouette:
				"roi_braises": _relief(mesh, Formes.contour(silhouette), teinte, .08, monde >= 0)
				"archiscribe_encres":
					_cercler(mesh, teinte.lightened(.5), .92, .10, .34)
					_cercler(mesh, teinte.lightened(.3), .72, .07, .69)
				"devoreur_neant": _cercler(mesh, teinte.lightened(.4), .95, .14, .20)
				"grand_alambic":
					for i in 3:
						var angle := i * TAU / 3.0
						_amande(mesh, Vector3(cos(angle) * .72, .60, sin(angle) * .72), .25, .50, .22, Rendu.REFLET, 5, 8)
				"salamandre": _cercler(mesh, teinte.lightened(.45), .95, .08, .2)
		else:
			_relief(mesh, Formes.contour(silhouette), teinte, .44, monde >= 0)
		mesh.surface_end()
		var coeur := ImmediateMesh.new()
		coeur.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere)
		_signature(coeur, silhouette, teinte, monde)
		coeur.surface_end()
		var halo := ImmediateMesh.new()
		halo.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere_halo)
		for i in 28:
			var a := Vector3(cos(TAU * i / 28.0), .015, sin(TAU * i / 28.0))
			var b := Vector3(cos(TAU * (i + 1) / 28.0), .015, sin(TAU * (i + 1) / 28.0))
			# La lueur couvre la capsule, y compris les coins hors du motif decoupe.
			a.z = (a.z + signf(a.z) * (allongement - 1.0)) / allongement
			b.z = (b.z + signf(b.z) * (allongement - 1.0)) / allongement
			_triangle(halo, Vector3(0, .015, 0), a, b, Color(teinte, .32), Color(teinte, .08), Color(teinte, .08))
		halo.surface_end()
		_formes[cle] = [mesh, halo, coeur]
	var racine := Node3D.new()
	var index := 0
	for mesh: Mesh in _formes[cle]:
		var piece := MeshInstance3D.new()
		piece.name = ["Corps", "Halo", "Coeur"][index]
		piece.mesh = mesh
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		racine.add_child(piece)
		index += 1
	return racine

static func _face(mesh: ImmediateMesh, contour: PackedVector2Array, couleur: Color, hauteur: float) -> void:
	var indices := Geometry2D.triangulate_polygon(contour)
	for i in range(0, indices.size(), 3):
		var a := contour[indices[i]]
		var b := contour[indices[i + 1]]
		var c := contour[indices[i + 2]]
		_triangle(mesh, Vector3(a.x, hauteur, a.y), Vector3(b.x, hauteur, b.y), Vector3(c.x, hauteur, c.y), couleur, couleur, couleur)

static func _relief(mesh: ImmediateMesh, contour: PackedVector2Array, teinte: Color, hauteur: float, hostile := false) -> void:
	var dessus := contour.duplicate()
	for i in dessus.size(): dessus[i] *= Rendu.INTERIEUR_HOSTILE
	# Le biseau relie de vrais etages ; le lisere sombre appartient au corps.
	_face(mesh, contour, Rendu.CONTOUR_HOSTILE if hostile else teinte.darkened(.6), .035)
	var indices := Geometry2D.triangulate_polygon(dessus)
	for i in range(0, indices.size(), 3):
		var a: Vector2 = dessus[indices[i]]
		var b: Vector2 = dessus[indices[i + 1]]
		var c: Vector2 = dessus[indices[i + 2]]
		_triangle(mesh, Vector3(a.x, hauteur, a.y), Vector3(b.x, hauteur, b.y), Vector3(c.x, hauteur, c.y),
			_email(a, teinte), _email(b, teinte), _email(c, teinte))
	for i in contour.size():
		var j := (i + 1) % contour.size()
		var a := Vector3(contour[i].x, .035, contour[i].y)
		var b := Vector3(contour[j].x, .035, contour[j].y)
		var haut_a := Vector3(dessus[i].x, hauteur, dessus[i].y)
		var haut_b := Vector3(dessus[j].x, hauteur, dessus[j].y)
		var bord := Rendu.CONTOUR_HOSTILE if hostile else teinte.darkened(.60)
		var reflet := teinte.lerp(Rendu.REFLET, .44 if (contour[j] - contour[i]).x < 0.0 else .12)
		_triangle(mesh, a, b, haut_a, bord, bord, reflet)
		_triangle(mesh, b, haut_b, haut_a, bord, reflet, reflet)

static func _email(point: Vector2, teinte: Color) -> Color:
	# Une lumiere continue evite les triangles clairs arbitraires sur les faces.
	var lumiere := clampf(.50 - point.x * .24 + point.y * .20, 0.0, 1.0)
	return teinte.darkened(.32).lerp(teinte.lerp(Rendu.REFLET, .22), lumiere)

static func _signature(mesh: ImmediateMesh, silhouette: String, teinte: Color, monde: int) -> void:
	var clair := teinte.lerp(Rendu.REFLET, .72)
	var hauteur := .47
	if silhouette in Formes.BOULES:
		# La couronne tourne au-dessus du noyau, a l'interieur du contour dangereux.
		_cercler(mesh, clair, .46, .055, .83)
		for i in 3:
			var angle := i * TAU / 3.0
			_amande(mesh, Vector3(cos(angle) * .46, .84, sin(angle) * .46), .08, .16, .04, clair, 3, 6)
	elif silhouette in ["plume_sentinelle", "marge_harceleuse", "index_brise", "maitre_orages", "cachet_phaseur"]:
		_amande(mesh, Vector3(0, hauteur, .03), .10, 1.20, .11, clair, 5, 8)
	elif silhouette in ["fiole_volatile", "encrier_rampant", "hydre_venins"]:
		_amande(mesh, Vector3(0, hauteur, -.18), .29, .63, .25, clair, 6, 10)
	elif silhouette in ["folio_orbiteur", "reliure_affamee", "l_errata", "virgule_noire", "souverain_ombres"]:
		# Le reflet suit la decoupe des lames, sans remplir leur echancrure.
		var trace := Formes.contour(silhouette)
		for i in trace.size(): trace[i] *= .54
		_face(mesh, trace, clair, hauteur + .015)
	else:
		_cercler(mesh, clair, .24, .07, hauteur + .02)
		_amande(mesh, Vector3(0, hauteur + .015, 0), .095, .19, .10, clair, 4, 8)
	if monde >= 0:
		_amande(mesh, Vector3(-.20, hauteur + .05, -.22), .043, .12, .025,
			BestiaireMondes.ACCENTS[monde], 3, 5)

static func _cercler(mesh: ImmediateMesh, teinte: Color, rayon: float, epaisseur: float, hauteur: float) -> void:
	for i in 32:
		var a := Vector3(cos(TAU * i / 32.0), 0, sin(TAU * i / 32.0))
		var b := Vector3(cos(TAU * (i + 1) / 32.0), 0, sin(TAU * (i + 1) / 32.0))
		var haut := Vector3.UP * hauteur
		_triangle(mesh, a * rayon + haut, b * rayon + haut, a * (rayon - epaisseur) + haut, teinte, teinte, Rendu.REFLET)
		_triangle(mesh, b * rayon + haut, b * (rayon - epaisseur) + haut, a * (rayon - epaisseur) + haut, teinte, Rendu.REFLET, Rendu.REFLET)

static func _triangle(mesh: ImmediateMesh, a: Vector3, b: Vector3, c: Vector3,
		ca: Color, cb: Color, cc: Color) -> void:
	for sommet: Array in [[a, ca], [b, cb], [c, cc]]:
		mesh.surface_set_color(sommet[1])
		mesh.surface_add_vertex(sommet[0])

static func _vernis(normale: Vector3, teinte: Color, facette := false) -> Color:
	var lumiere := maxf(0.0, normale.dot(Vector3(-.40, .78, .48).normalized()))
	var couleur := teinte.darkened(.70).lerp(teinte, smoothstep(-.15, .55, normale.y * .65 + lumiere * .6))
	var reflet := pow(lumiere, 5.0 if facette else 12.0)
	return couleur.lerp(Rendu.REFLET, reflet * .9)

static func _point_amande(v: float, angle: float, centre: Vector3,
		largeur: float, longueur: float, hauteur: float) -> Vector3:
	var radial := sin(v * PI)
	var ventre := radial * (.72 + .28 * sin(v * PI))
	return centre + Vector3(cos(angle) * ventre * largeur, sin(angle) * ventre * hauteur,
		cos(v * PI) * longueur * .52)

static func _amande(mesh: ImmediateMesh, centre: Vector3, largeur: float,
		longueur: float, hauteur: float, teinte: Color, anneaux: int, faces: int) -> void:
	for j in anneaux:
		for i in faces:
			var points: Array[Vector3] = []
			var couleurs: Array[Color] = []
			for uv: Vector2 in [Vector2(i, j), Vector2(i + 1, j), Vector2(i, j + 1), Vector2(i + 1, j + 1)]:
				var v := uv.y / anneaux
				var angle := TAU * uv.x / faces
				points.append(_point_amande(v, angle, centre, largeur, longueur, hauteur))
				couleurs.append(_vernis(Vector3(cos(angle) * sin(v * PI), sin(angle) * sin(v * PI), cos(v * PI)), teinte))
			_triangle(mesh, points[0], points[1], points[2], couleurs[0], couleurs[1], couleurs[2])
			_triangle(mesh, points[1], points[3], points[2], couleurs[1], couleurs[3], couleurs[2])
