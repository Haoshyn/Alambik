extends ProgressBar

var accent := StyleAzur.MENTHE
var _animation: Tween

func _ready() -> void:
	show_percentage = false
	step = 0.0
	custom_minimum_size.y = 32
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rail := StyleBoxFlat.new()
	rail.bg_color = Color("181c35")
	rail.border_color = accent.darkened(0.45)
	rail.set_border_width_all(2)
	rail.set_corner_radius_all(12)
	add_theme_stylebox_override("background", rail)
	var degrade := Gradient.new()
	degrade.set_color(0, accent.darkened(0.34))
	degrade.set_color(1, accent.lightened(0.12))
	var texture := GradientTexture2D.new()
	texture.gradient = degrade
	texture.width = 512
	texture.height = 32
	var plein := StyleBoxTexture.new()
	plein.texture = texture
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: plein.set_expand_margin(cote, -3)
	add_theme_stylebox_override("fill", plein)
	value_changed.connect(func(_valeur: float): queue_redraw())

func afficher(points: int, total: int) -> void:
	max_value = maxi(1, total)
	if is_instance_valid(_animation): _animation.kill()
	if ReglagesJoueur.effets_reduits or not is_visible_in_tree():
		value = points
	else:
		_animation = create_tween()
		_animation.tween_property(self, "value", float(points), 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	# Les reperes divisent le budget disponible, sans suggerer un plafond d'attribut.
	for index in range(1, 10):
		var x := size.x * float(index) / 10.0
		draw_line(Vector2(x, 5), Vector2(x - 5, size.y - 5), Color("171e386e"), 2, true)
	var fin := size.x * float(value / max_value)
	if fin > 8:
		draw_line(Vector2(5, 6), Vector2(fin - 4, 6), Color(accent.lightened(0.5), 0.65), 2, true)
