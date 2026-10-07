extends SceneTree

const MODELE := preload("res://scripts/presentation/familier_tireur_3d.gd")
const MODELES := preload("res://scripts/presentation/modeles_familiers_3d.gd")
const LOGIQUE := preload("res://scripts/combat/familier.gd")
const TRIANGLES_MAX := 12000
const SURFACES_MAX := 18

var _erreurs: Array[String] = []
var _controles := 0
var _export := ""
var _scene: Node3D
var _galerie: Node3D
var _galerie_repos: Node3D
var _legendes: Array[Dictionary] = []
var _legendes_repos: Array[Dictionary] = []
var _triangles_max := 0
var _surfaces_max := 0
var _hauteurs_min: Dictionary = {}

func _init() -> void:
	_executer.call_deferred()

func _executer() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Un profil de verification isole est requis.")
		quit(1)
		return
	var reglages := root.get_node("ReglagesJoueur")
	reglages.sauvegarde_active = false
	reglages.volume_musique = 0.0
	reglages.volume_effets = 0.0
	root.get_node("Sons").appliquer_reglages()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--exporter="):
			_export = argument.trim_prefix("--exporter=")
	_scene = Node3D.new()
	_scene.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(_scene)
	_galerie = Node3D.new()
	_scene.add_child(_galerie)
	_galerie_repos = Node3D.new()
	_scene.add_child(_galerie_repos)
	var signatures: Array[int] = []
	var index := 0
	for id: String in CatalogueFamiliers.TYPES:
		var modele := MODELE.new()
		modele.configurer(id)
		_scene.add_child(modele)
		_exiger(modele.id == id, "Identite ignoree : " + id)
		_verifier_budget(modele, id)
		_verifier_collisions(modele, id)
		modele.animer(0.0, true, Vector2.ZERO)
		var signature := _signature_geometrie(modele)
		_exiger(signature not in signatures, "Silhouette partagee par deux familiers : " + id)
		signatures.append(signature)
		_verifier_animations(modele, id)
		if not _export.is_empty():
			_ajouter_vues(id, index)
		modele.free()
		index += 1
	await _verifier_reconfiguration()
	await _verifier_suivi(reglages)
	if not _export.is_empty():
		_exporter()
	_scene.free()
	root.get_node("Sons").arreter()
	for erreur: String in _erreurs:
		push_error(erreur)
	print("Familiers : %d controles, %d erreurs ; maximum %d triangles et %d surfaces." % [
		_controles, _erreurs.size(), _triangles_max, _surfaces_max])
	for id: String in _hauteurs_min:
		print("Appui au sol %s : point le plus bas %.4f m." % [id, float(_hauteurs_min[id])])
	quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition and message not in _erreurs:
		_erreurs.append(message)

