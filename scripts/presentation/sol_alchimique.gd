extends RefCounted

const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")

static func surface(parent: Node3D, contour: PackedVector2Array, hauteur: float, teinte: Color) -> MeshInstance3D:
	var indices := Geometry2D.triangulate_polygon(contour)
	if indices.is_empty(): return null
	var maillage := SurfaceTool.new()
	maillage.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0, indices.size(), 3):
		var a := Vector3(contour[indices[i]].x, hauteur, contour[indices[i]].y)
		var b := Vector3(contour[indices[i + 1]].x, hauteur, contour[indices[i + 1]].y)
		var c := Vector3(contour[indices[i + 2]].x, hauteur, contour[indices[i + 2]].y)
		if (b - a).cross(c - a).y > 0.0:
			var ancien := b
			b = c
			c = ancien
		for point: Vector3 in [a, b, c]:
			maillage.set_normal(Vector3.UP)
			maillage.add_vertex(point)
	var objet := DECOR.piece(parent, maillage.commit(), Vector3.ZERO, teinte)
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return objet

static func construire(parent: Node3D, contour_logique: PackedVector2Array, limites: Rect2, monde: int, variante := 0) -> void:
	var contour := PackedVector2Array()
	for point in contour_logique:
		var p := Pont3D.vers_monde(point)
		contour.append(Vector2(p.x, p.z))
	var sol := DecorsMondes.couleur(monde, "sol")
	var email := DecorsMondes.couleur(monde, "accent").lerp(sol, .26)
	# Une frise large reste visible quand la camera ne montre qu'une portion
	# de la salle. Elle est incrustee dans le sol, jamais un obstacle ajoute.
	surface(parent, contour, -.040, email)
	var interieur := contour
	var retraits := [.09, .135, .46]
	var teintes := [DecorsMondes.CUIVRE.lerp(sol,.30), email, DecorsMondes.couleur(monde,"joint")]
	for i in retraits.size():
		var formes := Geometry2D.offset_polygon(contour, -float(retraits[i]))
		if formes.size() != 1: continue
		interieur = formes[0]
		surface(parent, interieur, -.036 + i*.004, teintes[i])
	var debut := Pont3D.vers_monde(limites.position)
	var fin := Pont3D.vers_monde(limites.end)
	var cadre := Rect2(Vector2(debut.x, debut.z), Vector2(fin.x - debut.x, fin.z - debut.z))
	var profil := DecorsMondes.profil(monde)
	_fond_mineral(parent, interieur, cadre.get_center(), monde, variante)
	var ilots: Array = profil["ilots"]
	var zones := DecorsMondes.zones_sol(monde, variante)
	for i in zones.size():
		var matiere: Dictionary = ilots[int(zones[i]["matiere"])]
		var zone := PackedVector2Array()
		for point: Vector2 in zones[i]["contour"]:
			zone.append(cadre.position + _implantation(point, monde, variante) * cadre.size)
		zone = _raccord(zone, int(matiere["motif"]), variante + i)
		for fragment: PackedVector2Array in Geometry2D.intersect_polygons(zone, interieur):
			surface(parent, fragment, -.018, Color(str(matiere["joint"])))
			_daller(parent, fragment, cadre.get_center(), matiere, -.012, variante + i)
	_traces_atelier(parent, interieur, cadre, monde, variante)
	var position := Pont3D.vers_monde(limites.get_center(), -.009)
	_sceau(parent, position, minf(2.0, limites.size.x * Pont3D.ECHELLE * .17), sol.lerp(DecorsMondes.couleur(monde, "joint"), .65))

