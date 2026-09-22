extends RefCounted

static var _matiere: StandardMaterial3D
static var _matiere_coeur: StandardMaterial3D
static var _formes := {}

static func construire(silhouette: String) -> Node3D:
	var racine := Node3D.new()
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
		_matiere.albedo_color = Color("ff6948")
		_matiere_coeur = _matiere.duplicate() as StandardMaterial3D
		_matiere_coeur.albedo_color = Color("ffe4ab")
	if not _formes.has(silhouette):
		var forme: Mesh
		if silhouette == "vrille":
			forme = _spirale()
		else:
			var prisme := PrismMesh.new()
			prisme.size = Vector3(.25,.24,.23) if silhouette == "eclat" else (Vector3(.38,.08,.14) if silhouette == "lame" else Vector3(.13,.10,.36))
			forme = prisme
		_formes[silhouette] = forme
	for i in (3 if silhouette == "vrille" else 1):
		var piece := MeshInstance3D.new()
		piece.mesh = _formes[silhouette]
		piece.material_override = _matiere
		piece.position.y = .10 + i * .10
		if silhouette == "vrille":
			piece.position.y = .05
			piece.rotation.y = TAU * float(i) / 3.0
			piece.material_override = _matiere_coeur if i == 0 else _matiere
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		racine.add_child(piece)
	return racine

static func _spirale() -> ImmediateMesh:
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 16:
		var t := float(i) / 16.0
		var suivant := float(i + 1) / 16.0
		var a := Vector3(cos(t * TAU) * (.05 + .19 * t), .42 * t, sin(t * TAU) * (.05 + .19 * t))
		var b := Vector3(cos(suivant * TAU) * (.05 + .19 * suivant), .42 * suivant, sin(suivant * TAU) * (.05 + .19 * suivant))
		var largeur_a := Vector3.UP * (.018 + sin(t * PI) * .025)
		var largeur_b := Vector3.UP * (.018 + sin(suivant * PI) * .025)
		for point: Vector3 in [a - largeur_a, b - largeur_b, a + largeur_a, a + largeur_a, b - largeur_b, b + largeur_b]:
			mesh.surface_add_vertex(point)
	mesh.surface_end()
	return mesh