func _verifier_budget(modele: Node3D, id: String) -> void:
	var triangles := 0
	var surfaces := 0
	for objet: MeshInstance3D in modele.find_children("*", "MeshInstance3D", true, false):
		_exiger(objet.mesh != null, "Maillage absent : " + id)
		if objet.mesh == null:
			continue
		surfaces += objet.mesh.get_surface_count()
		for surface in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(surface)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX] if tableaux[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			triangles += int((indices.size() if not indices.is_empty() else sommets.size()) / 3)
			var sommets_finis := true
			for sommet in sommets:
				if not sommet.is_finite():
					sommets_finis = false
			_exiger(sommets_finis, "Geometrie non finie : " + id)
	_triangles_max = maxi(_triangles_max, triangles)
	_surfaces_max = maxi(_surfaces_max, surfaces)
	_exiger(triangles > 0 and surfaces > 0, "Silhouette vide : " + id)
	_exiger(triangles <= TRIANGLES_MAX, "Budget de geometrie depasse : %s (%d)" % [id, triangles])
	_exiger(surfaces <= SURFACES_MAX, "Budget de surfaces depasse : %s (%d)" % [id, surfaces])
	print("OK : familier %s, %d triangles, %d surfaces." % [id, triangles, surfaces])

func _verifier_collisions(modele: Node3D, id: String) -> void:
	# Le familier visuel ne doit pas remplacer le rayon utilise par la simulation.
	var collisions := 0
	for objet in modele.find_children("*", "", true, false):
		if objet is CollisionObject2D or objet is CollisionObject3D \
			or objet is CollisionShape2D or objet is CollisionShape3D \
			or objet is CollisionPolygon2D or objet is CollisionPolygon3D:
			collisions += 1
	_exiger(collisions == 0, "Une collision est introduite par la presentation : " + id)

func _verifier_animations(modele: Node3D, id: String) -> void:
	var maillages := _maillages(modele)
	for reduit in [false, true]:
		modele.animer(1.0, reduit, Vector2.ZERO)
		var repos := _poses(modele)
		for image in 120:
			modele.animer(1.0 / 60.0, reduit, Vector2.ZERO)
			_verifier_poses_finies(modele, id)
			_verifier_appuis_sol(modele, id)
			if reduit:
				_exiger(not _pose_changee(modele, repos), "Oscillation au repos en effets reduits : " + id)
		modele.declencher_tir(Vector2.RIGHT)
		modele.animer(.06, reduit, Vector2.ZERO)
		_exiger(_pose_changee(modele, repos), "Tir sans geste visible : %s (reduit=%s)" % [id, reduit])
		_verifier_poses_finies(modele, id)
		for image in 120:
			var mouvement := Vector2.from_angle(float(image) * TAU / 120.0) * CatalogueFamiliers.DEPLACEMENT_VITESSE
			modele.animer(1.0 / 60.0, reduit, mouvement)
			_verifier_poses_finies(modele, id)
			_verifier_appuis_sol(modele, id)
		modele.animer(1.0, reduit, Vector2.ZERO)
		var apres_tir := _poses(modele)
		modele.animer(.5, reduit, Vector2.ZERO)
		if reduit:
			_exiger(not _pose_changee(modele, apres_tir), "Le geste de tir ne termine pas en effets reduits : " + id)
	_exiger(_maillages(modele) == maillages, "Les animations reconstruisent les maillages : " + id)

func _verifier_appuis_sol(modele: Node3D, id: String) -> void:
	if not MODELES.terrestre(id):
		return
	var minimum := INF
	var inverse := modele.global_transform.affine_inverse()
	for objet: MeshInstance3D in modele.find_children("*", "MeshInstance3D", true, false):
		var pose := inverse * objet.global_transform
		for surface in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(surface)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			for sommet in sommets:
				minimum = minf(minimum, (pose * sommet).y + MODELES.hauteur(id))
	_hauteurs_min[id] = minf(float(_hauteurs_min.get(id, INF)), minimum)
	_exiger(minimum >= -.005, "Un familier terrestre traverse le sol : %s (%.4f m)" % [id, minimum])

func _verifier_reconfiguration() -> void:
	var modele := MODELE.new()
	modele.configurer("golem")
	_scene.add_child(modele)
	for id: String in CatalogueFamiliers.TYPES:
		var anciens: Array[WeakRef] = []
		for membre in modele.find_children("Art_*", "Node3D", true, false):
			anciens.append(weakref(membre))
		modele.declencher_tir(Vector2.LEFT)
		modele.configurer(id)
		await process_frame
		_exiger(modele.id == id, "Changement d'identite ignore : " + id)
		for reference in anciens:
			var ancien := reference.get_ref() as Node
			_exiger(ancien == null or not modele.is_ancestor_of(ancien), "Ancien membre conserve apres changement : " + id)
		var neuf := MODELE.new()
		neuf.configurer(id)
		_scene.add_child(neuf)
		modele.animer(0.0, true, Vector2.ZERO)
		neuf.animer(0.0, true, Vector2.ZERO)
		_exiger(modele.find_children("*", "", true, false).size() == neuf.find_children("*", "", true, false).size(),
			"Des membres s'accumulent apres changement : " + id)
		_exiger(_signature_geometrie(modele) == _signature_geometrie(neuf), "Un changement conserve la geometrie precedente : " + id)
		neuf.free()
	modele.free()

func _verifier_suivi(reglages: Node) -> void:
	var logique := LOGIQUE.new()
	_scene.add_child(logique)
	logique.position = Vector2(350.0, 620.0)
	logique._position_precedente = logique.global_position
	var suivi: Node3D = load("res://scripts/presentation/suivi_familier_3d.gd").new()
	suivi.logique = logique
	_scene.add_child(suivi)
	var rayon := CatalogueFamiliers.RAYON
	for id: String in CatalogueFamiliers.TYPES:
		logique.id = id
		for reduit in [false, true]:
			reglages.effets_reduits = reduit
			var position_logique := logique.global_transform
			suivi.mettre_a_jour(.1)
			await process_frame
			var visuel := suivi.get_node_or_null("FamilierEquipe") as Node3D
			_exiger(visuel != null, "FamilierEquipe absent du suivi")
			if visuel != null:
				_exiger(str(visuel.get("id")) == id, "La transition du suivi garde l'ancien familier : " + id)
				var attendu := Pont3D.vers_monde(logique.position_affichee())
				_exiger(is_equal_approx(visuel.position.x, attendu.x) and is_equal_approx(visuel.position.z, attendu.z),
					"Le visuel perd la position logique : " + id)
				_verifier_collisions(visuel, id)
				_verifier_poses_finies(visuel, id)
			_exiger(logique.global_transform.is_equal_approx(position_logique) and is_equal_approx(CatalogueFamiliers.RAYON, rayon),
				"Le suivi modifie la simulation ou le rayon : " + id)
	logique.hide()
	suivi.mettre_a_jour(.1)
	_exiger(not suivi.visible, "Le suivi ignore la disparition du familier logique")
	suivi.free()
	logique.free()

func _poses(modele: Node3D) -> Dictionary:
	var resultat: Dictionary = {modele.get_instance_id(): modele.transform}
	for membre: Node3D in modele.find_children("*", "Node3D", true, false):
		resultat[membre.get_instance_id()] = membre.transform
	return resultat

func _pose_changee(modele: Node3D, poses: Dictionary) -> bool:
	var courantes := _poses(modele)
	if courantes.size() != poses.size():
		return true
	for identifiant: int in poses:
		if not courantes.has(identifiant):
			return true
		var avant: Transform3D = poses[identifiant]
		var apres: Transform3D = courantes[identifiant]
		if not avant.is_equal_approx(apres):
			return true
	return false

func _verifier_poses_finies(modele: Node3D, id: String) -> void:
	var valides := modele.transform.is_finite()
	for membre: Node3D in modele.find_children("*", "Node3D", true, false):
		if not membre.transform.is_finite():
			valides = false
	_exiger(valides, "Pose non finie : " + id)

func _maillages(modele: Node3D) -> Array[int]:
	var resultat: Array[int] = []
	for objet: MeshInstance3D in modele.find_children("*", "MeshInstance3D", true, false):
		if objet.mesh != null:
			resultat.append(objet.mesh.get_instance_id())
	return resultat

func _signature_geometrie(modele: Node3D) -> int:
	# Les couleurs ne suffisent pas a distinguer cinq silhouettes sur telephone.
	var volumes: Array[String] = []
	var inverse := modele.global_transform.affine_inverse()
	for objet: MeshInstance3D in modele.find_children("*", "MeshInstance3D", true, false):
		if objet.mesh == null:
			continue
		var pose := inverse * objet.global_transform
		volumes.append(str(pose) + str(objet.mesh.get_aabb()))
	return hash(volumes)

func _ajouter_vues(id: String, colonne: int) -> void:
	var donnees: Dictionary = CatalogueFamiliers.TYPES[id]
	for ligne in 3:
		var modele := MODELE.new()
		modele.configurer(id)
		_scene.add_child(modele)
		var pose := "Repos"
		if ligne == 0:
			modele.animer(0.0, true, Vector2.ZERO)
		elif ligne == 1:
			pose = "Déplacement"
			modele.animer(.18, false, Vector2.RIGHT * CatalogueFamiliers.DEPLACEMENT_VITESSE)
		else:
			pose = "Tir"
			modele.declencher_tir(Vector2.RIGHT)
			modele.animer(.06, false, Vector2.ZERO)
		var copie := _copier_pose(modele)
		_galerie.add_child(copie)
		copie.position = Vector3(float(colonne) * 1.85, MODELES.hauteur(id), float(ligne) * 2.775)
		_legendes.append({"nom": str(donnees["nom"]) + " · " + pose, "point": [copie.position.x, copie.position.z]})
		if ligne == 0:
			var repos := _copier_pose(modele)
			_galerie_repos.add_child(repos)
			var ligne_repos := int(colonne / 3)
			var decalage := .85 if ligne_repos == 1 else 0.0
			repos.position = Vector3(float(colonne % 3) * 1.70 + decalage, MODELES.hauteur(id), ligne_repos * 2.15)
			_legendes_repos.append({"nom": str(donnees["nom"]), "point": [repos.position.x, repos.position.z]})
		modele.free()

func _copier_pose(source: Node3D) -> Node3D:
	# Retirer les scripts evite que _ready reconstruise une pose exportee.
	var copie: Node3D
	if source is MeshInstance3D:
		var origine := source as MeshInstance3D
		var maillage := MeshInstance3D.new()
		maillage.mesh = origine.mesh
		maillage.material_override = origine.material_override
		var standard := origine.material_override as StandardMaterial3D
		if standard != null and standard.vertex_color_use_as_albedo and standard.vertex_color_is_srgb:
			# COLOR_0 du glTF est lineaire ; son export ne conserve pas le drapeau sRGB.
			maillage.mesh = _maillage_lineaire(origine.mesh)
			var matiere := standard.duplicate() as StandardMaterial3D
			matiere.vertex_color_is_srgb = false
			maillage.material_override = matiere
		maillage.cast_shadow = origine.cast_shadow
		for surface in origine.mesh.get_surface_count():
			maillage.set_surface_override_material(surface, origine.get_surface_override_material(surface))
		copie = maillage
	else:
		copie = Node3D.new()
	copie.name = source.name
	copie.transform = source.transform
	copie.visible = source.visible
	for enfant in source.get_children():
		if enfant is Node3D:
			copie.add_child(_copier_pose(enfant as Node3D))
	return copie

func _maillage_lineaire(source: Mesh) -> ArrayMesh:
	var resultat := ArrayMesh.new()
	for surface in source.get_surface_count():
		var tableaux := source.surface_get_arrays(surface)
		if tableaux[Mesh.ARRAY_COLOR] != null:
			var couleurs: PackedColorArray = tableaux[Mesh.ARRAY_COLOR]
			for indice in couleurs.size():
				couleurs[indice] = couleurs[indice].srgb_to_linear()
			tableaux[Mesh.ARRAY_COLOR] = couleurs
		resultat.add_surface_from_arrays(source.surface_get_primitive_type(surface), tableaux)
		resultat.surface_set_material(surface, source.surface_get_material(surface))
	return resultat

func _exporter() -> void:
	var erreur := DirAccess.make_dir_recursive_absolute(_export)
	_exiger(erreur == OK, "Dossier d'export impossible : " + _export)
	if erreur != OK:
		return
	var galeries := {"familiers": _galerie_repos, "familiers_poses": _galerie}
	for categorie: String in galeries:
		var document := GLTFDocument.new()
		var etat := GLTFState.new()
		var galerie: Node3D = galeries[categorie]
		_exiger(document.append_from_scene(galerie, etat) == OK, "Export de galerie impossible : " + categorie)
		_exiger(document.write_to_filesystem(etat, _export.path_join(categorie + ".glb")) == OK, "Ecriture GLB impossible : " + categorie)
	var fichier := FileAccess.open(_export.path_join("legendes.json"), FileAccess.WRITE)
	_exiger(fichier != null, "Ecriture des legendes impossible")
	if fichier != null:
		fichier.store_string(JSON.stringify({"familiers": _legendes_repos, "familiers_poses": _legendes}))
