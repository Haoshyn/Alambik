extends RefCounted

const Rendu = preload("res://data/animations_combat.gd")
const Magie = preload("res://scripts/presentation/dessin_magie.gd")

static func dessiner(noeud: Node2D, profil: Dictionary, origine: Vector2, age: float) -> void:
	var rayon := float(profil["rayon"])
	var delai := float(profil["delai"])
	var aspect := str(profil.get("aspect", "impact"))
	var couleur: Color = Rendu.ZONES_COULEURS.get(aspect, Color("ffb450"))
	if age < delai:
		var avancee := clampf(age / maxf(delai, 0.01), 0.0, 1.0)
		var danger := Color("ff523d")
		noeud.draw_circle(Vector2.ZERO, rayon, Color(danger, .07 + .08 * avancee))
		noeud.draw_arc(Vector2.ZERO, rayon, 0, TAU, 48, Color(danger, .65), 2.5, true)
		noeud.draw_arc(Vector2.ZERO, rayon * .94, -PI/2, -PI/2 + TAU * avancee, 48, danger, 4.0, true)
		# La limite reste fixe ; les chevrons convergent vers le point d'impact.
		for i in 4:
			var direction := Vector2.from_angle(PI * .25 + i * PI * .5)
			var point := direction * rayon * (1.0 - avancee * .52)
			noeud.draw_line(point, point + direction.rotated(.6) * 12, danger, 2.5, true)
			noeud.draw_line(point, point + direction.rotated(-.6) * 12, danger, 2.5, true)
		if bool(profil.get("lob", false)):
			_dessiner_lob(noeud, origine, avancee, couleur)
		return
	var temps := age - delai
	var duree := maxf(float(profil["duree"]), BestiaireMondes.ZONE_ECLAT_DUREE)
	var opacite := 1.0 - smoothstep(duree * .7, duree, temps)
	var frappe := clampf(temps / BestiaireMondes.ZONE_ECLAT_DUREE, 0.0, 1.0)
	var expansion := 1.0 - pow(1.0 - frappe, 3.0)
	noeud.draw_circle(Vector2.ZERO, rayon, Color(couleur, .09 * opacite))
	noeud.draw_arc(Vector2.ZERO, rayon, 0, TAU, 48, Color(Color("ff523d"), .55 * opacite), 2.5, true)
	if frappe < 1.0:
		noeud.draw_arc(Vector2.ZERO, rayon * (.12 + .88 * expansion), 0, TAU, 48, Color(couleur, (1.0 - frappe) * .9), 8.0 * (1.0 - frappe) + 1.0, true)
		noeud.draw_circle(Vector2.ZERO, rayon * .16 * (1.0 - frappe), Color(couleur.lightened(.8), (1.0 - frappe) * .75))
	if aspect == "foudre":
		var eclair := PackedVector2Array([Vector2(0,-rayon*1.5), Vector2(-rayon*.2,-rayon*.7), Vector2(rayon*.15,-rayon*.8), Vector2.ZERO])
		noeud.draw_polyline(eclair, Color(couleur, opacite * .4), 14.0, true)
		noeud.draw_polyline(eclair, Color(couleur.lightened(.8), opacite), 4.0, true)
		return
	if aspect == "maree":
		for i in 3:
			var vague := maxf(.02, expansion - float(i) * .20)
			noeud.draw_arc(Vector2.ZERO, rayon * vague, i * .9, i * .9 + PI * 1.5, 32, Color(couleur, opacite * .8), 4.0, true)
		return
	var nombre := 4 if ReglagesJoueur.effets_reduits else 7
	for i in nombre:
		var direction := Vector2.from_angle(TAU * i / float(nombre))
		var point := direction * rayon * (.12 + .60 * expansion)
		var hauteur := sin(frappe * PI) * rayon * .25
		if aspect == "braise":
			hauteur = (12.0 + 10.0 * sin(temps * 8.0 + i * 2.3)) * opacite
			noeud.draw_colored_polygon(PackedVector2Array([point + Vector2(-7,4), point + Vector2(sin(temps*6+i)*5,-hauteur), point + Vector2(7,4)]), Color(couleur, opacite * .85))
		else:
			point.y -= hauteur
			var taille := rayon * .08 * (1.0 - frappe)
			if taille <= .1: continue
			noeud.draw_colored_polygon(PackedVector2Array([point + direction*taille*1.8, point + direction.orthogonal()*taille, point - direction*taille, point - direction.orthogonal()*taille]), Color(couleur, opacite))

static func _dessiner_lob(noeud: Node2D, origine: Vector2, t: float, couleur: Color) -> void:
	var precedent := origine.lerp(Vector2.ZERO, t) - Vector2(0, sin(t * PI) * Rendu.LOB_HAUTEUR)
	var tete := precedent
	var avant := origine.lerp(Vector2.ZERO, maxf(0.0, t - .015)) - Vector2(0, sin(maxf(0.0, t - .015) * PI) * Rendu.LOB_HAUTEUR)
	var direction := avant.direction_to(tete)
	for i in (3 if ReglagesJoueur.effets_reduits else 6):
		var passe := maxf(0.0, t - float(i + 1) * .025)
		var point := origine.lerp(Vector2.ZERO, passe) - Vector2(0, sin(passe * PI) * Rendu.LOB_HAUTEUR)
		var force := 1.0 - float(i) / 6.0
		noeud.draw_line(precedent, point, Color(couleur, .16 * force), maxf(1.0, 18.0 - i * 2), true)
		noeud.draw_line(precedent, point, Color(couleur, .60 * force), maxf(1.0, 7.0 - i), true)
		noeud.draw_line(precedent, point, Color(couleur.lightened(.75), .65 * force), maxf(1.0, 2.5 - i * .3), true)
		precedent = point
	Magie.goutte(noeud, tete, direction.angle(), 11.0, couleur)
