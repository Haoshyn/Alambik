extends Button

const PIECES := preload("res://assets/visual/interface/coffre_pieces.png")
const FERME := preload("res://assets/visual/interface/coffre_ferme.png")
const CORPS := Rect2(0, 0, 971, 809)
const COUVERCLE := Rect2(971, 0, 971, 809)

var ouverture := 0.0:
	set(valeur):
		ouverture = clampf(valeur, -0.05, 1.08)
		queue_redraw()
var rang := 0

func _ready() -> void:
	HabillagePeint.appliquer(self)
	custom_minimum_size = Vector2(0, 400)
	focus_mode = Control.FOCUS_NONE
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	for etat in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(etat, StyleBoxEmpty.new())
	tooltip_text = "Ouvrir le coffre de l’aventure"

func _draw() -> void:
	var centre := size * Vector2(0.5, 0.51)
	var mouvement := ouverture
	var pression := Vector2(0, 4) if is_pressed() else Vector2.ZERO
	var fusion := clampf((mouvement - 0.48) / 0.32, 0.0, 1.0)
	fusion = fusion * fusion * (3.0 - 2.0 * fusion)
	var couvercle_position := Vector2(-195, -200).lerp(Vector2(-180, -270), mouvement)
	var couvercle_taille := Vector2(390, 325).lerp(Vector2(360, 300), mouvement)
	draw_texture_rect_region(PIECES, Rect2(centre + Vector2(-190, -124) + pression, Vector2(380, 316)), CORPS)
	if fusion > 0.0:
		draw_texture_rect_region(PIECES, Rect2(centre + couvercle_position + pression, couvercle_taille),
			COUVERCLE, Color(Color.WHITE, fusion))
	if fusion < 1.0:
		_dessiner_couvercle_ferme(centre + pression, mouvement, 1.0 - fusion)

func _dessiner_couvercle_ferme(centre: Vector2, mouvement: float, opacite: float) -> void:
	var origine := Vector2(-245, -199).lerp(Vector2(-230, -250), mouvement)
	var taille := Vector2(490, 408).lerp(Vector2(460, 383), mouvement)
	var contour: Array[Vector2] = [Vector2.ZERO, Vector2(1374, 0), Vector2(1374, 610),
		Vector2(1195, 610), Vector2(1155, 640), Vector2(1000, 745), Vector2(960, 745),
		Vector2(680, 675), Vector2(580, 680), Vector2(480, 610), Vector2(240, 540), Vector2(0, 540)]
	var points := PackedVector2Array()
	var uv := PackedVector2Array()
	for sommet in contour:
		var coordonnee := Vector2(sommet.x / 1374.0, sommet.y / 1145.0)
		points.append(centre + origine + coordonnee * taille)
		uv.append(coordonnee)
	draw_polygon(points, PackedColorArray([Color(Color.WHITE, opacite)]), uv, FERME)
