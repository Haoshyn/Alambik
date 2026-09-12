extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var v := Verif.new()
	for fps in [30,60,120]:
		var heros: Node2D = load("res://scripts/heros.gd").new()
		root.add_child(heros)
		heros.set_process(false)
		heros.set_physics_process(false)
		var modele: Node3D = load(Visuels3D.HEROS_MODELE).instantiate()
		root.add_child(modele)
		var animation: AnimationTree = load("res://scripts/presentation/animation_heros_3d.gd").new()
		modele.add_child(animation)
		animation.preparer(modele.find_child("AnimationPlayer",true,false))
		var evenements: Array[String] = []
		heros.connect("attaque_preparee",func(_direction):
			evenements.append("preparation")
			animation.armer())
		heros.connect("tir_demande",func(_tir,_origine,_direction):
			evenements.append("projectile")
			animation.projeter()
			v.presque(float(animation.get("parameters/attaque/current_position")),Reglages.TIR_PREPARATION,"pose synchronisee au projectile a %d Hz" % fps, .0001))
		# Deux tirs espaces comme une rafale doivent chacun avoir leur geste et leur projectile.
		for tir in 2:
			heros.call("_preparer_tir",Vector2.UP)
			v.egal(evenements.back(),"preparation","le geste precede le projectile")
			var temps := 0.0
			while temps < Reglages.RAFALE_INTERVALLE:
				var nombre_avant := evenements.size()
				heros.call("_avancer_tirs_prepares",1.0/fps)
				animation.mettre_a_jour(1.0/fps,0.0,false)
				if evenements.size() > nombre_avant:
					v.presque(float(animation.get("parameters/attaque/current_position")),Reglages.TIR_PREPARATION,"la premiere image affichee reste celle de la projection",.0001)
				temps += 1.0/fps
		v.egal(evenements,["preparation","projectile","preparation","projectile"],"un projectile par geste, meme en rafale")
		heros.call("_preparer_tir",Vector2.UP)
		heros.set("_rafale_restante",2)
		heros.preparer_nouvelle_salle()
		heros.call("_avancer_tirs_prepares",1.0)
		v.egal(evenements.back(),"preparation","le changement de salle annule le projectile prepare")
		v.egal(int(heros.get("_rafale_restante")),0,"la rafale ne deborde pas dans la salle suivante")
		heros.call("_preparer_tir",Vector2.UP)
		heros.stats.pv = 0
		heros.call("_avancer_tirs_prepares",1.0)
		v.egal(evenements.back(),"preparation","la mort annule le projectile en attente")
		modele.free()
		heros.free()
	print("SYNCHRONISATION_TIR : %d assertions, %d echecs" % [v.total,v.echecs.size()])
	for echec in v.echecs: push_error(echec)
	quit(1 if not v.echecs.is_empty() else 0)
