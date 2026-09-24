class_name CarteAnnexe
extends Control

const POSITIONS := [
	Vector2(0.18, 0.18), Vector2(0.50, 0.18), Vector2(0.82, 0.18),
	Vector2(0.68, 0.49), Vector2(0.32, 0.49),
	Vector2(0.18, 0.82), Vector2(0.50, 0.82), Vector2(0.82, 0.82),
]

var mode := "mine"
var _motif: TextureRect
var _chemin_ombre: Line2D
var _chemin_lumiere: Line2D
var _etapes: Array[EtapeNiveau] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = 750.0
	_motif = StyleAzur.illustration("mine" if mode == "mine" else "epreuves", 310.0)
	_motif.modulate = Color(1.0, 1.0, 1.0, 0.34)
	add_child(_motif)
	_chemin_ombre = Line2D.new()
	_chemin_ombre.width = 15.0
	_chemin_ombre.default_color = Color("152449bd")
	_chemin_ombre.antialiased = true
	add_child(_chemin_ombre)
	_chemin_lumiere = Line2D.new()
	_chemin_lumiere.width = 4.0
	_chemin_lumiere.default_color = Color("b4e6d7c8") if mode == "mine" else Color("e0c0f5c8")
	_chemin_lumiere.antialiased = true
	add_child(_chemin_lumiere)
	resized.connect(_replacer)
	_replacer()

func ajouter_etape(etape: EtapeNiveau) -> void:
	_etapes.append(etape)
	add_child(etape)
	_replacer()

func _replacer() -> void:
	if not is_instance_valid(_motif) or size.x <= 0.0 or size.y <= 0.0:
		return
	_motif.position = (size - _motif.custom_minimum_size) * 0.5
	var courbe := Curve2D.new()
	for i in POSITIONS.size():
		var centre: Vector2 = Vector2(size.x * POSITIONS[i].x, size.y * POSITIONS[i].y)
		var avant: Vector2 = Vector2(size.x * POSITIONS[maxi(i - 1, 0)].x, size.y * POSITIONS[maxi(i - 1, 0)].y)
		var apres: Vector2 = Vector2(size.x * POSITIONS[mini(i + 1, POSITIONS.size() - 1)].x, size.y * POSITIONS[mini(i + 1, POSITIONS.size() - 1)].y)
		var tangente := (apres - avant).normalized() * 40.0
		courbe.add_point(centre, -tangente, tangente)
		if i < _etapes.size():
			var etape := _etapes[i]
			etape.size = Vector2(188.0, 212.0)
			etape.position = centre - etape.size * 0.5
	var points := courbe.get_baked_points()
	_chemin_ombre.points = points
	_chemin_lumiere.points = points
