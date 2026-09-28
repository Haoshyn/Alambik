extends Node

const ARENE := preload("res://scripts/presentation/arene_3d.gd")
const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")
const STATIQUE := preload("res://scripts/presentation/decor_statique.gd")
var _erreurs: Array[String] = []
var _dessins_max := 0
var _triangles_max := 0
var _export := ""

func _ready() -> void:
	_executer()

func _exiger(condition: bool, message: String) -> void:
	if not condition and message not in _erreurs: _erreurs.append(message)

func _executer() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Un profil APPDATA de verification isole est requis.")
		get_tree().quit(1)
		return
	var reglages := get_tree().root.get_node("ReglagesJoueur")
	reglages.sauvegarde_active = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--exporter="): _export = argument.trim_prefix("--exporter=")
	if not _export.is_empty(): DirAccess.make_dir_recursive_absolute(_export)
	var arene := ARENE.new()
	add_child(arene)
	for monde in 5:
		for forme in FormesSalles.PROFILS.size():
			var facteur: Vector2 = FormesSalles.PROFILS[forme]["taille"]
			var origine := Vector2(-167,83) if forme % 2 == 0 else Vector2.ZERO
			var limites := Rect2(origine, Reglages.ARENE_TAILLE * facteur)
			var contour := FormesSalles.contour(limites, forme)
			arene.construire(limites, Callable(), monde, contour, forme % TerrainsMondes.MURETS.size())
			await get_tree().process_frame
			_verifier_sol(arene.get_node("SolJouable"), contour)
			_verifier_matieres(arene.get_node("SolJouable"), monde, limites)
			_verifier_budget(arene)
			_exiger(arene.find_children("*", "CollisionObject3D", true, false).is_empty(), "Le decor ajoute une collision")
			_exiger(arene.find_children("SignatureMonde", "Node3D", true, false).size() == 1, "Signature absente ou dupliquee apres changement de salle")
			arene.avancer_ambiance(.5, false)
			var temps: float = arene.get("_temps")
			arene.avancer_ambiance(.5, true)
			_exiger(is_equal_approx(temps, float(arene.get("_temps"))), "Les effets reduits ne figent pas le decor")
			if forme == FormesSalles.indice(8,monde * Chapitres.CHAPITRES_PAR_MONDE,0,"grimoire") and not _export.is_empty(): await _exporter(arene, limites, monde)
		var empreintes: Array[int] = []
		for variante in [0, 1, 0]:
			arene.construire(Rect2(Vector2.ZERO, Reglages.ARENE_TAILLE), Callable(), monde, PackedVector2Array(), variante)
			await get_tree().process_frame
			empreintes.append(_empreinte_sol(arene.get_node("SolJouable")))
		_exiger(empreintes[0] != empreintes[1], "Le sol ne varie pas entre deux terrains")
		_exiger(empreintes[0] == empreintes[2], "Le sol change a chaque reconstruction du meme terrain")
		print("OK : decors du monde %d, trois matieres sur neuf contours, origines decalees, variantes stables et effets reduits." % (monde + 1))
	for monde in 5:
		for type: String in TerrainsMondes.TYPES_OBSTACLES:
			var taille := Vector3(1.3,0,.85)
			var obstacle := DECOR.obstacle(taille,1,monde,type)
			add_child(obstacle)
			for objet: MeshInstance3D in obstacle.find_children("*","MeshInstance3D",true,false):
				var transformation := obstacle.global_transform.affine_inverse() * objet.global_transform
				var boite := transformation * objet.get_aabb()
				_exiger(boite.position.x >= -taille.x*.5-.015 and boite.end.x <= taille.x*.5+.015 and boite.position.z >= -taille.z*.5-.015 and boite.end.z <= taille.z*.5+.015, "Ornement hors de l'emprise d'un obstacle : %d/%s" % [monde,type])
			obstacle.free()
	arene.free()
	for erreur in _erreurs: push_error(erreur)
	print("Decors : maximum %d maillages, %d triangles par salle (hors acteurs)." % [_dessins_max,_triangles_max])
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _verifier_sol(sol: Node3D, contour: PackedVector2Array) -> void:
	for objet: MeshInstance3D in sol.find_children("*","MeshInstance3D",true,false):
		_exiger(objet.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "Le regroupement reactive les ombres du sol")
		for index in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(index)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			for sommet in sommets:
				_exiger(sommet.y <= 0.0, "Le sol masque les ombres et effets au ras du sol")
				var point := Pont3D.vers_logique(sommet)
				if Geometry2D.is_point_in_polygon(point,contour): continue
				var proche := INF
				for i in contour.size(): proche = minf(proche,point.distance_to(Geometry2D.get_closest_point_to_segment(point,contour[i],contour[(i+1)%contour.size()])))
				_exiger(proche < .1, "Le dallage deborde du contour de collision")

