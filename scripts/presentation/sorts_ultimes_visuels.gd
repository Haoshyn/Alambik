extends RefCounted

const M = preload("res://scripts/presentation/matiere_sort.gd")

static func dessiner(r: Array[Dictionary], id: String, c: Vector2, rayon: float,
		t: float, couleur: Color, reduit: bool) -> void:
	var expansion := 1.0 - pow(1.0 - t, 4.0)
	var or_chaud := Color("ffd074", couleur.a)
	var nombre := 6 if reduit else 12
	match id:
		"grand_oeuvre":
			M.halo(r, c, rayon * (.3 + .65 * expansion), Color(couleur, couleur.a * .26), .025)
			M.couronne(r, c, rayon * expansion, 24.0 * (1.0 - t), couleur, .06, 0, TAU, 32 if reduit else 64)
			M.sceau(r, c, rayon * (.20 + .26 * expansion), or_chaud, t * .26, reduit)
			for i in 6:
				var angle := TAU * i / 6.0 + t * .26
				var point := c + Vector2.from_angle(angle) * rayon * .46
				M.petale(r, c + Vector2.from_angle(angle) * rayon * .12, angle, rayon * .46 * expansion,
					20.0 * (1.0 - t), Color(couleur, couleur.a * .55), .08, .20, .32, 6)
				M.cristal(r, point, angle, 34.0 * sin(PI * t), or_chaud, .20 + t * .3, 1.0)
				M.petale(r, point, angle, rayon * .12, 18.0 * sin(PI * t), Color(couleur.lightened(.55), couleur.a * .8),
					.10, 2.25 * sin(PI * t), -.25, 8)
				M.couronne(r, c, rayon * .63, 9.0, Color(or_chaud, couleur.a * .75), .09, angle, .56, 8)
		"temps_suspendu":
			var taille := rayon * (.43 + .06 * expansion)
			var fige := minf(t, .28)
			M.halo(r, c, taille * 1.2, Color(couleur, couleur.a * .28), .04)
			M.couronne(r, c, rayon * expansion, 18.0 * (1.0 - t), Color(couleur, couleur.a * .32), .025, 0, TAU, 32 if reduit else 64)
			M.couronne(r, c, taille, 10.0, or_chaud, .08)
			M.couronne(r, c, taille * .84, 6.0, Color(couleur, couleur.a * .7), .10)
			for i in 12:
				var angle := TAU * i / 12.0
				var direction := Vector2.from_angle(angle)
				M.petale(r, c + direction * taille * .85, angle, taille * .13, 6.0 if i % 3 else 11.0,
					or_chaud, .12, .04, 0.0, 3)
			var aiguille := -PI * .5 + (1.0 - pow(1.0 - minf(t * 3.8, 1.0), 3.0)) * PI * .5
			M.petale(r, c, aiguille, taille * .76, 12.0, Color(couleur.lightened(.8), couleur.a), .20, .02, 0.0, 5)
			M.petale(r, c, aiguille - 1.8, taille * .50, 16.0, or_chaud, .22, .03, 0.0, 5)
			M.cristal(r, c, 0, 16.0, or_chaud, .18, .10)
			for i in nombre:
				var angle := TAU * i / float(nombre) + fige * .65
				var point := c + Vector2.from_angle(angle) * rayon * (.54 + fige * .40)
				M.cristal(r, point, angle + .4, 16.0, couleur, .16 + fige * .8, .35)
		"transmutation_totale":
			var transformation := smoothstep(.12, .72, t)
			var fusion := couleur.lerp(or_chaud, transformation)
			M.halo(r, c, rayon * expansion, Color(couleur, couleur.a * .25), .03)
			M.sceau(r, c, rayon * (.18 + .26 * expansion), or_chaud, -t * .30, reduit)
			for i in nombre:
				var angle := TAU * i / float(nombre) + t * .32
				var direction := Vector2.from_angle(angle)
				var point := c + direction * rayon * (.22 + .54 * expansion)
				M.petale(r, c + direction * rayon * .15, angle, rayon * .48 * expansion, 20.0 * (1.0 - t),
					Color(fusion, couleur.a * .6), .05, .28, -.3, 6)
				M.cristal(r, point, angle + transformation * PI * .5, 36.0 * sin(PI * t), fusion, .16 + t * .3, .95)
				M.etincelle(r, point, 23.0 * sin(PI * t), or_chaud, .55 + t * .4)
				if i % 2 == 0:
					M.couronne(r, c, rayon * .82, 13.0 * (1.0 - t), Color(fusion, couleur.a * .7), .04, angle, .58, 8)
		"purification_totale":
			M.halo(r, c, rayon * expansion, Color(couleur, couleur.a * .20), .03)
			for i in (2 if reduit else 3):
				M.couronne(r, c, rayon * maxf(.02, expansion - i * .13), (24.0 - i * 4) * (1.0 - t),
					Color(couleur, couleur.a * (1.0 - i * .13)), .06 + i * .13, 0, TAU, 32 if reduit else 64)
			for i in nombre:
				var angle := TAU * i / float(nombre) + t * .22
				var point := c + Vector2.from_angle(angle) * rayon * (.18 + .52 * expansion)
				var taille := sin(PI * t)
				M.petale(r, point, angle + .65, rayon * .28 * taille, 22.0 * taille,
					Color(couleur.lightened(.5), couleur.a), .12, .95 * taille, -.45, 8)
				M.etincelle(r, point, 22.0 * taille, or_chaud, .45 + taille * .3, angle)
				if not reduit:
					M.halo(r, point, 42.0 * taille, Color("b6f7eb", couleur.a * .22), .25, Vector2(1, .65), 12)
