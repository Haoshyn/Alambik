extends Node

const ARENE := preload("res://scripts/presentation/arene_3d.gd")
const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")
const STATIQUE := preload("res://scripts/presentation/decor_statique.gd")
const ORNEMENTS := preload("res://scripts/presentation/ornements_monde.gd")
const RIVES := preload("res://scripts/presentation/decors_rives.gd")
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
	await _verifier_regroupement()
	_verifier_modeles_rives()
	var arene := ARENE.new()
	add_child(arene)
	for monde in 5:
		for forme in FormesSalles.PROFILS.size():
			var facteur: Vector2 = FormesSalles.PROFILS[forme]["taille"]
			var origine := Vector2(-167,83) if forme % 2 == 0 else Vector2.ZERO
			var limites := Rect2(origine, Reglages.ARENE_TAILLE * facteur)
			var contour := FormesSalles.contour(limites, forme)
			arene.construire(limites, Callable(), monde, contour, forme % TerrainsMondes.MURETS.size(), forme + 1)
			await get_tree().process_frame
			_verifier_sol(arene.get_node("SolJouable"), contour)
			_verifier_matieres(arene.get_node("SolJouable"), monde, contour)
			_verifier_rives(arene.get_node("AtelierDuMonde"), contour)
			_verifier_budget(arene)
			_exiger(arene.find_children("*", "CollisionObject3D", true, false).is_empty(), "Le decor ajoute une collision")
			_exiger(arene.find_children("SignatureMonde", "Node3D", true, false).size() == 1, "Signature absente ou dupliquee apres changement de salle")
			arene.avancer_ambiance(.5, false)
			var temps: float = arene.get("_temps")
			arene.avancer_ambiance(.5, true)
			_exiger(is_equal_approx(temps, float(arene.get("_temps"))), "Les effets reduits ne figent pas le decor")
		var chapitre := monde * Chapitres.CHAPITRES_PAR_MONDE
		var contours: Dictionary = {}
		var compositions: Dictionary = {}
		var compositions_rives: Dictionary = {}
		for numero in range(1, Reglages.SALLES_PAR_RUN + 1):
			var limites := Rect2(Vector2.ZERO, FormesSalles.taille(numero, chapitre, 0, "grimoire"))
			var contour := FormesSalles.contour_salle(limites, numero, chapitre, 0, "grimoire")
			var variante := TerrainsMondes.variante(numero, chapitre, 0)
			contours[hash(contour)] = true
			compositions[hash(DecorsMondes.composition_sol(monde, numero, variante))] = true
			compositions_rives[hash(DecorsMondes.composition_rives(monde, numero, variante))] = true
			_exiger(contour == FormesSalles.contour_salle(limites, numero, chapitre, 12345, "grimoire"), "Le contour change selon la graine de run")
			_exiger(not Geometry2D.triangulate_polygon(contour).is_empty(), "Contour procedural invalide")
			_exiger(FormesSalles.contient_disque(limites.position + limites.size * Vector2(.5, .85), contour, FormesSalles.MARGE_APPARITION), "Entree du heros fermee")
			_exiger(FormesSalles.contient_disque(limites.position + limites.size * Vector2(.5, .08), contour, FormesSalles.MARGE_APPARITION), "Acces au portail ferme")
			for definition: Dictionary in TerrainsMondes.obstacles(numero, chapitre):
				var rect: Rect2 = definition["rect"]
				rect = Rect2(limites.position + rect.position * limites.size, rect.size * limites.size)
				for point: Vector2 in [rect.position, rect.end, Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.end.y)]:
					_exiger(Geometry2D.is_point_in_polygon(point, contour), "Couvert hors du contour procedural")
			arene.construire(limites, Callable(), monde, contour, variante, numero)
			await get_tree().process_frame
			_verifier_sol(arene.get_node("SolJouable"), contour)
			_verifier_matieres(arene.get_node("SolJouable"), monde, contour)
			_verifier_rives(arene.get_node("AtelierDuMonde"), contour)
			_verifier_budget(arene)
			if not _export.is_empty():
				if numero == 8: await _exporter(arene, limites, monde, numero)
				elif monde == 0 and numero in [2, 5, 7, 9, 14]: await _exporter(arene, limites, monde, numero, "encre_etage_%d.glb" % numero)
		_exiger(contours.size() == Reglages.SALLES_PAR_RUN, "Deux etages ont le meme contour")
		_exiger(compositions.size() == Reglages.SALLES_PAR_RUN, "Deux etages ont la meme composition de sol")
		_exiger(compositions_rives.size() == Reglages.SALLES_PAR_RUN, "Deux etages ont les memes decors de rive")
		var empreintes: Array[int] = []
		for variante in [0, 1, 0]:
			arene.construire(Rect2(Vector2.ZERO, Reglages.ARENE_TAILLE), Callable(), monde, PackedVector2Array(), variante, 8)
			await get_tree().process_frame
			empreintes.append(_empreinte_sol(arene.get_node("SolJouable")))
		_exiger(empreintes[0] != empreintes[1], "Le sol ne varie pas entre deux terrains")
		_exiger(empreintes[0] == empreintes[2], "Le sol change a chaque reconstruction du meme terrain")
		print("OK : monde %d, enduit cire, decors en volume, neuf formes et vingt etages proceduraux, UV, stabilite et effets reduits." % (monde + 1))
	for mode: String in ["mine", "epreuves"]:
		var limites := Rect2(Vector2.ZERO, Reglages.ARENE_TAILLE)
		_exiger(FormesSalles.contour_salle(limites, 8, 0, 0, mode) == FormesSalles.contour(limites, 0), "Contour des modes annexes modifie")
	for monde in 5:
		for type: String in TerrainsMondes.TYPES_OBSTACLES:
			var taille := Vector3(1.3,0,.85)
			var obstacle := DECOR.obstacle(taille,1,monde,type)
			RIVES.habiller_couvert(obstacle,taille,monde,1,type)
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
				_exiger(proche < .1, "L'enduit deborde du contour de collision")

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

