extends RefCounted

# Les petits ornements partagent leur matiere pour limiter les appels de dessin
# sur telephone. Seuls les decors proceduraux immobiles passent par ce regroupement.
static func regrouper(parent: Node3D) -> void:
	var groupes: Dictionary = {}
	var objets := parent.find_children("*","MeshInstance3D",true,false)
	for noeud: Node in objets:
		var objet := noeud as MeshInstance3D
		var ancetre: Node = objet
		var retire := false
		while ancetre != parent:
			retire = retire or ancetre.is_queued_for_deletion()
			ancetre = ancetre.get_parent()
		if retire: continue
		if objet.mesh == null: continue
		var mat := objet.material_override as StandardMaterial3D
		if mat == null: continue
		var cle := mat.albedo_color.to_html()+str(mat.roughness)+str(mat.metallic)+str(mat.shading_mode)
		if not groupes.has(cle):
			groupes[cle] = {"points":PackedVector3Array(),"normales":PackedVector3Array(),"indices":PackedInt32Array(),"matiere":mat}
		var groupe: Dictionary = groupes[cle]
		var points: PackedVector3Array = groupe["points"]
		var normales: PackedVector3Array = groupe["normales"]
		var indices: PackedInt32Array = groupe["indices"]
		var transformation := parent.global_transform.affine_inverse()*objet.global_transform
		var rotation := transformation.basis.inverse().transposed()
		for surface in objet.mesh.get_surface_count():
			var tableaux := objet.mesh.surface_get_arrays(surface)
			var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
			var directions: PackedVector3Array = tableaux[Mesh.ARRAY_NORMAL]
			var decalage := points.size()
			for i in sommets.size():
				points.append(transformation*sommets[i])
				normales.append((rotation*directions[i]).normalized())
			var triangles: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX] if tableaux[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			if triangles.is_empty():
				for i in sommets.size(): indices.append(decalage+i)
			else:
				for i in triangles: indices.append(decalage+i)
		groupe["points"] = points
		groupe["normales"] = normales
		groupe["indices"] = indices
		objet.visible = false
		objet.queue_free()
	for groupe: Dictionary in groupes.values():
		var tableaux := []
		tableaux.resize(Mesh.ARRAY_MAX)
		tableaux[Mesh.ARRAY_VERTEX] = groupe["points"]
		tableaux[Mesh.ARRAY_NORMAL] = groupe["normales"]
		tableaux[Mesh.ARRAY_INDEX] = groupe["indices"]
		var maillage := ArrayMesh.new()
		maillage.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,tableaux)
		var objet := MeshInstance3D.new()
		objet.mesh = maillage
		objet.material_override = groupe["matiere"]
		parent.add_child(objet)
