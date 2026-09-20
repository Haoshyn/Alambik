extends Node3D

const DOSSIER := "res://assets/3d/weapons/"
static var _scenes: Dictionary = {}
var _attache: BoneAttachment3D
var _arme: Node3D
var _identifiant := ""
var _lecture_directe := false

static func installer(modele: Node3D, identifiant: String, lecture_directe := false) -> Node3D:
	var controle := load("res://scripts/presentation/arme_tenue_3d.gd").new() as Node3D
	controle.name = "ArmeTenue"
	modele.add_child(controle)
	controle.preparer(modele, identifiant, lecture_directe)
	return controle

func preparer(modele: Node3D, identifiant: String, lecture_directe: bool) -> void:
	_lecture_directe = lecture_directe
	var squelettes := modele.find_children("*", "Skeleton3D", true, false)
	if squelettes.is_empty(): return
	var squelette := squelettes[0] as Skeleton3D
	if squelette.find_bone("main_droite") < 0: return
	_attache = BoneAttachment3D.new()
	_attache.name = "PriseArmeDroite"
	squelette.add_child(_attache)
	_attache.bone_name = "main_droite"
	changer(identifiant)

func changer(identifiant: String) -> void:
	if _attache == null: return
	# Le catalogue de combat reste la source du choix ; cette classe ne traite
	# que la presentation, sans toucher a l'equipement ni a la sauvegarde.
	if not identifiant in ["standard", "veloce", "lourd", "chercheur", "explosif", "prisme", "resonant", "draconique", "neant", "royal"]:
		identifiant = "standard"
	if identifiant == _identifiant: return
	var chemin := DOSSIER + identifiant + ".glb"
	var cle := chemin + str(_lecture_directe)
	if not _scenes.has(cle):
		var scene: PackedScene
		if _lecture_directe:
			var document := GLTFDocument.new()
			var etat := GLTFState.new()
			if document.append_from_file(chemin, etat) != OK: return
			var racine := document.generate_scene(etat)
			scene = PackedScene.new()
			var resultat := scene.pack(racine)
			racine.free()
			if resultat != OK: return
		else:
			scene = load(chemin) as PackedScene
		if scene == null: return
		_scenes[cle] = scene
	var scene_arme: PackedScene = _scenes[cle]
	var nouvelle := scene_arme.instantiate() as Node3D
	if nouvelle == null: return
	if is_instance_valid(_arme):
		_attache.remove_child(_arme)
		_arme.queue_free()
	_arme = nouvelle
	_attache.add_child(_arme)
	# Avancer la prise sur le manche rapproche la main de la monture.
	_arme.position = Vector3(-.052, -.010, -.055)
	_arme.rotation.x = PI * .5
	_identifiant = identifiant
