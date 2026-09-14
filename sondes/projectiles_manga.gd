extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var v := Verif.new()
	var reglages := root.get_node("ReglagesJoueur")
	for arme in ["standard","veloce","lourd","chercheur","explosif"]:
		for hostile in [false,true]:
			var projectile: Area2D = load("res://scenes/projectile.tscn").instantiate()
			var tir := Tir.new()
			tir.arme = arme
			projectile.tir = tir
			projectile.hostile = hostile
			projectile.set_physics_process(false)
			root.add_child(projectile)
			projectile.position = Vector2(310,750)
			projectile.direction = Vector2(1,-1).normalized()
			var proxy: Node3D = load("res://scripts/presentation/projectile_3d.gd").new()
			root.add_child(proxy)
			proxy.preparer(projectile,null,"projectile")
			v.vrai(proxy.position.is_equal_approx(Pont3D.vers_monde(projectile.position)),"Le visuel suit la collision : "+arme)
			var coeur: MeshInstance3D = proxy.modele.get_child(0)
			if hostile:
				v.vrai(coeur.mesh is QuadMesh,"Les tirs ennemis gardent leur presentation")
			else:
				v.vrai(coeur.mesh is SphereMesh,"Silhouette du tir sans support rectangulaire : "+arme)
				v.vrai(coeur.position.y > coeur.scale.y,"La perle n'est pas coupee par le sol : "+arme)
				for reduit in [true,false]:
					reglages.effets_reduits = reduit
					proxy.mettre_a_jour(0)
					v.vrai(coeur.visible,"Le coeur reste visible en effets reduits")
					for i in range(1,proxy.modele.get_child_count()):
						v.vrai(proxy.modele.get_child(i).visible == not reduit,"La trainee respecte les effets reduits")
			proxy.free()
			projectile.free()
	print("PROJECTILES_MANGA : %d assertions, %d echecs" % [v.total,v.echecs.size()])
	for message in v.echecs:
		push_error(message)
	quit(0 if v.echecs.is_empty() else 1)
