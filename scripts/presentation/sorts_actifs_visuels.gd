extends RefCounted

const M = preload("res://scripts/presentation/matiere_sort.gd")

static func dessiner(r: Array[Dictionary], id: String, c: Vector2, rayon: float,
		t: float, couleur: Color, reduit: bool) -> void:
	var expansion := 1.0 - pow(1.0 - t, 4.0)
	var nombre := 6 if reduit else 10
	match id:
		"onde_alchimique":
			M.halo(r, c, rayon * expansion, Color(couleur, couleur.a * .22), .03)
			for i in (2 if reduit else 3):
				var vague := maxf(.025, expansion - i * .15)
				M.couronne(r, c, rayon * vague, (13.0 - i * 2.0) * (1.0 - t) + 1.0,
					Color(couleur, couleur.a * (1.0 - i * .16)), .05 + i * .06, 0, TAU, 28 if reduit else 48)
			M.sceau(r, c, rayon * .42, Color("ffd68a", couleur.a * .7), -.25 * t, reduit)
			for i in nombre:
				var angle := TAU * i / float(nombre) + .18
				var point := c + Vector2.from_angle(angle) * rayon * (.18 + .65 * expansion)
				M.petale(r, point, angle + 1.1, rayon * .18 * (1.0 - t), 5.0 * (1.0 - t),
					Color(couleur.lightened(.35), couleur.a * .6), .12, .18, -.3, 4)
		"nova_de_givre":
			M.halo(r, c, rayon * expansion, Color(couleur, couleur.a * .23))
			M.couronne(r, c, rayon * expansion, 12.0 * (1.0 - t), couleur, .05, 0, TAU, 28 if reduit else 48)
			for i in nombre:
				var angle := TAU * i / float(nombre)
				var pousse := smoothstep(0.0, .18 + (i % 2) * .045, t)
				var direction := Vector2.from_angle(angle)
				var point := c + direction * rayon * (.38 + .32 * (i % 2)) * expansion
				M.petale(r, c + direction * rayon * .12, angle, rayon * .54 * expansion, 9.0,
					Color(couleur, couleur.a * .45), .025, .03, .07, 4)
				M.cristal(r, point, angle, rayon * .19 * pousse, couleur, .07, (.50 + .35 * (i % 2)) * pousse)
				M.etincelle(r, point, 10.0 * (1.0 - t), couleur.lightened(.6), .6 * pousse)
				if not reduit:
					M.halo(r, point + direction * rayon * .07, rayon * .22,
						Color(couleur, couleur.a * .12), .12 + t * .15, Vector2(1, .7), 12, t * 2.0)
		"barrage_de_braise":
			M.halo(r, c, rayon * (.28 + expansion * .6), Color(couleur, couleur.a * .40), .05, Vector2.ONE, 24, t * 4.0)
			M.couronne(r, c, rayon * expansion, 16.0 * (1.0 - t), Color(couleur, couleur.a * .48))
			for i in nombre:
				var phase := clampf(t * 1.5 - (i % 3) * .075, 0.0, 1.0)
				var angle := TAU * i / float(nombre) + .10 * sin(float(i * 7))
				var point := c + Vector2.from_angle(angle) * rayon * (.06 + phase * .60)
				var force := sin(PI * clampf(phase * 1.8, 0.0, 1.0))
				var braise := Color(couleur, couleur.a * (1.0 - phase))
				M.petale(r, point, angle, rayon * (.38 + .26 * force) * (1.0 - phase), rayon * .085 * (1.0 - phase),
					braise, .06 + sin(phase * PI) * .35, .35 + .30 * force, .20 * sin(phase * 8.0 + i), 7)
				M.cristal(r, point, angle + phase * 2.0, 6.0 * (1.0 - phase), Color("ffd677", braise.a), sin(phase * PI) * .8, .10)
				if not reduit:
					M.halo(r, point, rayon * .19 * (1.0 - phase), Color(couleur, braise.a * .18), .2 + sin(phase * PI) * .45, Vector2(1, .8), 12, t + i)
		"impulsion_foudroyante":
			M.halo(r, c, rayon * (.30 + .60 * expansion), Color(couleur, couleur.a * .38))
			M.couronne(r, c, rayon * expansion, 11.0 * (1.0 - t), Color(couleur, couleur.a * .7))
			for i in (6 if reduit else 8):
				var direction := Vector2.from_angle(TAU * i / (6.0 if reduit else 8.0))
				var precedent := c + direction * rayon * .06
				for j in range(1, 5):
					var point := c + direction * rayon * j / 4.0 + direction.orthogonal() * sin(float(i * 9 + j * 7)) * rayon * .14
					M.ruban(r, precedent, point, Color(couleur, couleur.a * .32), 18.0 * (1.0 - t), .11)
					M.ruban(r, precedent, point, couleur, 7.0 * (1.0 - t) + 1.0, .12)
					M.ruban(r, precedent, point, Color(couleur.lightened(.88), couleur.a), 2.0, .13)
					if j == 2:
						M.ruban(r, point, point + direction.rotated(.7) * rayon * .34, couleur, 3.5 * (1.0 - t), .12, .35)
					precedent = point
				M.etincelle(r, precedent, 13.0 * (1.0 - t), couleur, .12)
			M.petale(r, c, -PI * .5, rayon * .2, rayon * .12, Color(couleur.lightened(.5), couleur.a), .12, 1.45 * (1.0 - t), -.25, 7)
		"explosion_corrosive":
			M.halo(r, c, rayon * expansion, Color(couleur, couleur.a * .32), .025, Vector2.ONE, 28, t * 2.0)
			M.couronne(r, c, rayon * expansion * .86, 14.0 * (1.0 - t), Color(couleur, couleur.a * .65), .04, 0, TAU, 28 if reduit else 48)
			for i in nombre:
				var angle := TAU * i / float(nombre)
				var point := c + Vector2.from_angle(angle) * rayon * (.32 + .36 * expansion)
				var phase := clampf((t - (i % 3) * .08) / .76, 0.0, 1.0)
				var taille := rayon * .13 * sin(PI * phase)
				M.bulle(r, point, taille, couleur, .05 + phase * (.3 + .1 * (i % 3)))
				M.petale(r, c + Vector2.from_angle(angle) * rayon * .12, angle, rayon * .5 * expansion,
					rayon * .075 * (1.0 - t), Color(couleur, couleur.a * .6), .03, .15 * (1.0 - t), .2, 5)
			M.sceau(r, c, rayon * .25, Color(couleur, couleur.a * .4), t * .20, reduit)
		"vortex_alchimique":
			M.halo(r, c, rayon * (.8 - .3 * t), Color(couleur, couleur.a * .30), .06)
			M.halo(r, c, rayon * .2, Color(couleur.darkened(.6), couleur.a * .8), .08)
			_spirales(r, c, rayon, t, couleur, reduit)
			M.couronne(r, c, rayon * .15, 8.0 * (1.0 - t), Color(couleur.lightened(.6), couleur.a), .20)
			for i in nombre:
				var angle := TAU * i / float(nombre) - t * TAU
				var point := c + Vector2.from_angle(angle) * rayon * (.88 - .72 * t)
				M.cristal(r, point, angle - .8, 8.0 * (1.0 - t), Color("ffce9a", couleur.a * .9), t * .5, .10)

