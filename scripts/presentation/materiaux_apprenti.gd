extends RefCounted

static func appliquer(modele: Node3D) -> void:
	# Le visage miniature doit rester lisible sous le grand chapeau, sans bandes d'auto-ombrage.
	for objet: Node in modele.find_children("Apprenti_*", "MeshInstance3D", true, false):
		var maillage := objet as MeshInstance3D
		for surface in maillage.mesh.get_surface_count():
			var source := maillage.get_active_material(surface) as StandardMaterial3D
			if source == null:
				continue
			var matiere := source.duplicate() as StandardMaterial3D
			matiere.disable_receive_shadows = true
			matiere.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP
			maillage.set_surface_override_material(surface, matiere)
