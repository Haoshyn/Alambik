extends Node3D

const PROXY := preload("res://scripts/presentation/proxy_3d.gd")
const ARENE := preload("res://scripts/presentation/arene_3d.gd")
var camera: Camera3D
var salle: Node2D
var heros: Node2D
var _arene: Node3D
var _proxies := {}
var _scenes := {}
var _materiaux := {}
var _numero := -1
var _limites := Rect2()
var _portail: Node3D
var _obstacles: Node3D
var _lumiere: DirectionalLight3D

func _ready() -> void:
	process_priority = 100
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	camera = Camera3D.new()
	camera.current = true
	add_child(camera)
	_lumiere = DirectionalLight3D.new()
	_lumiere.rotation_degrees = Vector3(-62,-32,0)
	_lumiere.light_color = Color("fff1d6")
	_lumiere.light_energy = 0.7
	_lumiere.directional_shadow_max_distance = 65.0
	add_child(_lumiere)
	var environnement := WorldEnvironment.new()
	environnement.environment = Environment.new()
	environnement.environment.background_mode = Environment.BG_COLOR
	environnement.environment.background_color = Color("648b8d")
	environnement.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environnement.environment.ambient_light_color = Color("a6b5d2")
	environnement.environment.ambient_light_energy = 0.3
	add_child(environnement)
	_arene = Node3D.new()
	_arene.set_script(ARENE)
	add_child(_arene)
	_obstacles = Node3D.new()
	add_child(_obstacles)

func charger(chemin: String) -> PackedScene:
	if not _scenes.has(chemin):
		_scenes[chemin] = load(chemin)
	return _scenes[chemin]

func relier(salle_: Node2D, heros_: Node2D, fond: Node2D) -> void:
	salle = salle_
	heros = heros_
	fond.set_meta("visuel_3d", true)
	fond.queue_redraw()
	salle.set_meta("visuel_3d", true)
	salle.queue_redraw()
	var effets := Node3D.new()
	effets.set_script(load("res://scripts/presentation/effets_3d.gd"))
	add_child(effets)
	effets.relier(salle.get("effets"))
	# node_added precede _ready : l'inscription differee lit les donnees configurees.
	get_tree().node_added.connect(_noeud_ajoute)
	_inscrire(heros)
	for enfant in salle.get_children():
		_inscrire(enfant)

func _noeud_ajoute(noeud: Node) -> void:
	if noeud is Node2D and (noeud.get_parent() == salle or noeud is Gardien):
		call_deferred("_inscrire", noeud)

func _inscrire(noeud: Node) -> void:
	if not is_instance_valid(noeud) or noeud.is_queued_for_deletion() or _proxies.has(noeud.get_instance_id()):
		return
	var chemin := ""
	var genre := ""
	if noeud == heros:
		chemin = "res://assets/3d/characters/heros.glb"
		genre = "heros"
	elif noeud.is_in_group("ennemis"):
		chemin = Visuels3D.chemin_ennemi(noeud.get("donnees"))
		genre = "ennemi"
	elif noeud is Area2D and noeud.get_script() != null and noeud.get_script().resource_path == "res://scripts/projectile.gd":
		chemin = "res://assets/3d/projectiles/orbe.glb"
		genre = "projectile"
	elif noeud is Gardien:
		chemin = "res://assets/3d/characters/gardien.glb"
		genre = "gardien"
	if chemin.is_empty():
		return
	var proxy := Node3D.new()
	proxy.set_script(PROXY)
	add_child(proxy)
	proxy.preparer(noeud, charger(chemin), genre)
	if genre == "projectile":
		var couleur: Color = noeud.get("couleur")
		var cle := couleur.to_html()
		if not _materiaux.has(cle):
			var mat := StandardMaterial3D.new()
			mat.albedo_color = couleur.lightened(0.15)
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			_materiaux[cle] = mat
		for mesh in proxy.find_children("*", "MeshInstance3D", true, false):
			mesh.material_override = _materiaux[cle]
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var id := noeud.get_instance_id()
	_proxies[id] = proxy
	noeud.tree_exiting.connect(func():
		_proxies.erase(id)
		if is_instance_valid(proxy):
			proxy.queue_free())

func _process(delta: float) -> void:
	if not is_instance_valid(salle):
		return
	Pont3D.cadrer(camera,get_viewport().get_visible_rect().size,get_viewport().canvas_transform)
	_lumiere.shadow_enabled = not ReglagesJoueur.effets_reduits and (OS.get_name() != "Android" or Visuels3D.OMBRES_ANDROID)
	var limites: Rect2 = salle.get("limites")
	var numero: int = salle.get("numero")
	if limites != _limites or numero != _numero:
		_limites = limites
		_numero = numero
		_arene.construire(limites,charger)
		_reconstruire_obstacles()
	for proxy in _proxies.values():
		if is_instance_valid(proxy):
			proxy.mettre_a_jour(delta)
	if salle.portail_ouvert():
		if not is_instance_valid(_portail):
			_portail = charger("res://assets/3d/environment/portail.glb").instantiate()
			add_child(_portail)
		_portail.position = Pont3D.vers_monde(salle.position_portail())
		_portail.visible = true
	elif is_instance_valid(_portail):
		_portail.visible = false

func _reconstruire_obstacles() -> void:
	for enfant in _obstacles.get_children():
		enfant.queue_free()
	var index := 0
	for rect in salle.obstacles():
		var obstacle := charger("res://assets/3d/props/obstacle_%d.glb" % ((_numero+index)%3)).instantiate() as Node3D
		_obstacles.add_child(obstacle)
		obstacle.position = Pont3D.vers_monde(rect.get_center())
		var taille := Pont3D.vers_monde(rect.size)
		# La base du mesh couvre le rectangle physique, sans agrandir la hitbox.
		obstacle.scale = Vector3(taille.x/.95, minf(.85,taille.x), taille.z/.45)
		index += 1
