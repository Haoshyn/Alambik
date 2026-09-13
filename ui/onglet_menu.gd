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
	var r := Rect2(Vector2(8, 8), size - Vector2(16, 16))
	if actif or _pression > 0.0:
		draw_style_box(StyleAzur.cadre(Color("614675"), StyleAzur.CUIVRE, 22), r)
	var cote := minf(86.0, size.y * 0.52)
	var icones := [preload("res://assets/visual/atelier/sac.svg"),preload("res://assets/visual/atelier/boussole.svg"),preload("res://assets/visual/atelier/livre.svg"),preload("res://assets/visual/atelier/fiole.svg")]
	draw_texture_rect(icones[index_icone], Rect2(Vector2((size.x-cote)*0.5,16),Vector2.ONE*cote), false)
	var police := Polices.CORPS
	var taille := 23
	var largeur := police.get_string_size(libelle,HORIZONTAL_ALIGNMENT_LEFT,-1,taille).x
	draw_string(police,Vector2((size.x-largeur)*0.5,size.y-30),libelle,HORIZONTAL_ALIGNMENT_LEFT,-1,taille,Color("fff2dc"))
	if actif:
		draw_line(Vector2(size.x*.3,size.y-13),Vector2(size.x*.7,size.y-13),Color("59d7ca"),4.0,true)
