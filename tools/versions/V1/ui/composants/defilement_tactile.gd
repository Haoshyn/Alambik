class_name DefilementTactile
extends ScrollContainer

const SEUIL_GLISSEMENT := 14.0
var _doigt := -1
var _origine := Vector2.ZERO
var _depart := 0
var _glisse := false

func _ready() -> void:
	set_process_input(false)

func _gui_input(evenement: InputEvent) -> void:
	if evenement is InputEventScreenTouch and evenement.pressed and _doigt < 0:
		_doigt = evenement.index
		_origine = evenement.position
		_depart = scroll_vertical
		_glisse = false
		set_process_input(true)

func _input(evenement: InputEvent) -> void:
	if _doigt < 0: return
	if evenement is InputEventScreenDrag and evenement.index == _doigt:
		var position_locale: Vector2 = get_global_transform_with_canvas().affine_inverse() * evenement.position
		var distance: float = position_locale.y - _origine.y
		if not _glisse and absf(distance) >= SEUIL_GLISSEMENT:
			_glisse = true
			# Annule l'activation de la case sans la desactiver ni perdre la capture du doigt.
			propagate_notification(Control.NOTIFICATION_SCROLL_BEGIN)
			scroll_started.emit()
		if _glisse:
			scroll_vertical = _depart - int(distance)
			get_viewport().set_input_as_handled()
	elif evenement is InputEventScreenTouch and evenement.index == _doigt and not evenement.pressed:
		if _glisse:
			get_viewport().set_input_as_handled()
			propagate_notification(Control.NOTIFICATION_SCROLL_END)
			scroll_ended.emit()
		_doigt = -1
		_glisse = false
		set_process_input(false)
	elif _glisse and evenement is InputEventMouseMotion:
		# Android peut emettre aussi une souris synthetique pour le meme mouvement.
		get_viewport().set_input_as_handled()
