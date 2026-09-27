extends RefCounted

const Rendu = preload("res://data/presentation/animations_combat.gd")

static func dessiner_zone(noeud: Node2D, centre: Vector2, rayon: float, progression: float) -> void:
	var danger: Color = Rendu.ANNONCE_COULEUR
	noeud.draw_circle(centre, rayon, Color(danger, .12 + .12 * progression))
	noeud.draw_arc(centre, rayon, 0, TAU, 48, Color(Rendu.ANNONCE_CONTRASTE, .85), 8.0, true)
	noeud.draw_arc(centre, rayon, 0, TAU, 48, Color(danger, .85), Rendu.ANNONCE_TRAIT, true)
	if progression > 0.0:
		noeud.draw_arc(centre, rayon * .88, -PI / 2, -PI / 2 + TAU * progression, 48,
			danger.lightened(.3), Rendu.ANNONCE_TRAIT, true)
	for i in 4:
		var direction := Vector2.from_angle(PI * .25 + i * PI * .5)
		var point := centre + direction * rayon * (1.0 - progression * .45)
		noeud.draw_line(point, point + direction.rotated(.6) * 12, danger, 3.0, true)
		noeud.draw_line(point, point + direction.rotated(-.6) * 12, danger, 3.0, true)

static func _trait(noeud: Node2D, debut: Vector2, fin: Vector2) -> void:
	noeud.draw_line(debut, fin, Color(Rendu.ANNONCE_CONTRASTE, .7), Rendu.ANNONCE_TRAIT + 4.0, true)
	noeud.draw_line(debut, fin, Color(Rendu.ANNONCE_COULEUR, .85), Rendu.ANNONCE_TRAIT, true)

static func _progression(ennemi: Node2D, duree: float) -> float:
	return clampf(1.0 - float(ennemi._minuterie) / maxf(duree, .01), 0.0, 1.0)

static func dessiner(ennemi: Node2D, rayon: float) -> bool:
	var etat := str(ennemi._etat)
	var d: Dictionary = ennemi.donnees
	var danger: Color = Rendu.ANNONCE_COULEUR
	var salves: Array = ennemi._salves
	if not salves.is_empty():
		var annonce_visible := false
		for salve: Dictionary in salves:
			if not bool(salve["annonce"]): continue
			annonce_visible = true
			var nombre := int(salve["cercle"])
			if nombre > 0: _anneau(ennemi, rayon, nombre)
			else: _tirs(ennemi, rayon, salve["cible"])
		return annonce_visible
	if etat == "phase":
		var destination: Vector2 = ennemi._destination_phase - ennemi.global_position
		dessiner_zone(ennemi, destination, rayon + Reglages.HEROS_RAYON,
			_progression(ennemi, Reglages.PHASE_ANNONCE))
		_trait(ennemi, Vector2.ZERO, destination)
		return true
	if etat == "preparer":
		var longueur := float(d["vitesse"]) * float(d.get("duree_charge", EvolutionEnnemis.ELAN_DUREE)) * float(ennemi._facteur_vitesse())
		if str(d["cerveau"]) == "rampant": longueur *= EvolutionEnnemis.ELAN_VITESSE
		var direction: Vector2 = ennemi._direction_charge
		var largeur := rayon * Reglages.ENNEMI_HITBOX_MULT
		var fin := direction * longueur
		ennemi.draw_line(Vector2.ZERO, fin, Color(danger,.22), largeur * 2.0, true)
		for cote in [-1.0, 1.0]:
			var decalage := direction.orthogonal() * largeur * float(cote)
			_trait(ennemi, decalage, fin + decalage)
		_trait(ennemi, fin, fin - direction.rotated(.5) * rayon)
		_trait(ennemi, fin, fin - direction.rotated(-.5) * rayon)
		return true
	if etat == "bombarde":
		var profil: Dictionary = BestiaireMondes.ZONES[str(d.get("zone", "impact"))]
		var destination: Vector2 = ennemi._point_vise - ennemi.global_position
		# La meme limite est visible pendant l'armement puis pendant le vol.
		dessiner_zone(ennemi, destination, float(profil["rayon"]), 0.0)
		dessiner_zone(ennemi, Vector2.ZERO, rayon, _progression(ennemi, float(d["telegraphe"])))
		return true
	if etat == "frappe":
		dessiner_zone(ennemi, Vector2.ZERO, float(ennemi._distance_contact()) + Reglages.ENNEMI_CONTACT_MARGE,
			_progression(ennemi, Reglages.ENNEMI_CONTACT_ANNONCE))
		return true
	if etat == "gonfler":
		dessiner_zone(ennemi, Vector2.ZERO, float(d["rayon_explosion"]), _progression(ennemi, float(d["preparation"])))
		if bool(ennemi._annonce_projectile): _anneau(ennemi, rayon, int(d.get("projectiles_cercle", 0)))
		return true
	if etat in ["pulse", "invoque", "vise_phase"]:
		var duree := Reglages.PHASE_PREPARATION_TIR if etat == "vise_phase" else float(d["telegraphe"])
		dessiner_zone(ennemi, Vector2.ZERO, rayon * 1.4, _progression(ennemi, duree))
		if bool(ennemi._annonce_projectile): _anneau(ennemi, rayon, int(d.get("projectiles_cercle", 0)))
		if etat == "vise_phase": _tirs(ennemi, rayon, ennemi._point_vise)
		return true
	if etat not in ["vise", "vise_orbite", "crache"]: return false
	_tirs(ennemi, rayon, ennemi._point_vise)
	return true