static func _fond_mineral(parent: Node3D, contour: PackedVector2Array, origine: Vector2, monde: int, variante: int) -> void:
	var sol := DecorsMondes.couleur(monde, "sol")
	var joint := DecorsMondes.couleur(monde, "joint")
	var sombre := sol.lerp(joint, .48)
	var clair := sol.lerp(DecorsMondes.PAPIER, .16).lightened(.055)
	var bruit := FastNoiseLite.new()
	bruit.seed = monde * 104729 + variante * 7919 + 41
	bruit.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	bruit.frequency = .28
	bruit.fractal_octaves = 3
	var cadre := Rect2(contour[0] - origine, Vector2.ZERO)
	for point in contour: cadre = cadre.expand(point - origine)
	# Les couleurs se fondent entre les sommets : pas de joints ni de texture
	# repetee sous les acteurs. Le maillage reste plat et decoupe au vrai contour.
	var pas := .32
	var maillage := SurfaceTool.new()
	maillage.begin(Mesh.PRIMITIVE_TRIANGLES)
	for ligne in range(floori(cadre.position.y / pas), ceili(cadre.end.y / pas)):
		for colonne in range(floori(cadre.position.x / pas), ceili(cadre.end.x / pas)):
			var a := origine + Vector2(colonne, ligne) * pas
			var cellule := PackedVector2Array([a, a + Vector2(pas, 0), a + Vector2(pas, pas), a + Vector2(0, pas)])
			for fragment: PackedVector2Array in Geometry2D.intersect_polygons(cellule, contour):
				var indices := Geometry2D.triangulate_polygon(fragment)
				for i in range(0, indices.size(), 3):
					var triangle := PackedVector2Array([fragment[indices[i]], fragment[indices[i+1]], fragment[indices[i+2]]])
					if (triangle[1] - triangle[0]).cross(triangle[2] - triangle[0]) < 0.0:
						triangle.reverse()
					for point in triangle:
						var local := point - origine
						var nuance := clampf(.5 + bruit.get_noise_2dv(local) * 1.35, 0.0, 1.0)
						var grain := bruit.get_noise_2dv(local * 5.0 + Vector2(137, 71)) * .024
						var couleur := sombre.lerp(clair, nuance)
						couleur = couleur.lightened(grain) if grain > 0.0 else couleur.darkened(-grain)
						maillage.set_color(couleur.srgb_to_linear())
						maillage.set_normal(Vector3.UP)
						maillage.add_vertex(Vector3(point.x, -.024, point.y))
	maillage.index()
	var objet := DECOR.piece(parent, maillage.commit(), Vector3.ZERO, Color.WHITE, .97)
	objet.name = "FondMineral"
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var matiere := objet.material_override as StandardMaterial3D
	matiere.vertex_color_use_as_albedo = true
	# Les couleurs lineaires conservent la palette aussi lors de l'export GLB.
	matiere.vertex_color_is_srgb = false
	# Quelques veines courtes et des reprises claires donnent une echelle a la
	# matiere sans redessiner une grille sur toute la surface de combat.
	var hasard := RandomNumberGenerator.new()
	hasard.seed = bruit.seed + 113
	for i in 8:
		var centre := origine + cadre.position + cadre.size * Vector2(hasard.randf_range(.08, .92), hasard.randf_range(.06, .94))
		var direction := Vector2.from_angle(hasard.randf_range(0.0, TAU))
		var longueur := hasard.randf_range(.65, 1.6)
		var points := PackedVector2Array()
		for j in 5:
			points.append(centre + direction * (float(j) / 4.0 - .5) * longueur + direction.orthogonal() * hasard.randf_range(-.08, .08))
		_ruban(parent, points, .055, contour, -.023, sol.lerp(clair, .60))
		_ruban(parent, points, .015, contour, -.022, sol.lerp(joint, .36))

static func _implantation(point: Vector2, monde: int, variante: int) -> Vector2:
	var resultat := point
	if posmod(variante + monde, 2) == 1: resultat.x = 1.0 - resultat.x
	if posmod(variante + monde / 2, 3) == 2: resultat.y = 1.0 - resultat.y
	# Un decalage borne conserve les trois matieres dans les salles etroites.
	resultat.y += (posmod(variante, 3) - 1) * .025
	return resultat

