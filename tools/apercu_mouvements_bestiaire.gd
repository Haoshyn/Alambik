extends SceneTree

# Les poses sont calculees par le vrai proxy Godot, puis rendues hors ecran.
const IDS := ["encrier_rampant", "scribe_essaimeur", "folio_orbiteur", "sceau_belier"]
const IMAGES_SECONDE := 24
var _dossier := "tmp/verification_matieres/mouvements"

func _init() -> void:
	call_deferred("_executer")

func _executer() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Un profil APPDATA de verification isole est requis.")
		quit(1)
		return
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--exporter="): _dossier = argument.trim_prefix("--exporter=")
	DirAccess.make_dir_recursive_absolute(_dossier)
	var scene := Node2D.new()
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(scene)
	var galerie := Node3D.new()
	galerie.name = "Mouvements"
	scene.add_child(galerie)
	var acteurs: Array[CharacterBody2D] = []
	var proxies: Array[Node3D] = []
	var noeuds: Array[Node3D] = []
	var legendes: Array[Dictionary] = []
	for index in IDS.size():
		var donnees := BestiaireMondes.appliquer(CatalogueEnnemis.par_id(IDS[index]), IDS[index], 0)
		var acteur: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
		acteur.configurer(donnees)
		scene.add_child(acteur)
		acteur._apparition = 1.0
		acteur.global_position = Vector2(index * 170.0, 0)
		var proxy: Node3D = load("res://scripts/presentation/proxy_3d.gd").new()
		galerie.add_child(proxy)
		proxy.preparer(acteur, load(Visuels3D.chemin_ennemi(donnees)), "ennemi")
		proxy._animation_ennemi._temps = index * .8
		proxy._animation_ennemi._membres._temps = index * .8
		acteurs.append(acteur)
		proxies.append(proxy)
		legendes.append({"nom":str(donnees["nom"]), "point":[index*1.7,0]})
		noeuds.append(proxy)
		for enfant: Node3D in proxy.find_children("*", "Node3D", true, false): noeuds.append(enfant)
	for i in noeuds.size(): noeuds[i].name = "Pose_%03d" % i
	var document := GLTFDocument.new()
	var etat := GLTFState.new()
	if document.append_from_scene(galerie, etat) != OK or document.write_to_filesystem(etat, _dossier.path_join("mouvements.glb")) != OK:
		push_error("Export des modeles impossible.")
		quit(1)
		return
	var images: Array = []
	for frame in IMAGES_SECONDE * 5:
		var temps := float(frame) / IMAGES_SECONDE
		for i in acteurs.size():
			var acteur := acteurs[i]
			var proxy := proxies[i]
			# Un deplacement court permet de voir les appuis, puis l'arret et le tir.
			var avance := smoothstep(.30, 1.75, temps) * 95.0
			acteur.global_position = Vector2(i * 170.0, avance)
			acteur._etat = "vise" if temps > 2.1 and temps < 2.8 else "avancer"
			acteur._point_vise = acteur.global_position + Vector2.DOWN * 300
			acteur._minuterie = maxf(0, 2.8 - temps)
			if frame == 67: proxy._projeter_ennemi()
			if frame == 91: proxy._animation_ennemi.toucher()
			proxy.mettre_a_jour(1.0 / IMAGES_SECONDE)
		var poses: Array = []
		for noeud in noeuds:
			var p := noeud.position
			var q := noeud.basis.orthonormalized().get_rotation_quaternion()
			var s := noeud.scale
			poses.append([p.x,p.y,p.z,q.x,q.y,q.z,q.w,s.x,s.y,s.z])
		images.append(poses)
	var fichier := FileAccess.open(_dossier.path_join("poses.json"), FileAccess.WRITE)
	fichier.store_string(JSON.stringify({"fps":IMAGES_SECONDE,"images":images,"legendes":legendes}))
	scene.free()
	print("APERCU_MOUVEMENTS_OK : %d poses du moteur." % images.size())
	quit()