static func _anneau(ennemi: Node2D, rayon: float, nombre: int) -> void:
	var d: Dictionary = ennemi.donnees
	var longueur := minf(float(d.get("portee_projectile", 0.0)), Rendu.ANNONCE_ANNEAU_PORTEE)
	var tir := _tir_annonce(d)
	for i in nombre:
		var axe := Vector2.from_angle(TAU * float(i) / float(nombre) + float(ennemi.decalage_anneau()))
		_trajectoire(ennemi, axe * rayon, axe, tir, longueur)

static func _tir_annonce(d: Dictionary) -> Tir:
	var tir := Tir.new()
	tir.vitesse = float(d.get("vitesse_projectile", 1.0))
	tir.portee = float(d.get("portee_projectile", BestiaireMondes.BOSS_PORTEE_PROJECTILE))
	if str(d["cerveau"]) == "boss": tir.vitesse *= Reglages.BOSS_PROJECTILE_VITESSE_MULT
	ProjectilesEnnemis.appliquer(tir, d)
	return tir

static func _trajectoire(noeud: Node2D, origine: Vector2, direction: Vector2, tir: Tir, longueur: float) -> void:
	if tir.trajectoire == "aller_retour": longueur = minf(longueur, tir.distance_retour)
	var points := PackedVector2Array()
	for i in 33:
		var distance := longueur * i / 32.0
		var lateral := tir.amplitude * sin(distance / maxf(tir.vitesse, 1.0) * TAU * tir.frequence) if tir.trajectoire == "sinus" else 0.0
		points.append(origine + direction * distance + direction.orthogonal() * lateral)
	noeud.draw_polyline(points, Color(Rendu.ANNONCE_COULEUR, .10), tir.rayon * 2.0, true)
	noeud.draw_polyline(points, Color(Rendu.ANNONCE_CONTRASTE, .7), Rendu.ANNONCE_TRAIT + 4.0, true)
	noeud.draw_polyline(points, Color(Rendu.ANNONCE_COULEUR, .85), Rendu.ANNONCE_TRAIT, true)
	if tir.trajectoire == "aller_retour":
		noeud.draw_arc(points[-1], tir.rayon + 8.0, .2, TAU - .2, 24, Rendu.ANNONCE_COULEUR, 3.0, true)
		var milieu := origine + direction * longueur * .5
		_trait(noeud, milieu, milieu + direction.rotated(.5) * 22.0)
		_trait(noeud, milieu, milieu + direction.rotated(-.5) * 22.0)

static func _tirs(ennemi: Node2D, rayon: float, cible: Vector2) -> void:
	var d: Dictionary = ennemi.donnees
	var fin := cible - ennemi.global_position
	var direction := fin.normalized()
	var longueur := float(d.get("portee_projectile", fin.length()))
	var tir := _tir_annonce(d)
	tir.nb_projectiles = int(d.get("projectiles", 1))
	tir.angle_eventail = float(d.get("angle_eventail", 0.0))
	tir.ecart_lateral = float(d.get("ecart_lateral", 0.0))
	var angles := tir.angles()
	var decalages := tir.decalages()
	for i in angles.size():
		var axe := direction.rotated(angles[i])
		var origine := direction.orthogonal() * decalages[i]
		_trajectoire(ennemi, origine, axe, tir, longueur)

