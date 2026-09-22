extends Control

const LUCIOLES := [Vector2(224, 657), Vector2(632, 581), Vector2(136, 930),
	Vector2(727, 986), Vector2(845, 854)]

var _temps := 0.0
var _mage: TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mage = get_parent().get_node("Mage") as TextureRect
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)
	_actualiser_effets()

func _actualiser_effets() -> void:
	set_process(not ReglagesJoueur.effets_reduits)
	queue_redraw()

func _process(delta: float) -> void:
	_temps += delta
	queue_redraw()

func _draw() -> void:
	if ReglagesJoueur.effets_reduits or _mage == null:
		return
	var pulsation := 0.5 + 0.5 * sin(_temps * 2.1)
	# La pointe suit le meme transform que le mage, meme pendant sa respiration.
	var baguette := _mage.get_transform() * Vector2(_mage.size.x * 0.94, _mage.size.y * 0.34)
	draw_circle(baguette, 19.0, Color(0.25, 0.92, 0.98, 0.035 + pulsation * 0.055))
	draw_circle(baguette, 7.0, Color(0.72, 1.0, 1.0, 0.09 + pulsation * 0.12))
	for point in range(3):
		var angle := _temps * 0.45 + float(point) * TAU / 3.0
		var position_point := baguette + Vector2(cos(angle), sin(angle)) * 24.0
		draw_circle(position_point, 1.7, Color(0.65, 1.0, 1.0, 0.10 + pulsation * 0.13))

	for rune in [Vector2(92, 610), Vector2(895, 750)]:
		draw_circle(rune, 26.0 + pulsation * 3.0, Color(0.29, 0.90, 1.0, 0.025 + pulsation * 0.02))
	for index in LUCIOLES.size():
		var depart: Vector2 = LUCIOLES[index]
		var flottement := Vector2(sin(_temps * 0.55 + index * 2.3) * 5.0,
			cos(_temps * 0.72 + index * 1.7) * 7.0)
		var eclat := 0.5 + 0.5 * sin(_temps * 1.8 + index * 2.2)
		draw_circle(depart + flottement, 3.5, Color(0.70, 0.97, 1.0, 0.05 + eclat * 0.09))
		draw_circle(depart + flottement, 1.3, Color(0.90, 1.0, 1.0, 0.19 + eclat * 0.23))
	for index in range(3):
		var x := 406.0 + float(index) * 77.0
		var y := 820.0 + float(index % 2) * 26.0
		var reflet := 0.035 + 0.035 * (0.5 + 0.5 * sin(_temps * 1.4 + index))
		draw_line(Vector2(x, y), Vector2(x + 35.0, y), Color(0.73, 0.94, 1.0, reflet), 2.0, true)
