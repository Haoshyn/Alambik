extends "res://sondes/retouches_graphiques.gd"

func capturer(nom: String) -> void:
	await super.capturer(nom)
	if nom != "heros": return
	var squelette := root.find_child("Skeleton3D",true,false) as Skeleton3D
	var lecteur := root.find_child("AnimationPlayer",true,false) as AnimationPlayer
	exiger(squelette != null and lecteur != null,"squelette et animations charges")
	if squelette == null or lecteur == null: return
	var poignet := squelette.find_bone("main_droite")
	exiger(poignet >= 0,"poignet de la baguette articule")
	if poignet >= 0:
		exiger(squelette.get_bone_parent(poignet) == squelette.find_bone("avant_bras_droit"),"main reliee a l'avant-bras")
	var materiaux := 0
	for objet in root.find_children("*","MeshInstance3D",true,false):
		var instance := objet as MeshInstance3D
		if instance.mesh == null: continue
		for i in instance.mesh.get_surface_count():
			var mat := instance.get_active_material(i) as StandardMaterial3D
			if mat != null: materiaux += 1
	exiger(materiaux >= 3,"materiaux du personnage effectivement importes")
	var genou := squelette.find_bone("tibia_gauche")
	var cheville := squelette.find_bone("pied_gauche")
	var racine := squelette.find_bone("racine")
	exiger(genou >= 0 and cheville >= 0,"chaine hanche genou cheville exportee")
	if genou < 0 or cheville < 0: return
	lecteur.play("course")
	lecteur.seek(0.0,true)
	lecteur.pause()
	var flexion := squelette.get_bone_pose_rotation(genou)
	var pied := squelette.get_bone_pose_rotation(cheville)
	lecteur.seek(0.25,true)
	exiger(not flexion.is_equal_approx(squelette.get_bone_pose_rotation(genou)),"le genou se plie pendant le pas")
	exiger(not pied.is_equal_approx(squelette.get_bone_pose_rotation(cheville)),"la cheville compense le mouvement du genou")
	exiger(squelette.get_bone_pose_scale(racine).is_equal_approx(Vector3.ONE),"aucun ecrasement global du corps")
	var position_buste := squelette.get_bone_global_pose(racine).origin
	var repere := squelette.global_transform
	DirAccess.make_dir_recursive_absolute("res://tmp/mage-marche")
	var camera := root.get_camera_3d()
	var vue_initiale := camera.transform
	# La marche doit montrer ce que le joueur voit sous le chapeau.
	camera.position = Vector3(0,1.0+4.6*tan(deg_to_rad(Pont3D.INCLINAISON)),4.6)
	camera.look_at(Vector3(0,1.0,0))
	for i in 32:
		lecteur.seek(float(i)/32.0,true)
		exiger(squelette.get_bone_global_pose(racine).origin.distance_to(position_buste)<0.001,"buste stable pendant le cycle")
		exiger(squelette.global_transform.is_equal_approx(repere),"le parent du squelette ne bascule ni ne change d'echelle")
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tmp/mage-marche/%02d.png" % i)
	lecteur.play("repos")
	lecteur.seek(0.2,true)
	lecteur.pause()
	for angle in [0,90,180,270]:
		var radians := deg_to_rad(float(angle))
		camera.position = Vector3(sin(radians)*4.6,1.55,cos(radians)*4.6)
		camera.look_at(Vector3(0,1.0,0))
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tmp/mage-vue-%d.png" % angle)
	camera.position = Vector3(0,1.0+4.6*tan(deg_to_rad(Pont3D.INCLINAISON)),4.6)
	camera.look_at(Vector3(0,1.0,0))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/mage-vue-jeu.png")
	camera.transform = vue_initiale
