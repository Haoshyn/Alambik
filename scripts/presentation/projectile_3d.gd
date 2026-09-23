extends "res://scripts/presentation/proxy_3d.gd"

static var _matieres := {}
var _ruban := ImmediateMesh.new()
var _matiere_ruban: StandardMaterial3D
var _matiere_coeur: ShaderMaterial
var _couleur := Color.WHITE
var _hostile := false
var _aiguille := false
var _familier := false
var _tourbillon: Node3D
var _rotation_tourbillon := 0.0
static var _perle: SphereMesh

func preparer(cible: Node2D, _scene: PackedScene, type: String) -> void:
	logique = cible
	genre = type
	_couleur = logique.get("couleur")
	var hostile: bool = logique.get("hostile")
	_hostile = hostile
	var tir: Tir = logique.get("tir")
	if hostile:
		_couleur = {"trait": Color("ff5848"), "aiguille": Color("ff697d"),
			"eclat": Color("ffac56"), "lame": Color("f66aa9"),
			"vrille": Color("ff725c")}.get(tir.silhouette, Color("ff5848"))
	_familier = "trait_familier" in tir.drapeaux
	_aiguille = not hostile and tir.arme == "veloce"
	if not hostile:
		_couleur = {"standard": Color("c5a1ff"), "veloce": Color("e6ff9c"), "lourd": Color("ffbf74"), "chercheur": Color("c2a5ff"), "explosif": Color("ff8b60")}.get(tir.arme, _couleur)
		if _familier:
			_couleur = Color("66dfd3")
		if "trait_orbe" in tir.drapeaux:
			_couleur = Color("e6b3ff")
	var cle := _couleur.to_html()+str(hostile)+tir.arme
	if not _matieres.has(cle):
		var mat := ShaderMaterial.new()
		mat.shader = preload("res://shaders/trait_magique.gdshader") if hostile else preload("res://shaders/perle_magique.gdshader")
		mat.set_shader_parameter("teinte",_couleur)
		if hostile:
			mat.set_shader_parameter("hostile",true)
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
	if hostile:
		var plan := QuadMesh.new()
		plan.size = Vector2(0.52,0.62)
		coeur.mesh = plan
		coeur.rotation.x = -PI/2
	coeur.position.y = 0.10
	coeur.material_override = _matiere_coeur
	coeur.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	modele.add_child(coeur)
	if hostile and tir.silhouette != "trait":
		coeur.visible = false
		_tourbillon = preload("res://scripts/presentation/formes_projectiles_hostiles.gd").construire(tir.silhouette, _couleur)
		modele.add_child(_tourbillon)
	if not hostile:
		# Une vraie silhouette volumique evite de voir le support rectangulaire
		# des anciens quads depuis la camera plongeante du telephone.
		if _perle == null:
			_perle = SphereMesh.new()
			_perle.radius = 1.0
			_perle.height = 2.0
			_perle.radial_segments = 16
			_perle.rings = 8
		coeur.mesh = _perle
		coeur.rotation = Vector3.ZERO
		coeur.scale = {"standard":Vector3(.14,.14,.20),"veloce":Vector3(.13,.13,.36),"lourd":Vector3(.19,.17,.26),"chercheur":Vector3(.17,.17,.17),"explosif":Vector3(.22,.22,.22)}.get(tir.arme,Vector3.ONE*.14)
		coeur.position.y = coeur.scale.y + .025
		if _familier:
			coeur.scale = Vector3.ONE * .115
			coeur.position.y = .14
		if "trait_orbe" in tir.drapeaux:
			coeur.scale = Vector3.ONE * 0.19
			coeur.position.y = 0.24
		if _familier:
			var anneau := TorusMesh.new()
			anneau.inner_radius = .14
			anneau.outer_radius = .18
			anneau.rings = 16
			anneau.ring_segments = 6
			var halo := MeshInstance3D.new()
			halo.mesh = anneau
			halo.material_override = _matiere_coeur
			halo.position.y = .14
			halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			modele.add_child(halo)
		else:
			for i in 2:
				var perle := MeshInstance3D.new()
				perle.mesh = _perle
				perle.material_override = _matiere_coeur
				perle.scale = coeur.scale * (0.48 if i == 0 else 0.24)
				perle.position = Vector3(0,coeur.position.y,-coeur.scale.z*(1.25+i*.7))
				perle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				modele.add_child(perle)
	if hostile or _aiguille:
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
	var points: Array[Vector2] = logique.get("_trainee")
	if points.size() > 1 and points[0].distance_squared_to(points[1]) > 0.01:
		direction = points[1].direction_to(points[0])
	modele.rotation.y = atan2(direction.x,direction.y)
	if _tourbillon != null:
		if not ReglagesJoueur.effets_reduits:
			_rotation_tourbillon += _delta * (9.0 if str(logique.tir.silhouette) == "vrille" else 4.0)
		_tourbillon.rotation.y = _rotation_tourbillon if str(logique.tir.silhouette) in ["vrille", "lame", "eclat"] else 0.0
	_ruban.clear_surfaces()
	if not _hostile:
		for index in range(1, modele.get_child_count()):
			modele.get_child(index).visible = not ReglagesJoueur.effets_reduits
		if not _aiguille:
			return
	else:
		_matiere_coeur.set_shader_parameter("reduit",ReglagesJoueur.effets_reduits)
	# Le ruban continu garde l'aiguille lisible entre deux positions rapides.
	var nombre := mini(points.size(),3 if ReglagesJoueur.effets_reduits else 8)
	if nombre < 2: return
	_ruban.surface_begin(Mesh.PRIMITIVE_TRIANGLES,_matiere_ruban)
	for i in range(nombre-1):
		var a := Pont3D.vers_monde(points[i])-position+Vector3(0,0.09,0)
		var b := Pont3D.vers_monde(points[i+1])-position+Vector3(0,0.09,0)
		var cote := (b-a).cross(Vector3.UP).normalized()
		var debut := 1.0-float(i)/float(nombre-1)
		var fin := 1.0-float(i+1)/float(nombre-1)
		var largeur := 0.11 if _hostile and str(logique.tir.silhouette) in ["eclat", "vrille"] else 0.075
		var sommets := [a+cote*largeur*debut,a-cote*largeur*debut,b+cote*largeur*fin,
			b+cote*largeur*fin,a-cote*largeur*debut,b-cote*largeur*fin]
		for j in 6:
			var alpha := debut if j in [0,1,4] else fin
			_ruban.surface_set_color(Color(_couleur.lightened(0.20),alpha*0.65))
			_ruban.surface_add_vertex(sommets[j])
	_ruban.surface_end()
