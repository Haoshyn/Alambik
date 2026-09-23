extends Control

const DONNEES := preload("res://data/animations_decors.gd")
const MOUVEMENT_DECOR := preload("res://shaders/accueil_vivant.gdshader")
const MOUVEMENT_VEGETATION := preload("res://shaders/vegetation_vivante.gdshader")
const MOUVEMENT_EAU := preload("res://shaders/eau_clairiere.gdshader")
const MOUVEMENT_ATMOSPHERE := preload("res://shaders/atmosphere_peinte.gdshader")

var _plateau: Control
var _relief: Control
var _vegetation: TextureRect
var _brume: TextureRect
var _nuages: Array[TextureRect] = []
var _matieres: Array[ShaderMaterial] = []
var _temps := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_plateau = Control.new()
	_plateau.name = "PlansClairiere"
	_plateau.size = DONNEES.TAILLE_ACCUEIL
	_plateau.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plateau)
	_construire_ciel()
	for donnees: Dictionary in DONNEES.NUAGES:
		var nuage := _ajouter_atmosphere("Nuage", donnees["case"], _plateau)
		nuage.size = donnees["taille"]
		nuage.modulate.a = donnees["opacite"]
		_nuages.append(nuage)
	_relief = Control.new()
	_relief.name = "Relief"
	_relief.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plateau.add_child(_relief)
	_ajouter_plan("Paysage", DONNEES.PAYSAGE, MOUVEMENT_DECOR, _relief)
	var eau := _ajouter_plan("CascadeEtLac", DONNEES.EAU, MOUVEMENT_EAU, _relief)
	# La couche repeinte a son propre cadrage ; elle epouse les rives du paysage.
	eau.position = DONNEES.TAILLE_ACCUEIL * Vector2(0.09, 0.115)
	eau.size = DONNEES.TAILLE_ACCUEIL * Vector2(0.80, 0.71)
	_brume = _ajouter_atmosphere("BrumeDuLac", Vector2(0, 1), _relief)
	_brume.size = Vector2(760, 165)
	_brume.modulate = Color(0.80, 0.87, 1.0, 0.20)
	_vegetation = _ajouter_plan("VegetationProche", DONNEES.VEGETATION, MOUVEMENT_VEGETATION, _plateau)
	_vegetation.scale = Vector2.ONE * 1.016
	resized.connect(_cadrer)
	visibility_changed.connect(_actualiser_effets)
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)
	_cadrer()
	_animer()
	_actualiser_effets()

func _construire_ciel() -> void:
	var degrade := Gradient.new()
	degrade.colors = PackedColorArray([Color("548aeb"), Color("acc5ff"), Color("f1ddeb")])
	degrade.offsets = PackedFloat32Array([0.0, 0.62, 1.0])
	var texture_ciel := GradientTexture2D.new()
	texture_ciel.gradient = degrade
	texture_ciel.width = 4
	texture_ciel.height = 256
	texture_ciel.fill_from = Vector2(0, 0)
	texture_ciel.fill_to = Vector2(0, 1)
	var ciel := _ajouter_plan("Ciel", texture_ciel, null, _plateau)
	ciel.size.y = 720.0
	ciel.modulate = Color.WHITE

func _ajouter_plan(nom: String, texture: Texture2D, shader: Shader, parent: Control) -> TextureRect:
	var plan := TextureRect.new()
	plan.name = nom
	plan.texture = texture
	plan.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plan.stretch_mode = TextureRect.STRETCH_SCALE
	plan.size = DONNEES.TAILLE_ACCUEIL
	plan.modulate = Color("dce2f4")
	plan.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	plan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if shader != null:
		var matiere := ShaderMaterial.new()
		matiere.shader = shader
		plan.material = matiere
		_matieres.append(matiere)
	parent.add_child(plan)
	return plan

func _ajouter_atmosphere(nom: String, case_atlas: Vector2, parent: Control) -> TextureRect:
	var plan := _ajouter_plan(nom, DONNEES.ATMOSPHERE, MOUVEMENT_ATMOSPHERE, parent)
	var matiere := plan.material as ShaderMaterial
	matiere.set_shader_parameter("case_atlas", case_atlas)
	plan.modulate = Color.WHITE
	return plan

func _cadrer() -> void:
	if not is_instance_valid(_plateau):
		return
	# Le debord absorbe la parallaxe sans jamais decouvrir un bord de texture.
	var echelle := maxf(size.x / DONNEES.TAILLE_ACCUEIL.x, size.y / DONNEES.TAILLE_ACCUEIL.y) * 1.025
	_plateau.scale = Vector2.ONE * echelle
	_plateau.position = (size - DONNEES.TAILLE_ACCUEIL * echelle) * 0.5

func _actualiser_effets() -> void:
	set_process(is_visible_in_tree() and not ReglagesJoueur.effets_reduits)

func _process(delta: float) -> void:
	_temps += delta
	_animer()

func _animer() -> void:
	for matiere in _matieres:
		matiere.set_shader_parameter("temps_animation", _temps)
	_relief.position = Vector2(sin(_temps * 0.17) * 2.0, sin(_temps * 0.21) * 1.2)
	_vegetation.position = -DONNEES.TAILLE_ACCUEIL * 0.008 + Vector2(sin(_temps * 0.17) * 6.0, sin(_temps * 0.21) * 2.5)
	_brume.position = Vector2(85.0 + sin(_temps * 0.13) * 38.0, 643.0 + sin(_temps * 0.24) * 5.0)
	for index in _nuages.size():
		var donnees: Dictionary = DONNEES.NUAGES[index]
		var nuage := _nuages[index]
		var trajet := DONNEES.TAILLE_ACCUEIL.x + nuage.size.x
		var vitesse: float = donnees["vitesse"]
		var phase: float = donnees["phase"]
		var haut: float = donnees["haut"]
		nuage.position = Vector2(fposmod(_temps * vitesse + phase * trajet, trajet) - nuage.size.x, haut)
