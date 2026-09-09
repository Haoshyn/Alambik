extends SceneTree

var echecs := 0

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	var viewport := SubViewport.new()
	root.add_child(viewport)
	var scene := Node3D.new()
	viewport.add_child(scene)
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.current = true
	for taille in [Vector2i(1080,1920),Vector2i(1080,2400),Vector2i(540,960)]:
		viewport.size = taille
		for zoom in [1.0,0.72]:
			var canevas := Transform2D(Vector2(zoom,0),Vector2(0,zoom),Vector2.ZERO)
			Pont3D.cadrer(camera,Vector2(taille),canevas)
			for p in [Vector2(80,300),Vector2(1000,1700),Vector2(540,960)]:
				var obtenu := camera.unproject_position(Pont3D.vers_monde(p))
				if obtenu.distance_to(canevas*p) > 0.05:
					push_error("Projection decalee : %s attendu %s" % [obtenu,canevas*p])
					echecs += 1
	for id in CatalogueEnnemis.TOUS:
		var chemin := Visuels3D.chemin_ennemi(CatalogueEnnemis.par_id(id))
		var modele := load(chemin) as PackedScene
		if modele == null:
			echecs += 1
			continue
		var instance := modele.instantiate()
		var lecteur := instance.find_child("AnimationPlayer",true,false) as AnimationPlayer
		if lecteur == null:
			push_error("Animations absentes : " + chemin)
			echecs += 1
		else:
			for nom in ["repos","course","attaque","touche","mort","victoire"]:
				if not lecteur.has_animation(nom):
					push_error("Animation absente : %s / %s (%s)" % [chemin,nom,lecteur.get_animation_list()])
					echecs += 1
		instance.free()
	viewport.free()
	print("SONDE_3D : 18 projections, 31 ennemis, animations : %d echecs" % echecs)
	quit(1 if echecs else 0)
