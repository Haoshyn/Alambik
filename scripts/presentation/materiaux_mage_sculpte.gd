extends RefCounted

static func appliquer(modele: Node3D) -> void:
	for noeud: Node in modele.find_children("*", "MeshInstance3D", true, false):
		var maillage := noeud as MeshInstance3D
		maillage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for indice in maillage.mesh.get_surface_count():
			var source := maillage.get_active_material(indice) as StandardMaterial3D
			if source == null or source.resource_name != "Mage_sculpte_matiere":
				continue
			var matiere := ShaderMaterial.new()
			matiere.shader = preload("res://shaders/mage_sculpte_surface.gdshader")
			matiere.set_shader_parameter("couleur", source.albedo_texture)
			matiere.set_shader_parameter("normales", source.normal_texture)
			matiere.set_shader_parameter("rugosite", source.roughness_texture)
			maillage.set_surface_override_material(indice, matiere)
