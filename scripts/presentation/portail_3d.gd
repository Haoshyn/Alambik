extends Node3D

var _matiere: ShaderMaterial
var _temps := 0.0
var _eclats: MultiMesh

func _ready() -> void:
	var voile := MeshInstance3D.new()
	var plan := QuadMesh.new()
	plan.size = Vector2(1.12,1.54)
	voile.mesh = plan
	voile.position = Vector3(0,0.99,0.025)
	_matiere = ShaderMaterial.new()
	_matiere.shader = preload("res://shaders/portail_azur.gdshader")
	voile.material_override = _matiere
	voile.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(voile)
	_eclats = MultiMesh.new()
	_eclats.transform_format = MultiMesh.TRANSFORM_3D
	var grain := SphereMesh.new()
	grain.radius = 0.018
	grain.height = 0.036
	grain.radial_segments = 6
	grain.rings = 3
	_eclats.mesh = grain
	_eclats.instance_count = 12
	var particules := MultiMeshInstance3D.new()
	particules.multimesh = _eclats
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("abeced")
	particules.material_override = mat
	particules.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(particules)

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	_temps += delta * (0.12 if ReglagesJoueur.effets_reduits else 1.0)
	_matiere.set_shader_parameter("mouvement",0.12 if ReglagesJoueur.effets_reduits else 1.0)
	_eclats.visible_instance_count = 4 if ReglagesJoueur.effets_reduits else 12
	for i in _eclats.visible_instance_count:
		var phase := fposmod(_temps*0.18+float(i)/12.0,1.0)
		var p := Vector3(sin(float(i)*2.4)*0.46,0.2+phase*1.2,0.14)
		_eclats.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*sin(phase*PI)),p))

