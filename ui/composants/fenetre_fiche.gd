class_name FenetreFiche
extends Control

signal fermee

var detruire_en_fermant := true
var contenu: VBoxContainer
var pied: VBoxContainer
var largeur_max := 840.0
var hauteur_max := 820.0
var presentation_soignee := false
var accent := Color("f5dbaa")
var _panneau: Panel
var _titre: Label
var _embleme: TextureRect
var _entete: HBoxContainer
var _voile: ColorRect
var _animation: Tween
var _validation: Tween
var _mise_en_page: Tween
var _taille_cible := Vector2.ZERO
var _position_cible := Vector2.ZERO
var _fermeture_en_cours := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 20
	mouse_filter = Control.MOUSE_FILTER_STOP
	_voile = ColorRect.new()
	_voile.color = Color("253a6299") if presentation_soignee else Color("141d3bc4")
	_voile.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_voile)
	_voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_voile.gui_input.connect(func(evenement: InputEvent) -> void:
		if (evenement is InputEventMouseButton and evenement.pressed and evenement.button_index == MOUSE_BUTTON_LEFT) or (evenement is InputEventScreenTouch and evenement.pressed):
			get_viewport().set_input_as_handled()
			fermer())
	_panneau = Panel.new()
	_panneau.mouse_filter = Control.MOUSE_FILTER_STOP
	_panneau.add_theme_stylebox_override("panel", StyleAzur.cadre(StyleAzur.PANNEAU, StyleAzur.LILAS))
	add_child(_panneau)
	_panneau.resized.connect(func() -> void:
		if presentation_soignee: _panneau.pivot_offset = _panneau.size * 0.5)
	if presentation_soignee:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("334f70")
		style.border_color = Color(accent, 0.8)
		style.set_border_width_all(2)
		style.set_corner_radius_all(28)
		style.shadow_color = Color("26345066")
		style.shadow_size = 16
		style.shadow_offset = Vector2(0, 8)
		_panneau.add_theme_stylebox_override("panel", style)
		var gravure := CadreAtelier.new()
		gravure.accent = accent
		_panneau.add_child(gravure)
	var marges := MarginContainer.new()
	_panneau.add_child(marges)
	marges.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for cote in ["left", "right"]: marges.add_theme_constant_override("margin_" + cote, 44)
	for cote in ["top", "bottom"]: marges.add_theme_constant_override("margin_" + cote, 42)
	var colonne := VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 20)
	marges.add_child(colonne)
	_entete = HBoxContainer.new()
	_entete.add_theme_constant_override("separation", 18)
	colonne.add_child(_entete)
	_embleme = StyleAzur.illustration("grimoire", 74)
	_embleme.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_entete.add_child(_embleme)
	_titre = StyleAzur.texte("", 42, Color("f7e4c2"))
	_titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_entete.add_child(_titre)
	var fermer_bouton := StyleAzur.bouton_rond("×", fermer, 88)
	fermer_bouton.tooltip_text = "Fermer la fiche"
	fermer_bouton.accessibility_name = "Fermer la fiche"
	fermer_bouton.size_flags_horizontal = Control.SIZE_SHRINK_END
	_entete.add_child(fermer_bouton)
	var defilement := preload("res://ui/composants/defilement_tactile.gd").new() as ScrollContainer
	defilement.size_flags_vertical = Control.SIZE_EXPAND_FILL
	defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	defilement.follow_focus = true
	colonne.add_child(defilement)
	contenu = VBoxContainer.new()
	contenu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_theme_constant_override("separation", 18)
	defilement.add_child(contenu)
	contenu.minimum_size_changed.connect(func(): _replacer.call_deferred())
	pied = VBoxContainer.new()
	pied.visible = false
	colonne.add_child(pied)
	pied.minimum_size_changed.connect(func(): _replacer.call_deferred())
	resized.connect(_replacer)
	_replacer.call_deferred()
	visibility_changed.connect(func() -> void:
		if visible: _animer_entree.call_deferred())
	_animer_entree.call_deferred()

func configurer(titre: String, glyphe: String) -> void:
	_titre.text = titre
	_embleme.texture = StyleAzur.texture_interface(glyphe) if StyleAzur.TEXTURES_INTERFACE.has(glyphe) or HabillagePeint.contient(glyphe) else StyleAzur.glyphe(glyphe)
	_replacer.call_deferred()

func definir_embleme(texture: Texture2D) -> void:
	_embleme.texture = texture

