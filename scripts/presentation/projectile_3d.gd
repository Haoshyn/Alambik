extends "res://scripts/presentation/proxy_3d.gd"

static var _matieres := {}
var _ruban := ImmediateMesh.new()
var _matiere_ruban: StandardMaterial3D
var _matiere_coeur: ShaderMaterial
var _couleur := Color.WHITE

func preparer(cible: Node2D, _scene: PackedScene, type: String) -> void:
	logique = cible
	genre = type
	_couleur = logique.get("couleur")
	var hostile: bool = logique.get("hostile")
	if hostile:
		_couleur = Color("ff493a")
	var cle := _couleur.to_html()+str(hostile)
	if not _matieres.has(cle):
		var mat := ShaderMaterial.new()
		mat.shader = preload("res://shaders/trait_magique.gdshader")
		mat.set_shader_parameter("teinte",_couleur)
		mat.set_shader_parameter("hostile",hostile)
		var ruban := StandardMaterial3D.new()
		ruban.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ruban.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ruban.vertex_color_use_as_albedo = true
		ruban.cull_mode = BaseMaterial3D.CULL_DISABLED
		_matieres[cle] = [mat,ruban]
	_matiere_coeur = _matieres[cle][0]
	_matiere_ruban = _matieres[cle][1]
	modele = Node3D.new()
	add_child(modele)
	var coeur := MeshInstance3D.new()
	var plan := QuadMesh.new()
	plan.size = Vector2(0.52,0.62) if hostile else Vector2(0.42,0.56)
	coeur.mesh = plan
	coeur.rotation.x = -PI/2
	coeur.position.y = 0.10
	coeur.material_override = _matiere_coeur
	coeur.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	modele.add_child(coeur)
	var trainee := MeshInstance3D.new()
	trainee.mesh = _ruban
	trainee.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(trainee)
	logique.set_meta("visuel_3d",true)
	logique.queue_redraw()
	mettre_a_jour(0.0)

func mettre_a_jour(_delta: float) -> void:
	if not is_instance_valid(logique) or logique.is_queued_for_deletion():
		queue_free()
		return
	position = Pont3D.vers_monde(logique.global_position)
	visible = logique.is_visible_in_tree()
	var direction: Vector2 = logique.get("direction")
	modele.rotation.y = atan2(direction.x,direction.y)
	_matiere_coeur.set_shader_parameter("reduit",ReglagesJoueur.effets_reduits)
	_ruban.clear_surfaces()
	var points: Array[Vector2] = logique.get("_trainee")
	var nombre := mini(points.size(),3 if ReglagesJoueur.effets_reduits else 8)
	if nombre < 2: return
	_ruban.surface_begin(Mesh.PRIMITIVE_TRIANGLES,_matiere_ruban)
	for i in range(nombre-1):
		var a := Pont3D.vers_monde(points[i])-position+Vector3(0,0.09,0)
		var b := Pont3D.vers_monde(points[i+1])-position+Vector3(0,0.09,0)
		var cote := (b-a).cross(Vector3.UP).normalized()
		var debut := 1.0-float(i)/float(nombre-1)
		var fin := 1.0-float(i+1)/float(nombre-1)
		var sommets := [a+cote*0.085*debut,a-cote*0.085*debut,b+cote*0.085*fin,
			b+cote*0.085*fin,a-cote*0.085*debut,b-cote*0.085*fin]
		for j in 6:
			var alpha := debut if j in [0,1,4] else fin
			_ruban.surface_set_color(Color(_couleur.lightened(0.20),alpha*0.65))
			_ruban.surface_add_vertex(sommets[j])
	_ruban.surface_end()
