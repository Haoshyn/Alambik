extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var v := Verif.new()
	test_gestes_sans_interruption_des_jambes(v)
	test_cadence_independante_de_la_frequence(v)
	test_suivi_et_teleportation(v)
	print("FLUIDITE_HEROS : %d assertions, %d echecs" % [v.total, v.echecs.size()])
	for echec in v.echecs:
		push_error(echec)
	quit(1 if not v.echecs.is_empty() else 0)

func _creer() -> Node3D:
	var modele: Node3D = load(Visuels3D.HEROS_MODELE).instantiate()
	Engine.get_main_loop().root.add_child(modele)
	var lecteur := modele.find_child("AnimationPlayer", true, false) as AnimationPlayer
	for nom: String in ["repos", "course"]:
		lecteur.get_animation(nom).loop_mode = Animation.LOOP_LINEAR
	var animation: AnimationTree = load("res://scripts/presentation/animation_heros_3d.gd").new()
	animation.name = "Controleur"
	modele.add_child(animation)
	animation.preparer(lecteur)
	return modele

func test_gestes_sans_interruption_des_jambes(v: Verif) -> void:
	var temoin := _creer()
	var modele := _creer()
	var base: AnimationTree = temoin.get_node("Controleur")
	var animation: AnimationTree = modele.get_node("Controleur")
	var os_base := temoin.find_child("Skeleton3D", true, false) as Skeleton3D
	var os := modele.find_child("Skeleton3D", true, false) as Skeleton3D
	var bras_change := false
	for i in 120:
		if i in [10, 12, 15, 65]:
			animation.tirer()
		if i in [30, 32]:
			animation.toucher()
		base.mettre_a_jour(1.0/60.0, Reglages.HEROS_VITESSE, false)
		animation.mettre_a_jour(1.0/60.0, Reglages.HEROS_VITESSE, false)
		for nom: String in ["racine", "bassin", "cuisse_gauche", "tibia_droite", "pied_gauche"]:
			var index := os.find_bone(nom)
			v.vrai(os.get_bone_pose(index).is_equal_approx(os_base.get_bone_pose(index)), "les gestes preservent les appuis : "+nom)
		var bras := os.find_bone("bras_droite")
		bras_change = bras_change or not os.get_bone_pose(bras).is_equal_approx(os_base.get_bone_pose(bras))
	v.vrai(bras_change, "les gestes affectent effectivement le haut du corps")
	animation.mettre_a_jour(1.0/60.0, 0.0, true)
	v.egal(str(animation.get("parameters/etat/current_state")), "mort", "la mort prend priorite sur tous les gestes")
	for i in 120:
		animation.mettre_a_jour(1.0/60.0, 0.0, true)
	var mort := os.get_bone_pose(os.find_bone("racine"))
	animation.tirer()
	animation.toucher()
	animation.mettre_a_jour(.2, 0.0, true)
	v.vrai(mort.is_equal_approx(os.get_bone_pose(os.find_bone("racine"))), "la pose finale ne redemarre pas et ignore les tirs")
	modele.free()
	temoin.free()

func test_cadence_independante_de_la_frequence(v: Verif) -> void:
	var poses: Array[Transform3D] = []
	for fps in [30, 60, 120]:
		var modele := _creer()
		var animation: AnimationTree = modele.get_node("Controleur")
		var squelette := modele.find_child("Skeleton3D", true, false) as Skeleton3D
		animation.mettre_a_jour(0.0, Reglages.HEROS_VITESSE, false)
		for i in fps * 2:
			animation.mettre_a_jour(1.0/float(fps), Reglages.HEROS_VITESSE, false)
		poses.append(squelette.get_bone_pose(squelette.find_bone("cuisse_gauche")))
		modele.free()
	for pose in poses:
		v.vrai(pose.is_equal_approx(poses[0]), "meme phase de course a 30, 60 et 120 fps")

func test_suivi_et_teleportation(v: Verif) -> void:
	var cible := CharacterBody2D.new()
	root.add_child(cible)
	cible.set_physics_process(true)
	var suivi: Node = load("res://scripts/presentation/suivi_visuel_2d.gd").new()
	cible.add_child(suivi)
	cible.position = Vector2(12,0)
	suivi._physics_process(1.0/60.0)
	var attendu := Vector2(12,0)*Engine.get_physics_interpolation_fraction()
	v.vrai(suivi.position_affichee().is_equal_approx(attendu), "le rendu interpole entre deux positions de physique")
	cible.position = Vector2(500,500)
	v.vrai(suivi.position_affichee().is_equal_approx(cible.position), "le placement de salle est immediat avant le prochain pas")
	suivi._physics_process(1.0/60.0)
	v.vrai(suivi.position_affichee().is_equal_approx(cible.position), "une teleportation ne traverse pas la salle")
	cible.free()
