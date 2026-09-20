class_name StyleInterface
extends RefCounted

# Les coins du kit restent fixes pour que les ornements ne se deforment pas.
static func panneau(fond: Color, bord: Color, rayon := 24, _ombre := 10) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = HabillagePeint.texture("medaillon" if rayon >= 60 else "panneau")
	if fond.a == 0.0:
		style.draw_center = false
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_texture_margin(cote, 24)
	for cote in [SIDE_LEFT, SIDE_RIGHT]: style.set_content_margin(cote, 44)
	for cote in [SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(cote, 30)
	style.modulate_color = Color.WHITE.lerp(bord, 0.18)
	style.modulate_color.a = fond.a if fond.a > 0.0 else bord.a
	return style

static func panneau_leger(accent := Palette.ESSENCE, rayon := 22) -> StyleBoxTexture:
	return panneau(Color(0.075, 0.105, 0.205, 0.9), accent, rayon, 6)

# Les ecrans premium sont peints : leurs boutons ne sont que des zones tactiles
# posees sur la peinture. Un Button garde pourtant ses styleboxes de survol, de
# clic et de focus, que Godot dessine par-dessus le decor — d'ou les rectangles
# gris qui apparaissaient sous la souris. `flat` n'enleve que l'etat normal.
static func rendre_invisible(bouton: Button) -> Button:
	bouton.flat = true
	bouton.focus_mode = Control.FOCUS_NONE
	bouton.mouse_filter = Control.MOUSE_FILTER_STOP
	var vide := StyleBoxEmpty.new()
	for etat in ["normal", "hover", "pressed", "focus", "disabled"]:
		bouton.add_theme_stylebox_override(etat, vide)
	return bouton

static func zone_tactile(action := Callable()) -> Button:
	var bouton := Button.new()
	HabillagePeint.appliquer(bouton)
	rendre_invisible(bouton)
	if action.is_valid():
		bouton.pressed.connect(action)
	return bouton

static func styliser_bouton(bouton: Button, accent := Palette.OR, secondaire := false) -> void:
	HabillagePeint.appliquer(bouton)
	# Pas de focus clavier ni de déclenchement au premier contact : sur mobile,
	# le joueur doit pouvoir glisser hors du bouton pour annuler son geste.
	bouton.focus_mode = Control.FOCUS_NONE
	bouton.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	var fond := Color(0.095, 0.125, 0.235, 0.96) if secondaire else Color(accent.darkened(0.46), 0.94)
	bouton.add_theme_stylebox_override("normal", panneau(fond, Color(accent, 0.42), 0, 0))
	# L'état hover ne porte aucune information : un écran tactile n'en a pas.
	bouton.add_theme_stylebox_override("hover", panneau(fond, Color(accent, 0.42), 0, 0))
	bouton.add_theme_stylebox_override("pressed", panneau(Color(accent, 0.48), accent.lightened(0.24), 0, 3))
	bouton.add_theme_stylebox_override("focus", panneau(Color(accent, 0.24), accent, 0, 0))
	bouton.add_theme_stylebox_override("disabled", panneau(Color(0.06, 0.05, 0.08, 0.72), Color(accent, 0.14), 0, 0))
	bouton.add_theme_color_override("font_color", Palette.TEXTE)
	bouton.add_theme_color_override("font_hover_color", Color.WHITE)
	bouton.add_theme_color_override("font_pressed_color", Color.WHITE)
	bouton.add_theme_color_override("font_focus_color", Color.WHITE)
	bouton.add_theme_color_override("font_disabled_color", Color("dedceb"))
	bouton.add_theme_constant_override("outline_size", 4)
	bouton.add_theme_constant_override("icon_max_width", 64)
	bouton.add_theme_constant_override("h_separation", 16)
	bouton.add_theme_color_override("font_outline_color", Color(0.03, 0.05, 0.13, 0.88))
	if not bouton.has_meta("micro_animation_installee"):
		bouton.set_meta("micro_animation_installee", true)
		bouton.resized.connect(func() -> void: bouton.pivot_offset = bouton.size * 0.5)
		bouton.button_down.connect(func() -> void:
			StyleInterface._animer_bouton(bouton,
				Vector2.ONE * (0.985 if ReglagesJoueur.effets_reduits else 0.955), true))
		bouton.button_up.connect(func() -> void:
			StyleInterface._animer_bouton(bouton, Vector2.ONE, false))

static func _animer_bouton(bouton: Button, echelle: Vector2, enfonce: bool) -> void:
	if not is_instance_valid(bouton):
		return
	var precedente: Variant = bouton.get_meta("micro_animation") if bouton.has_meta("micro_animation") else null
	if precedente is Tween and (precedente as Tween).is_valid():
		(precedente as Tween).kill()
	var animation := bouton.create_tween()
	animation.set_trans(Tween.TRANS_QUINT if enfonce else Tween.TRANS_BACK)
	animation.set_ease(Tween.EASE_OUT)
	animation.tween_property(bouton, "scale", echelle,
		0.06 if ReglagesJoueur.effets_reduits else (0.09 if enfonce else 0.20))
	bouton.set_meta("micro_animation", animation)

static func styliser_selecteur(selecteur: OptionButton, accent := Palette.ESSENCE) -> void:
	HabillagePeint.appliquer(selecteur)
	selecteur.focus_mode = Control.FOCUS_NONE
	selecteur.add_theme_font_size_override("font_size", 23)
	selecteur.add_theme_color_override("font_color", Palette.TEXTE)
	selecteur.add_theme_color_override("font_disabled_color", Color("dedceb"))
	selecteur.add_theme_stylebox_override("normal", panneau_leger(accent, 18))
	selecteur.add_theme_stylebox_override("hover",
		panneau(Color(accent, 0.10), Color(accent, 0.48), 18, 4))
	selecteur.add_theme_stylebox_override("pressed",
		panneau(Color(accent, 0.16), Color(accent, 0.68), 18, 3))
	selecteur.add_theme_stylebox_override("disabled",
		panneau(Color(0.025, 0.022, 0.040, 0.72), Color(accent, 0.12), 18, 1))
	var menu := selecteur.get_popup()
	menu.add_theme_font_size_override("font_size", 22)
	menu.add_theme_color_override("font_color", Palette.TEXTE)
	menu.add_theme_color_override("font_hover_color", Color.WHITE)
	menu.add_theme_stylebox_override("panel", panneau(Color(0.025, 0.020, 0.045, 0.99),
		Color(accent, 0.42), 18, 8))

static func animer_entree(controle: Control, distance := 22.0) -> void:
	var duree_fondu := 0.12 if ReglagesJoueur.effets_reduits else 0.28
	var duree_mouvement := 0.16 if ReglagesJoueur.effets_reduits else 0.42
	var mouvement := distance * (0.25 if ReglagesJoueur.effets_reduits else 1.0)
	var place_par_conteneur := controle.get_parent() is Container
	controle.modulate.a = 0.0
	# Le conteneur place les recompenses apres leur affichage ; un tween ne doit pas ecraser cette position.
	if not place_par_conteneur:
		controle.position.y += mouvement
		controle.pivot_offset = controle.size * 0.5
		controle.scale = Vector2.ONE * (0.985 if ReglagesJoueur.effets_reduits else 0.925)
	var animation := controle.create_tween()
	animation.set_parallel(true)
	animation.set_trans(Tween.TRANS_QUINT)
	animation.set_ease(Tween.EASE_OUT)
	animation.tween_property(controle, "modulate:a", 1.0, duree_fondu)
	if not place_par_conteneur:
		animation.tween_property(controle, "position:y", controle.position.y - mouvement, duree_mouvement)
		animation.tween_property(controle, "scale", Vector2.ONE, duree_mouvement)

# L'action n'est executee qu'une fois l'ecran sorti. Cela evite les queue_free
# et changements de scene secs encore visibles pendant la derniere image.
static func sortir_puis(controle: Control, action: Callable, distance := -18.0) -> void:
	if controle.has_meta("sortie_interface_en_cours"):
		return
	controle.set_meta("sortie_interface_en_cours", true)
	controle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var duree := 0.11 if ReglagesJoueur.effets_reduits else 0.34
	var mouvement := distance * (0.25 if ReglagesJoueur.effets_reduits else 1.0)
	var animation := controle.create_tween()
	animation.set_parallel(true)
	animation.set_trans(Tween.TRANS_QUINT)
	animation.set_ease(Tween.EASE_IN)
	animation.tween_property(controle, "modulate:a", 0.0, duree)
	animation.tween_property(controle, "position:y", controle.position.y + mouvement, duree)
	animation.tween_property(controle, "scale", Vector2.ONE *
		(0.98 if ReglagesJoueur.effets_reduits else 1.065), duree)
	animation.chain().tween_callback(action)
