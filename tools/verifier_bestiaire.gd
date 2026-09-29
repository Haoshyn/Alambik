extends SceneTree

const HABILLAGE := preload("res://scripts/presentation/habillage_ennemis_3d.gd")
const CHEMIN_PROXY := "res://scripts/presentation/proxy_3d.gd"
const FORMES := preload("res://scripts/presentation/formes_projectiles_hostiles.gd")
const COULEURS := preload("res://data/presentation/animations_projectiles.gd")
var _erreurs: Array[String] = []
var _export := ""
var _galeries: Dictionary = {}
var _legendes: Dictionary = {}
var _triangles_max := 0
var _surfaces_max := 0

func _init() -> void:
	call_deferred("_executer")

func _exiger(condition: bool, message: String) -> void:
	if not condition and message not in _erreurs: _erreurs.append(message)

func _executer() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Un profil APPDATA de verification isole est requis.")
		quit(1)
		return
	var reglages := root.get_node("ReglagesJoueur")
	reglages.sauvegarde_active = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--exporter="): _export = argument.trim_prefix("--exporter=")
	var scene := Node2D.new()
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(scene)
	var index := 0
	for id: String in CatalogueEnnemis.TOUS:
		var source := CatalogueEnnemis.par_id(id)
		var boss := str(source["cerveau"]) == "boss"
		for monde in (1 if boss else 5):
			var donnees := BestiaireMondes.appliquer(source, id, monde * Chapitres.CHAPITRES_PAR_MONDE)
			var acteur: CharacterBody2D = load("res://scenes/boss.tscn" if boss else "res://scenes/ennemi.tscn").instantiate()
			acteur.configurer(donnees)
			scene.add_child(acteur)
			acteur._apparition = 1.0
			var proxy: Node3D = load(CHEMIN_PROXY).new()
			scene.add_child(proxy)
			proxy.preparer(acteur, load(Visuels3D.chemin_ennemi(donnees)), "ennemi")
			var membres: Array[Node] = proxy.modele.find_children("Art_*", "Node3D", true, false)
			_exiger(membres.size() >= 3, "Articulations absentes : " + id)
			_verifier_budget(proxy.modele, boss, id)
			var collision: Shape2D = acteur.get_node("CollisionShape2D").shape
			var rayon := (collision as CircleShape2D).radius
			for reduit in [false, true]:
				reglages.effets_reduits = reduit
				acteur.velocity = Vector2(0, float(donnees["vitesse"]) * Reglages.ENNEMI_VITESSE_MULT)
				for image in 15: proxy.mettre_a_jour(1.0 / 60.0)
				var poses: Array[Transform3D] = []
				for membre: Node3D in membres: poses.append(membre.transform)
				acteur._gel = 1.0
				proxy.mettre_a_jour(.1)
				for i in membres.size():
					_exiger(poses[i].is_equal_approx(membres[i].transform), "Gel ignore par un membre : " + id)
				acteur._gel = 0.0
				proxy._projeter_ennemi()
				proxy.mettre_a_jour(.045)
				var bouge := false
				for i in membres.size():
					if not poses[i].is_equal_approx(membres[i].transform): bouge = true
				_exiger(bouge, "Attaque sans geste articule : " + id)
				proxy._animation_ennemi.toucher()
				proxy.mettre_a_jour(.025)
				_exiger(proxy.transform.is_finite(), "Pose invalide : " + id)
				_exiger(is_equal_approx((collision as CircleShape2D).radius, rayon), "Une pose modifie la collision : " + id)
			if monde == 0: _verifier_appuis(acteur, proxy, id)
			reglages.effets_reduits = false
			if not _export.is_empty():
				var categorie := ("miniboss" if str(source.get("rang_boss", "")) == "miniboss" else "boss") if boss else "communs"
				if boss or monde == 0:
					var numero := int(source.get("ornement", index)) if boss else index
					_ajouter_vue(proxy, categorie, numero, str(source["nom"]), 4 if not boss else 5)
				if not boss and id in ["encrier_rampant", "folio_orbiteur", "fiole_volatile"]:
					var ligne := ["encrier_rampant", "folio_orbiteur", "fiole_volatile"].find(id)
					_ajouter_vue(proxy, "mondes", ligne * 5 + monde, str(donnees["nom"]), 5)
			proxy.free()
			acteur.free()
		if not boss: index += 1
		print("OK : bestiaire %s, articulations, gel, effets reduits et collisions." % id)
	_verifier_projectiles()
	_verifier_rechargement()
	await _verifier_disparition()
	if not _export.is_empty(): _exporter()
	for galerie: Node3D in _galeries.values(): galerie.free()
	scene.free()
	for erreur in _erreurs: push_error(erreur)
	print("Bestiaire : maximum %d triangles et %d surfaces par creature." % [_triangles_max, _surfaces_max])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier_appuis(acteur: CharacterBody2D, proxy: Node3D, id: String) -> void:
	var appuis: RefCounted = proxy._animation_ennemi._appuis
	if appuis.pattes.is_empty(): return
	var pire := 0.0
	for i in 90:
		acteur.position += Vector2(0, .6)
		proxy.mettre_a_jour(1.0 / 60.0)
		for patte: Dictionary in appuis.pattes:
			var bout: Node3D = patte["bout"]
			var ancre: Vector3 = patte["ancre"]
			pire = maxf(pire, bout.global_position.distance_to(ancre) / proxy.facteur)
		_exiger(proxy._animation_ennemi.scale.is_equal_approx(Vector3.ONE), "Le corps se deforme pendant la marche : " + id)
	_exiger(pire < .08, "Un appui glisse hors de sa cible : %s (%.3f)" % [id, pire])
	acteur.velocity = Vector2.ZERO
	for i in 90: proxy.mettre_a_jour(1.0 / 60.0)
	var avant: Array[Transform3D] = []
	for patte: Dictionary in appuis.pattes: avant.append(patte["bout"].global_transform)
	for i in 60: proxy.mettre_a_jour(1.0 / 60.0)
	for i in appuis.pattes.size():
		var bout: Node3D = appuis.pattes[i]["bout"]
		_exiger(avant[i].is_equal_approx(bout.global_transform), "Pietinement a l'arret : " + id)
	# Les charges et les changements de direction ne doivent pas laisser un pied derriere.
	for delta in [1.0 / 60.0, 1.0 / 30.0]:
		var pire_course := 0.0
		var detail := ""
		var donnees: Dictionary = acteur.donnees
		var vitesse := float(donnees["vitesse"]) * Reglages.ENNEMI_VITESSE_MULT
		for i in 90:
			acteur.velocity = Vector2.DOWN.rotated(floorf(float(i) / 30.0) * PI * .5) * vitesse
			acteur.position += acteur.velocity * delta
			proxy.mettre_a_jour(delta)
			for patte: Dictionary in appuis.pattes:
				var bout: Node3D = patte["bout"]
				var ancre: Vector3 = patte["ancre"]
				var ecart: float = bout.global_position.distance_to(ancre) / proxy.facteur
				if ecart > pire_course:
					pire_course = ecart
					detail = "%s image %d, phase %.3f, vol %s, %.3f a %d Hz" % [bout.name, i, appuis.phase, patte["vol"], ecart, roundi(1.0 / delta)]
		_exiger(pire_course < .30, "Appui abandonne en course ou virage : %s (%s)" % [id, detail])
	acteur.position += Vector2(1600,1600)
	proxy.mettre_a_jour(1.0 / 60.0)
	for patte: Dictionary in appuis.pattes:
		var bout: Node3D = patte["bout"]
		_exiger(bout.global_transform.is_finite(), "Pose invalide apres teleportation : " + id)

