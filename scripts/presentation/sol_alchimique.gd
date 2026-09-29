extends RefCounted

const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")
const BORDURES := preload("res://scripts/presentation/bordures_sol.gd")
const PAS_NUANCES := .50

static func surface(parent: Node3D, contour: PackedVector2Array, hauteur: float, teinte: Color, cadre_uv := Rect2(), composition: Dictionary = {}) -> MeshInstance3D:
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
			if cadre_uv.has_area():
				var uv := (Vector2(point.x, point.z) - cadre_uv.position) / cadre_uv.size
				# Les miroirs renouvellent le dessin en gardant sa zone centrale calme.
				if bool(composition.get("miroir_x", false)): uv.x = 1.0 - uv.x
				if bool(composition.get("miroir_y", false)): uv.y = 1.0 - uv.y
				var fenetre: Rect2 = composition.get("fenetre_uv", Rect2(Vector2.ZERO, Vector2.ONE))
				uv = fenetre.position + uv * fenetre.size
				maillage.set_uv(uv)
			maillage.add_vertex(point)
	var objet := DECOR.piece(parent, maillage.commit(), Vector3.ZERO, teinte, .97, false)
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return objet

static func construire(parent: Node3D, contour_logique: PackedVector2Array, limites: Rect2, monde: int, variante := 0, etage := 0) -> void:
	var contour := PackedVector2Array()
	for point in contour_logique:
		var position := Pont3D.vers_monde(point)
		contour.append(Vector2(position.x, position.z))
	var sol := DecorsMondes.couleur(monde, "sol")
	var email := DecorsMondes.couleur(monde, "accent").lerp(sol, .16)
	surface(parent, contour, -.040, email)
	var interieur := contour
	var retraits := [.065, .105, .36]
	var teintes := [DecorsMondes.CUIVRE.lerp(sol, .22), email, sol.lerp(email, .28)]
	for i in retraits.size():
		var formes := Geometry2D.offset_polygon(contour, -float(retraits[i]))
		if formes.size() != 1: continue
		interieur = formes[0]
		surface(parent, interieur, -.036 + i * .004, teintes[i])
	var debut := Pont3D.vers_monde(limites.position)
	var fin := Pont3D.vers_monde(limites.end)
	var cadre := Rect2(Vector2(debut.x, debut.z), Vector2(fin.x - debut.x, fin.z - debut.z))
	var composition := DecorsMondes.composition_sol(monde, etage, variante)
	var fond := _enduit(parent, interieur, cadre, composition)
	fond.name = "EnduitCire"
	fond.material_override = DecorsMondes.matiere_sol(monde)
	parent.set_meta("monde_enduit", monde)
	parent.set_meta("etage_decor", etage)
	BORDURES.new().construire(parent, interieur, cadre, monde)
	_frise(parent, contour, monde, variante, float(composition["decalage_frise"]))

static func _enduit(parent: Node3D, contour: PackedVector2Array, cadre: Rect2, composition: Dictionary) -> MeshInstance3D:
	# Une seule surface porte les reprises : aucun decal flottant ni dessin par zone.
	var maillage := SurfaceTool.new()
	maillage.begin(Mesh.PRIMITIVE_TRIANGLES)
	var colonnes := maxi(1, ceili(cadre.size.x / PAS_NUANCES))
	var lignes := maxi(1, ceili(cadre.size.y / PAS_NUANCES))
	var pas := cadre.size / Vector2(colonnes, lignes)
	for ligne in lignes:
		for colonne in colonnes:
			var origine := cadre.position + Vector2(colonne, ligne) * pas
			var cellule := PackedVector2Array([origine, origine + Vector2(pas.x, 0), origine + pas, origine + Vector2(0, pas.y)])
			for morceau: PackedVector2Array in Geometry2D.intersect_polygons(cellule, contour):
				var indices := Geometry2D.triangulate_polygon(morceau)
				for i in range(0, indices.size(), 3):
					var triangle := PackedVector2Array([morceau[indices[i]], morceau[indices[i + 1]], morceau[indices[i + 2]]])
					if (triangle[1] - triangle[0]).cross(triangle[2] - triangle[0]) < 0.0:
						triangle.reverse()
					for point in triangle: _sommet_enduit(maillage, point, cadre, composition)
	maillage.index()
	var objet := DECOR.piece(parent, maillage.commit(), Vector3.ZERO, Color.WHITE, .86, false)
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return objet