func _verifier_budget(arene: Node3D) -> void:
	var objets := arene.find_children("*","MeshInstance3D",true,false)
	var triangles := 0
	for objet: MeshInstance3D in objets:
		for i in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(i)
			var indices: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX] if tableaux[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			triangles += (indices.size() if not indices.is_empty() else sommets.size()) / 3
	_dessins_max = maxi(_dessins_max, objets.size())
	_triangles_max = maxi(_triangles_max, triangles)
	_exiger(objets.size() <= 100, "Trop de maillages de decor pour le mobile")
	_exiger(triangles < 65000, "Budget de triangles de decor depasse")

func _empreinte_sol(sol: Node3D) -> int:
	var empreintes: Array[int] = []
	for objet: MeshInstance3D in sol.find_children("*","MeshInstance3D",true,false):
		for i in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(i)
			empreintes.append(hash(tableaux[Mesh.ARRAY_VERTEX]))
	return hash(empreintes)

func _verifier_matieres(sol: Node3D, monde: int, limites: Rect2) -> void:
	var ilots: Array = DecorsMondes.profil(monde)["ilots"]
	for matiere: Dictionary in ilots:
		var couleur := Color(str(matiere["sol"]))
		var palette := [couleur.darkened(.028), couleur, couleur.lightened(.035)]
		var aire := 0.0
		for objet: MeshInstance3D in sol.find_children("*","MeshInstance3D",true,false):
			var materiau := objet.material_override as StandardMaterial3D
			if materiau == null or materiau.albedo_color not in palette: continue
			for i in objet.mesh.get_surface_count():
				var tableaux := objet.mesh.surface_get_arrays(i)
				var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
				var indices: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX]
				for j in range(0, indices.size(), 3):
					var a := sommets[indices[j]]
					var b := sommets[indices[j+1]]
					var c := sommets[indices[j+2]]
					aire += (b-a).cross(c-a).length() * .5
		var taille := Pont3D.vers_monde(limites.size)
		_exiger(aire > taille.x * taille.z * .035, "Matiere absente ou trop petite : %d/%s" % [monde,matiere["nom"]])

func _exporter(arene: Node3D, limites: Rect2, monde: int) -> void:
	# Le rendu headless de Godot ne produit pas d'image. Ce GLB permet de juger
	# la geometrie reelle dans Blender ; ce n'est pas une capture du moteur.
	var obstacles := Node3D.new()
	arene.add_child(obstacles)
	for definition: Dictionary in TerrainsMondes.obstacles(8, monde * Chapitres.CHAPITRES_PAR_MONDE):
		var rect: Rect2 = definition["rect"]
		rect = Rect2(limites.position + rect.position * limites.size, rect.size * limites.size)
		var obstacle := DECOR.obstacle(Pont3D.vers_monde(rect.size), 1, monde, str(definition["type"]))
		obstacles.add_child(obstacle)
		obstacle.position = Pont3D.vers_monde(rect.get_center())
	STATIQUE.regrouper(obstacles)
	var ancien_chapitre := Jeu.chapitre
	var ancien_mode := Jeu.mode_run
	Jeu.chapitre = monde * Chapitres.CHAPITRES_PAR_MONDE
	Jeu.mode_run = "grimoire"
	var salle := preload("res://scripts/monde/salle.gd").new()
	add_child(salle)
	salle.numero = 8
	salle.limites = limites
	salle.set("_contour", FormesSalles.contour(limites,FormesSalles.indice(8,Jeu.chapitre,0,"grimoire")))
	var blocs: Array[Rect2] = []
	for definition: Dictionary in TerrainsMondes.obstacles(8,Jeu.chapitre):
		var rect: Rect2 = definition["rect"]
		blocs.append(Rect2(limites.position + rect.position * limites.size,rect.size * limites.size))
	salle.set("_obstacles", blocs)
	var terrain := preload("res://scripts/monde/terrain_elementaire.gd").new()
	salle.add_child(terrain)
	salle.set("_terrain",terrain)
	terrain.set_physics_process(false)
	terrain.configurer(salle)
	terrain.temps = TerrainsMondes.DELAI_ACTIVATION + TerrainsMondes.VENT_REPOS + TerrainsMondes.VENT_MONTEE
	var terrain_visible := preload("res://scripts/presentation/terrain_elementaire_3d.gd").new()
	terrain_visible.salle = salle
	arene.add_child(terrain_visible)
	terrain_visible.mettre_a_jour(0)
	Jeu.chapitre = ancien_chapitre
	Jeu.mode_run = ancien_mode
	await get_tree().process_frame
	var heros: Node3D = load(Visuels3D.HEROS_MODELE).instantiate()
	arene.add_child(heros)
	heros.position = Pont3D.vers_monde(limites.position + limites.size * Vector2(.52,.73))
	heros.scale = Vector3.ONE * Reglages.HEROS_ECHELLE
	var lecteur := heros.find_child("AnimationPlayer",true,false) as AnimationPlayer
	if lecteur != null and lecteur.has_animation("repos"):
		lecteur.play("repos")
		lecteur.seek(.2,true)
	for animation: Node in heros.find_children("*","AnimationPlayer",true,false): animation.free()
	var remplacements: Dictionary = {}
	for objet: MeshInstance3D in arene.find_children("*","MeshInstance3D",true,false):
		var mat := objet.material_override as ShaderMaterial
		if mat == null: continue
		remplacements[objet] = mat
		var remplacement := StandardMaterial3D.new()
		remplacement.albedo_color = mat.get_shader_parameter("teinte")
		remplacement.roughness = .38
		objet.material_override = remplacement
	var document := GLTFDocument.new()
	var etat := GLTFState.new()
	_exiger(document.append_from_scene(arene,etat) == OK, "Export de geometrie impossible")
	_exiger(document.write_to_filesystem(etat,_export.path_join("monde_%d.glb" % monde)) == OK, "Ecriture GLB impossible")
	for objet: MeshInstance3D in remplacements: objet.material_override = remplacements[objet]
	obstacles.free()
	heros.free()
	terrain_visible.free()
	salle.free()
