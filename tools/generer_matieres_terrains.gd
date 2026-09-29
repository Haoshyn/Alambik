extends SceneTree

# Source originale des peintures et normales des nappes, sans texture externe.
const TAILLE := 384

func _init() -> void:
	call_deferred("_generer")

func _generer() -> void:
	DirAccess.make_dir_recursive_absolute(DecorsTerrains.DOSSIER)
	var erreurs := 0
	for type: String in DecorsTerrains.PROFILS:
		var bruit := FastNoiseLite.new()
		bruit.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		bruit.frequency = 1.0
		bruit.fractal_type = FastNoiseLite.FRACTAL_NONE
		bruit.seed = 28092026 + type.hash()
		var peinture := Image.create(TAILLE, TAILLE, false, Image.FORMAT_RGB8)
		var normale := Image.create(TAILLE, TAILLE, false, Image.FORMAT_RGB8)
		var fond := DecorsTerrains.couleur(type, "fond")
		var profond := DecorsTerrains.couleur(type, "profond")
		var clair := DecorsTerrains.couleur(type, "clair")
		var reflet := DecorsTerrains.couleur(type, "reflet")
		for y in TAILLE:
			for x in TAILLE:
				var uv := (Vector2(x, y) + Vector2(.5, .5)) / TAILLE
				var nuage := bruit.get_noise_2d(uv.x * 4.0, uv.y * 4.0)
				var detail := bruit.get_noise_2d(uv.x * 17.0 + 41.0, uv.y * 17.0)
				var veine := sin(uv.y * 24.0 + sin(uv.x * 9.0) * 1.8 + nuage * 2.0)
				var couleur := fond.lerp(profond, clampf(.15 - nuage * .35, 0.0, .5))
				couleur = couleur.lerp(clair, clampf(nuage * .28 + .08 + detail * .04, 0.0, .28))
				var lueur := exp(-pow((uv.x + sin(uv.y * 7.0) * .09 - .34) / .13, 2.0)) * exp(-pow((uv.y - .28) / .13, 2.0))
				if type == "sable":
					couleur = couleur.lerp(clair, smoothstep(.35, 1.0, veine) * .17)
					couleur *= .98 + bruit.get_noise_2d(uv.x * 170.0, uv.y * 170.0) * .07
				elif type == "lave":
					couleur = couleur.lerp(reflet, smoothstep(.87, 1.0, veine) * .66)
				else:
					var rive_claire := exp(-pow((uv.x - .24 - sin(uv.y * 8.0) * .055) / .018, 2.0))
					rive_claire *= smoothstep(.12, .24, uv.y) * (1.0 - smoothstep(.48, .67, uv.y))
					var ridule := exp(-pow((uv.y - .30 - sin(uv.x * 9.0) * .03) / .012, 2.0))
					ridule *= smoothstep(.38, .48, uv.x) * (1.0 - smoothstep(.65, .77, uv.x))
					var reflet_surface := lueur * .34 + rive_claire * .40 + ridule * .20
					couleur = couleur.lerp(reflet, reflet_surface * (1.0 if type == "eau" else .70))
				peinture.set_pixel(x, y, couleur)
				var pente := Vector2(sin(uv.x * 29.0 + uv.y * 12.0 + nuage) * .12,
					cos(uv.y * 24.0 + uv.x * 8.0 + detail) * .13)
				var z := sqrt(maxf(0.0, 1.0 - pente.length_squared()))
				normale.set_pixel(x, y, Color(.5 + pente.x * .5, .5 + pente.y * .5, .5 + z * .5))
		for sortie: Dictionary in [{"image":peinture,"nom":type},{"image":normale,"nom":type + "_normale"}]:
			var image: Image = sortie["image"]
			var chemin := DecorsTerrains.DOSSIER + str(sortie["nom"]) + ".png"
			if image.save_png(chemin) != OK:
				push_error("Ecriture de matiere impossible : " + chemin)
				erreurs += 1
		print("Matiere de terrain originale : " + type)
	quit(0 if erreurs == 0 else 1)
