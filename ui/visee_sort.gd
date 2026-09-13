extends Control
signal confirme(point: Vector2)
signal annule
var point := Vector2.ZERO
var rayon := 180.0
var vers_logique: Callable
var vers_ecran: Callable
var _valide := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var titre := StyleAzur.texte("Touchez la zone · temps ralenti", 28)
	titre.add_theme_color_override("font_color", StyleAzur.ENCRE)
	titre.position = Vector2(30, Ecran.marge_haute() + 140)
	titre.size = Vector2(get_viewport_rect().size.x - 60, 80)
	add_child(titre)
	var actions := HBoxContainer.new()
	add_child(actions)
	actions.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	actions.offset_top = -200 - Ecran.marge_basse()
	actions.offset_bottom = -70 - Ecran.marge_basse()
	actions.offset_left = 30
	actions.offset_right = -30
	actions.add_child(StyleAzur.bouton("Annuler", func(): annule.emit()))
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if _valide: return
	if event is InputEventScreenTouch and event.pressed:
		point = vers_logique.call(event.position)
		_valide = true
		confirme.emit(point)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		point = vers_logique.call(event.position)
		_valide = true
		confirme.emit(point)

func _draw() -> void:
	if not vers_ecran.is_valid(): return
	var centre: Vector2 = vers_ecran.call(point)
	var bord: Vector2 = vers_ecran.call(point + Vector2(rayon, 0))
	var r := centre.distance_to(bord)
	draw_circle(centre, r, Color(0.25, 0.9, 1.0, 0.18))
	draw_arc(centre, r, 0, TAU, 64, Color("81f5ff"), 3.0, true)
	draw_line(centre - Vector2(14,0), centre + Vector2(14,0), Color.WHITE, 3)
	draw_line(centre - Vector2(0,14), centre + Vector2(0,14), Color.WHITE, 3)