static func _sommet_enduit(maillage: SurfaceTool, point: Vector2, cadre: Rect2, composition: Dictionary) -> void:
	var relatif := (point - cadre.position) / cadre.size
	var teinte: Color = composition["teinte"]
	var phase := float(composition["phase"])
	var axe := float(composition["axe_poli"]) + sin(relatif.y * 7.0 + phase) * .016
	var polissage := exp(-pow((relatif.x - axe) / .15, 2.0)) * .018
	var usure := float(composition["usure"]) * smoothstep(.17, .40, absf(relatif.x - .5)) * (.5 + .5 * sin(relatif.y * 13.0 + phase))
	var valeur := .975 + sin(relatif.x * 9.0 + relatif.y * 5.0 + phase) * .009 + polissage - usure
	teinte *= Color(valeur, valeur, valeur)
	var projection := relatif
	var zones: Array = composition["zones"]
	for zone: Dictionary in zones:
		var centre: Vector2 = zone["position"]
		var rayon: Vector2 = zone["rayon"]
		var local := (relatif - centre).rotated(-float(zone["angle"])) / rayon
		var relief := sin(local.x * 3.1 + local.y * 1.9 + float(zone["phase"])) * .075
		relief += sin(local.y * 7.0 - local.x * 2.1 + phase) * .025
		var poids := 1.0 - smoothstep(.32, 1.08, local.length() + relief)
		var force := float(zone["force"]) * poids
		var nuance: Color = zone["teinte"]
		teinte = teinte.lerp(nuance, force)
		# La taloche change aussi de direction dans une reprise, sans couture franche.
		projection += (relatif - centre).rotated(float(zone["torsion"]) * poids) - (relatif - centre)
	var angle := float(composition["angle_matiere"])
	var normalisation := absf(cos(angle)) + absf(sin(angle))
	var uv := (projection - Vector2.ONE * .5).rotated(angle) / normalisation + Vector2.ONE * .5
	if bool(composition["miroir_x"]): uv.x = 1.0 - uv.x
	if bool(composition["miroir_y"]): uv.y = 1.0 - uv.y
	var fenetre: Rect2 = composition["fenetre_uv"]
	uv = fenetre.position + uv * fenetre.size
	maillage.set_uv(uv.clamp(Vector2.ZERO, Vector2.ONE))
	maillage.set_color(teinte)
	maillage.set_normal(Vector3.UP)
	maillage.add_vertex(Vector3(point.x, -.020, point.y))

static func _frise(parent: Node3D, contour: PackedVector2Array, monde: int, variante: int, decalage: float) -> void:
	# Les petites incrustations restent dans la frise et suivent aussi les coins.
	var aire := 0.0
	for i in contour.size(): aire += contour[i].cross(contour[(i + 1) % contour.size()])
	var teinte := DecorsMondes.CUIVRE.lerp(DecorsMondes.couleur(monde, "sol"), .35)
	for i in contour.size():
		var a := contour[i]
		var b := contour[(i + 1) % contour.size()]
		var direction := (b - a).normalized()
		var dedans := Vector2(-direction.y, direction.x) * (1.0 if aire > 0.0 else -1.0)
		var nombre := floori(a.distance_to(b) / 1.6)
		for j in nombre:
			var centre := a.lerp(b, (float(j) + decalage) / nombre) + dedans * .22
			var motif := PackedVector2Array()
			if monde == 2:
				for k in 7:
					var angle := PI + k * PI / 6.0
					motif.append(Vector2(cos(angle) * .11, sin(angle) * .08))
				motif.append(Vector2(0, .04))
			else:
				var longueur := .13 if monde == 3 else .09
				motif = PackedVector2Array([Vector2(-longueur, 0), Vector2(0, -.055), Vector2(longueur, 0), Vector2(0, .055)])
			for k in motif.size():
				motif[k] = centre + direction * motif[k].x + dedans * motif[k].y
			_fragment(parent, motif, contour, -.018, teinte)
			if posmod(j + variante, 3) == 0:
				_ruban(parent, PackedVector2Array([centre - direction * .20, centre - direction * .15]), .018, contour, -.018, teinte)
				_ruban(parent, PackedVector2Array([centre + direction * .15, centre + direction * .20]), .018, contour, -.018, teinte)

static func _fragment(parent: Node3D, forme: PackedVector2Array, contour: PackedVector2Array, hauteur: float, teinte: Color) -> void:
	for morceau: PackedVector2Array in Geometry2D.intersect_polygons(forme, contour):
		surface(parent, morceau, hauteur, teinte)

static func _ruban(parent: Node3D, points: PackedVector2Array, largeur: float, contour: PackedVector2Array, hauteur: float, teinte: Color) -> void:
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i + 1]
		var normale := (b - a).orthogonal().normalized() * largeur * .5
		_fragment(parent, PackedVector2Array([a - normale, b - normale, b + normale, a + normale]), contour, hauteur, teinte)
