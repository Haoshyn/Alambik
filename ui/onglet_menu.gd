class_name OngletMenu
extends Button

var symbole := "stats"
var libelle := ""
var index_icone := 0
var _selection := 0.0
var _pression := 0.0
var _embleme := ""
var _illustration: TextureRect
var actif := false:
	set(valeur):
		actif = valeur
		queue_redraw()

func configurer(symbole_: String, libelle_ := "", index_icone_ := 0) -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	HabillagePeint.appliquer(self)
	symbole = symbole_
	libelle = libelle_
	index_icone = index_icone_
	var emblemes := ["forge", "portail", "astrolabe", "grimoire"]
	_embleme = emblemes[index_icone]
	_illustration = StyleAzur.illustration(_embleme, 0)
	add_child(_illustration)
	resized.connect(_replacer_illustration)
	flat = true
	for etat in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(etat, StyleBoxEmpty.new())
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(0, 164)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tooltip_text = libelle
	button_down.connect(func() -> void:
		_pression = 1.0
		_replacer_illustration()
		queue_redraw())
	button_up.connect(func() -> void:
		_pression = 0.0
		_replacer_illustration()
		queue_redraw())
	_replacer_illustration()
	queue_redraw()

func _process(delta: float) -> void:
	var cible := 1.0 if actif else 0.0
	var vitesse := 18.0 if ReglagesJoueur.effets_reduits else 10.0
	var avant := _selection
	_selection = move_toward(_selection, cible, delta * vitesse)
	if not is_equal_approx(avant, _selection) or _pression > 0.0:
		_replacer_illustration()
		queue_redraw()

func _replacer_illustration() -> void:
	if _illustration == null:
		return
	var hauteur_icone := minf(116.0, size.y * 0.66)
	var centre := Vector2(size.x * 0.5, 69.0 - _selection * 4.0 + _pression * 3.0)
	_illustration.position = centre - Vector2.ONE * hauteur_icone * 0.5
	_illustration.size = Vector2.ONE * hauteur_icone
	_illustration.modulate = Color("cbd2e7").lerp(Color.WHITE, _selection)

func _draw() -> void:
	if _selection > 0.0 or _pression > 0.0:
		var halo := StyleAzur.texture_interface("selection_onglet")
		draw_texture_rect(halo, Rect2(Vector2(8, 6), size - Vector2(16, 10)), false, Color(1.0, 1.0, 1.0, maxf(_selection, _pression * 0.5)))
	var police := Polices.CORPS
	var taille := 25
	while taille > 16 and police.get_string_size(libelle, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > size.x - 16:
		taille -= 1
	var largeur := police.get_string_size(libelle, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	var origine := Vector2((size.x - largeur) * 0.5, size.y - 27)
	draw_string_outline(police, origine, libelle, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, 3, Color("160d30"))
	draw_string(police, origine, libelle, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, StyleAzur.IVOIRE if actif else StyleAzur.ATTENUE)
