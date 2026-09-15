extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	marge.offset_top = 210
	marge.offset_left = 30
	marge.offset_right = -30
	marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marge)
	var col := StyleAzur.plaque(marge)
	col.add_child(StyleAzur.texte("Premiers pas", 32))
	col.add_child(StyleAzur.texte("Glissez le doigt pour vous déplacer. Arrêtez-vous pour tirer automatiquement.\nÉvitez les attaques, puis prenez le portail quand la salle est vide.\nVotre première victoire garantit un bijou : équipez-le à l’atelier !", 25))
	col.add_child(StyleAzur.bouton("Compris", _fermer))
	# Le conseil laisse les gestes parvenir au joystick et ne suspend jamais la run.
	for enfant in [col, col.get_parent()]:
		enfant.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _fermer() -> void:
	ReglagesJoueur.tutoriel_vu = true
	ReglagesJoueur.sauvegarder()
	queue_free()
