class_name CommandeDepart
extends VBoxContainer

signal destination_demandee
signal depart_demande

var _chapitre: Label
var _mode: Label
var _embleme: TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 16)
	var destination := StyleAzur.bouton("", func(): destination_demandee.emit())
	destination.name = "Destination"
	StyleAzur.habiller_lecture(destination)
	destination.tooltip_text = "Choisir un chapitre ou un mode"
	destination.custom_minimum_size.y = 136
	add_child(destination)
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for cote in ["left", "right", "top", "bottom"]:
		marge.add_theme_constant_override("margin_" + cote, 44)
	destination.add_child(marge)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 18)
	marge.add_child(ligne)
	_embleme = StyleAzur.illustration("grimoire", 82)
	ligne.add_child(_embleme)
	var textes := VBoxContainer.new()
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	textes.add_theme_constant_override("separation", 2)
	ligne.add_child(textes)
	_mode = StyleAzur.texte("", 21, StyleAzur.CUIVRE)
	textes.add_child(_mode)
	_chapitre = StyleAzur.texte("", 31, StyleAzur.IVOIRE)
	textes.add_child(_chapitre)
	ligne.add_child(StyleAzur.illustration("fleche_droite", 40))
	# Le chapitre peut passer sur deux lignes sans deborder du bouton.
	marge.minimum_size_changed.connect(func(): destination.custom_minimum_size.y = maxf(136.0, marge.get_combined_minimum_size().y))
	var depart := StyleAzur.bouton("JOUER", func(): depart_demande.emit(), true)
	depart.name = "Jouer"
	StyleAzur.habiller_accueil(depart, true)
	depart.add_theme_font_size_override("font_size", 54)
	depart.custom_minimum_size.y = 156
	depart.icon = StyleAzur.texture_interface("portail")
	depart.expand_icon = true
	depart.add_theme_constant_override("icon_max_width", 96)
	depart.add_theme_constant_override("h_separation", 28)
	add_child(depart)

func afficher(chapitre: String, mode: String) -> void:
	_chapitre.text = chapitre
	_mode.text = "CAMPAGNE" if mode == "grimoire" else ("SURVIE" if mode == "mine" else "ÉPREUVES DE MAGIE")
	_embleme.texture = StyleAzur.texture_interface("grimoire" if mode == "grimoire" else ("mine" if mode == "mine" else "epreuves"))
