class_name CarteReactif
extends Button

signal choisie(id: String)

const HAUTEUR := 250.0

var reactif: Reactif
var pour_choix := false
var selectionnee := false:
	set(valeur):
		selectionnee = valeur
		if is_node_ready():
			_appliquer_cadre()
var desactivee := false:
	set(valeur):
		desactivee = valeur
		disabled = valeur
		if is_instance_valid(_contenu):
			_contenu.modulate.a = 0.45 if valeur else 1.0

var _contenu: MarginContainer

func configurer(reactif_: Reactif) -> void:
	reactif = reactif_
	custom_minimum_size = Vector2(0, HAUTEUR)
	if is_node_ready():
		_construire()

func _ready() -> void:
	custom_minimum_size = Vector2(0, HAUTEUR)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	StyleInterface.styliser_bouton(self)
	pressed.connect(_sur_appui)
	_construire()

func _construire() -> void:
	if reactif == null:
		return
	if is_instance_valid(_contenu):
		remove_child(_contenu)
		_contenu.queue_free()
	_appliquer_cadre()
	tooltip_text = "%s — %s" % [reactif.nom, reactif.description]
	_contenu = MarginContainer.new()
	_contenu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_contenu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contenu.modulate.a = 0.45 if desactivee else 1.0
	for cote in ["left", "right"]:
		_contenu.add_theme_constant_override("margin_" + cote, 44)
	for cote in ["top", "bottom"]:
		_contenu.add_theme_constant_override("margin_" + cote, 44)
	add_child(_contenu)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 26)
	_contenu.add_child(ligne)
	var illustration := Control.new()
	illustration.custom_minimum_size = Vector2(156, 156)
	illustration.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_child(illustration)
	var medaillon := Panel.new()
	HabillagePeint.appliquer(medaillon)
	medaillon.add_theme_stylebox_override("panel", StyleAzur.cercle())
	medaillon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	medaillon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	illustration.add_child(medaillon)
	var glyphe := StyleAzur.vignette(reactif.id, 88)
	glyphe.position = Vector2(34, 34)
	glyphe.size = Vector2(88, 88)
	illustration.add_child(glyphe)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.add_theme_constant_override("separation", 8)
	ligne.add_child(textes)
	var possedees := Jeu.copies(reactif.id)
	var etiquette := reactif.nom_rarete().to_upper()
	if pour_choix and reactif.copies_permises() > 1 and not reactif.mods.has("soin_part"):
		etiquette += "  ·  Rang %d / %d" % [possedees + 1, reactif.copies_permises()]
	elif not pour_choix and possedees > 0:
		etiquette += "  ·  Acquis ×%d" % possedees
	textes.add_child(StyleAzur.texte(etiquette, 22, reactif.couleur_rarete()))
	var filet := ColorRect.new()
	filet.color = Color(reactif.couleur_rarete(), 0.82)
	filet.custom_minimum_size = Vector2(90, 3)
	filet.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	filet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.add_child(filet)
	textes.add_child(StyleAzur.texte(reactif.nom, 35, StyleAzur.IVOIRE))
	textes.add_child(StyleAzur.texte(reactif.description, 27, StyleAzur.ATTENUE))
	if pour_choix and reactif.rarete != Reactif.COMMUN:
		textes.add_child(StyleAzur.texte(DetailsReactif.texte(reactif), 24, reactif.couleur_rarete()))
	# Les descriptions longues agrandissent la carte au lieu de chevaucher la suivante.
	_contenu.minimum_size_changed.connect(_adapter_hauteur)
	_adapter_hauteur.call_deferred()

func _adapter_hauteur() -> void:
	if is_instance_valid(_contenu):
		custom_minimum_size.y = maxf(HAUTEUR, _contenu.get_combined_minimum_size().y)

func _appliquer_cadre() -> void:
	if reactif == null:
		return
	var accent := reactif.couleur_rarete()
	add_theme_stylebox_override("normal", StyleAzur.carte_augment(accent, selectionnee))
	add_theme_stylebox_override("hover", StyleAzur.carte_augment(accent, true))
	add_theme_stylebox_override("pressed", StyleAzur.carte_augment(StyleAzur.IVOIRE, true))
	add_theme_stylebox_override("disabled", StyleAzur.carte_augment(accent if selectionnee else accent.darkened(0.5), selectionnee))
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _sur_appui() -> void:
	if desactivee or reactif == null:
		return
	if not pour_choix:
		Sons.jouer("choix", -14.0)
	choisie.emit(reactif.id)
