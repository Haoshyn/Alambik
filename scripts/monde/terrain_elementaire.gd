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
		vent["orientation"] = posmod(salle.numero + Jeu.chapitre, TerrainsMondes.VENT_DIRECTIONS.size())
		zones.append(vent)
		return
	var alea := RandomNumberGenerator.new()
	alea.seed = Jeu.chapitre * 104729 + salle.numero * 7919
	for i in TerrainsMondes.EMPLACEMENTS.size():
		if zones.size() >= nombre: break
		var index := posmod(depart + i, TerrainsMondes.EMPLACEMENTS.size())
		var rayon := float(profil["rayon"]) * float(TerrainsMondes.TAILLES_ZONES[alea.randi_range(0, TerrainsMondes.TAILLES_ZONES.size()-1)])
		var marge := rayon + TerrainsMondes.MARGE_OBSTACLE
		var decalage := Vector2(alea.randf_range(-1,1),alea.randf_range(-1,1)) * TerrainsMondes.DECALAGE_ZONE
		var position_zone: Vector2 = salle.limites.position + (TerrainsMondes.EMPLACEMENTS[index] + decalage) * salle.limites.size
		if not FormesSalles.contient_disque(position_zone, salle.contour_sol(), marge): continue
		var libre := true
		for rect: Rect2 in salle.obstacles():
			if rect.grow(marge).has_point(position_zone):
				libre = false
				break
		for precedente in zones:
			var centre_precedent: Vector2 = precedente["position"]
			if centre_precedent.distance_to(position_zone) < rayon + float(precedente["rayon"]) + TerrainsMondes.MARGE_OBSTACLE:
				libre = false
		if not libre: continue
		var zone: Dictionary = profil.duplicate()
		zone["position"] = position_zone
		zone["rayon"] = rayon
		zone["contour"] = _contour_flaque(rayon, alea)
		zones.append(zone)

func _contour_flaque(rayon: float, alea: RandomNumberGenerator) -> PackedVector2Array:
	var points := PackedVector2Array()
	var phase := alea.randf_range(0,TAU)
	var rotation_flaque := alea.randf_range(0,TAU)
	var proportions := Vector2(alea.randf_range(.70,1.0),1.0)
	for i in 28:
		var angle := i * TAU / 28.0
		var distance := rayon * (.81 + .10 * sin(angle * 3 + phase) + .06 * sin(angle * 5 - phase))
		points.append((Vector2(cos(angle),sin(angle)) * distance * proportions).rotated(rotation_flaque))
	return points

func _contient(zone: Dictionary, point: Vector2) -> bool:
	var centre: Vector2 = zone["position"]
	var contour: PackedVector2Array = zone["contour"]
	return Geometry2D.is_point_in_polygon(point - centre, contour)

func actif() -> bool:
	return not is_queued_for_deletion() and is_instance_valid(salle) and temps >= TerrainsMondes.DELAI_ACTIVATION and not salle.portail_ouvert()

func etat_vent() -> Dictionary:
	var resultat := {"direction":Vector2.ZERO, "force":0.0, "annonce":false}
	if not actif() or zones.is_empty() or str(zones[0]["type"]) != "vent": return resultat
	var periode := TerrainsMondes.VENT_REPOS + TerrainsMondes.VENT_DUREE
	var age := temps - TerrainsMondes.DELAI_ACTIVATION
	var cycle := floori(age / periode)
	var phase := fposmod(age, periode) - TerrainsMondes.VENT_REPOS
	resultat["direction"] = TerrainsMondes.VENT_DIRECTIONS[posmod(int(zones[0]["orientation"]) + cycle, TerrainsMondes.VENT_DIRECTIONS.size())]
	resultat["annonce"] = phase < 0.0 and phase >= -TerrainsMondes.VENT_ANNONCE
	if phase >= 0.0:
		resultat["force"] = clampf(minf(phase / TerrainsMondes.VENT_MONTEE, (TerrainsMondes.VENT_DUREE - phase) / TerrainsMondes.VENT_DESCENTE), 0.0, 1.0)
	return resultat

func _physics_process(delta: float) -> void:
	if is_queued_for_deletion(): return
	temps += delta
	_recharge_degats = maxf(0.0, _recharge_degats - delta)
	queue_redraw()
	if not actif():
		_temps_sable = 0.0
		return
	var heros := get_tree().get_first_node_in_group("heros")
	if not is_instance_valid(heros) or heros.stats.est_mort(): return
	var dans_sable := false
	for zone in zones:
		if str(zone["type"]) == "vent": continue
		if not _contient(zone, heros.global_position): continue
		if str(zone["type"]) == "sable": dans_sable = true
		if float(zone["degats"]) > 0.0 and _recharge_degats <= 0.0:
			_recharge_degats = TerrainsMondes.INTERVALLE_DEGATS
			heros.recevoir_degats(heros.stats.pv_max * float(zone["degats"]))
	_temps_sable = minf(_temps_sable + delta, TerrainsMondes.SABLE_DUREE_ENFONCEMENT) if dans_sable else 0.0

func mouvement(position_heros: Vector2) -> Vector3:
	var resultat := Vector3(0, 0, 1)
	if not actif(): return resultat
	for zone in zones:
		var type := str(zone["type"])
		if type == "vent":
			# La poussee est une fraction de l'allure du heros. Meme a pleine
			# rafale, courir contre le vent garde une vitesse strictement positive.
			var vent := etat_vent()
			var direction_vent: Vector2 = vent["direction"]
			var poussee := direction_vent * float(vent["force"]) * TerrainsMondes.VENT_VARIATION_VITESSE
			resultat.x = poussee.x
			resultat.y = poussee.y
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
			var vent := etat_vent()
			if float(vent["force"]) <= 0.0 and not bool(vent["annonce"]): continue
			var direction: Vector2 = vent["direction"]
			for i in 9:
				var p: Vector2 = salle.limites.position + Vector2(.18 + (i % 3) * .32, .22 + (i / 3) * .27) * salle.limites.size
				if not ReglagesJoueur.effets_reduits and not bool(vent["annonce"]): p += direction * (fposmod(temps * 38.0 + i * 17.0, 60.0) - 30.0)
				draw_line(p - direction * 24.0, p, Color(teinte, .55), 2.0)
				draw_line(p, p - direction.rotated(.6) * 9.0, teinte, 2.0)
				draw_line(p, p - direction.rotated(-.6) * 9.0, teinte, 2.0)
			continue
		var centre: Vector2 = zone["position"]
		var contour: PackedVector2Array = zone["contour"]
		var points := PackedVector2Array()
		for point in contour: points.append(centre + point)
		draw_colored_polygon(points, teinte.darkened(.18))
		points.append(points[0])
		draw_polyline(points, teinte.lightened(.20), 2.0, true)
