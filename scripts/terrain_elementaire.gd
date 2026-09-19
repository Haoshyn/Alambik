extends Node2D

var zones: Array[Dictionary] = []
var temps := 0.0
var salle: Node2D
var _recharge_degats := 0.0
var _temps_sable := 0.0

func configurer(salle_: Node2D) -> void:
	salle = salle_
	zones.clear()
	temps = 0.0
	_recharge_degats = 0.0
	_temps_sable = 0.0
	var nombre := TerrainsMondes.nombre(salle.numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run)
	if nombre == 0: return
	var monde := int(Jeu.chapitre_courant()["monde"])
	var profil: Dictionary = TerrainsMondes.PROFILS[monde]
	var depart := TerrainsMondes.variante(salle.numero, Jeu.chapitre, Jeu.graine)
	if str(profil["type"]) == "vent":
		var vent: Dictionary = profil.duplicate()
		vent["position"] = salle.limites.get_center()
		vent["direction"] = TerrainsMondes.VENT_DIRECTIONS[posmod(depart, TerrainsMondes.VENT_DIRECTIONS.size())]
		zones.append(vent)
		return
	var marge := float(profil["rayon"]) + TerrainsMondes.MARGE_OBSTACLE
	for i in TerrainsMondes.EMPLACEMENTS.size():
		if zones.size() >= nombre: break
		var index := posmod(depart + i, TerrainsMondes.EMPLACEMENTS.size())
		var position_zone: Vector2 = salle.limites.position + TerrainsMondes.EMPLACEMENTS[index] * salle.limites.size
		if not FormesSalles.contient_disque(position_zone, salle.contour_sol(), marge): continue
		var libre := true
		for rect: Rect2 in salle.obstacles():
			if rect.grow(marge).has_point(position_zone):
				libre = false
				break
		if not libre: continue
		var zone: Dictionary = profil.duplicate()
		zone["position"] = position_zone
		zones.append(zone)

func _contient(zone: Dictionary, point: Vector2) -> bool:
	var centre: Vector2 = zone["position"]
	return point.distance_to(centre) <= float(zone["rayon"])

func tir_bloque(point: Vector2) -> bool:
	for zone in zones:
		if str(zone["type"]) == "eau" and _contient(zone, point): return true
	return false

func _physics_process(delta: float) -> void:
	if is_queued_for_deletion(): return
	temps += delta
	_recharge_degats = maxf(0.0, _recharge_degats - delta)
	queue_redraw()
	if temps < TerrainsMondes.DELAI_ACTIVATION or salle.portail_ouvert():
		_temps_sable = 0.0
		return
	var heros := get_tree().get_first_node_in_group("heros")
	if not is_instance_valid(heros): return
	var dans_sable := false
	for zone in zones:
		if not _contient(zone, heros.global_position): continue
		if str(zone["type"]) == "sable": dans_sable = true
		if float(zone["degats"]) > 0.0 and _recharge_degats <= 0.0:
			_recharge_degats = TerrainsMondes.INTERVALLE_DEGATS
			heros.recevoir_degats(heros.stats.pv_max * float(zone["degats"]))
	_temps_sable = minf(_temps_sable + delta, TerrainsMondes.SABLE_DUREE_ENFONCEMENT) if dans_sable else 0.0

func mouvement(position_heros: Vector2, direction_voulue: Vector2) -> Vector3:
	var resultat := Vector3(0, 0, 1)
	if is_queued_for_deletion() or temps < TerrainsMondes.DELAI_ACTIVATION or salle.portail_ouvert(): return resultat
	for zone in zones:
		var type := str(zone["type"])
		if type == "vent":
			# Le vent module l'allure choisie, sans deplacer le heros a l'arret.
			var direction_vent: Vector2 = zone["direction"]
			resultat.z = 1.0 + direction_voulue.normalized().dot(direction_vent) * TerrainsMondes.VENT_VARIATION_VITESSE
		elif _contient(zone, position_heros):
			var facteur := float(zone["vitesse"])
			if type == "sable":
				facteur = lerpf(TerrainsMondes.SABLE_VITESSE_INITIALE, TerrainsMondes.SABLE_VITESSE_MINIMALE, _temps_sable / TerrainsMondes.SABLE_DUREE_ENFONCEMENT)
			resultat.z = minf(resultat.z, facteur)
	return resultat

func _draw() -> void:
	if not is_instance_valid(salle) or salle.has_meta("visuel_3d"): return
	for zone in zones:
		var teinte: Color = zone["couleur"]
		if str(zone["type"]) == "vent":
			var direction: Vector2 = zone["direction"]
			for i in 9:
				var p: Vector2 = salle.limites.position + Vector2(.18 + (i % 3) * .32, .22 + (i / 3) * .27) * salle.limites.size
				p += direction * (fposmod(temps * 38.0 + i * 17.0, 60.0) - 30.0)
				draw_line(p - direction * 24.0, p, Color(teinte, .55), 2.0)
				draw_line(p, p - direction.rotated(.6) * 9.0, teinte, 2.0)
				draw_line(p, p - direction.rotated(-.6) * 9.0, teinte, 2.0)
			continue
		var centre: Vector2 = zone["position"]
		var rayon := float(zone["rayon"])
		draw_circle(centre, rayon, Color(teinte, .35))
		draw_arc(centre, rayon, 0, TAU, 32, teinte, 3.0)
