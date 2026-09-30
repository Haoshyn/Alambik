class_name SatellitesAlchimiques
extends Node2D

var heros: Node2D
var _salle: Node2D
var _angle := 0.0
var _temps := 0.0
var _numero_salle := -1
var _prochains_impacts: Dictionary = {}

func actif() -> bool:
	return is_instance_valid(heros) and not heros.stats.est_mort() \
		and heros.tir_courant != null and "satellites_alchimiques" in heros.tir_courant.drapeaux

func positions_satellites() -> Array[Vector2]:
	var points: Array[Vector2] = []
	if not actif(): return points
	for index in ReglagesAugments.SATELLITES_NOMBRE:
		points.append(heros.global_position + Vector2.from_angle(_angle + TAU * index / ReglagesAugments.SATELLITES_NOMBRE) * ReglagesAugments.SATELLITES_ORBITE)
	return points

func preparer_nouvelle_salle() -> void:
	_prochains_impacts.clear()
	_angle = 0.0
	_temps = 0.0

func _physics_process(delta: float) -> void:
	if not actif():
		queue_redraw()
		return
	if not is_instance_valid(_salle):
		_salle = get_tree().get_first_node_in_group("salle") as Node2D
	if is_instance_valid(_salle) and _numero_salle != int(_salle.get("numero")):
		_numero_salle = int(_salle.get("numero"))
		preparer_nouvelle_salle()
	_temps += delta
	_angle = fposmod(_angle + TAU * delta / ReglagesAugments.SATELLITES_PERIODE, TAU)
	var points := positions_satellites()
	var obstacles: Array = _salle.obstacles() if is_instance_valid(_salle) else []
	var contour: PackedVector2Array = _salle.contour_sol() if is_instance_valid(_salle) else PackedVector2Array()
	var vivants := {}
	for cible: Node2D in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(cible) or cible.is_queued_for_deletion() or not cible.has_method("recevoir_degats"): continue
		var id := cible.get_instance_id()
		var prochain := float(_prochains_impacts.get(id, 0.0))
		vivants[id] = prochain
		if prochain > _temps: continue
		var donnees: Dictionary = cible.get("donnees")
		var rayon := ReglagesAugments.SATELLITES_RAYON + float(donnees.get("rayon", 0.0))
		for point in points:
			if point.distance_squared_to(cible.global_position) > rayon * rayon: continue
			# Le cercle ne frappe pas a travers un couvert ou hors du contour de salle.
			if not Geometrie.ligne_libre(heros.global_position, point, obstacles, 0.0, contour) \
				or not Geometrie.ligne_libre(point, cible.global_position, obstacles, 0.0, contour): continue
			vivants[id] = _temps + ReglagesAugments.SATELLITES_INTERVALLE_IMPACT
			cible.recevoir_degats(heros.degats_finaux(heros.attaque_reelle() * ReglagesAugments.SATELLITES_PART_ATTAQUE, "baguette", false))
			break
	# Retirer les ennemis disparus sans modifier la collection parcourue.
	_prochains_impacts = vivants
	queue_redraw()

func _draw() -> void:
	if not actif() or heros.has_meta("visuel_3d"): return
	for point in positions_satellites():
		var centre := to_local(point)
		draw_circle(centre, ReglagesAugments.SATELLITES_RAYON, Color("86e8d12a"))
		draw_arc(centre, ReglagesAugments.SATELLITES_RAYON * 0.7, 0.0, TAU, 24, Color("86e8d1"), 3.0, true)
		draw_circle(centre, 5.0, Color("f5dbaa"))
