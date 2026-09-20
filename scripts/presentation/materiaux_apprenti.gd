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
	for noeud: Node in modele.find_children("*", "MeshInstance3D", true, false):
		var maillage := noeud as MeshInstance3D
		# Le GLB porte ses textures ; l'ombre au sol remplace l'auto-ombre mobile.
		maillage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
