class_name CarteCampagne
extends Control

# Les chemins peints changent selon le monde ; une grille unique masquerait leurs lieux.
const REPERES := [
	[Vector2(0.26, 0.63), Vector2(0.56, 0.61), Vector2(0.79, 0.52), Vector2(0.62, 0.44), Vector2(0.44, 0.39), Vector2(0.77, 0.31), Vector2(0.52, 0.23)],
	[Vector2(0.59, 0.66), Vector2(0.36, 0.63), Vector2(0.47, 0.51), Vector2(0.71, 0.50), Vector2(0.56, 0.39), Vector2(0.38, 0.30), Vector2(0.65, 0.17)],
	[Vector2(0.68, 0.66), Vector2(0.54, 0.52), Vector2(0.34, 0.45), Vector2(0.17, 0.35), Vector2(0.78, 0.49), Vector2(0.79, 0.31), Vector2(0.61, 0.19)],
	[Vector2(0.49, 0.65), Vector2(0.32, 0.63), Vector2(0.64, 0.59), Vector2(0.51, 0.46), Vector2(0.75, 0.40), Vector2(0.34, 0.34), Vector2(0.62, 0.15)],
	[Vector2(0.38, 0.73), Vector2(0.52, 0.64), Vector2(0.72, 0.57), Vector2(0.57, 0.49), Vector2(0.19, 0.30), Vector2(0.43, 0.35), Vector2(0.58, 0.30)],
]

var _ile: IleAnimee
var _monde := 0
var _etapes: Array[RepereCampagne] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_ile = IleAnimee.new()
	add_child(_ile)
	resized.connect(_replacer)
	_replacer()

func ajouter_etape(etape: RepereCampagne) -> void:
	_etapes.append(etape)
	add_child(etape)
	_replacer()

func afficher_monde(index: int) -> void:
	_monde = clampi(index, 0, REPERES.size() - 1)
	_ile.afficher_monde(_monde)
	_replacer()

func _replacer() -> void:
	if not is_instance_valid(_ile) or size.x <= 0.0 or size.y <= 0.0:
		return
	var aspect := 0.72
	if _ile.texture != null:
		aspect = float(_ile.texture.get_width()) / float(_ile.texture.get_height())
	var hauteur := minf(size.y * 1.04, size.x * 0.90 / aspect)
	var largeur := hauteur * aspect
	_ile.position = (size - Vector2(largeur, hauteur)) * 0.5
	_ile.size = Vector2(largeur, hauteur)
	var positions: Array = REPERES[_monde]
	for i in mini(_etapes.size(), positions.size()):
		var point: Vector2 = positions[i]
		var etape := _etapes[i]
		var cote_repere := clampf(minf(hauteur * 0.13, largeur * 0.16), 48.0, 58.0)
		etape.size = Vector2.ONE * cote_repere
		var centre := _ile.position + Vector2(point.x * largeur, point.y * hauteur)
		etape.position = centre - etape.size * 0.5
