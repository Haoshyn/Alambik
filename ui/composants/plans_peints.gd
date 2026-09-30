extends Control

var _vue_peinte: SubViewport

func _creer_plans(nom: String) -> Control:
	_vue_peinte = SubViewport.new()
	_vue_peinte.name = "RenduPeinture"
	_vue_peinte.disable_3d = true
	_vue_peinte.transparent_bg = true
	_vue_peinte.gui_disable_input = true
	# Les mouvements lents doivent conserver leurs fractions de pixel, sans
	# changer la grille utilisee par les textes et commandes du menu.
	_vue_peinte.gui_snap_controls_to_pixels = false
	_vue_peinte.snap_2d_transforms_to_pixel = false
	_vue_peinte.snap_2d_vertices_to_pixel = false
	add_child(_vue_peinte)

	var sortie := TextureRect.new()
	sortie.name = "PeintureComposee"
	sortie.texture = _vue_peinte.get_texture()
	sortie.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sortie.stretch_mode = TextureRect.STRETCH_SCALE
	sortie.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sortie.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sortie)
	sortie.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var plans := Control.new()
	plans.name = nom
	plans.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vue_peinte.add_child(plans)
	resized.connect(_dimensionner_vue)
	get_viewport().size_changed.connect(_dimensionner_vue)
	visibility_changed.connect(_actualiser_vue)
	ReglagesJoueur.reglages_changes.connect(_actualiser_vue)
	_dimensionner_vue()
	return plans

func _dimensionner_vue() -> void:
	if not is_instance_valid(_vue_peinte) or size.x <= 0.0 or size.y <= 0.0:
		return
	# Le rendu suit les pixels affiches, meme lorsque le menu logique de
	# 1080 px est reduit sur telephone. Il ne reserve pas une grande texture source.
	var dimensions := size * get_screen_transform().get_scale().abs()
	_vue_peinte.size = Vector2i(maxi(2, ceili(dimensions.x)), maxi(2, ceili(dimensions.y)))
	_vue_peinte.canvas_transform = Transform2D.IDENTITY.scaled(Vector2(_vue_peinte.size) / size)
	_actualiser_vue()

func _actualiser_vue() -> void:
	if not is_instance_valid(_vue_peinte):
		return
	if not is_visible_in_tree():
		_vue_peinte.render_target_update_mode = SubViewport.UPDATE_DISABLED
	elif ReglagesJoueur.effets_reduits:
		# Un seul rendu conserve toutes les couches lors d'un recadrage ou du gel.
		_vue_peinte.render_target_update_mode = SubViewport.UPDATE_ONCE
	else:
		_vue_peinte.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