static func _raccord(contour: PackedVector2Array, motif: int, graine: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var pas := Vector2(.54,.65) if motif == 5 else Vector2(.45,.45)
	# Les sols poses ont des reprises en gradins ; la pierre et la terre gardent
	# un bord erode. Aucun grand trait droit ne traverse les matieres en biais.
	for i in contour.size():
		var a := contour[i]
		var b := contour[(i+1)%contour.size()]
		var morceaux := maxi(1, ceili(a.distance_to(b) / .55))
		var normale := (b - a).orthogonal().normalized()
		for j in morceaux:
			var point := a.lerp(b, float(j) / morceaux)
			if motif in [0, 2, 3, 4, 5]:
				point = point.snapped(pas)
				if not points.is_empty():
					var precedent := points[points.size()-1]
					if point.is_equal_approx(precedent): continue
					if not is_equal_approx(point.x, precedent.x) and not is_equal_approx(point.y, precedent.y):
						points.append(Vector2(precedent.x,point.y))
			else:
				point += normale * sin((i * 19 + j * 7 + graine * 3) * 1.7) * .11
			points.append(point)
	# Fermer aussi la derniere reprise en gradins.
	if motif in [0, 2, 3, 4, 5] and not is_equal_approx(points[-1].x, points[0].x) and not is_equal_approx(points[-1].y, points[0].y):
		points.append(Vector2(points[-1].x, points[0].y))
	return points

static func _daller(parent: Node3D, contour: PackedVector2Array, origine: Vector2, matiere: Dictionary, hauteur: float, variante: int) -> void:
	var dimensions: Vector2 = matiere["dalle"]
	var motif := int(matiere["motif"])
	var angle := float(matiere.get("angle", 0.0))
	var sol := Color(str(matiere["sol"]))
	var joint := Color(str(matiere["joint"]))
	var grain := Color(str(matiere.get("grain", joint.lerp(sol, .40).to_html(false))))
	var local := PackedVector2Array()
	for point in contour: local.append((point - origine).rotated(-angle))
	var cadre := Rect2(local[0], Vector2.ZERO)
	for point in local: cadre = cadre.expand(point)
	var pas := dimensions
	if motif == 1: pas = dimensions * Vector2(1.5, sqrt(3.0))
	if motif == 2: pas = dimensions * Vector2(2.0, 1.0)
	for ligne in range(floori(cadre.position.y / pas.y) - 2, ceili(cadre.end.y / pas.y) + 2):
		for colonne in range(floori(cadre.position.x / pas.x) - 2, ceili(cadre.end.x / pas.x) + 2):
			var graine := posmod(colonne * 73 + ligne * 137 + variante * 17, 997)
			if motif == 7 and graine % 4 == 0: continue
			var centre := Vector2(colonne * pas.x, ligne * pas.y)
			if motif in [0, 2, 3, 6, 7, 8]: centre.x += posmod(ligne, 2) * pas.x * .5
			if motif == 5: centre.y += posmod(colonne, 3) * pas.y / 3.0
			if motif == 1: centre.y += posmod(colonne, 2) * pas.y * .5
			var taille := dimensions
			if motif in [7, 8]:
				taille *= .58 + (graine % 3) * .09
				centre += Vector2(sin(graine * .73), cos(graine * .91)) * .10
			var dalle := _dalle(centre, taille, motif, graine)
			for i in dalle.size(): dalle[i] = origine + dalle[i].rotated(angle)
			# Decouper les dalles contre le vrai contour evite de suggerer des
			# passages dans les coins arrondis et les retraits des modes annexes.
			var variation := posmod(floori(colonne / 3.0) + floori(ligne / 2.0) + graine % 2, 3)
			var teinte := sol.darkened(.028) if variation == 0 else sol.lightened((variation - 1) * .035)
			for fragment: PackedVector2Array in Geometry2D.intersect_polygons(dalle, contour):
				surface(parent, fragment, hauteur, teinte)
				_patine(parent, fragment, origine + centre.rotated(angle), taille, angle, motif, graine, hauteur + .002, grain)

static func _dalle(centre: Vector2, taille: Vector2, motif: int, graine := 0) -> PackedVector2Array:
	var points := PackedVector2Array()
	match motif:
		1:
			for i in 6:
				var angle := float(i) * TAU / 6.0
				points.append(centre + Vector2(cos(angle), sin(angle)) * (taille.x - .018))
		2:
			for point: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
				points.append(centre + point * (taille - Vector2.ONE * .025))
		4:
			var demi := taille * .5 - Vector2.ONE * .014
			for point: Vector2 in [Vector2(-.82,-1),Vector2(.82,-1),Vector2(1,-.82),Vector2(1,.82),Vector2(.82,1),Vector2(-.82,1),Vector2(-1,.82),Vector2(-1,-.82)]:
				points.append(centre + point * demi)
		6, 7, 8:
			var demi := taille * .5 - Vector2.ONE * .028
			var coin := .16 + (graine % 4) * .065
			for point: Vector2 in [Vector2(-1+coin,-1),Vector2(.68,-1),Vector2(1,-.62),Vector2(1,.67),Vector2(.72,1),Vector2(-.65,1),Vector2(-1,.60),Vector2(-1,-.66)]:
				points.append(centre + point * demi)
		_:
			var demi := taille * .5 - Vector2.ONE * .012
			for point: Vector2 in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
				points.append(centre + point * demi)
	return points

static func _patine(parent: Node3D, contour: PackedVector2Array, centre: Vector2, taille: Vector2, angle: float, motif: int, graine: int, hauteur: float, teinte: Color) -> void:
	if motif == 5:
		if graine % 3 == 0: return
		for cote: float in [-1.0, 1.0]:
			var points := PackedVector2Array([Vector2(cote*.22,-.34),Vector2(cote*.19,.06),Vector2(cote*.24,.31)])
			for i in points.size(): points[i] = centre + (points[i] * taille).rotated(angle)
			_ruban(parent, points, .012, contour, hauteur, teinte)
	elif motif == 4:
		for cote: float in [-1.0, 1.0]:
			var point := centre + (taille * Vector2(cote*.35,-.35)).rotated(angle)
			_fragment(parent, _dalle(point, Vector2(.065,.065), 4), contour, hauteur, teinte)
		if graine % 3 == 0:
			for i in 3:
				var a := centre + (taille * Vector2(-.19,(i-1)*.065)).rotated(angle)
				var b := centre + (taille * Vector2(.19,(i-1)*.065)).rotated(angle)
				_ruban(parent, PackedVector2Array([a,b]), .025, contour, hauteur, teinte)
	elif graine % 7 == 0 and taille.x > 1.0:
		var points := PackedVector2Array([Vector2(-.5,-.22),Vector2(-.22,-.12),Vector2(-.15,.04),Vector2(.04,.10)])
		for i in points.size(): points[i] = centre + (points[i] * taille).rotated(angle)
		_ruban(parent, points, .021, contour, hauteur, teinte)
	elif graine % 5 == 0 and motif in [3, 6, 7, 8]:
		var points := PackedVector2Array([Vector2(-.26,.29),Vector2(.03,.32),Vector2(.23,.28)])
		for i in points.size(): points[i] = centre + (points[i] * taille).rotated(angle)
		_ruban(parent, points, .026, contour, hauteur, teinte)

static func _fragment(parent: Node3D, forme: PackedVector2Array, contour: PackedVector2Array, hauteur: float, teinte: Color) -> void:
	for morceau: PackedVector2Array in Geometry2D.intersect_polygons(forme, contour):
		surface(parent, morceau, hauteur, teinte)

static func _ruban(parent: Node3D, points: PackedVector2Array, largeur: float, contour: PackedVector2Array, hauteur: float, teinte: Color) -> void:
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i+1]
		var normale := (b - a).orthogonal().normalized() * largeur * .5
		_fragment(parent, PackedVector2Array([a-normale,b-normale,b+normale,a+normale]), contour, hauteur, teinte)

