extends RefCounted

static func appliquer(modele: Node3D) -> void:
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
			matiere.shader = preload("res://shaders/apprenti_surface.gdshader")
			matiere.set_shader_parameter("teinte",source.albedo_color)
			matiere.set_shader_parameter("metal",source.metallic)
			matiere.set_shader_parameter("rugosite",source.roughness)
			maillage.set_surface_override_material(surface, matiere)
