extends RefCounted

static func appliquer(modele: Node3D) -> void:
	var secours := modele.scene_file_path == Visuels3D.HEROS_MODELE_SECOURS
	var accueil_v2 := secours or modele.scene_file_path == Visuels3D.HEROS_MODELE_ACCUEIL_V2
	if modele.get_node_or_null("Ombre_apprenti") == null:
		var ombre := MeshInstance3D.new()
		ombre.name = "Ombre_apprenti"
		var plan := PlaneMesh.new()
		plan.size = Vector2(.87,.62)
		ombre.mesh = plan
		ombre.position.y = .005
		ombre.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var mat := ShaderMaterial.new()
		mat.shader = preload("res://shaders/ombre_apprenti.gdshader")
		ombre.material_override = mat
		modele.add_child(ombre)
	# Le nouveau mage porte ses textures et ses reliefs dans le GLB.
	if modele.scene_file_path == Visuels3D.HEROS_MODELE_REFERENCE:
		for objet: Node in modele.find_children("*", "MeshInstance3D", true, false):
			var maillage := objet as MeshInstance3D
			maillage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if maillage.name == &"Apprenti_peau":
				var peau := ShaderMaterial.new()
				peau.shader = preload("res://shaders/mage_reference_peau.gdshader")
				var source := maillage.get_active_material(0) as StandardMaterial3D
				if source != null:
					peau.set_shader_parameter("teinte", source.albedo_color)
				maillage.material_override = peau
		return
	# Le visage miniature doit rester lisible sous le grand chapeau, sans bandes d'auto-ombrage.
	for objet: Node in modele.find_children("Apprenti_*", "MeshInstance3D", true, false):
		var maillage := objet as MeshInstance3D
		# Le profil Compatibility mobile produit des bandes d'auto-ombre sur
		# ces petits volumes. L'occlusion douce du modele conserve les raccords.
		maillage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface in maillage.mesh.get_surface_count():
			var source := maillage.get_active_material(surface) as StandardMaterial3D
			if source == null:
				continue
			var matiere := ShaderMaterial.new()
			matiere.shader = preload("res://shaders/apprenti_accueil_surface.gdshader") if accueil_v2 else preload("res://shaders/apprenti_surface.gdshader")
			if secours:
				matiere.shader = preload("res://shaders/apprenti_secours_surface.gdshader")
			matiere.set_shader_parameter("teinte",source.albedo_color)
			matiere.set_shader_parameter("metal",source.metallic)
			matiere.set_shader_parameter("rugosite",source.roughness)
			if accueil_v2:
				matiere.set_shader_parameter("peau", maillage.name == &"Apprenti_peau")
				matiere.set_shader_parameter("tissu", maillage.name in [&"Apprenti_violet", &"Apprenti_violet_clair", &"Apprenti_pantalon"])
				matiere.set_shader_parameter("cheveux", maillage.name in [&"Apprenti_cheveux", &"Apprenti_cheveux_clair"])
				matiere.set_shader_parameter("oeil", maillage.name in [&"Apprenti_yeux", &"Apprenti_iris", &"Apprenti_iris_miel", &"Apprenti_blanc_oeil", &"Apprenti_reflet"])
			maillage.set_surface_override_material(surface, matiere)
