extends Node

const HEROS := preload("res://scenes/heros.tscn")
const PROXY := preload("res://scripts/presentation/proxy_3d.gd")
var _erreurs: Array[String] = []
var _tirs := 0

func _ready() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Un profil de verification isole est requis.")
		get_tree().quit(1)
		return
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.volume_musique = 0.0
	ReglagesJoueur.volume_effets = 0.0
	Sons.appliquer_reglages()
	var heros := HEROS.instantiate() as CharacterBody2D
	add_child(heros)
	heros.set_process(false)
	heros.set_physics_process(false)
	heros.tir_demande.connect(func(_tir: Tir, _origine: Vector2, _direction: Vector2): _tirs += 1)
	# Un depart avant la projection doit annuler le tir, y compris les salves.
	heros.definir_intention(Vector2.ZERO)
	heros._preparer_tir(Vector2.UP)
	heros.definir_intention(Vector2.RIGHT)
	heros._avancer_tirs_prepares(.08)
	_exiger(_tirs == 0, "Un tir prepare part encore pendant un deplacement")
	_exiger(not heros.peut_tirer(), "Le deplacement commande ne bloque pas le tir")
	heros.definir_intention(Vector2.ZERO)
	heros.velocity = Vector2(50,0)
	_exiger(heros.peut_tirer(), "Une poussee du terrain desarme le heros sans commande")
	var avant := _tirs
	heros._preparer_tir(Vector2.UP)
	heros._avancer_tirs_prepares(.08)
	_exiger(_tirs == avant + 1, "Le tir ne reprend pas a l'arret")
	heros.velocity = Vector2.ZERO
	var proxy := PROXY.new()
	add_child(proxy)
	proxy.preparer(heros, load(Visuels3D.HEROS_MODELE) as PackedScene, "heros")
	var squelette := proxy.modele.find_child("Skeleton3D",true,false) as Skeleton3D
	_exiger(proxy.modele.find_child("Aster_Body",true,false) != null, "Le nouveau modele Aster n'est pas le heros du jeu")
	if squelette != null and squelette.find_bone("Hips") >= 0:
		_verifier_reperes(proxy.modele)
		_verifier_animation(proxy, squelette)
		_verifier_impact_en_rafale()
		proxy._arme_tenue.changer("royal")
		_exiger(proxy.modele.find_child("Arme_royal",true,false) != null, "L’arme equipee ne suit pas la nouvelle main")
		proxy._arme_tenue.changer("standard")
		_exiger((proxy.modele.find_child("Aster_Wand",true,false) as Node3D).visible, "La baguette Aster ne revient pas avec l’arme standard")
	else:
		_exiger(false, "Le rig Aster n'est pas charge")
	proxy.queue_free()
	heros.queue_free()
	await get_tree().process_frame
	Sons.arreter()
	for erreur: String in _erreurs: push_error(erreur)
	if _erreurs.is_empty(): print("OK : Aster, animations, tir stationnaire et prise des armes.")
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _verifier_reperes(modele: Node3D) -> void:
	# Une attache peut exister tout en etant decalee de sa geometrie de repos.
	var baguette := modele.find_child("Aster_Wand",true,false) as MeshInstance3D
	var visage := modele.find_child("Aster_Face",true,false) as MeshInstance3D
	_exiger(visage != null and visage.mesh.get_blend_shape_count() > 0, "Les expressions du visage sont perdues")
	for nom: String in ["Aster_PriseArme","Aster_PointeBaguette"]:
		var repere := modele.find_child(nom,true,false) as Node3D
		_exiger(repere != null, "Repere du modele manquant : " + nom)
		if repere != null and baguette != null:
			var local := baguette.global_transform.affine_inverse() * repere.global_position
			_exiger(baguette.get_aabb().grow(.025).has_point(local), "Repere hors du manche de repos : " + nom)

func _verifier_animation(proxy: Node3D, squelette: Skeleton3D) -> void:
	for clip: String in ["repos","marche","course","attaque","touche","mort","visee","incantation"]:
		_exiger(proxy.lecteur.has_animation(clip), "Animation manquante : " + clip)
	for mesh: MeshInstance3D in proxy.modele.find_children("*","MeshInstance3D",true,false):
		if mesh.skin != null:
			_exiger(mesh.get_skin_reference() != null, "Maillage non lie au squelette : " + mesh.name)
	var base: Dictionary = {}
	proxy.mettre_a_jour(.2)
	for os: String in ["Hips","Foot.L","Foot.R"]:
		base[os] = squelette.get_bone_global_pose(squelette.find_bone(os))
	for image in range(120):
		if image % 5 == 0: proxy._armer_tir(Vector2.DOWN)
		if image % 5 == 3: proxy._jouer_tir(null,Vector2.ZERO,Vector2.DOWN)
		proxy.mettre_a_jour(1.0/60.0)
		for os: String in ["Foot.L","Foot.R"]:
			var pose := squelette.get_bone_global_pose(squelette.find_bone(os))
			_exiger(pose.origin.distance_to((base[os] as Transform3D).origin) < .025, "Le tir rapide deplace un appui : " + os)
		for index in range(squelette.get_bone_count()):
			_exiger(squelette.get_bone_pose(index).is_finite(), "Pose non finie")
	proxy.animation_heros.toucher()
	for image in range(20): proxy.mettre_a_jour(1.0/60.0)
	proxy._mort = true
	for image in range(180): proxy.mettre_a_jour(1.0/60.0)
	_exiger(proxy.animation_heros.get("_mort"), "L'etat de mort n'est pas applique")

func _exiger(condition: bool, message: String) -> void:
	if not condition and not message in _erreurs: _erreurs.append(message)

func _verifier_impact_en_rafale() -> void:
	# Deux acteurs synchronises isolent la reaction au coup recu pendant le tir.
	var modeles: Array[Node3D] = []
	var controles: Array[AnimationTree] = []
	var squelettes: Array[Skeleton3D] = []
	for i in 2:
		var modele := (load(Visuels3D.HEROS_MODELE) as PackedScene).instantiate() as Node3D
		add_child(modele)
		var controle := preload("res://scripts/presentation/animation_heros_3d.gd").new()
		modele.add_child(controle)
		controle.preparer(modele.find_child("AnimationPlayer",true,false) as AnimationPlayer)
		modeles.append(modele)
		controles.append(controle)
		squelettes.append(modele.find_child("Skeleton3D",true,false) as Skeleton3D)
	var ecart_tete := 0.0
	for image in 72:
		if image == 30: controles[0].toucher()
		for controle in controles:
			if image % 5 == 0: controle.armer()
			if image % 5 == 3: controle.projeter()
			controle.mettre_a_jour(1.0/60.0,0.0,false,false)
		if image >= 36 and image <= 48:
			var a := squelettes[0].get_bone_global_pose(squelettes[0].find_bone("Head"))
			var b := squelettes[1].get_bone_global_pose(squelettes[1].find_bone("Head"))
			ecart_tete = maxf(ecart_tete,a.basis.get_rotation_quaternion().angle_to(b.basis.get_rotation_quaternion()))
	_exiger(ecart_tete>.15,"La rafale masque la reaction aux degats")
	for modele in modeles: modele.queue_free()
