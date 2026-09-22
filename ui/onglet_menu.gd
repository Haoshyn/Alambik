class_name OngletMenu
extends Button

var symbole := "stats"
var libelle := ""
var index_icone := 0
var _selection := 0.0
var _pression := 0.0
var _illustration: TextureRect
var _trait_selection: Panel
var _texte: Label
var actif := false:
	set(valeur):
		actif = valeur
		set_process(true)

func configurer(symbole_: String, libelle_ := "", index_icone_ := 0) -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	StyleInterface.rendre_invisible(self)
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	symbole = symbole_
	libelle = libelle_
	index_icone = index_icone_
	custom_minimum_size = Vector2(0, 164)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tooltip_text = libelle
	_trait_selection = Panel.new()
	_trait_selection.name = "Selection"
	_trait_selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style_trait := StyleBoxFlat.new()
	style_trait.bg_color = StyleAzur.MAGIE
	style_trait.set_corner_radius_all(4)
	_trait_selection.add_theme_stylebox_override("panel", style_trait)
	_trait_selection.modulate.a = 0.0
	add_child(_trait_selection)
	var emblemes := ["heros", "forge", "portail", "astrolabe", "grimoire"]
	_illustration = StyleAzur.illustration(emblemes[index_icone], 0)
	_illustration.name = "Icone"
	add_child(_illustration)
	_texte = StyleAzur.texte(libelle, 25, StyleAzur.ATTENUE)
	_texte.name = "Libelle"
	_texte.autowrap_mode = TextServer.AUTOWRAP_OFF
	_texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texte.add_theme_constant_override("outline_size", 3)
	_texte.add_theme_color_override("font_outline_color", StyleAzur.OMBRE_CLAIRIERE)
	add_child(_texte)
	resized.connect(_replacer)
	button_down.connect(func() -> void:
		_pression = 1.0
		_replacer())
	button_up.connect(func() -> void:
		_pression = 0.0
		_replacer())
	_replacer()

func _process(delta: float) -> void:
	var cible := 1.0 if actif else 0.0
	_selection = move_toward(_selection, cible, delta * (18.0 if ReglagesJoueur.effets_reduits else 10.0))
	_replacer()
	if is_equal_approx(_selection, cible): set_process(false)

func _replacer() -> void:
	if _illustration == null or size.x <= 0.0: return
	_trait_selection.size = Vector2(minf(62.0, size.x * 0.55), 5.0)
	_trait_selection.position = Vector2((size.x - _trait_selection.size.x) * 0.5, size.y - 7.0)
	_trait_selection.modulate.a = _selection
	var cote := minf(108.0, size.y * 0.62) * (1.0 + _selection * 0.06 - _pression * 0.05)
	_illustration.position = Vector2((size.x - cote) * 0.5, 13.0 - _selection * 5.0 + _pression * 3.0)
	_illustration.size = Vector2.ONE * cote
	_illustration.modulate = Color("97a6c9").lerp(Color.WHITE, _selection)
	var taille := 25
	while taille > 18 and Polices.CORPS.get_string_size(libelle, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > size.x - 12:
		taille -= 1
	_texte.add_theme_font_size_override("font_size", taille)
	_texte.add_theme_color_override("font_color", Color("bcc8e0").lerp(StyleAzur.MAGIE, _selection))
	_texte.position = Vector2(0, size.y - 43)
	_texte.size = Vector2(size.x, 34)
