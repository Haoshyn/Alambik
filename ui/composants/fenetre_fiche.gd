class_name FenetreFiche
extends Control

signal fermee

var detruire_en_fermant := true
var contenu: VBoxContainer
var _panneau: Panel
var _titre: Label
var _embleme: TextureRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 20
	mouse_filter = Control.MOUSE_FILTER_STOP
	var voile := ColorRect.new()
	voile.color = Color("141d3bc4")
	voile.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(voile)
	voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	voile.gui_input.connect(func(evenement: InputEvent) -> void:
		if (evenement is InputEventMouseButton and evenement.pressed and evenement.button_index == MOUSE_BUTTON_LEFT) or (evenement is InputEventScreenTouch and evenement.pressed):
			get_viewport().set_input_as_handled()
			fermer())
	_panneau = Panel.new()
	_panneau.mouse_filter = Control.MOUSE_FILTER_STOP
	_panneau.add_theme_stylebox_override("panel", StyleAzur.cadre(StyleAzur.PANNEAU, StyleAzur.LILAS))
	add_child(_panneau)
	var marges := MarginContainer.new()
	_panneau.add_child(marges)
	marges.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for cote in ["left", "right"]: marges.add_theme_constant_override("margin_" + cote, 44)
	for cote in ["top", "bottom"]: marges.add_theme_constant_override("margin_" + cote, 42)
	var colonne := VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 20)
	marges.add_child(colonne)
	var entete := HBoxContainer.new()
	entete.add_theme_constant_override("separation", 18)
	colonne.add_child(entete)
	_embleme = StyleAzur.illustration("grimoire", 74)
	_embleme.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	entete.add_child(_embleme)
	_titre = StyleAzur.texte("", 42, Color("f7e4c2"))
	_titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(_titre)
	var fermer_bouton := StyleAzur.bouton_rond("×", fermer, 88)
	fermer_bouton.tooltip_text = "Fermer la fiche"
	fermer_bouton.accessibility_name = "Fermer la fiche"
	fermer_bouton.size_flags_horizontal = Control.SIZE_SHRINK_END
	entete.add_child(fermer_bouton)
	var defilement := preload("res://ui/composants/defilement_tactile.gd").new() as ScrollContainer
	defilement.size_flags_vertical = Control.SIZE_EXPAND_FILL
	defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	defilement.follow_focus = true
	colonne.add_child(defilement)
	contenu = VBoxContainer.new()
	contenu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_theme_constant_override("separation", 18)
	defilement.add_child(contenu)
	resized.connect(_replacer)
	_replacer.call_deferred()

func configurer(titre: String, glyphe: String) -> void:
	_titre.text = titre
	_embleme.texture = StyleAzur.texture_interface(glyphe) if StyleAzur.TEXTURES_INTERFACE.has(glyphe) or HabillagePeint.contient(glyphe) else StyleAzur.glyphe(glyphe)

func fermer() -> void:
	fermee.emit()
	if detruire_en_fermant:
		queue_free()
	else:
		call_deferred("hide")

func _replacer() -> void:
	if _panneau == null or size.x <= 0.0: return
	var marge := maxf(24.0, size.x * 0.05)
	var hauteur_libre := maxf(0.0, size.y - Ecran.marge_haute() - Ecran.marge_basse() - 96.0)
	_panneau.size = Vector2(minf(840.0, size.x - marge * 2.0), minf(820.0, hauteur_libre))
	_panneau.position = (size - _panneau.size) * 0.5

func _unhandled_key_input(evenement: InputEvent) -> void:
	if visible and evenement.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		fermer()