func _verifier_rives(decor: Node3D, contour_logique: PackedVector2Array) -> void:
	var contour := PackedVector2Array()
	for point in contour_logique:
		var position := Pont3D.vers_monde(point)
		contour.append(Vector2(position.x,position.z))
	var placements: Array = decor.get_meta("decors_rives", [])
	_exiger(placements.size() >= 4 and placements.size() <= 6, "Decors en volume absents ou excessifs")
	for placement: Dictionary in placements:
		var origine: Vector2 = placement["position"]
		var rayon := float(placement["rayon"])
		_exiger(not Geometry2D.is_point_in_polygon(origine, contour), "Un decor de rive est dans le passage")
		for i in contour.size():
			var distance := origine.distance_to(Geometry2D.get_closest_point_to_segment(origine,contour[i],contour[(i+1)%contour.size()]))
			_exiger(distance >= rayon+.10, "Un decor de rive deborde dans une alcove jouable")

func _verifier_modeles_rives() -> void:
	for monde in 5:
		for famille in 4:
			var modele := Node3D.new()
			add_child(modele)
			if famille == 3:
				modele.scale = Vector3.ONE*.67
				ORNEMENTS._repere(modele, monde)
			else:
				RIVES.construire(modele, monde, famille)
			var objets := modele.find_children("*", "MeshInstance3D", true, false)
			_exiger(not objets.is_empty(), "Modele de rive vide")
			var rayon := 1.40 if famille == 3 else 1.06
			for objet: MeshInstance3D in objets:
				var boite := objet.global_transform*objet.get_aabb()
				for x: float in [boite.position.x,boite.end.x]:
					for z: float in [boite.position.z,boite.end.z]:
						_exiger(Vector2(x,z).length() <= rayon+.02, "Modele hors de l'emprise de rive : %d/%d" % [monde,famille])
			modele.free()

func _empreinte_sol(sol: Node3D) -> int:
	var empreintes: Array[int] = []
	for objet: MeshInstance3D in sol.find_children("*","MeshInstance3D",true,false):
		for i in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(i)
			empreintes.append(hash(tableaux[Mesh.ARRAY_VERTEX]))
			empreintes.append(hash(tableaux[Mesh.ARRAY_TEX_UV]))
			empreintes.append(hash(tableaux[Mesh.ARRAY_COLOR]))
	return hash(empreintes)

