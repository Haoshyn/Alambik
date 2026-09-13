extends Node3D

var _materiaux := {}

func materiau(couleur: Color, emission := false) -> StandardMaterial3D:
	var cle := couleur.to_html() + str(emission)
	if _materiaux.has(cle):
		return _materiaux[cle]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = couleur
	mat.roughness = 0.9
	if emission:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_materiaux[cle] = mat
	return mat

func bloc(centre: Vector3, taille: Vector3, couleur: Color) -> MeshInstance3D:
	var objet := MeshInstance3D.new()
	objet.mesh = preload("res://scripts/presentation/decor_alchimique.gd").pierre(taille)
	objet.material_override = materiau(couleur)
	objet.position = centre
	add_child(objet)
	return objet

func construire(limites: Rect2, _charger: Callable, monde := 0, contour := PackedVector2Array()) -> void:
	for enfant in get_children():
		enfant.queue_free()
	var centre := Pont3D.vers_monde(limites.get_center())
	var taille := Pont3D.vers_monde(limites.size)
	var ambiance := [DecorsMondes.couleur(monde,"sol"),DecorsMondes.couleur(monde,"dehors"),DecorsMondes.couleur(monde,"mur")]
	bloc(centre + Vector3(0,-0.7,0), Vector3(taille.x+12,0.1,taille.z+12), ambiance[1])
	# Le meme contour pilote le sol, sa tranche et les collisions de la salle.
	if contour.is_empty():
		contour = PackedVector2Array([limites.position,Vector2(limites.position.x,limites.end.y),limites.end,Vector2(limites.end.x,limites.position.y)])
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var indices := Geometry2D.triangulate_polygon(contour)
	for i in range(0,indices.size(),3):
		var a := Pont3D.vers_monde(contour[indices[i]])
		var b := Pont3D.vers_monde(contour[indices[i+1]])
		var c := Pont3D.vers_monde(contour[indices[i+2]])
		# Godot attend des faces horaires vues du dessus.
		if (b-a).cross(c-a).y > 0.0:
			var ancien := b
			b = c
			c = ancien
		for point in [a,b,c]:
			surface.set_normal(Vector3.UP)
			surface.set_uv(Vector2(point.x,point.z))
			surface.add_vertex(point)
	var instance := MeshInstance3D.new()
	instance.mesh = surface.commit()
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/dalles_alchimiques.gdshader")
	mat.set_shader_parameter("pierre", ambiance[0])
	mat.set_shader_parameter("calcaire",preload("res://assets/visual/atelier/calcaire.png"))
	mat.set_shader_parameter("motif", int(DecorsMondes.profil(monde)["motif"]))
	mat.set_shader_parameter("joint", DecorsMondes.couleur(monde,"joint"))
	instance.material_override = mat
	# Le sol recoit les ombres des acteurs sans produire de bandes d'auto-ombre.
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)
	for i in contour.size():
		var a := Pont3D.vers_monde(contour[i])
		var b := Pont3D.vers_monde(contour[(i+1)%contour.size()])
		var longueur := a.distance_to(b)
		var bord := bloc((a+b)*0.5+Vector3(0,0.05,0),Vector3(longueur+0.12,0.50,0.24),ambiance[2])
		bord.rotation.y = -atan2(b.z-a.z,b.x-a.x)
		var tranche := bloc((a+b)*0.5+Vector3(0,-0.42,0),Vector3(longueur+0.10,0.4,0.22),ambiance[2].darkened(.18))
		tranche.rotation.y = bord.rotation.y
		var ceramique := bloc((a+b)*0.5+Vector3(0,.32,0),Vector3(longueur+.12,.10,.30),DecorsMondes.couleur(monde,"accent"))
		ceramique.rotation.y = bord.rotation.y
	# Les ornements restent hors de la surface de collision, meme dans les retraits.
	var ornements := preload("res://scripts/presentation/ornements_monde.gd")
	for cote in [-1.0,1.0]:
		for i in 4:
			var p := centre+Vector3(cote*(taille.x/2+.65),0,-taille.z*.40+i*taille.z*.26)
			ornements.pilier(self,p,monde)
			if monde in [0,4,7]:
				ornements.jardin(self,p+Vector3(cote*.20,0,1.0),monde)
	ornements.entree(self,centre+Vector3(0,0,-taille.z*.5-1.2),monde)
	preload("res://scripts/presentation/decor_statique.gd").regrouper(self)
