class_name AmbianceAtelier
extends Control

var _campagne := false
var _temps := 0.0

func configurer(campagne: bool) -> void:
	_campagne = campagne
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(_actualiser_effets)
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)
	_actualiser_effets()

func _actualiser_effets() -> void:
	set_process(is_visible_in_tree() and not ReglagesJoueur.effets_reduits)
	queue_redraw()

func _process(delta: float) -> void:
	_temps += delta
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var teinte := StyleAzur.MAGIE if _campagne else StyleAzur.CUIVRE
	for i in 18:
		var bord := i % 2
		var fraction_x := float((i * 37 + 19) % 83) / 83.0
		var x := size.x * ((0.025 + fraction_x * 0.12) if bord == 0 else (0.975 - fraction_x * 0.12))
		var vitesse := 9.0 + float(i % 5) * 4.0
		var y := fposmod(float((i * 67 + 13) % 101) / 101.0 * size.y - _temps * vitesse, size.y + 100.0) - 50.0
		var rayon := 2.0 + float(i % 4) * 1.4
		var couleur := Color(teinte, 0.16 + float(i % 3) * 0.05)
		draw_circle(Vector2(x, y), rayon * 3.0, Color(teinte, 0.035))
		draw_circle(Vector2(x, y), rayon, couleur)
