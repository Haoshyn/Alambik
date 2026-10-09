class_name EffetsPeriodiquesAugments
extends Node2D

var heros: Node2D
var meteorite_position := Vector2.ZERO
var chute_restante := 0.0
var impact_restant := 0.0
var _salle: Node2D
var _numero_salle := -1
var _trait_restant := ReglagesAugments.TRAIT_INTERVALLE
var _meteorite_restante := ReglagesAugments.METEORITE_INTERVALLE
var _degats_meteorite := 0.0

func actif() -> bool:
	return is_instance_valid(heros) and not heros.stats.est_mort() and heros.tir_courant != null

func preparer_nouvelle_salle() -> void:
	_trait_restant = ReglagesAugments.TRAIT_INTERVALLE
	_meteorite_restante = ReglagesAugments.METEORITE_INTERVALLE
	chute_restante = 0.0
	impact_restant = 0.0

func _physics_process(delta: float) -> void:
	if not actif():
		preparer_nouvelle_salle()
		queue_redraw()
		return
	if not is_instance_valid(_salle):
		_salle = get_tree().get_first_node_in_group("salle") as Node2D
	if not is_instance_valid(_salle): return
	if _numero_salle != int(_salle.get("numero")):
		_numero_salle = int(_salle.get("numero"))
		preparer_nouvelle_salle()
	impact_restant = maxf(0.0, impact_restant - delta)
	if chute_restante > 0.0:
		chute_restante = maxf(0.0, chute_restante - delta)
		if chute_restante <= 0.0: _frapper_zone()
	var drapeaux: Array = heros.tir_courant.drapeaux
	if "trait_periodique" in drapeaux:
		_trait_restant = maxf(0.0, _trait_restant - delta)
		if _trait_restant <= 0.0:
			var cible := _cible_proche(true)
			if cible != null:
				_lancer_trait(cible)
				_trait_restant = ReglagesAugments.TRAIT_INTERVALLE
	else:
		_trait_restant = ReglagesAugments.TRAIT_INTERVALLE
	if "meteorite_alchimique" in drapeaux:
		_meteorite_restante = maxf(0.0, _meteorite_restante - delta)
		if _meteorite_restante <= 0.0:
			var cible := _cible_proche(false)
			if cible != null:
				meteorite_position = cible.global_position
				chute_restante = ReglagesAugments.METEORITE_CHUTE
				_degats_meteorite = heros.degats_finaux(ReglagesAugments.impact_meteorite(heros.attaque_reelle()), "baguette", false)
				_meteorite_restante = ReglagesAugments.METEORITE_INTERVALLE
	else:
		_meteorite_restante = ReglagesAugments.METEORITE_INTERVALLE
		chute_restante = 0.0
	queue_redraw()

func _cible_proche(exiger_ligne_libre: bool) -> Node2D:
	var resultat: Node2D
	var distance := INF
	var obstacles: Array = _salle.obstacles()
	var contour: PackedVector2Array = _salle.contour_sol()
	for cible: Node2D in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(cible) or cible.is_queued_for_deletion() or not cible.has_method("recevoir_degats"): continue
		var ecart := heros.global_position.distance_squared_to(cible.global_position)
		if ecart >= distance: continue
		if exiger_ligne_libre and (ecart > ReglagesAugments.TRAIT_PORTEE * ReglagesAugments.TRAIT_PORTEE \
			or not Geometrie.ligne_libre(heros.global_position, cible.global_position, obstacles, 0.0, contour)): continue
		distance = ecart
		resultat = cible
	return resultat

func _lancer_trait(cible: Node2D) -> void:
	var tir := Tir.new()
	tir.arme = "augment"
	tir.degats = heros.degats_finaux(ReglagesAugments.impact_trait(heros.attaque_reelle(), Jeu.inventaire.count("trait_alchimique")), "baguette", false)
	tir.vitesse = ReglagesAugments.TRAIT_VITESSE
	tir.portee = ReglagesAugments.TRAIT_PORTEE
	tir.portee_limitee = true
	tir.cadence = 1.0
	tir.drapeaux.assign(["trait_periodique"])
	var vitesse: Vector2 = cible.velocity if "velocity" in cible else Vector2.ZERO
	var point := Geometrie.point_anticipe(cible.global_position, vitesse, heros.global_position, tir.vitesse)
	Jeu.tirs_emis += 1
	_salle.tirer(tir, heros.global_position, heros.global_position.direction_to(point))

func _frapper_zone() -> void:
	Sons.jouer("explosion", -11.0, randf_range(0.95, 1.1))
	var effets: Node = _salle.get("effets")
	if effets != null and effets.has_signal("secousse_demandee"):
		effets.secousse_demandee.emit(0.22)
	var obstacles: Array = _salle.obstacles()
	var contour: PackedVector2Array = _salle.contour_sol()
	# La chute traverse le couvert depuis le ciel ; son souffle reste dans la
	# salle et ne traverse pas un mur entre le point d'impact et une autre cible.
	for cible: Node2D in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(cible) or cible.is_queued_for_deletion() or not cible.has_method("recevoir_degats"): continue
		var donnees: Dictionary = cible.get("donnees")
		var rayon := ReglagesAugments.METEORITE_RAYON + float(donnees.get("rayon", 0.0))
		if meteorite_position.distance_squared_to(cible.global_position) > rayon * rayon: continue
		if not Geometrie.ligne_libre(meteorite_position, cible.global_position, obstacles, 0.0, contour): continue
		cible.recevoir_degats(_degats_meteorite)
	impact_restant = ReglagesAugments.METEORITE_IMPACT_VISUEL

func _draw() -> void:
	if not actif() or heros.has_meta("visuel_3d") or (chute_restante <= 0.0 and impact_restant <= 0.0): return
	var centre := to_local(meteorite_position)
	var progression := 1.0 - chute_restante / ReglagesAugments.METEORITE_CHUTE
	draw_arc(centre, ReglagesAugments.METEORITE_RAYON, 0.0, TAU, 32, Color("86e8d199"), 3.0, true)
	if chute_restante > 0.0:
		draw_circle(centre - Vector2(0, 180.0 * (1.0 - progression)), 16.0, Color("f5dbaa"))
	else:
		draw_circle(centre, ReglagesAugments.METEORITE_RAYON, Color("86e8d133"))
