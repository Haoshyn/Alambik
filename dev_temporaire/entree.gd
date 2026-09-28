extends Node

const PANNEAU := preload("res://dev_temporaire/panneau.gd")
const SESSION := preload("res://dev_temporaire/session.gd")
var _accueil: Control
var _bouton: Button

func _process(_delta: float) -> void:
	var menu := get_parent()
	var page: Control = menu.get("_page_actuelle")
	if not page is AccueilClairiere:
		return
	if not is_instance_valid(_accueil) or _accueil != page:
		_accueil = page
		var composition := page.get_node("ZoneSure/Defilement/Composition")
		_bouton = StyleAzur.bouton("DEV", _ouvrir)
		_bouton.name = "DevTemporaire"
		_bouton.size_flags_horizontal = Control.SIZE_SHRINK_END
		_bouton.custom_minimum_size.x = 200
		composition.add_child(_bouton)
		composition.move_child(_bouton, 1)
	_bouton.visible = menu.get("_superposition") == null
	_bouton.disabled = bool(menu.get("_lancement")) or bool(menu.get("_transition_page"))
	_bouton.text = "DEV · actif" if SESSION.active() else "DEV"

func _ouvrir() -> void:
	get_parent().call("_ouvrir_superposition", PANNEAU.new())
