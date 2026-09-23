extends Control

signal passe

var _marge: MarginContainer
var _progression: Label
var _titre: Label
var _detail: Label
var _icone: TextureRect
var _heros: CharacterBody2D
var _salle: Node2D
var _etape := 0
var _pulsation := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	visible = false
	_marge = MarginContainer.new()
	_marge.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_marge)
	_replacer()
	get_viewport().size_changed.connect(_replacer)
	var col := StyleAzur.plaque(_marge)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(col.get_parent() as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var entete := HBoxContainer.new()
	entete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entete.add_theme_constant_override("separation", 8)
	col.add_child(entete)
	_progression = StyleAzur.texte("1/5", 24, StyleAzur.CUIVRE)
	_progression.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progression.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entete.add_child(_progression)
	var passer := StyleAzur.bouton("Passer", func() -> void: passe.emit())
	passer.size_flags_horizontal = Control.SIZE_SHRINK_END
	passer.custom_minimum_size.x = 120
	entete.add_child(passer)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 10)
	col.add_child(ligne)
	_icone = StyleAzur.illustration("joystick_base", 48.0)
	ligne.add_child(_icone)
	var textes := VBoxContainer.new()
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.add_theme_constant_override("separation", 6)
	ligne.add_child(textes)
	_titre = StyleAzur.texte("", 27)
	_detail = StyleAzur.texte("", 21, StyleAzur.ATTENUE)
	textes.add_child(_titre)
	textes.add_child(_detail)

func configurer(heros: CharacterBody2D, salle: Node2D) -> void:
	_heros = heros
	_salle = salle

func afficher_etape(numero: int) -> void:
	_etape = numero
	_progression.text = "%d/5" % (numero + 1)
	match numero:
		0:
			_titre.text = "Glissez pour bouger"
			_detail.text = "Posez le pouce en bas de l’écran, puis glissez."
			_icone.texture = StyleAzur.texture_interface("joystick_base")
		1:
			_titre.text = "Arrêtez-vous pour tirer"
			_detail.text = "Votre baguette vise et tire dès que vous restez immobile."
			_icone.texture = StyleAzur.texture_interface("heros")
		2:
			_titre.text = "Esquivez, puis ripostez"
			_detail.text = "Bougez pour éviter les coups. Arrêtez-vous pour attaquer."
			_icone.texture = StyleAzur.texture_interface("heros")
		3:
			_titre.text = "Traversez le portail"
			_detail.text = "Suivez la flèche vers le cercle lumineux."
			_icone.texture = StyleAzur.texture_interface("portail")
	queue_redraw()

func _replacer() -> void:
	_marge.offset_left = 20
	_marge.offset_right = minf(get_viewport_rect().size.x * 0.44, 480.0)
	_marge.offset_top = Ecran.marge_haute() + 145

func _process(delta: float) -> void:
	if not visible:
		return
	_pulsation += delta
	queue_redraw()

func _draw() -> void:
	if not visible or not is_instance_valid(_heros) or not is_instance_valid(_salle):
		return
	var position_heros := _vers_ecran(_heros.global_position)
	var cible := Vector2.ZERO
	var origine := position_heros
	match _etape:
		0:
			cible = Vector2(size.x * 0.23, size.y * 0.74)
			origine = cible + Vector2(0, -115)
		1:
			cible = position_heros
			origine = cible + Vector2(-125, -100)
		2:
			var ennemi := _ennemi_proche()
			if ennemi == null:
				cible = position_heros
				origine = cible + Vector2(115, -105)
			else:
				cible = _vers_ecran(ennemi.global_position)
		3:
			cible = _vers_ecran(_salle.position_portail())
		_:
			return
	var bord := 55.0
	cible.x = clampf(cible.x, bord, size.x - bord)
	cible.y = clampf(cible.y, Ecran.marge_haute() + bord, size.y - Ecran.marge_basse() - bord)
	var direction := origine.direction_to(cible)
	if direction == Vector2.ZERO:
		return
	var separation := origine.distance_to(cible)
	var pointe := cible - direction * minf(33.0, separation * 0.25)
	var depart := origine + direction * minf(55.0 if _etape >= 2 else 18.0, separation * 0.25)
	_dessiner_fleche(depart, pointe)
	var rayon := 33.0 + (0.0 if ReglagesJoueur.effets_reduits else sin(_pulsation * 4.0) * 4.0)
	draw_arc(cible, rayon, 0.0, TAU, 32, Color(StyleAzur.MAGIE, 0.84), 4.0, true)

func _vers_ecran(position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * position

func _ennemi_proche() -> Node2D:
	var resultat: Node2D
	var distance_min := 1.0e20
	for candidat in get_tree().get_nodes_in_group("ennemis"):
		var ennemi := candidat as Node2D
		if not is_instance_valid(ennemi):
			continue
		var distance := _heros.global_position.distance_squared_to(ennemi.global_position)
		if distance < distance_min:
			distance_min = distance
			resultat = ennemi
	return resultat

func _dessiner_fleche(depart: Vector2, pointe: Vector2) -> void:
	var direction := depart.direction_to(pointe)
	if direction == Vector2.ZERO:
		return
	var couleur := Color(StyleAzur.MAGIE, 0.85)
	draw_line(depart, pointe, Color("203967"), 12.0, true)
	draw_line(depart, pointe, couleur, 6.0, true)
	var aile := direction.orthogonal() * 16.0
	draw_colored_polygon(PackedVector2Array([pointe + direction * 18.0,
		pointe - direction * 17.0 + aile, pointe - direction * 17.0 - aile]), couleur)
