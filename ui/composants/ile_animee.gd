class_name IleAnimee
extends Control

const DONNEES := preload("res://data/animations_decors.gd")
const MOUVEMENT := preload("res://shaders/ile_vivante.gdshader")
const ATMOSPHERE := preload("res://shaders/atmosphere_peinte.gdshader")

var texture: Texture2D
var _corps: Control
var _image: TextureRect
var _matiere: ShaderMaterial
var _vapeurs: Array[Dictionary] = []
var _monde := -1
var _temps := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_corps = Control.new()
	_corps.name = "PlansIle"
	_corps.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_corps)
	_image = TextureRect.new()
	_image.name = "MatieresAnimees"
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_SCALE
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_matiere = ShaderMaterial.new()
	_matiere.shader = MOUVEMENT
	_image.material = _matiere
	_corps.add_child(_image)
	resized.connect(_replacer)
	visibility_changed.connect(_actualiser_effets)
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)
	_actualiser_effets()

func afficher_monde(index: int) -> void:
	index = clampi(index, 0, DONNEES.MONDES.size() - 1)
	if index == _monde:
		return
	_monde = index
	var donnees: Dictionary = DONNEES.MONDES[index]
	texture = donnees["image"]
	_image.texture = texture
	_matiere.set_shader_parameter("monde", index)
	_matiere.set_shader_parameter("accent", donnees["accent"])
	_matiere.set_shader_parameter("portail", donnees["portail"])
	for cle: String in ["chutes", "bassins", "feuillages", "tissus"]:
		var quantite := 6 if cle == "chutes" else (3 if cle == "bassins" else (4 if cle == "feuillages" else 2))
		var zones := PackedVector4Array()
		zones.resize(quantite)
		var valeurs: Array = donnees[cle]
		for rang in mini(quantite, valeurs.size()):
			zones[rang] = valeurs[rang]
		_matiere.set_shader_parameter(cle, zones)
	for vapeur in _vapeurs:
		var ancien: TextureRect = vapeur["noeud"]
		ancien.hide()
		ancien.queue_free()
	_vapeurs.clear()
	var sources: Array = donnees["vapeurs"]
	for source: Dictionary in sources:
		for rang in 3:
			_ajouter_vapeur(source, float(rang) / 3.0)
	_replacer()

func _ajouter_vapeur(source: Dictionary, phase: float) -> void:
	var vapeur := TextureRect.new()
	vapeur.name = "Vapeur"
	vapeur.texture = DONNEES.ATMOSPHERE
	vapeur.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vapeur.stretch_mode = TextureRect.STRETCH_SCALE
	vapeur.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	vapeur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var matiere := ShaderMaterial.new()
	matiere.shader = ATMOSPHERE
	matiere.set_shader_parameter("case_atlas", source["case"])
	vapeur.material = matiere
	_corps.add_child(vapeur)
	_vapeurs.append({"noeud": vapeur, "matiere": matiere, "source": source, "phase": phase})

func _replacer() -> void:
	if not is_instance_valid(_image):
		return
	_image.size = size
	_animer()

func _actualiser_effets() -> void:
	set_process(is_visible_in_tree() and not ReglagesJoueur.effets_reduits)

func _process(delta: float) -> void:
	_temps += delta
	_animer()

func _animer() -> void:
	_matiere.set_shader_parameter("temps_animation", _temps)
	_corps.position.y = sin(_temps * 0.72) * 3.0
	for entree in _vapeurs:
		var source: Dictionary = entree["source"]
		var vapeur: TextureRect = entree["noeud"]
		var matiere: ShaderMaterial = entree["matiere"]
		var duree: float = source["duree"]
		var phase: float = entree["phase"]
		var vie := fposmod(_temps / duree + phase, 1.0)
		var depart: Vector2 = source["depart"]
		var derive: Vector2 = source["derive"]
		var dimensions: Vector2 = source["taille"]
		var couleur: Color = source["couleur"]
		vapeur.size = dimensions * size * lerpf(0.76, 1.18, vie)
		vapeur.position = (depart + derive * vie) * size - vapeur.size * 0.5
		vapeur.modulate = Color(couleur, couleur.a * sin(vie * PI))
		matiere.set_shader_parameter("temps_animation", _temps + phase * duree)
