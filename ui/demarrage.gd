extends Control

const ILLUSTRATION := preload("res://assets/visual/interface/chargement_clairiere.png")
const CADRAGE := preload("res://shaders/chargement_adaptatif.gdshader")
const MENU := "res://scenes/menu.tscn"

var _matiere: ShaderMaterial
var _erreur: Label

func _ready() -> void:
	_construire_illustration()
	# Le premier dessin precede le chargement des ressources lourdes du menu.
	await get_tree().process_frame
	await get_tree().process_frame
	var scene := load(MENU) as PackedScene
	if scene == null:
		_afficher_erreur()
		return
	get_tree().change_scene_to_packed.call_deferred(scene)

func _construire_illustration() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var peinture := TextureRect.new()
	peinture.name = "IllustrationDemarrage"
	peinture.texture = ILLUSTRATION
	peinture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	peinture.stretch_mode = TextureRect.STRETCH_SCALE
	peinture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	peinture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_matiere = ShaderMaterial.new()
	_matiere.shader = CADRAGE
	peinture.material = _matiere
	add_child(peinture)
	peinture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_cadrer)
	_cadrer()

func _cadrer() -> void:
	if _matiere == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var debut := Vector2.ZERO
	var fin := Vector2.ZERO
	if OS.get_name() == "Android":
		debut = Vector2(Ecran.marge_gauche(), Ecran.marge_haute())
		fin = Vector2(Ecran.marge_droite(), Ecran.marge_basse())
	var disponible := (size - debut - fin).max(Vector2.ONE)
	var source := ILLUSTRATION.get_size()
	var echelle := minf(disponible.x / source.x, disponible.y / source.y)
	var dimensions := source * echelle
	var origine := debut + (disponible - dimensions) * 0.5
	_matiere.set_shader_parameter("cadre", Vector4(origine.x / size.x,
		origine.y / size.y, dimensions.x / size.x, dimensions.y / size.y))
	if is_instance_valid(_erreur):
		_erreur.position = Vector2(debut.x + 32.0, size.y - fin.y - 160.0)
		_erreur.size = Vector2(maxf(1.0, disponible.x - 64.0), 128.0)

func _afficher_erreur() -> void:
	push_error("Impossible de charger le menu depuis l'ecran de demarrage.")
	_erreur = Label.new()
	_erreur.text = "Impossible de démarrer le jeu.\nFermez puis relancez Alambic."
	_erreur.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_erreur.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_erreur.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_erreur.add_theme_font_override("font", Polices.CORPS)
	_erreur.add_theme_font_size_override("font_size", 30)
	_erreur.add_theme_color_override("font_color", Color("fff6e9"))
	_erreur.add_theme_color_override("font_shadow_color", Color("202574"))
	_erreur.add_theme_constant_override("shadow_offset_y", 3)
	add_child(_erreur)
	_cadrer()
