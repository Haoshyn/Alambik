extends Control

const DONNEES := preload("res://data/animations_decors.gd")
const MOUVEMENT_EAU := preload("res://shaders/eau_clairiere.gdshader")
const BOUCLE_CASCADE := preload("res://shaders/cascade_boucle.gdshader")

var fond_externe := false
var _plateau: Control
var _brume: TextureRect
var _nuages: Array[TextureRect] = []
var _rameaux: Array[TextureRect] = []
var _matieres: Array[ShaderMaterial] = []
var _temps := 0.0

func _ready() -> void:
	if fond_externe:
		hide()
		set_process(false)
		return
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_plateau = Control.new()
	_plateau.name = "PlansClairiere"
	_plateau.size = DONNEES.TAILLE_ACCUEIL
	_plateau.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plateau)

	_construire_ciel()
	for donnees: Dictionary in DONNEES.NUAGES:
		var image: Texture2D = donnees["image"]
		var nuage := _ajouter_plan("Nuage", image)
		nuage.position = donnees["position"]
		var echelle: float = donnees["echelle"]
		nuage.size = Vector2(image.get_size()) * echelle
		var opacite: float = donnees["opacite"]
		nuage.modulate.a = opacite
		_nuages.append(nuage)

	var paysage := _ajouter_plan("PaysageFixe", DONNEES.PAYSAGE)
	paysage.size = DONNEES.TAILLE_ACCUEIL
	var lac := _ajouter_plan("RefletsDuLac", DONNEES.REFLETS_LAC)
	lac.position = DONNEES.POSITION_LAC
	var matiere_lac := _ajouter_matiere(lac, MOUVEMENT_EAU)
	matiere_lac.set_shader_parameter("masque_eau", DONNEES.MASQUE_LAC)

	var cascade := _ajouter_plan("CascadeInterieure", DONNEES.CASCADE_BOUCLE)
	cascade.position = DONNEES.POSITION_CASCADE
	cascade.size = DONNEES.TAILLE_CASCADE
	_ajouter_matiere(cascade, BOUCLE_CASCADE)

	_brume = _ajouter_plan("BrumeDuLac", DONNEES.BRUME_LAC)
	_brume.position = DONNEES.BRUME["position"]
	var echelle_brume: float = DONNEES.BRUME["echelle"]
	_brume.size = Vector2(DONNEES.BRUME_LAC.get_size()) * echelle_brume
	var opacite_brume: float = DONNEES.BRUME["opacite"]
	_brume.modulate.a = opacite_brume

	for index in DONNEES.VEGETATION_FIXE.size():
		var donnees: Dictionary = DONNEES.VEGETATION_FIXE[index]
		var image: Texture2D = donnees["image"]
		var vegetation := _ajouter_plan("VegetationFixe%d" % index, image)
		vegetation.position = donnees["position"]
	for donnees: Dictionary in DONNEES.RAMEAUX:
		var image: Texture2D = donnees["image"]
		var rameau := _ajouter_plan("RameauMobile", image)
		rameau.position = donnees["position"]
		rameau.pivot_offset = donnees["pivot"]
		_rameaux.append(rameau)

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
	var ciel := _ajouter_plan("Ciel", texture_ciel)
	ciel.size = Vector2(DONNEES.TAILLE_ACCUEIL.x, 720.0)

func _ajouter_plan(nom: String, texture: Texture2D) -> TextureRect:
	var plan := TextureRect.new()
	plan.name = nom
	plan.texture = texture
	plan.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plan.stretch_mode = TextureRect.STRETCH_SCALE
	plan.size = Vector2(texture.get_size())
	plan.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	plan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plateau.add_child(plan)
	return plan

func _ajouter_matiere(plan: TextureRect, shader: Shader) -> ShaderMaterial:
	var matiere := ShaderMaterial.new()
	matiere.shader = shader
	plan.material = matiere
	_matieres.append(matiere)
	return matiere

func _cadrer() -> void:
	if not is_instance_valid(_plateau):
		return
	var echelle := maxf(size.x / DONNEES.TAILLE_ACCUEIL.x, size.y / DONNEES.TAILLE_ACCUEIL.y)
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
	for index in _nuages.size():
		var donnees: Dictionary = DONNEES.NUAGES[index]
		var position: Vector2 = donnees["position"]
		var vitesse: float = donnees["vitesse_px"]
		var nuage := _nuages[index]
		nuage.position = Vector2(_position_passage(position.x, nuage.size.x, vitesse), position.y)
	var position_brume: Vector2 = DONNEES.BRUME["position"]
	var vitesse_brume: float = DONNEES.BRUME["vitesse_px"]
	_brume.position = Vector2(_position_passage(position_brume.x, _brume.size.x, vitesse_brume), position_brume.y)
	for index in _rameaux.size():
		var donnees: Dictionary = DONNEES.RAMEAUX[index]
		var amplitude: float = donnees["amplitude"]
		var vitesse: float = donnees["vitesse"]
		var phase: float = donnees["phase"]
		var souffle := 0.72 * sin(_temps * vitesse) + 0.28 * (sin(_temps * vitesse * 0.43 + phase) - sin(phase))
		_rameaux[index].rotation = amplitude * souffle

func _position_passage(depart: float, largeur: float, vitesse: float) -> float:
	var trajet := DONNEES.TAILLE_ACCUEIL.x + largeur
	return fposmod(depart + _temps * vitesse + largeur, trajet) - largeur
