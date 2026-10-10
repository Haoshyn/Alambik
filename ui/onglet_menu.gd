class_name OngletMenu
extends Button

var symbole := "stats"
var libelle := ""
var index_icone := 0
var _selection := 0.0
var _pression := 0.0
var _illustration: TextureRect
var _texte: Label
var _separateur: TextureRect
var _accent: TextureRect
var _fond_actif: Panel

const EMBLEMES := [
	preload("res://assets/visual/interface/menu/navigation/heros.svg"),
	preload("res://assets/visual/interface/menu/navigation/forge.svg"),
	preload("res://assets/visual/interface/menu/navigation/portail.svg"),
	preload("res://assets/visual/interface/menu/navigation/astrolabe.svg"),
	preload("res://assets/visual/interface/menu/navigation/grimoire.svg"),
]
const SEPARATEUR := preload("res://assets/visual/interface/menu/navigation_separateur.svg")
const ACCENT := preload("res://assets/visual/interface/menu/navigation_accent.svg")
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
	# Pastille bombee derriere l'onglet actif, a la couleur de son menu.
	_fond_actif = Panel.new()
	_fond_actif.name = "FondActif"
	_fond_actif.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fond_actif.add_theme_stylebox_override("panel",
		StyleJeu.boite(StyleAzur.teinte_proche(StyleAzur.ACCENTS_MENU[index_icone]), 26.0))
	add_child(_fond_actif)
	_illustration = TextureRect.new()
	_illustration.texture = EMBLEMES[index_icone]
	_illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_illustration.name = "Icone"
	add_child(_illustration)
	_texte = StyleAzur.texte(libelle, 25, StyleAzur.ACCENTS_MENU[index_icone])
	_texte.name = "Libelle"
	_texte.autowrap_mode = TextServer.AUTOWRAP_OFF
	_texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_texte)
	_accent = TextureRect.new()
	_accent.name = "LigneAccent"
	_accent.texture = ACCENT
	_accent.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_accent.stretch_mode = TextureRect.STRETCH_SCALE
	_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_accent)
	_separateur = TextureRect.new()
	_separateur.name = "Separateur"
	_separateur.texture = SEPARATEUR
	_separateur.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_separateur.stretch_mode = TextureRect.STRETCH_SCALE
	_separateur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_separateur.visible = index_icone < 4
	add_child(_separateur)
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
	var cote := minf(90.0, size.y * 0.6) * (1.0 + _selection * 0.16 - _pression * 0.06)
	_illustration.position = Vector2((size.x - cote) * 0.5, 4.0 - _selection * 16.0 + _pression * 4.0)
	_illustration.size = Vector2.ONE * cote
	_illustration.modulate = Color("c4c7de").lerp(Color.WHITE, 0.35 + _selection * 0.65)
	_fond_actif.position = Vector2(6.0, 4.0 - _selection * 6.0 + _pression * 3.0)
	_fond_actif.size = Vector2(maxf(0.0, size.x - 12.0), maxf(0.0, size.y - 14.0))
	_fond_actif.modulate.a = _selection
	_fond_actif.visible = _selection > 0.01
	var taille := 28 if actif else 24
	var police: Font = Polices.JEU_FORT if actif else Polices.JEU
	while taille > 20 and police.get_string_size(libelle, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > size.x - 12:
		taille -= 1
	_texte.add_theme_font_override("font", police)
	_texte.add_theme_font_size_override("font_size", taille)
	_texte.add_theme_color_override("font_color", Color.WHITE if actif else StyleAzur.ACCENTS_MENU[index_icone])
	_texte.modulate.a = 0.85 + _selection * 0.15
	_texte.visible = size.x >= 105.0 or actif
	_texte.position = Vector2(0, size.y - 63)
	_texte.size = Vector2(size.x, 46)
	_accent.position = Vector2(8, size.y - 11)
	_accent.size = Vector2(maxf(0.0, size.x - 16.0), 9)
	_accent.modulate = StyleAzur.ACCENTS_MENU[index_icone]
	_accent.modulate.a = 0.55 + _selection * 0.45
	_separateur.position = Vector2(size.x - 7, 23)
	_separateur.size = Vector2(12, size.y - 40)
