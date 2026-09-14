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
	var accents := [StyleAzur.CUIVRE, StyleAzur.CORAIL, StyleAzur.MENTHE, StyleAzur.LILAS]
	var accent: Color = accents[index_icone]
	var r := Rect2(Vector2(4, 12), size - Vector2(8, 24))
	if actif or _pression > 0.0:
		draw_style_box(StyleAzur.cadre(StyleAzur.VIOLET, accent, 24), r)
	var cote := minf(72.0, size.y * 0.44)
	var identifiants := ["navigation_equipement", "navigation_aventure", "navigation_maitrises", "navigation_sorts"]
	draw_texture_rect(IconesArcane.texture(identifiants[index_icone]), Rect2(Vector2((size.x-cote)*0.5,24),Vector2.ONE*cote), false)
	var police := Polices.CORPS
	var taille := 23
	while taille > 16 and police.get_string_size(libelle,HORIZONTAL_ALIGNMENT_LEFT,-1,taille).x > size.x-20:
		taille -= 1
	var largeur := police.get_string_size(libelle,HORIZONTAL_ALIGNMENT_LEFT,-1,taille).x
	draw_string(police,Vector2((size.x-largeur)*0.5,size.y-38),libelle,HORIZONTAL_ALIGNMENT_LEFT,-1,taille,accent if actif else StyleAzur.TEXTE)
	if actif:
		draw_line(Vector2(size.x*.4,size.y-24),Vector2(size.x*.6,size.y-24),accent,4.0,true)