func _verifier_matieres(sol: Node3D, monde: int, contour: PackedVector2Array) -> void:
	var fonds := 0
	var bordures := 0
	var aire := 0.0
	for objet: MeshInstance3D in sol.find_children("*","MeshInstance3D",true,false):
		var materiau := objet.material_override as StandardMaterial3D
		if materiau != null and materiau.resource_name == "BorduresEmail":
			bordures += 1
			_exiger(materiau.vertex_color_use_as_albedo and materiau.vertex_color_is_srgb, "La bordure perd ses couleurs")
		if materiau == null or materiau.resource_name != "Enduit_" + str(monde): continue
		fonds += 1
		_exiger(materiau.albedo_texture != null and materiau.albedo_texture.resource_path == str(DecorsMondes.profil(monde)["texture"]), "Texture du mauvais monde")
		_exiger(materiau.roughness >= .8, "L'enduit n'est pas sobre")
		# Le dallage multiplie suit l'espace monde, en dalles carrees a l'ecran.
		_exiger(materiau.detail_enabled and materiau.detail_albedo == DecorsMondes.DALLES and materiau.detail_blend_mode == BaseMaterial3D.BLEND_MODE_MUL, "Le sol perd son dallage")
		_exiger(materiau.uv2_world_triplanar and is_equal_approx(materiau.uv2_scale.z, materiau.uv2_scale.x * sin(deg_to_rad(Pont3D.INCLINAISON))), "Dalles deformees par l'anamorphose")
		_exiger(materiau.vertex_color_use_as_albedo and materiau.vertex_color_is_srgb, "Les zones d'enduit perdent leurs teintes")
		_exiger(materiau.albedo_texture.get_image().has_mipmaps(), "Texture sans mipmaps")
		for i in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(i)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX]
			var uv: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV]
			var couleurs: PackedColorArray = tableaux[Mesh.ARRAY_COLOR]
			_exiger(uv.size() == sommets.size(), "UV perdus pendant le regroupement")
			_exiger(couleurs.size() == sommets.size(), "Patine perdue pendant le regroupement")
			var minimum := Vector3.ONE
			var maximum := Vector3.ZERO
			for couleur in couleurs:
				var valeur := Vector3(couleur.r, couleur.g, couleur.b)
				minimum = minimum.min(valeur)
				maximum = maximum.max(valeur)
			_exiger(minimum.distance_to(maximum) > .07, "Le sol reste uniforme malgre les reprises d'enduit")
			for point in uv:
				_exiger(point.x >= 0.0 and point.x <= 1.0 and point.y >= 0.0 and point.y <= 1.0, "La texture du sol se repete")
			for j in range(0, indices.size(), 3):
				var a := sommets[indices[j]]
				var b := sommets[indices[j+1]]
				var c := sommets[indices[j+2]]
				aire += (b-a).cross(c-a).length() * .5
	var aire_contour := 0.0
	for i in contour.size():
		var a := Pont3D.vers_monde(contour[i])
		var b := Pont3D.vers_monde(contour[(i + 1) % contour.size()])
		aire_contour += Vector2(a.x, a.z).cross(Vector2(b.x, b.z))
	_exiger(fonds == 1 and aire > absf(aire_contour) * .5 * .82, "Le fond peint ne couvre pas la salle")
	_exiger(bordures == 1, "Bordure d'email absente ou non regroupee")
	_exiger(not sol.has_meta("ornements_sol") and sol.find_children("FresquesAlchimiques*", "MeshInstance3D", true, false).is_empty(), "Les pictogrammes retires recouvrent encore le sol")
	_exiger(sol.find_children("EclatsIncrustes*", "MeshInstance3D", true, false).is_empty(), "Les anciens eclats recouvrent l'enduit")

func _verifier_regroupement() -> void:
	# Deux peintures avec les memes autres reglages doivent rester deux dessins.
	var parent := Node3D.new()
	add_child(parent)
	var uv := PackedVector2Array([Vector2.ZERO, Vector2.RIGHT, Vector2.ONE])
	var couleurs := PackedColorArray([Color(.7,.7,.7), Color.WHITE, Color(.9,.8,.7)])
	var maillage := SurfaceTool.new()
	maillage.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 3:
		maillage.set_normal(Vector3.UP)
		maillage.set_uv(uv[i])
		maillage.set_uv2(uv[i] * .5)
		maillage.set_color(couleurs[i])
		maillage.add_vertex(Vector3(uv[i].x, 0, uv[i].y))
	var forme := maillage.commit()
	couleurs = forme.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
	var matiere := StandardMaterial3D.new()
	matiere.albedo_texture = DecorsMondes.matiere_sol(0).albedo_texture
	matiere.vertex_color_use_as_albedo = true
	var matiere_autre := matiere.duplicate() as StandardMaterial3D
	matiere_autre.albedo_texture = load("res://assets/visual/terrains/eau.png") as Texture2D
	var attendus: Dictionary = {}
	for i in 3:
		var objet := MeshInstance3D.new()
		objet.mesh = forme
		objet.material_override = matiere if i < 2 else matiere_autre
		objet.position = Vector3(i * 2, .4, 0)
		objet.rotation.y = i * .3
		parent.add_child(objet)
		var mat := objet.material_override as StandardMaterial3D
		var cle := mat.albedo_texture.resource_path
		var points: PackedVector3Array = attendus.get(cle, PackedVector3Array())
		var source: PackedVector3Array = forme.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		for point in source: points.append(objet.transform * point)
		attendus[cle] = points
	STATIQUE.regrouper(parent)
	await get_tree().process_frame
	var objets := parent.find_children("*", "MeshInstance3D", true, false)
	_exiger(objets.size() == 2, "Deux textures distinctes fusionnent ou des matieres identiques restent separees")
	for objet: MeshInstance3D in objets:
		var mat := objet.material_override as StandardMaterial3D
		var tableaux := objet.mesh.surface_get_arrays(0)
		var points: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
		var reference: PackedVector3Array = attendus[mat.albedo_texture.resource_path]
		var uv_groupes: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV]
		var uv2_groupes: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV2]
		var couleurs_groupees: PackedColorArray = tableaux[Mesh.ARRAY_COLOR]
		_exiger(points.size() == reference.size(), "Sommets perdus dans le regroupement")
		for i in mini(points.size(), reference.size()):
			_exiger(points[i].distance_to(reference[i]) < .001, "Transformation perdue dans le regroupement")
			_exiger(uv_groupes[i].is_equal_approx(uv[i % 3]) and uv2_groupes[i].is_equal_approx(uv[i % 3] * .5), "Coordonnees de peinture perdues")
			_exiger(couleurs_groupees[i].is_equal_approx(couleurs[i % 3]), "Modelage peint perdu")
	parent.free()