static func dessiner_boss(boss: Node2D, cible: Vector2, annonce: float) -> void:
	if str(boss._motif) == "assaut_contact": _contact_boss(boss)
	for attente: Dictionary in boss._tirs_annonces.attentes:
		var origine: Vector2 = attente["origine"] - boss.global_position
		var direction: Vector2 = attente["direction"]
		var tir: Tir = attente["tir"]
		var progression := 1.0 - float(attente["reste"]) / BestiaireMondes.BOSS_ANNONCE_TIR
		dessiner_zone(boss, origine, maxf(tir.rayon, tir.longueur * .5), progression)
		_trajectoire(boss, origine, direction, tir, minf(tir.portee, Rendu.ANNONCE_ANNEAU_PORTEE))
	if annonce <= 0.0: return
	var fin := cible - boss.global_position
	var motif := str(boss._motif)
	if motif in ["encrage_cible", "foyers_cibles"]:
		var monde := int(boss.donnees["monde_visuel"])
		var profil: Dictionary = BestiaireMondes.ZONES[BestiaireMondes.BOSS_ZONE_PAR_MONDE[monde]]
		dessiner_zone(boss, fin, float(profil["rayon"]) * BestiaireMondes.BOSS_ZONE_RAYON_MULT, 0.0)
		return
	for angle: float in boss._motifs_mondes.angles:
		var axe := fin.normalized().rotated(angle)
		_trajectoire(boss, Vector2.ZERO, axe, _tir_annonce(boss.donnees), fin.length())

static func _contact_boss(boss: Node2D) -> void:
	var contact: RefCounted = boss._contact
	if str(contact.etat) not in ["annonce", "frappe"]: return
	var profil: Dictionary = contact.profil
	var rayon := float(profil["portee"])
	var arc := float(profil["arc"])
	var direction: Vector2 = contact.direction
	var debut := direction.angle() - arc * .5
	var progression := 1.0 - float(contact.reste) / float(profil["annonce"]) if str(contact.etat) == "annonce" else 1.0
	if is_equal_approx(arc, TAU):
		dessiner_zone(boss, Vector2.ZERO, rayon, progression)
		return
	var contour := PackedVector2Array([Vector2.ZERO])
	for i in 49: contour.append(Vector2.from_angle(debut + arc * i / 48.0) * rayon)
	boss.draw_colored_polygon(contour, Color(Rendu.ANNONCE_COULEUR, .13 + .18 * progression))
	contour.append(Vector2.ZERO)
	boss.draw_polyline(contour, Color(Rendu.ANNONCE_CONTRASTE, .85), 8.0, true)
	boss.draw_polyline(contour, Rendu.ANNONCE_COULEUR, 4.0, true)
	boss.draw_arc(Vector2.ZERO, rayon * progression, debut, debut + arc, 48, Rendu.ANNONCE_COULEUR, 3.0, true)

static func dessiner_charge_boss(boss: Node2D) -> void:
	var duree := float(Reglages.BOSS_DUREES_MOTIFS["charge"]) - BestiaireMondes.BOSS_CHARGE_ANNONCE
	var longueur := minf(AttaquesContactBoss.CHARGE_DISTANCE_MAX, float(boss.donnees["vitesse"]) * BestiaireMondes.BOSS_CHARGE_VITESSE * Reglages.ENNEMI_VITESSE_MULT * float(boss._facteur_ralentissement()) * duree)
	var direction: Vector2 = boss._direction_charge
	var largeur := float(boss.donnees["rayon"]) * Reglages.BOSS_HITBOX_MULT
	var fin := direction * longueur
	boss.draw_line(Vector2.ZERO, fin, Color(Rendu.ANNONCE_COULEUR, .22), largeur * 2.0, true)
	for cote in [-1.0, 1.0]:
		var decalage := direction.orthogonal() * largeur * float(cote)
		_trait(boss, decalage, fin + decalage)