func _verifier_rechargement() -> void:
	var avant := HABILLAGE._maillages.size()
	for monde in 5:
		for forme: String in Visuels3D.COMMUNS:
			var id: String = Visuels3D.COMMUNS[forme]
			var donnees := BestiaireMondes.appliquer(CatalogueEnnemis.par_id(id), id, monde * Chapitres.CHAPITRES_PAR_MONDE)
			var modele: Node3D = load(Visuels3D.chemin_ennemi(donnees)).instantiate()
			HABILLAGE.appliquer(modele, donnees)
			modele.free()
	_exiger(HABILLAGE._maillages.size() == avant, "Les variantes s'accumulent apres rechargement des modeles")

func _verifier_disparition() -> void:
	var reglages := root.get_node("ReglagesJoueur")
	for reduit in [false, true]:
		reglages.effets_reduits = reduit
		var acteur: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
		acteur.configurer(CatalogueEnnemis.par_id("encrier_rampant"))
		root.add_child(acteur)
		acteur.set_physics_process(false)
		var proxy: Node3D = load(CHEMIN_PROXY).new()
		root.add_child(proxy)
		proxy.preparer(acteur, load(Visuels3D.chemin_ennemi(acteur.donnees)), "ennemi")
		acteur._apparition = 1.0
		proxy.mettre_a_jour(.016)
		acteur.mort.emit(acteur, Vector2.ZERO, Color.WHITE)
		acteur.queue_free()
		proxy.queue_free()
		await process_frame
		var vestiges := get_nodes_in_group("dissipations_ennemis")
		_exiger(vestiges.size() == 1, "La mort ne conserve pas sa derniere pose")
		for vestige in vestiges:
			_exiger(vestige.find_children("*", "CollisionObject2D", true, false).is_empty(), "Le vestige conserve une collision")
		await create_timer(.35).timeout
		_exiger(get_nodes_in_group("dissipations_ennemis").is_empty(), "Une disparition conserve un visuel orphelin")

