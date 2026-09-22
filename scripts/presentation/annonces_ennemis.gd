extends RefCounted

static func dessiner(ennemi: Node2D, rayon: float) -> bool:
	var etat := str(ennemi._etat)
	var d: Dictionary = ennemi.donnees
	var danger := Color(1.0,.16,.12,.58)
	if etat == "phase":
		var destination: Vector2 = ennemi._destination_phase - ennemi.global_position
		ennemi.draw_arc(destination, rayon, 0, TAU, 24, danger, 3.0, true)
		ennemi.draw_line(destination, ennemi._point_vise - ennemi.global_position, danger, 2.0, true)
		return true
	if etat == "preparer":
		var longueur := float(d["vitesse"]) * float(d.get("duree_charge", EvolutionEnnemis.ELAN_DUREE)) * float(ennemi._facteur_vitesse())
		var direction: Vector2 = ennemi._direction_charge
		var largeur := rayon * Reglages.ENNEMI_HITBOX_MULT
		var fin := direction * longueur
		ennemi.draw_line(Vector2.ZERO, fin, Color(danger,.13), largeur * 2.0, true)
		for cote in [-1.0, 1.0]:
			var decalage := direction.orthogonal() * largeur * float(cote)
			ennemi.draw_line(decalage, fin + decalage, danger, 2.5, true)
		ennemi.draw_line(fin, fin - direction.rotated(.5) * rayon, danger, 3.0, true)
		ennemi.draw_line(fin, fin - direction.rotated(-.5) * rayon, danger, 3.0, true)
		return true
	if etat == "bombarde":
		ennemi.draw_arc(Vector2.ZERO, rayon*1.2, 0, TAU, 24, danger, 3.0, true)
		return true
	if etat not in ["vise", "vise_orbite", "tisser", "crache"]: return false
	var fin: Vector2 = ennemi._point_vise - ennemi.global_position
	var direction := fin.normalized()
	var tir := Tir.new()
	tir.nb_projectiles = int(d.get("projectiles", 1))
	tir.angle_eventail = float(d.get("angle_eventail", 0.0))
	tir.ecart_lateral = float(d.get("ecart_lateral", 0.0))
	var angles := tir.angles()
	var decalages := tir.decalages()
	for i in angles.size():
		var axe := direction.rotated(angles[i])
		var origine := direction.orthogonal() * decalages[i]
		if str(d.get("trajectoire", "droite")) == "sinus":
			var points := PackedVector2Array()
			for j in 33:
				var distance := fin.length() * j / 32.0
				var temps := distance / float(d["vitesse_projectile"])
				points.append(origine + axe * distance + axe.orthogonal() * BestiaireMondes.ONDULATION_AMPLITUDE * sin(temps * TAU * BestiaireMondes.ONDULATION_FREQUENCE))
			ennemi.draw_polyline(points, danger, 2.5, true)
		else:
			ennemi.draw_line(origine + axe*rayon, origine + axe*fin.length(), danger, 3.0, true)
	return true

static func dessiner_boss(boss: Node2D, cible: Vector2, annonce: float) -> void:
	if annonce <= 0.0: return
	var fin := cible - boss.global_position
	var motif := str(boss._motif)
	var danger := Color(1,.18,.15,.60)
	if motif in ["encrage_cible", "foyers_cibles"]:
		boss.draw_arc(fin, 18, 0, TAU, 24, danger, 3.0, true)
		return
	for angle: float in boss._motifs_mondes.angles:
		var axe := fin.normalized().rotated(angle)
		if motif == "pierres_rebondissantes":
			boss.draw_line(Vector2.ZERO, axe * fin.length(), danger, 4.0, true)
		else:
			var points := PackedVector2Array()
			var vitesse := float(boss.donnees["vitesse_projectile"]) * Reglages.BOSS_PROJECTILE_VITESSE_MULT
			for i in 33:
				var distance := fin.length() * i / 32.0
				var lateral := BestiaireMondes.BOSS_ONDULATION_AMPLITUDE * sin(distance / vitesse * TAU * BestiaireMondes.BOSS_ONDULATION_FREQUENCE)
				points.append(axe * distance + axe.orthogonal() * lateral)
			boss.draw_polyline(points, danger, 3.0, true)

static func dessiner_charge_boss(boss: Node2D) -> void:
	var duree := float(Reglages.BOSS_DUREES_MOTIFS["charge"]) - BestiaireMondes.BOSS_CHARGE_ANNONCE
	var longueur := float(boss.donnees["vitesse"]) * BestiaireMondes.BOSS_CHARGE_VITESSE * Reglages.ENNEMI_VITESSE_MULT * float(boss._facteur_ralentissement()) * duree
	var direction: Vector2 = boss._direction_charge
	var largeur := float(boss.donnees["rayon"]) * Reglages.BOSS_HITBOX_MULT
	var fin := direction * longueur
	boss.draw_line(Vector2.ZERO, fin, Color(1,.1,.08,.12), largeur * 2.0, true)
	for cote in [-1.0, 1.0]:
		var decalage := direction.orthogonal() * largeur * float(cote)
		boss.draw_line(decalage, fin + decalage, Color(1,.18,.15,.65), 3.0, true)
