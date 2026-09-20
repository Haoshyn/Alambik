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
	HabillagePeint.appliquer(self)
	var bandeau := PanelContainer.new()
	HabillagePeint.appliquer(bandeau)
	bandeau.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bandeau.add_theme_stylebox_override("panel", StyleAzur.cadre(Color(StyleAzur.FOND, 0.94), StyleAzur.MAGIE, 18))
	add_child(bandeau)
	bandeau.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bandeau.offset_top = Ecran.marge_haute() + 300
	bandeau.offset_bottom = Ecran.marge_haute() + 412
	bandeau.offset_left = 56
	bandeau.offset_right = -56
	var entete := HBoxContainer.new()
	entete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entete.add_theme_constant_override("separation", 20)
	bandeau.add_child(entete)
	entete.add_child(StyleAzur.illustration("astrolabe", 64.0))
	var textes := VBoxContainer.new()
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.alignment = BoxContainer.ALIGNMENT_CENTER
	entete.add_child(textes)
	textes.add_child(StyleAzur.texte("Choisissez votre cible", 28, StyleAzur.CUIVRE))
	textes.add_child(StyleAzur.texte("Touchez l’arène · Le temps est ralenti", 22, StyleAzur.ATTENUE))
	var actions := HBoxContainer.new()
	add_child(actions)
	actions.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	actions.offset_top = -200 - Ecran.marge_basse()
	actions.offset_bottom = -70 - Ecran.marge_basse()
	actions.offset_left = 100
	actions.offset_right = -100
	actions.add_child(StyleAzur.bouton("Annuler la visée", func(): annule.emit()))
	StyleInterface.animer_entree(bandeau, 12.0)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if _valide or not vers_logique.is_valid(): return
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
	# Le cercle conserve le rayon exact du sort, l'ornement ne cache pas le danger.
	draw_circle(centre, r, Color(StyleAzur.MAGIE, 0.10))
	draw_arc(centre, r, 0, TAU, 64, StyleAzur.MAGIE, 3.0, true)
	draw_texture_rect(StyleAzur.texture_interface("joystick_curseur"), Rect2(centre - Vector2.ONE * 23, Vector2.ONE * 46), false)
