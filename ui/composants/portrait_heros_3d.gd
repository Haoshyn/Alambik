extends SubViewportContainer

var _vue: SubViewport
var _camera: Camera3D
var _dimensions := Vector3.ONE

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true
	_vue = SubViewport.new()
	_vue.transparent_bg = true
	_vue.own_world_3d = true
	_vue.handle_input_locally = false
	_vue.msaa_3d = Viewport.MSAA_2X
	add_child(_vue)
	var monde := Node3D.new()
	_vue.add_child(monde)
	var modele := (load(Visuels3D.HEROS_MODELE) as PackedScene).instantiate() as Node3D
	monde.add_child(modele)
	var lecteur := modele.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if lecteur != null and lecteur.has_animation("repos"):
		lecteur.animation_finished.connect(func(nom: StringName):
			if nom == &"repos": lecteur.play("repos"))
		lecteur.play("repos")
		lecteur.advance(0.0)
	var limites := AABB()
	var premiere := true
	for noeud: Node in modele.find_children("*", "MeshInstance3D", true, false):
		var mesh := noeud as MeshInstance3D
		var boite: AABB = mesh.global_transform * mesh.get_aabb()
		limites = boite if premiere else limites.merge(boite)
		premiere = false
	_dimensions = limites.size
	modele.position -= limites.get_center()
	preload("res://scripts/presentation/materiaux_apprenti.gd").appliquer(modele)
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.position = Vector3(0, _dimensions.y * 0.04, maxf(_dimensions.length() * 2.0, 5.0))
	monde.add_child(_camera)
	_camera.look_at(Vector3.ZERO)
	_camera.current = true
	var environnement := WorldEnvironment.new()
	var ambiance := Environment.new()
	ambiance.background_mode = Environment.BG_CLEAR_COLOR
	ambiance.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	ambiance.ambient_light_color = Color("dbe1f5")
	ambiance.ambient_light_energy = 0.7
	environnement.environment = ambiance
	monde.add_child(environnement)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-35, -30, 0)
	lumiere.light_color = Color("f6edff")
	lumiere.light_energy = 1.15
	monde.add_child(lumiere)
	resized.connect(_cadrer)
	visibility_changed.connect(_actualiser_visibilite)
	_cadrer()
	_actualiser_visibilite()

func _cadrer() -> void:
	if _camera == null: return
	var ratio := maxf(size.x / maxf(size.y, 1.0), 0.1)
	# KEEP_HEIGHT conserve le corps entier, y compris dans une zone tres etroite.
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.size = maxf(_dimensions.y, _dimensions.x / ratio) * 1.16

func _actualiser_visibilite() -> void:
	if _vue == null: return
	_vue.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE if is_visible_in_tree() else SubViewport.UPDATE_DISABLED
	_vue.process_mode = Node.PROCESS_MODE_INHERIT if is_visible_in_tree() else Node.PROCESS_MODE_DISABLED
