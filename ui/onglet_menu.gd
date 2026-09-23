class_name OngletMenu
extends Button

var symbole := "stats"
var libelle := ""
var index_icone := 0
var _selection := 0.0
var _pression := 0.0
var _illustration: TextureRect
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
	custom_minimum_size = Vector2(0, 136)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tooltip_text = libelle
	var emblemes := ["heros", "forge", "portail", "astrolabe", "grimoire"]
	_illustration = StyleAzur.illustration(emblemes[index_icone], 0)
	_illustration.name = "Icone"
	add_child(_illustration)
	_texte = StyleAzur.texte(libelle, 28, StyleAzur.ATTENUE)
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
	var cote := minf(100.0, size.y * 0.69) * (1.0 + _selection * 0.12 - _pression * 0.05)
	_illustration.position = Vector2((size.x - cote) * 0.5, 15.0 - _selection * 8.0 + _pression * 3.0)
	_illustration.size = Vector2.ONE * cote
	_illustration.modulate = Color("bdc9e4").lerp(Color.WHITE, _selection)
	var taille := 28
	while taille > 18 and Polices.CORPS.get_string_size(libelle, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > size.x - 12:
		taille -= 1
	_texte.add_theme_font_size_override("font_size", taille)
	_texte.add_theme_color_override("font_color", Color("bcc8e0").lerp(StyleAzur.MAGIE, _selection))
	_texte.modulate.a = _selection
	_texte.position = Vector2(0, size.y - 42)
	_texte.size = Vector2(size.x, 38)
