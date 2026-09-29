extends RefCounted

# L'email souligne le contour sans dessiner d'objets sous les combattants.
static var _matiere: StandardMaterial3D

var _surface: SurfaceTool
var _contour := PackedVector2Array()
var _cadre := Rect2()
var _palette: Array[Color] = []

func construire(parent: Node3D, contour: PackedVector2Array, cadre: Rect2, monde: int) -> void:
	_contour = contour
	_cadre = cadre
	var couleurs: Array = DecorsMondes.profil(monde)["parure"]
	for couleur: String in couleurs: _palette.append(Color(couleur))
	_surface = SurfaceTool.new()
	_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	_bordure()
	_surface.index()
	var objet := MeshInstance3D.new()
	objet.name = "BorduresEmail"
	objet.mesh = _surface.commit()
	objet.material_override = _matiere_partagee()
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(objet)

static func _matiere_partagee() -> StandardMaterial3D:
	if _matiere != null: return _matiere
	_matiere = StandardMaterial3D.new()
	_matiere.resource_name = "BorduresEmail"
	_matiere.albedo_texture = load(DecorsMondes.TEXTURE_ENDUIT) as Texture2D
	_matiere.vertex_color_use_as_albedo = true
	_matiere.vertex_color_is_srgb = true
	_matiere.roughness = .78
	_matiere.metallic_specular = .26
	_matiere.texture_repeat = false
	_matiere.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return _matiere

func _bordure() -> void:
	var retraits := Geometry2D.offset_polygon(_contour, -.28)
	if retraits.size() != 1: return
	var ligne: PackedVector2Array = retraits[0]
	var dehors := PackedVector2Array()
	var dedans := PackedVector2Array()
	for i in ligne.size():
		var avant := (ligne[i] - ligne[posmod(i-1,ligne.size())]).normalized().orthogonal()
		var apres := (ligne[(i+1)%ligne.size()] - ligne[i]).normalized().orthogonal()
		var bissectrice := (avant + apres).normalized()
		var retrait := bissectrice * (.18 / maxf(.30, absf(bissectrice.dot(apres))))
		dehors.append(ligne[i] + retrait)
		dedans.append(ligne[i] - retrait)
	# Les raccords partagent leurs sommets, y compris dans les rentrants.
	for i in ligne.size():
		var j := (i+1)%ligne.size()
		_poser(PackedVector2Array([dehors[i],dehors[j],dedans[j],dedans[i]]), _palette[0].lerp(_palette[1], .18), -.019)
	var filets := Geometry2D.offset_polygon(_contour, -.51)
	if filets.size() == 1:
		var filet: PackedVector2Array = filets[0]
		filet.append(filet[0])
		_ruban(filet, .022, _palette[2], -.018)

func _ruban(points: PackedVector2Array, largeur: float, teinte: Color, hauteur: float) -> void:
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i + 1]
		var normale := (b-a).orthogonal().normalized() * largeur * .5
		_poser(PackedVector2Array([a-normale,b-normale,b+normale,a+normale]), teinte, hauteur)

func _poser(forme: PackedVector2Array, teinte: Color, hauteur: float) -> void:
	for morceau: PackedVector2Array in Geometry2D.intersect_polygons(forme, _contour):
		var indices := Geometry2D.triangulate_polygon(morceau)
		for i in range(0, indices.size(), 3):
			var triangle := PackedVector2Array([morceau[indices[i]],morceau[indices[i+1]],morceau[indices[i+2]]])
			if (triangle[1]-triangle[0]).cross(triangle[2]-triangle[0]) < 0.0: triangle.reverse()
			for point in triangle:
				var nuance := .96 + sin(point.x * 1.9 + point.y * 2.1) * .035
				_surface.set_color(teinte * Color(nuance,nuance,nuance))
				_surface.set_normal(Vector3.UP)
				_surface.set_uv((Vector2.ONE*.04 + (point-_cadre.position)/_cadre.size*.92).clamp(Vector2.ZERO,Vector2.ONE))
				_surface.add_vertex(Vector3(point.x,hauteur,point.y))
