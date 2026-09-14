extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var v := Verif.new()
	var presentation: Script = load("res://scripts/presentation/materiaux_apprenti.gd")
	for chemin: String in [Visuels3D.HEROS_MODELE_ORIGINAL,Visuels3D.HEROS_MODELE_ACCUEIL,Visuels3D.HEROS_MODELE_ACCUEIL_V2]:
		var modele: Node3D = load(chemin).instantiate()
		root.add_child(modele)
		presentation.appliquer(modele)
		var peau := modele.find_child("Apprenti_peau",true,false) as MeshInstance3D
		v.vrai(peau != null,"Peau presente : "+chemin)
		if peau != null:
			var mat := peau.get_active_material(0) as ShaderMaterial
			v.vrai(mat != null,"Materiau du jeu applique")
			if mat != null:
				var nouveau := chemin == Visuels3D.HEROS_MODELE_ACCUEIL_V2
				v.vrai(mat.shader.resource_path == ("res://shaders/apprenti_accueil_surface.gdshader" if nouveau else "res://shaders/apprenti_surface.gdshader"),"Le retour a un ancien modele conserve son shader")
				if nouveau:
					v.vrai(mat.get_shader_parameter("peau") == true,"La peau utilise les ombres chaudes")
					v.vrai(mat.get_shader_parameter("oeil") == false,"La peau garde son modelage")
		if chemin == Visuels3D.HEROS_MODELE_ACCUEIL_V2:
			for nom: String in ["Apprenti_iris","Apprenti_iris_miel","Apprenti_yeux","Apprenti_blanc_oeil"]:
				var oeil := modele.find_child(nom,true,false) as MeshInstance3D
				v.vrai(oeil != null,"Couche d'oeil : "+nom)
				if oeil != null:
					var mat := oeil.get_active_material(0) as ShaderMaterial
					v.vrai(mat.get_shader_parameter("oeil") == true,"Les yeux gardent leurs couleurs et reflets dessines")
			var squelette := modele.find_child("Skeleton3D",true,false) as Skeleton3D
			v.vrai(squelette != null and squelette.get_bone_count() == 18,"Rig complet preserve")
		modele.free()
	var aventure := IconesArcane.texture("navigation_aventure")
	v.vrai(aventure.resource_path == "res://assets/visual/manga/navigation_aventure.png","Navigation Aventure avec les epees croisees")
	v.vrai(aventure.get_width() <= 256,"Icone de navigation adaptee au mobile")
	print("MATERIAUX_ACCUEIL : %d assertions, %d echecs" % [v.total,v.echecs.size()])
	for message in v.echecs: push_error(message)
	quit(0 if v.echecs.is_empty() else 1)
