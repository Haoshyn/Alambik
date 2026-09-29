extends "res://ui/composants/chargement_aventure.gd"

signal terminee

const DUREE := 1.45

var _terminee := false

func _ready() -> void:
	super._ready()
	Capture.programmer(self)

func _process(delta: float) -> void:
	super._process(delta)
	if _terminee or _temps < DUREE:
		return
	_terminee = true
	terminee.emit()