func vider() -> void:
	# Une transaction met a jour la fiche en place, sans rejouer son ouverture.
	for colonne: VBoxContainer in [contenu, pied]:
		for enfant in colonne.get_children():
			colonne.remove_child(enfant)
			enfant.queue_free()
	pied.visible = false

func souligner_validation() -> void:
	if is_instance_valid(_validation): _validation.kill()
	if ReglagesJoueur.effets_reduits: return
	contenu.modulate = Color.WHITE.lerp(accent, 0.25)
	_validation = create_tween()
	_validation.tween_property(contenu, "modulate", Color.WHITE, 0.30)

func fermeture_en_cours() -> bool:
	return _fermeture_en_cours

func fermer() -> void:
	if _fermeture_en_cours or not visible:
		return
	_fermeture_en_cours = true
	if is_instance_valid(_mise_en_page): _mise_en_page.kill()
	if presentation_soignee:
		for bouton: Button in _panneau.find_children("*", "Button", true, false):
			bouton.disabled = true
	if is_instance_valid(_animation) and _animation.is_valid():
		_animation.kill()
	if ReglagesJoueur.effets_reduits:
		_achever_fermeture()
		return
	_animation = create_tween().set_parallel(true)
	_animation.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_animation.tween_property(_voile, "modulate:a", 0.0, 0.19)
	_animation.tween_property(_panneau, "modulate:a", 0.0, 0.17)
	_animation.tween_property(_panneau, "scale", Vector2.ONE * 0.96, 0.19)
	_animation.chain().tween_callback(_achever_fermeture)

func _achever_fermeture() -> void:
	fermee.emit()
	if detruire_en_fermant:
		queue_free()
	else:
		hide()
		_fermeture_en_cours = false

func _animer_entree() -> void:
	if not visible or _fermeture_en_cours:
		return
	if is_instance_valid(_animation) and _animation.is_valid():
		_animation.kill()
	_replacer()
	_panneau.pivot_offset = _panneau.size * 0.5
	if presentation_soignee and ReglagesJoueur.effets_reduits:
		_panneau.scale = Vector2.ONE
		_panneau.modulate.a = 1.0
		_voile.modulate.a = 1.0
		return
	_panneau.scale = Vector2.ONE * (0.98 if ReglagesJoueur.effets_reduits else 0.91)
	_panneau.modulate.a = 0.0
	_voile.modulate.a = 0.0
	_animation = create_tween().set_parallel(true)
	_animation.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_animation.tween_property(_voile, "modulate:a", 1.0, 0.10 if ReglagesJoueur.effets_reduits else 0.20)
	_animation.tween_property(_panneau, "modulate:a", 1.0, 0.10 if ReglagesJoueur.effets_reduits else 0.23)
	_animation.tween_property(_panneau, "scale", Vector2.ONE, 0.15 if ReglagesJoueur.effets_reduits else 0.34)

func _replacer() -> void:
	if _panneau == null or _entete == null or contenu == null or size.x <= 0.0: return
	if _fermeture_en_cours: return
	var marge := maxf(24.0, size.x * 0.05)
	var hauteur_libre := maxf(0.0, size.y - Ecran.marge_haute() - Ecran.marge_basse() - 96.0)
	var hauteur_contenu := 84.0 + _entete.get_combined_minimum_size().y + 20.0 + contenu.get_combined_minimum_size().y
	if pied.visible:
		hauteur_contenu += 20.0 + pied.get_combined_minimum_size().y
	var taille := Vector2(minf(largeur_max, size.x - marge * 2.0), minf(hauteur_libre, minf(hauteur_max, maxf(300.0, hauteur_contenu))))
	var position_panneau := (size - taille) * 0.5
	if taille.is_equal_approx(_taille_cible) and position_panneau.is_equal_approx(_position_cible): return
	_taille_cible = taille
	_position_cible = position_panneau
	if is_instance_valid(_mise_en_page): _mise_en_page.kill()
	var ouverture := is_instance_valid(_animation) and _animation.is_running()
	if presentation_soignee and not ReglagesJoueur.effets_reduits and _panneau.size.x > 0.0 and not ouverture:
		_mise_en_page = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_mise_en_page.tween_property(_panneau, "size", taille, 0.20)
		_mise_en_page.tween_property(_panneau, "position", position_panneau, 0.20)
	else:
		_panneau.size = taille
		_panneau.position = position_panneau

func _unhandled_key_input(evenement: InputEvent) -> void:
	if visible and evenement.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		fermer()
