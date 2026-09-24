extends Control

const FEUILLES := [
	Vector2(63, 86), Vector2(147, 117), Vector2(235, 80),
	Vector2(88, 205), Vector2(43, 344), Vector2(87, 386),
	Vector2(740, 79), Vector2(810, 98), Vector2(894, 143),
	Vector2(866, 261), Vector2(907, 354), Vector2(830, 506),
	Vector2(34, 742), Vector2(138, 823), Vector2(905, 632),
	Vector2(857, 803),
]
const HERBES := [
	Vector2(37, 934), Vector2(82, 1010), Vector2(178, 940),
	Vector2(276, 962), Vector2(384, 934), Vector2(546, 937),
	Vector2(695, 970), Vector2(827, 947), Vector2(901, 1035),
	Vector2(45, 1248), Vector2(116, 1360), Vector2(243, 1372),
	Vector2(352, 1334), Vector2(562, 1328), Vector2(693, 1370),
	Vector2(817, 1327), Vector2(896, 1409), Vector2(70, 1480),
	Vector2(196, 1498), Vector2(742, 1510), Vector2(853, 1517),
]

var _temps := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)
	_actualiser_effets()

func _actualiser_effets() -> void:
	visible = not ReglagesJoueur.effets_reduits
	set_process(visible)

func _process(delta: float) -> void:
	_temps += delta
	queue_redraw()

func _draw() -> void:
	var vent := sin(_temps * 0.85) * 0.8 + sin(_temps * 0.29) * 0.3
	_dessiner_feuilles(vent)
	_dessiner_herbes(vent)

func _dessiner_feuilles(vent: float) -> void:
	var forme := PackedVector2Array([
		Vector2.ZERO, Vector2(-4, -5), Vector2(-5, -12),
		Vector2(0, -19), Vector2(5, -14), Vector2(5, -7),
	])
	for index in FEUILLES.size():
		var ancrage: Vector2 = FEUILLES[index]
		var oscillation := vent + sin(_temps * 1.12 + float(index) * 1.7) * 0.18
		var angle := (float(index % 5) - 2.0) * 0.21 + oscillation * 0.18
		var taille := 0.78 + float(index % 4) * 0.14
		var teinte := Color(0.68, 0.79, 0.86, 0.82)
		if index >= 6 and index < 12:
			teinte = Color(0.62, 0.75, 0.89, 0.82)
		elif index >= 12:
			teinte = Color(0.72, 0.82, 0.70, 0.80)
		# Le point d'attache reste fixe : le vent plie seulement la feuille.
		draw_set_transform(ancrage, angle, Vector2.ONE * taille)
		draw_colored_polygon(forme, teinte)
	draw_set_transform(Vector2.ZERO)

func _dessiner_herbes(vent: float) -> void:
	for index in HERBES.size():
		var ancrage: Vector2 = HERBES[index]
		var oscillation := vent + sin(_temps * 1.07 + float(index) * 0.83) * 0.15
		for brin in 3:
			var hauteur := 16.0 + float((index * 3 + brin * 5) % 13)
			var depart := float(brin - 1) * 5.0
			var inclinaison := float(brin - 1) * 4.0 + oscillation * hauteur * 0.16
			var forme := PackedVector2Array([
				ancrage + Vector2(depart - 2.2, 0),
				ancrage + Vector2(depart + inclinaison, -hauteur),
				ancrage + Vector2(depart + 2.2, 0),
			])
			var teinte := Color(0.72, 0.78, 0.64, 0.68) if index % 3 == 0 \
				else Color(0.53, 0.71, 0.73, 0.70)
			draw_colored_polygon(forme, teinte)
