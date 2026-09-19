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

func construire(limites: Rect2, _charger: Callable, monde := 0, contour := PackedVector2Array(), variante := 0) -> void:
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
	var numero_segment := 0
	for i in contour.size():
		var a := Pont3D.vers_monde(contour[i])
		var b := Pont3D.vers_monde(contour[(i+1)%contour.size()])
		var longueur := a.distance_to(b)
		var angle := -atan2(b.z-a.z,b.x-a.x)
		# Meme sans muret, une tranche et un rebord rendent la limite lisible.
		var tranche := bloc((a+b)*.5+Vector3(0,-.24,0),Vector3(longueur+.10,.48,.22),ambiance[2].darkened(.18))
		tranche.rotation.y = angle
		var rebord := bloc((a+b)*.5+Vector3(0,.015,0),Vector3(longueur+.10,.04,.16),ambiance[2])
		rebord.rotation.y = angle
		var morceaux := maxi(1, ceili(longueur / 2.1))
		for j in morceaux:
			var visible_ := TerrainsMondes.muret_visible(variante, numero_segment)
			numero_segment += 1
			if not visible_: continue
			var position_bord := a.lerp(b, (float(j)+.5)/morceaux)
			var bord := bloc(position_bord+Vector3(0,.18,0),Vector3(longueur/morceaux-.08,.36,.24),ambiance[2])
			bord.rotation.y = angle
			var ceramique := bloc(position_bord+Vector3(0,.39,0),Vector3(longueur/morceaux-.06,.06,.28),DecorsMondes.couleur(monde,"accent"))
			ceramique.rotation.y = angle
	# Les ornements restent hors de la surface de collision, meme dans les retraits.
	var ornements := preload("res://scripts/presentation/ornements_monde.gd")
	for cote in [-1.0,1.0]:
		for i in range(3 + variante % 3):
			var nombre := 3 + variante % 3
			var p := centre+Vector3(cote*(taille.x/2+.85),0,lerpf(-taille.z*.40,taille.z*.40,float(i)/maxi(1,nombre-1)))
			if monde == 1 or (monde in [3,2] and (i + variante) % 3 == 0):
				ornements.jardin(self,p,monde)
			else:
				ornements.pilier(self,p,monde)
			if monde == 1 and i % 2 == 0:
				ornements.jardin(self,p+Vector3(cote*.35,0,1.15),monde)
	ornements.abords(self, centre, taille, monde, variante)
	ornements.entree(self,centre+Vector3(0,0,-taille.z*.5-1.2),monde)
	preload("res://scripts/presentation/decor_statique.gd").regrouper(self)