func _verifier_budget(modele: Node3D, boss: bool, id: String) -> void:
	var surfaces := 0
	var triangles := 0
	for objet: MeshInstance3D in modele.find_children("*", "MeshInstance3D", true, false):
		surfaces += objet.mesh.get_surface_count()
		for i in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(i)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX] if tableaux[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var couleurs: PackedColorArray = tableaux[Mesh.ARRAY_COLOR]
			var roles: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV2]
			var uv: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV]
			var normales: PackedVector3Array = tableaux[Mesh.ARRAY_NORMAL]
			triangles += (indices.size() if not indices.is_empty() else sommets.size()) / 3
			_exiger(couleurs.size() == sommets.size() and roles.size() == sommets.size(), "Palette ou roles de matiere perdus a l'import : " + id)
			_exiger(uv.size() == sommets.size(), "UV de l'atlas absents : " + id)
			var uv_valides := true
			for point in uv:
				if not point.is_finite() or point.x < 0.0 or point.x > 1.0 or point.y < 0.0 or point.y > 1.0:
					uv_valides = false
			var normales_valides := normales.size() == sommets.size()
			for normale in normales:
				if not normale.is_finite() or absf(normale.length_squared() - 1.0) > .05:
					normales_valides = false
			_exiger(uv_valides, "Coordonnees hors de l'atlas : " + id)
			_exiger(normales_valides, "Normales de surface invalides : " + id)
		var matiere := objet.get_active_material(0) as StandardMaterial3D
		_exiger(matiere != null and matiere.albedo_texture == HABILLAGE.ATLAS, "L'atlas peint n'est pas partage : " + id)
		if matiere != null:
			_exiger(matiere.roughness_texture != null and matiere.metallic_texture == matiere.roughness_texture,
				"Les reponses des matieres ne partagent pas leur carte : " + id)
	_surfaces_max = maxi(_surfaces_max, surfaces)
	_triangles_max = maxi(_triangles_max, triangles)
	_exiger(surfaces <= 16, "Budget de surfaces depasse : " + id)
	_exiger(triangles <= (15000 if boss else 10000), "Budget de geometrie depasse : " + id)

func _verifier_projectiles() -> void:
	var index := 0
	for id: String in ProjectilesEnnemis.PROFILS:
		var teinte := COULEURS.couleur_hostile(id, 0)
		var profil: Dictionary = ProjectilesEnnemis.PROFILS[id]
		var allongement := float(profil["longueur"]) / (2.0 * float(profil["rayon"]))
		var forme := FORMES.construire(id, teinte, allongement, 0)
		var copie := FORMES.construire(id, teinte, allongement, 0)
		_exiger(forme.get_node("Corps").mesh == copie.get_node("Corps").mesh, "Geometrie recreee pour chaque tir : " + id)
		for objet: MeshInstance3D in forme.get_children():
			var tableaux := objet.mesh.surface_get_arrays(0)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			for point in sommets:
				_exiger(point.is_finite() and absf(point.x) <= 1.001 and absf(point.z) <= 1.001,
					"Decor hors du contour normalise d'un projectile : " + id)
		# Dimensions relatives reelles : une aiguille reste etroite dans la planche.
		forme.scale = Vector3(1.0 / allongement, 1.0 / allongement, 1.0)
		if not _export.is_empty(): _ajouter_vue(forme, "projectiles", index, str(profil["nom"]), 6)
		forme.free()
		copie.free()
		index += 1

func _ajouter_vue(source: Node3D, categorie: String, index: int, nom: String, colonnes: int) -> void:
	if not _galeries.has(categorie):
		var galerie := Node3D.new()
		galerie.name = "Bestiaire_" + categorie
		root.add_child(galerie)
		_galeries[categorie] = galerie
		_legendes[categorie] = []
	var modele := (source.modele if source.get_script() != null and source.get_script().resource_path == CHEMIN_PROXY else source) as Node3D
	var copie := modele.duplicate() as Node3D
	# La pose et les matieres viennent du proxy ; la planche isole les creatures.
	copie.rotation.y = .18
	_galeries[categorie].add_child(copie)
	var taille := 2.7 if categorie == "projectiles" else 1.85
	copie.position = Vector3(float(index % colonnes) * taille, 0, float(index / colonnes) * taille * 1.5)
	var legendes: Array = _legendes[categorie]
	legendes.append({"nom":nom, "point":[copie.position.x, copie.position.z]})

func _exporter() -> void:
	DirAccess.make_dir_recursive_absolute(_export)
	for categorie: String in _galeries:
		var document := GLTFDocument.new()
		var etat := GLTFState.new()
		_exiger(document.append_from_scene(_galeries[categorie], etat) == OK, "Export de galerie impossible")
		_exiger(document.write_to_filesystem(etat, _export.path_join(categorie + ".glb")) == OK, "Ecriture de galerie impossible")
	var fichier := FileAccess.open(_export.path_join("legendes.json"), FileAccess.WRITE)
	fichier.store_string(JSON.stringify(_legendes))