static func _traces_atelier(parent: Node3D, contour: PackedVector2Array, cadre: Rect2, monde: int, variante: int) -> void:
	# Quelques objets plats racontent l'atelier sans suggerer de nouveau couvert
	# ni masquer les ombres des personnages qui passent au-dessus.
	var emplacements := [Vector2(.17,.19),Vector2(.83,.55),Vector2(.16,.86)]
	var papier := DecorsMondes.PAPIER.lerp(DecorsMondes.couleur(monde,"sol"), .20)
	var marque := DecorsMondes.couleur(monde,"joint")
	for i in emplacements.size():
		var centre := cadre.position + _implantation(emplacements[i], monde, variante) * cadre.size
		var angle := (i - 1) * .7 + variante * .23
		for j in (2 if monde in [0, 3] else 3):
			var position := centre + Vector2(j * .32, sin(j * 2.3 + i) * .30)
			var points := PackedVector2Array()
			var teinte := papier
			match monde:
				0:
					points = PackedVector2Array([Vector2(-.23,-.34),Vector2(.23,-.34),Vector2(.23,.23),Vector2(.12,.34),Vector2(-.23,.34)])
				1, 3:
					points = PackedVector2Array([Vector2(0,-.37),Vector2(.17,-.08),Vector2(.10,.17),Vector2(0,.30),Vector2(-.11,.10),Vector2(-.14,-.16)])
					if monde == 1: teinte = DecorsMondes.couleur(monde,"detail").lerp(papier,.38)
				2:
					points = PackedVector2Array([Vector2(-.17,-.12),Vector2(.08,-.20),Vector2(.20,.04),Vector2(.08,.19),Vector2(-.19,.09)])
					teinte = papier.lerp(DecorsMondes.couleur(monde,"sol"), .45)
				4:
					points = PackedVector2Array([Vector2(-.20,-.06),Vector2(.20,-.06),Vector2(.23,.05),Vector2(-.14,.08)])
					teinte = DecorsMondes.CUIVRE.lerp(DecorsMondes.couleur(monde,"sol"), .55)
			var rotation_trace := angle + j * .9
			for k in points.size(): points[k] = position + points[k].rotated(rotation_trace)
			_fragment(parent, points, contour, -.006, teinte)
			if monde == 0:
				for k in 3:
					var a := position + Vector2(-.13,(k-1)*.10).rotated(rotation_trace)
					var b := position + Vector2(.10,(k-1)*.10).rotated(rotation_trace)
					_ruban(parent, PackedVector2Array([a,b]), .016, contour, -.004, marque)
			elif monde in [1, 3]:
				var a := position + Vector2(0,-.22).rotated(rotation_trace)
				var b := position + Vector2(0,.24).rotated(rotation_trace)
				_ruban(parent, PackedVector2Array([a,b]), .017, contour, -.004, marque)