static func _spirales(r: Array[Dictionary], c: Vector2, rayon: float, t: float, couleur: Color, reduit: bool) -> void:
	var nombre := 3 if reduit else 5
	var pas := 14 if reduit else 24
	for i in nombre:
		for j in pas:
			var points: Array[Vector2] = []
			var hauteurs: Array[float] = []
			var couleurs: Array[Color] = []
			for k in 2:
				var part := float(j + k) / pas
				var angle := TAU * i / float(nombre) + part * TAU * .9 - t * TAU * 1.2
				var radial := Vector2.from_angle(angle)
				var point := c + radial * rayon * (.08 + .88 * part) * (1.0 - t * .48)
				var largeur := rayon * .062 * sin(part * PI) * (1.0 - t * .4)
				var h := .12 + (1.0 - part) * .72
				points.append_array([point - radial * largeur, point, point + radial * largeur])
				hauteurs.append_array([h, h + .09, h])
				couleurs.append_array([Color(couleur, 0), Color(couleur.lightened(.45), couleur.a * sin(part * PI)), Color(couleur, 0)])
			M.quad(r, [points[0], points[1], points[4], points[3]], [hauteurs[0], hauteurs[1], hauteurs[4], hauteurs[3]], [couleurs[0], couleurs[1], couleurs[4], couleurs[3]])
			M.quad(r, [points[1], points[2], points[5], points[4]], [hauteurs[1], hauteurs[2], hauteurs[5], hauteurs[4]], [couleurs[1], couleurs[2], couleurs[5], couleurs[4]])
