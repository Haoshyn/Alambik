extends Control

# Joystick flottant : le pouce se pose n'importe ou sur la moitie basse, le
# joystick nait sous lui. Aucune zone a viser, donc jouable d'une main sans
# regarder ses doigts.

signal intention_changee(direction: Vector2, intensite: float)
var _logique := JoystickLogique.new()
var _doigt := -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func _zone_valide(position: Vector2) -> bool:
	var taille := get_viewport_rect().size
	return position.y > taille.y * 0.42 and position.x < taille.x * 0.78

func annuler() -> void:
	_doigt = -1
	_logique.relacher()
	intention_changee.emit(Vector2.ZERO, 0.0)
	queue_redraw()

func _notification(quoi: int) -> void:
	if quoi in [NOTIFICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		annuler()

func _input(evenement: InputEvent) -> void:
	var mouvement_change := false
	if evenement is InputEventScreenTouch:
		if evenement.pressed:
			if _doigt == -1 and _zone_valide(evenement.position):
				_doigt = evenement.index
				_logique.appuyer(evenement.position)
				mouvement_change = true
		else:
			if evenement.index == _doigt:
				_doigt = -1
				_logique.relacher()
				mouvement_change = true
	elif evenement is InputEventScreenDrag:
		if evenement.index == _doigt:
			_logique.deplacer(evenement.position)
			mouvement_change = true
	else:
		return
	if mouvement_change:
		intention_changee.emit(_logique.direction(), _logique.intensite())
	queue_redraw()

func _draw() -> void:
	if _doigt == -1:
		return
	var origine := _logique.origine
	var pouce := origine + _logique.direction() * _logique.intensite() * JoystickLogique.RAYON
	var base := Vector2.ONE * (JoystickLogique.RAYON + 10.0) * 2.0
	var curseur := Vector2.ONE * JoystickLogique.RAYON * 0.88
	draw_texture_rect(StyleAzur.texture_interface("joystick_base"), Rect2(origine - base * 0.5, base), false, Color(1, 1, 1, 0.78))
	draw_texture_rect(StyleAzur.texture_interface("joystick_curseur"), Rect2(pouce - curseur * 0.5, curseur), false)