static func _trait(parent: Node3D, a: Vector3, b: Vector3, largeur: float, teinte: Color) -> void:
	var objet := DECOR.bloc(parent, (a + b) * .5, Vector3(a.distance_to(b), .0008, largeur), teinte)
	objet.rotation.y = -atan2(b.z - a.z, b.x - a.x)
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func _sceau(parent: Node3D, centre: Vector3, echelle: float, teinte: Color) -> void:
	# Une marque d'atelier gravee, sans halo ni cercle de telegraphe hostile.
	var contour := PackedVector2Array([Vector2(-.24,-.74),Vector2(.24,-.74),Vector2(.24,-.27),Vector2(.62,.37),Vector2(.48,.61),Vector2(-.48,.61),Vector2(-.62,.37),Vector2(-.24,-.27),Vector2(-.24,-.74)])
	for i in contour.size() - 1:
		var a := centre + Vector3(contour[i].x, 0, contour[i].y) * echelle
		var b := centre + Vector3(contour[i + 1].x, 0, contour[i + 1].y) * echelle
		_trait(parent, a, b, .037, teinte)
	_trait(parent, centre + Vector3(-.44,0,.22) * echelle, centre + Vector3(.44,0,.22) * echelle, .03, teinte)
	for cote: float in [-1.0, 1.0]:
		_trait(parent, centre + Vector3(cote*.84,0,.05) * echelle, centre + Vector3(cote*1.14,0,.05) * echelle, .035, teinte)
		_trait(parent, centre + Vector3(cote*.98,0,-.08) * echelle, centre + Vector3(cote*.98,0,.18) * echelle, .035, teinte)
