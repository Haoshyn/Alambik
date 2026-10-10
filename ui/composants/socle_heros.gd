extends Control

# Socle lumineux sous le portrait du heros : anneaux d'email et halo doux,
# dessines pour suivre la taille de la vitrine sans ressource supplementaire.
var accent := Color("8fe5f1")
var _temps := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(not ReglagesJoueur.effets_reduits)

func _process(delta: float) -> void:
	_temps += delta
	queue_redraw()

func _draw() -> void:
	var centre := Vector2(size.x * .5, size.y * .86)
	var rayon := size.x * .46
	var aplati := Vector2(1.0, .30)
	var pulsation := .5 + .5 * sin(_temps * 1.6)
	for i in 6:
		var r := rayon * (1.25 - i * .09)
		_ellipse(centre, r, aplati, Color(accent, .035 + i * .012))
	_ellipse(centre + Vector2(0, 10), rayon, aplati, Color(0.02, 0.01, 0.08, .55))
	_ellipse(centre, rayon, aplati, Color("2b2160"))
	_ellipse(centre, rayon * .94, aplati, Color("43358f"))
	_anneau(centre, rayon * .94, aplati, Color(StyleJeu.OR, .9), 4.0)
	_anneau(centre, rayon * .72, aplati, Color(accent, .45 + .25 * pulsation), 3.0)
	_anneau(centre, rayon * .48, aplati, Color(accent, .25 + .2 * pulsation), 2.0)

func _ellipse(centre: Vector2, rayon: float, aplati: Vector2, couleur: Color) -> void:
	var points := PackedVector2Array()
	for i in 48:
		var angle := TAU * i / 48.0
		points.append(centre + Vector2(cos(angle), sin(angle)) * rayon * aplati)
	draw_colored_polygon(points, couleur)

func _anneau(centre: Vector2, rayon: float, aplati: Vector2, couleur: Color, largeur: float) -> void:
	var points := PackedVector2Array()
	for i in 49:
		var angle := TAU * i / 48.0
		points.append(centre + Vector2(cos(angle), sin(angle)) * rayon * aplati)
	draw_polyline(points, couleur, largeur, true)
