extends Node3D

const MODELES := preload("res://scripts/presentation/modeles_familiers_3d.gd")
const DUREE_TIR := .28

var id := "homoncule_encre"
var _corps: Node3D
var _membres: Array[Dictionary] = []
var _temps := 0.0
var _distance := 0.0
var _tir_restant := 0.0
var _direction_tir := Vector2.RIGHT
var _cap := 0.0
var _cap_vise := 0.0

func _ready() -> void:
	add_to_group("familiers_visuels")
	configurer(id)

func configurer(identifiant: String) -> void:
	id = identifiant if CatalogueFamiliers.contient(identifiant) else "homoncule_encre"
	if not is_inside_tree(): return
	if is_instance_valid(_corps):
		remove_child(_corps)
		_corps.queue_free()
	_membres.clear()
	_temps = 0.0
	_distance = 0.0
	_tir_restant = 0.0
	_cap = 0.0
	_cap_vise = 0.0
	_corps = Node3D.new()
	_corps.name = "Corps_" + id
	add_child(_corps)
	_membres = MODELES.construire(_corps, id)

func declencher_tir(direction: Vector2) -> void:
	_direction_tir = direction.normalized()
	_cap_vise = atan2(_direction_tir.x, _direction_tir.y)
	_tir_restant = DUREE_TIR

func animer(delta: float, reduit: bool, mouvement := Vector2.ZERO) -> void:
	if not is_instance_valid(_corps): return
	_temps += delta
	_tir_restant = maxf(0.0, _tir_restant - delta)
	var impulsion := _tir_restant / DUREE_TIR
	var vitesse := clampf(mouvement.length() / CatalogueFamiliers.DEPLACEMENT_VITESSE, 0.0, 1.0)
	_distance += mouvement.length() * delta
	var pas := _distance * .045
	var direction := mouvement.normalized()
	if vitesse > .03 and impulsion <= 0.0:
		_cap_vise = atan2(direction.x, direction.y)
	# Le museau et le bec accompagnent la patrouille et la direction du vrai tir.
	_cap = lerp_angle(_cap, _cap_vise, 1.0 if reduit else 1.0 - exp(-delta * 12.0))
	var terrestre := MODELES.terrestre(id)
	var repos := 0.0 if reduit or terrestre else sin(_temps * 2.6) * .018
	# Le recul traduit le vrai tir ; les oscillations decoratives se figent en reduit.
	var inclinaison := .025 if terrestre else .065
	_corps.rotation = Vector3(direction.y * vitesse * inclinaison, _cap, -direction.x * vitesse * inclinaison + repos)
	_corps.position = -Vector3(_direction_tir.x, 0, _direction_tir.y) * impulsion * (.027 if reduit else .065)
	for membre: Dictionary in _membres:
		var noeud: Node3D = membre["noeud"]
		var cote: float = membre["cote"]
		var role: String = membre["role"]
		noeud.transform = membre["repos"]
		match role:
			"aile":
				noeud.rotation.z = cote * ((0.0 if reduit else sin(_temps*6.0)*.12) + impulsion*.18)
			"nageoire":
				noeud.rotation.z = cote * ((0.0 if reduit else sin(_temps*3.8)*.09) + impulsion*.15)
			"queue":
				noeud.rotation.y = (0.0 if reduit else sin(_temps*3.2)*.08) + direction.x*vitesse*.10
				noeud.rotation.x = impulsion*.15
			"crete":
				noeud.rotation.x = (0.0 if reduit else sin(_temps*3.5)*.055) - impulsion*.12
			"patte":
				noeud.rotation.x = sin(pas)*cote*vitesse*.13
				noeud.position.y += maxf(0.0,sin(pas)*cote)*vitesse*.025
			"bras":
				noeud.rotation.x = -sin(pas)*cote*vitesse*.12 - impulsion*.28
				noeud.position.y += maxf(0.0, -sin(pas)*cote)*vitesse*.025
