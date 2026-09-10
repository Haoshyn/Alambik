class_name OngletMenu
extends Button

var symbole := "stats"
var libelle := ""
var index_icone := 0
var _selection := 0.0
var _pression := 0.0
var actif := false:
	set(valeur):
		actif = valeur
		queue_redraw()

func configurer(symbole_: String, libelle_ := "", index_icone_ := 0) -> void:
	symbole = symbole_
	libelle = libelle_
	index_icone = index_icone_
	flat = true
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(0.0, 112.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_down.connect(func() -> void: _pression = 1.0)
	button_up.connect(func() -> void: _pression = 0.0)
	queue_redraw()

func _process(delta: float) -> void:
	var cible := 1.0 if actif else 0.0
	var vitesse := 18.0 if ReglagesJoueur.effets_reduits else 10.0
	var avant := _selection
	_selection = move_toward(_selection, cible, delta * vitesse)
	if not is_equal_approx(avant, _selection) or _pression > 0.0:
		queue_redraw()

func _draw() -> void:
	# Les quatre vignettes viennent de la barre d'accueil approuvee.
	var source := Rect2(index_icone * 256, 1350, 256, 150)
	var hauteur := size.x * 150.0 / 256.0
	draw_texture_rect_region(preload("res://assets/visual/azur/accueil_valide.png"),
		Rect2(0, 0, size.x, hauteur), source, Color.WHITE.darkened(_pression * 0.12))
	if _selection > 0.001:
		var y := hauteur + 8.0
		draw_line(Vector2(size.x * 0.18, y), Vector2(size.x * 0.82, y), Color(StyleAzur.MAGIE, 0.16 * _selection), 12.0, true)
		draw_line(Vector2(size.x * 0.22, y), Vector2(size.x * 0.78, y), Color(StyleAzur.MAGIE, _selection), 3.0, true)
		draw_circle(Vector2(size.x * 0.5, y), 3.0, Color(StyleAzur.TEXTE, _selection))
