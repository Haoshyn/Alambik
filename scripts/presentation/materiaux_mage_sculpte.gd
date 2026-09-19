extends RefCounted

static func appliquer(modele: Node3D) -> void:
	for noeud: Node in modele.find_children("*", "MeshInstance3D", true, false):
		var maillage := noeud as MeshInstance3D
		maillage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# Conserver les materiaux standard et les textures importes du GLB.
