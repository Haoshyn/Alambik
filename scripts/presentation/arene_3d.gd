extends Node3D

var _materiaux := {}

func materiau(couleur: Color, emission := false) -> StandardMaterial3D:
	var cle := couleur.to_html() + str(emission)
	if _materiaux.has(cle):
		return _materiaux[cle]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = couleur
	mat.roughness = 0.9
	if emission:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_materiaux[cle] = mat
	return mat

func bloc(centre: Vector3, taille: Vector3, couleur: Color) -> MeshInstance3D:
	var objet := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = taille
	objet.mesh = mesh
	objet.material_override = materiau(couleur)
	objet.position = centre
	add_child(objet)
	return objet

func construire(limites: Rect2, charger: Callable) -> void:
	for enfant in get_children():
		enfant.queue_free()
	var centre := Pont3D.vers_monde(limites.get_center())
	var taille := Pont3D.vers_monde(limites.size)
	bloc(centre + Vector3(0,-0.7,0), Vector3(taille.x+12,0.1,taille.z+12), Color("397c80"))
	bloc(centre + Vector3(0,-0.22,0), Vector3(taille.x+0.5,0.4,taille.z+0.5), Color("7a857e"))
	# Un seul MultiMesh pour le dallage ; les joints demeurent fins et peu contrastes.
	var nx := ceili(taille.x / 0.9)
	var nz := ceili(taille.z / 0.9)
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	var dalle := BoxMesh.new()
	dalle.size = Vector3(taille.x/nx-0.012,0.06,taille.z/nz-0.012)
	multi.mesh = dalle
	multi.instance_count = nx*nz
	for x in nx:
		for z in nz:
			var pos := centre + Vector3((x+0.5)*taille.x/nx-taille.x/2, -0.02, (z+0.5)*taille.z/nz-taille.z/2)
			multi.set_instance_transform(x*nz+z,Transform3D(Basis.IDENTITY,pos))
			multi.set_instance_color(x*nz+z,Color.WHITE.darkened(float((x*13+z*7)%5)*0.012))
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multi
	var mat := materiau(Color("838c7c")).duplicate() as StandardMaterial3D
	mat.vertex_color_use_as_albedo = true
	instance.material_override = mat
	add_child(instance)
	for cote in [-1.0,1.0]:
		var x: float = centre.x + float(cote)*(taille.x/2+0.17)
		bloc(Vector3(x,0.045,centre.z),Vector3(0.27,0.13,taille.z+0.45),Color("919d8e"))
		for i in 5:
			var z := centre.z-taille.z/2+float(i)*taille.z/4
			var scene: PackedScene = charger.call("res://assets/3d/environment/colonne.glb")
			var colonne := scene.instantiate() as Node3D
			colonne.position=Vector3(x+cote*.22,-.1,z)
			colonne.scale=Vector3.ONE*(0.7 if i%2 else 1.0)
			add_child(colonne)
			if i%2==1:
				var plante: Node3D = (charger.call("res://assets/3d/props/obstacle_1.glb") as PackedScene).instantiate()
				plante.position=Vector3(x+cote*.4,-.03,z+.7)
				plante.rotation.y=PI/2
				add_child(plante)
	for cote in [-1.0,1.0]:
		bloc(centre+Vector3(0,0.045,cote*(taille.z/2+.14)),Vector3(taille.x+.5,.13,.28),Color("919d8e"))
	# Ruines et chutes d'eau hors du perimetre physique.
	for cote in [-1.0,1.0]:
		for i in 3:
			var p := centre+Vector3(cote*(taille.x/2+1.3+i*.4),-.5,-taille.z/2+i*2.7)
			bloc(p,Vector3(.65,.8,.8),Color("839790"))
			bloc(p+Vector3(.15,-.4,.41),Vector3(.22,.95,.035),Color("80b4b3"))
