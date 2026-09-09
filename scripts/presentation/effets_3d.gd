extends Node3D

var source: Node2D
var _particules: MultiMesh
var _lignes := ImmediateMesh.new()
var _mat := StandardMaterial3D.new()

func _ready() -> void:
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.vertex_color_use_as_albedo = true
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.no_depth_test = true
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 6
	mesh.rings = 3
	_particules = MultiMesh.new()
	_particules.transform_format = MultiMesh.TRANSFORM_3D
	_particules.use_colors = true
	_particules.mesh = mesh
	_particules.instance_count = Visuels3D.PARTICULES_MAX
	_particules.visible_instance_count = 0
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = _particules
	instance.material_override = _mat
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)
	var lignes := MeshInstance3D.new()
	lignes.mesh = _lignes
	lignes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(lignes)

func relier(noeud: Node2D) -> void:
	source = noeud
	source.set_meta("visuel_3d",true)

func _process(_delta: float) -> void:
	if not is_instance_valid(source):
		return
	var particules: Array = source.get("_particules")
	var nombre := mini(particules.size(),Visuels3D.PARTICULES_REDUITES if ReglagesJoueur.effets_reduits else Visuels3D.PARTICULES_MAX)
	_particules.visible_instance_count = nombre
	for i in nombre:
		var p: Dictionary = particules[i]
		var fraction := clampf(float(p["vie"])/float(p["vie_max"]),0,1)
		var taille := maxf(0.015,float(p["taille"])*Pont3D.ECHELLE*fraction)
		var couleur: Color = p["couleur"]
		_particules.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*taille),Pont3D.vers_monde(p["position"])))
		_particules.set_instance_color(i,Color(couleur,fraction))
	_lignes.clear_surfaces()
	var ondes: Array = source.get("_ondes")
	var arcs: Array = source.get("_arcs")
	if ondes.is_empty() and arcs.is_empty():
		return
	_lignes.surface_begin(Mesh.PRIMITIVE_LINES,_mat)
	for onde in ondes:
		var t := 1.0-float(onde["vie"])/float(onde["vie_max"])
		var couleur: Color = onde["couleur"]
		_lignes.surface_set_color(Color(couleur,(1.0-t)*0.7))
		var centre: Vector2 = onde["position"]
		var rayon := float(onde["rayon"])*(0.3+t)
		for i in 32:
			_lignes.surface_add_vertex(Pont3D.vers_monde(centre+Vector2.RIGHT.rotated(TAU*i/32)*rayon))
			_lignes.surface_add_vertex(Pont3D.vers_monde(centre+Vector2.RIGHT.rotated(TAU*(i+1)/32)*rayon))
	for arc in arcs:
		var couleur: Color = arc["couleur"]
		_lignes.surface_set_color(Color(couleur,float(arc["vie"])/float(arc["vie_max"])))
		_lignes.surface_add_vertex(Pont3D.vers_monde(arc["depart"]))
		_lignes.surface_add_vertex(Pont3D.vers_monde(arc["arrivee"]))
	_lignes.surface_end()
