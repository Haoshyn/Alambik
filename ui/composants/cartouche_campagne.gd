extends Button

var _titre: Label
var _numero: Label
var _monde: Label
var _niveau: Label

func _ready() -> void:
	name = "ChoisirCampagne"
	custom_minimum_size = Vector2(0, 136)
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	for etat in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(etat, StyleAzur.cadre_enlumine(StyleAzur.CUIVRE, etat != "normal"))
	var marge := MarginContainer.new()
	marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marge)
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for cote in ["left", "right"]: marge.add_theme_constant_override("margin_" + cote, 32)
	for cote in ["top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 12)
	var colonne := VBoxContainer.new()
	colonne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colonne.alignment = BoxContainer.ALIGNMENT_CENTER
	marge.add_child(colonne)
	var ligne := HBoxContainer.new()
	ligne.name = "IdentiteMonde"
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.alignment = BoxContainer.ALIGNMENT_CENTER
	ligne.add_theme_constant_override("separation", 9)
	colonne.add_child(ligne)
	_monde = StyleAzur.calligraphie("Monde", 40, StyleAzur.OR_VIF)
	_monde.autowrap_mode = TextServer.AUTOWRAP_OFF
	ligne.add_child(_monde)
	_numero = StyleAzur.texte("", 34, StyleAzur.OR_VIF)
	_numero.name = "NumeroMonde"
	_numero.add_theme_font_override("font", Polices.CHIFFRES)
	_numero.autowrap_mode = TextServer.AUTOWRAP_OFF
	ligne.add_child(_numero)
	_titre = StyleAzur.calligraphie("", 40, StyleAzur.OR_VIF)
	_titre.name = "TitreCampagne"
	_titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titre.autowrap_mode = TextServer.AUTOWRAP_OFF
	ligne.add_child(_titre)
	_niveau = StyleAzur.texte("", 28, StyleAzur.MENTHE)
	_niveau.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonne.add_child(_niveau)
	resized.connect(func():
		for texte in [_monde, _titre]: texte.add_theme_font_size_override("font_size", 30 if size.x < 440 else 40)
		_numero.add_theme_font_size_override("font_size", 28 if size.x < 440 else 34))

func afficher(index_monde: int, numero_niveau: int, nom_monde: String) -> void:
	_numero.text = str(index_monde + 1)
	_titre.text = "· " + nom_monde
	_niveau.text = "Niveau %d  ›" % numero_niveau
	tooltip_text = "Choisir une campagne"
	accessibility_name = "Choisir une campagne. Monde %d, %s, niveau %d." % [index_monde + 1, nom_monde, numero_niveau]
