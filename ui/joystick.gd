extends Control

# Joystick flottant : le pouce se pose n'importe ou sur la moitie basse, le
# joystick nait sous lui. Aucune zone a viser, donc jouable d'une main sans
# regarder ses doigts.

signal intention_changee(direction: Vector2, intensite: float)
# Nombre de tapes rapides enchainees au meme endroit. Le combat decide de ce
# qu'il en fait : l'ecran de reglages choisit le mode, pas le joystick.
signal tape_rapide(nombre: int)

var _logique := JoystickLogique.new()
var _raccourci := RaccourciTactile.new()
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
	_raccourci.annuler()
	intention_changee.emit(Vector2.ZERO, 0.0)
	queue_redraw()

func consommer_raccourci() -> void:
	_raccourci.consommer()

func _notification(quoi: int) -> void:
	if quoi in [NOTIFICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		annuler()

func _temps() -> float:
	return float(Time.get_ticks_msec()) / 1000.0

func _input(evenement: InputEvent) -> void:
	var tapes := 0
	if evenement is InputEventScreenTouch:
		if evenement.pressed and _doigt == -1:
			if not _zone_valide(evenement.position):
				return
			_doigt = evenement.index
			_logique.appuyer(evenement.position)
			_raccourci.appuyer(evenement.position, _temps())
		elif not evenement.pressed and evenement.index == _doigt:
			_doigt = -1
			_logique.relacher()
			tapes = _raccourci.relacher(_temps())
		else:
			return
	elif evenement is InputEventScreenDrag and evenement.index == _doigt:
		_logique.deplacer(evenement.position)
		_raccourci.deplacer(evenement.position)
	else:
		return
	intention_changee.emit(_logique.direction(), _logique.intensite())
	if tapes > 0:
		tape_rapide.emit(tapes)
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