func _exporter(arene: Node3D, limites: Rect2, monde: int, numero: int, nom_fichier := "") -> void:
	# Le rendu headless de Godot ne produit pas d'image. Ce GLB permet de juger
	# la geometrie reelle dans Blender ; ce n'est pas une capture du moteur.
	var obstacles := Node3D.new()
	arene.add_child(obstacles)
	for definition: Dictionary in TerrainsMondes.obstacles(numero, monde * Chapitres.CHAPITRES_PAR_MONDE):
		var rect: Rect2 = definition["rect"]
		rect = Rect2(limites.position + rect.position * limites.size, rect.size * limites.size)
		var obstacle := DECOR.obstacle(Pont3D.vers_monde(rect.size), 1, monde, str(definition["type"]))
		RIVES.habiller_couvert(obstacle,Pont3D.vers_monde(rect.size),monde,1,str(definition["type"]))
		obstacles.add_child(obstacle)
		obstacle.position = Pont3D.vers_monde(rect.get_center())
	STATIQUE.regrouper(obstacles)
	var ancien_chapitre := Jeu.chapitre
	var ancien_mode := Jeu.mode_run
	Jeu.chapitre = monde * Chapitres.CHAPITRES_PAR_MONDE
	Jeu.mode_run = "grimoire"
	var salle := preload("res://scripts/monde/salle.gd").new()
	add_child(salle)
	salle.numero = numero
	salle.limites = limites
	salle.set("_contour", FormesSalles.contour_salle(limites, numero, Jeu.chapitre, 0, "grimoire"))
	var blocs: Array[Rect2] = []
	for definition: Dictionary in TerrainsMondes.obstacles(numero,Jeu.chapitre):
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
	var maillages_srgb: Dictionary = {}
	for objet: MeshInstance3D in arene.find_children("*","MeshInstance3D",true,false):
		var standard := objet.material_override as StandardMaterial3D
		if standard != null and standard.vertex_color_use_as_albedo and standard.vertex_color_is_srgb:
			# COLOR_0 du glTF est lineaire ; le drapeau sRGB de Godot n'est pas exporte.
			maillages_srgb[objet] = objet.mesh
			remplacements[objet] = standard
			objet.mesh = _maillage_lineaire(objet.mesh)
			var copie := standard.duplicate() as StandardMaterial3D
			copie.vertex_color_is_srgb = false
			objet.material_override = copie
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
	var nom := "monde_%d.glb" % monde if nom_fichier.is_empty() else nom_fichier
	_exiger(document.write_to_filesystem(etat,_export.path_join(nom)) == OK, "Ecriture GLB impossible")
	for objet: MeshInstance3D in maillages_srgb: objet.mesh = maillages_srgb[objet]
	for objet: MeshInstance3D in remplacements: objet.material_override = remplacements[objet]
	obstacles.free()
	heros.free()
	terrain_visible.free()
	salle.free()

func _maillage_lineaire(source: Mesh) -> ArrayMesh:
	var resultat := ArrayMesh.new()
	for i in source.get_surface_count():
		var tableaux := source.surface_get_arrays(i)
		if tableaux[Mesh.ARRAY_COLOR] != null:
			var couleurs: PackedColorArray = tableaux[Mesh.ARRAY_COLOR]
			for j in couleurs.size(): couleurs[j] = couleurs[j].srgb_to_linear()
			tableaux[Mesh.ARRAY_COLOR] = couleurs
		resultat.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, tableaux)
	return resultat
