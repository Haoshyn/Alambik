extends RefCounted

# Les ornements partagent leur matiere pour limiter les appels de dessin.
# Les UV et le modelage peint doivent survivre a cette fusion.
static func regrouper(parent: Node3D) -> void:
	var groupes: Dictionary = {}
	var objets_fusionnes: Array[MeshInstance3D] = []
	var objets := parent.find_children("*", "MeshInstance3D", true, false)
	for noeud: Node in objets:
		var objet := noeud as MeshInstance3D
		var ancetre: Node = objet
		var retire := false
		while ancetre != parent:
			retire = retire or ancetre.is_queued_for_deletion() or ancetre.has_meta("mobile_decor")
			ancetre = ancetre.get_parent()
		if retire or objet.mesh == null: continue
		var mat := objet.material_override as StandardMaterial3D
		if mat == null: continue
		var texture := mat.albedo_texture.get_instance_id() if mat.albedo_texture != null else 0
		var normale_texture := mat.normal_texture.get_instance_id() if mat.normal_texture != null else 0
		var cle := str([mat.albedo_color, mat.roughness, mat.metallic, mat.metallic_specular, mat.shading_mode, objet.cast_shadow,
			mat.vertex_color_use_as_albedo, mat.vertex_color_is_srgb, texture, mat.texture_filter, mat.texture_repeat,
			mat.uv1_scale, mat.uv1_offset, mat.transparency, mat.emission_enabled, mat.emission, mat.emission_energy_multiplier,
			mat.normal_enabled, normale_texture, mat.normal_scale])
		if not groupes.has(cle):
			groupes[cle] = {"points":PackedVector3Array(), "normales":PackedVector3Array(), "couleurs":PackedColorArray(),
				"uv":PackedVector2Array(), "uv2":PackedVector2Array(), "tangentes":PackedFloat32Array(), "indices":PackedInt32Array(), "matiere":mat, "ombre":objet.cast_shadow, "nom":objet.name}
		var groupe: Dictionary = groupes[cle]
		var points: PackedVector3Array = groupe["points"]
		var normales: PackedVector3Array = groupe["normales"]
		var couleurs: PackedColorArray = groupe["couleurs"]
		var uv: PackedVector2Array = groupe["uv"]
		var uv2: PackedVector2Array = groupe["uv2"]
		var tangentes: PackedFloat32Array = groupe["tangentes"]
		var indices: PackedInt32Array = groupe["indices"]
		var transformation := parent.global_transform.affine_inverse() * objet.global_transform
		var rotation := transformation.basis.inverse().transposed()
		for surface in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(surface)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			var directions: PackedVector3Array = tableaux[Mesh.ARRAY_NORMAL]
			var teintes: PackedColorArray = tableaux[Mesh.ARRAY_COLOR] if tableaux[Mesh.ARRAY_COLOR] != null else PackedColorArray()
			var source_uv: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV] if tableaux[Mesh.ARRAY_TEX_UV] != null else PackedVector2Array()
			var source_uv2: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV2] if tableaux[Mesh.ARRAY_TEX_UV2] != null else PackedVector2Array()
			var source_tangentes: PackedFloat32Array = tableaux[Mesh.ARRAY_TANGENT] if tableaux[Mesh.ARRAY_TANGENT] != null else PackedFloat32Array()
			var decalage := points.size()
			for i in sommets.size():
				points.append(transformation * sommets[i])
				normales.append((rotation * directions[i]).normalized())
				if mat.vertex_color_use_as_albedo: couleurs.append(teintes[i] if not teintes.is_empty() else Color.WHITE)
				uv.append(source_uv[i] if not source_uv.is_empty() else Vector2.ZERO)
				uv2.append(source_uv2[i] if not source_uv2.is_empty() else Vector2.ZERO)
				if mat.normal_enabled:
					# Les normales peintes gardent leur repere apres fusion et miroir.
					var tangente := Vector3.RIGHT
					var sens := 1.0
					if not source_tangentes.is_empty():
						tangente = Vector3(source_tangentes[i * 4], source_tangentes[i * 4 + 1], source_tangentes[i * 4 + 2])
						sens = source_tangentes[i * 4 + 3]
					tangente = transformation.basis * tangente
					var normale := normales[normales.size() - 1]
					tangente = (tangente - normale * tangente.dot(normale)).normalized()
					tangentes.append_array(PackedFloat32Array([tangente.x, tangente.y, tangente.z, sens * signf(transformation.basis.determinant())]))
			var triangles: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX] if tableaux[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			if triangles.is_empty():
				for i in sommets.size(): indices.append(decalage + i)
			else:
				for i in triangles: indices.append(decalage + i)
		groupe["points"] = points
		groupe["normales"] = normales
		groupe["couleurs"] = couleurs
		groupe["uv"] = uv
		groupe["uv2"] = uv2
		groupe["tangentes"] = tangentes
		groupe["indices"] = indices
		objet.visible = false
		objets_fusionnes.append(objet)
		objet.queue_free()
	# Detacher les sources une fois toutes les transformations lues, avant de
	# recreer leurs noms : Godot ne doit pas renommer les maillages regroupes.
	for objet in objets_fusionnes: objet.get_parent().remove_child(objet)
	for groupe: Dictionary in groupes.values():
		var tableaux := []
		tableaux.resize(Mesh.ARRAY_MAX)
		tableaux[Mesh.ARRAY_VERTEX] = groupe["points"]
		tableaux[Mesh.ARRAY_NORMAL] = groupe["normales"]
		var couleurs: PackedColorArray = groupe["couleurs"]
		if not couleurs.is_empty(): tableaux[Mesh.ARRAY_COLOR] = couleurs
		tableaux[Mesh.ARRAY_TEX_UV] = groupe["uv"]
		tableaux[Mesh.ARRAY_TEX_UV2] = groupe["uv2"]
		var tangentes: PackedFloat32Array = groupe["tangentes"]
		if not tangentes.is_empty(): tableaux[Mesh.ARRAY_TANGENT] = tangentes
		tableaux[Mesh.ARRAY_INDEX] = groupe["indices"]
		var maillage := ArrayMesh.new()
		maillage.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, tableaux)
		var objet := MeshInstance3D.new()
		objet.name = str(groupe["nom"])
		objet.mesh = maillage
		objet.material_override = groupe["matiere"]
		objet.cast_shadow = int(groupe["ombre"]) as GeometryInstance3D.ShadowCastingSetting
		parent.add_child(objet)
