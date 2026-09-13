extends Node3D

var logique: Node2D
var modele: Node3D
var lecteur: AnimationPlayer
var animation_heros: AnimationTree
var suivi: Node
var genre := ""
var facteur := 1.0
var _temps_attaque := 0.0
var _temps_touche := 0.0
var _mort := false
var _derniere_animation := ""
var _orientation := Vector2.DOWN
var _visee_mesh: MeshInstance3D

func preparer(cible: Node2D, scene: PackedScene, type: String) -> void:
	logique = cible
	genre = type
	modele = scene.instantiate()
	add_child(modele)
	lecteur = modele.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if lecteur != null:
		for nom in lecteur.get_animation_list():
			if str(nom) in ["repos", "course"]:
				lecteur.get_animation(nom).loop_mode = Animation.LOOP_LINEAR
	if genre == "ennemi":
		var donnees: Dictionary = logique.get("donnees")
		facteur = float(donnees["rayon"]) / (65.0 if donnees.get("cerveau", "") == "boss" else 30.0)
	if genre == "heros":
		facteur = Reglages.HEROS_ECHELLE
		preload("res://scripts/presentation/materiaux_apprenti.gd").appliquer(modele)
		var peau := modele.find_child("Heros_B_peau", true, false) as MeshInstance3D
		if peau != null:
			var source := peau.get_active_material(0) as StandardMaterial3D
			if source != null and source.albedo_texture != null and source.normal_texture != null:
				var matiere := ShaderMaterial.new()
				matiere.shader = preload("res://shaders/heros_matiere.gdshader")
				matiere.set_shader_parameter("couleur", source.albedo_texture)
				matiere.set_shader_parameter("normales", source.normal_texture)
				peau.set_surface_override_material(0, matiere)
		suivi = load("res://scripts/presentation/suivi_visuel_2d.gd").new()
		suivi.name = "SuiviVisuel3D"
		logique.add_child(suivi)
		if lecteur != null:
			animation_heros = load("res://scripts/presentation/animation_heros_3d.gd").new()
			add_child(animation_heros)
			animation_heros.preparer(lecteur)
		logique.connect("tir_demande", _jouer_tir)
		logique.connect("attaque_preparee", _armer_tir)
		logique.connect("touchee", func(_position):
			if animation_heros != null:
				animation_heros.toucher())
		logique.connect("morte", func(): _mort = true)
	elif genre == "ennemi":
		_visee_mesh = MeshInstance3D.new()
		_visee_mesh.mesh = ImmediateMesh.new()
		var matiere := StandardMaterial3D.new()
		matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		matiere.albedo_color = Color("ff965b")
		_visee_mesh.material_override = matiere
		add_child(_visee_mesh)
		logique.connect("tir_demande", func(_tir, _origine, _direction): _temps_attaque = 0.25)
		logique.connect("touche", func(_position, _couleur): _temps_touche = 0.22)
	logique.set_meta("visuel_3d", true)
	logique.queue_redraw()
	mettre_a_jour(0.0)

func mettre_a_jour(delta: float) -> void:
	if not is_instance_valid(logique) or logique.is_queued_for_deletion():
		queue_free()
		return
	visible = logique.is_visible_in_tree()
	if _visee_mesh != null: _dessiner_visee()
	position = Pont3D.vers_monde(suivi.position_affichee() if is_instance_valid(suivi) else logique.global_position)
	# Le mage conserve ses volumes dans toutes les orientations.
	scale = Vector3.ONE * facteur if genre == "heros" else Vector3(facteur, facteur, facteur / sin(deg_to_rad(Pont3D.INCLINAISON)))
	_temps_attaque = maxf(0.0, _temps_attaque - delta)
	_temps_touche = maxf(0.0, _temps_touche - delta)
	var direction := Vector2.DOWN
	var vitesse := 0.0
	if logique is CharacterBody2D:
		vitesse = (logique as CharacterBody2D).velocity.length()
		if vitesse > 1.0:
			direction = (logique as CharacterBody2D).velocity.normalized()
	if genre == "heros":
		if vitesse > 1.0:
			_orientation = direction
		direction = _orientation
	elif genre == "ennemi":
		var cible: Node2D = logique.get("_cible")
		if is_instance_valid(cible):
			direction = logique.global_position.direction_to(cible.global_position)
		var cerveau := str(logique.get("donnees").get("cerveau", ""))
		if cerveau in ["sentinelle", "harceleur"] and str(logique.get("_etat")) == "vise":
			direction = logique.global_position.direction_to(logique.get("_point_vise"))
	elif genre == "projectile":
		direction = logique.get("direction")
	# Les GLB regardent +Z (Blender -Y). La rotation ne touche que le modele.
	var direction_monde := Pont3D.vers_monde(direction)
	var angle := atan2(direction_monde.x, direction_monde.z) if genre == "heros" else atan2(direction.x, direction.y)
	var ecart := angle_difference(modele.rotation.y, angle)
	modele.rotation.y = lerp_angle(modele.rotation.y, angle, 1.0-exp(-Visuels3D.HEROS_LISSAGE_ORIENTATION*delta)) if genre == "heros" and delta > 0.0 else angle
	if animation_heros != null:
		var inclinaison := -clampf(ecart, -1.0, 1.0) * Visuels3D.HEROS_INCLINAISON_VIRAGE * minf(vitesse / Reglages.HEROS_VITESSE, 1.0) if not _mort else 0.0
		modele.rotation.z = lerpf(modele.rotation.z, inclinaison, 1.0-exp(-Visuels3D.HEROS_LISSAGE_MOUVEMENT*delta))
		animation_heros.mettre_a_jour(delta, vitesse, _mort)
		return
	var animation := "course" if vitesse > 4.0 else "repos"
	if _temps_attaque > 0.0 and (genre != "heros" or vitesse <= 4.0):
		animation = "attaque"
	if _temps_touche > 0.0:
		animation = "touche"
	if _mort:
		animation = "mort"
	elif genre == "heros" and Jeu.salle_courante > 0 and not Jeu.mode_auto:
		if logique.get("stats").pv <= 0.0:
			animation = "mort"
	if lecteur != null and animation != _derniere_animation and lecteur.has_animation(animation):
		var transition := Visuels3D.HEROS_TRANSITION_MOUVEMENT if genre == "heros" and animation in ["course", "repos"] else 0.08
		lecteur.play(animation, transition)
		_derniere_animation = animation

func _jouer_tir(_tir, _origine: Vector2, direction: Vector2) -> void:
	_orientation = direction.normalized()
	if animation_heros != null:
		if not _mort:
			animation_heros.projeter()

func _armer_tir(direction: Vector2) -> void:
	_orientation = direction.normalized()
	if animation_heros != null and not _mort:
		animation_heros.armer()

func _exit_tree() -> void:
	if is_instance_valid(suivi):
		suivi.queue_free()
	if is_instance_valid(logique):
		logique.remove_meta("visuel_3d")
		logique.queue_redraw()

func _dessiner_visee() -> void:
	var maillage := _visee_mesh.mesh as ImmediateMesh
	maillage.clear_surfaces()
	var donnees: Dictionary = logique.get("donnees")
	var cerveau := str(donnees.get("cerveau", ""))
	if cerveau not in ["sentinelle", "harceleur", "veloce"]: return
	var etat := str(logique.get("_etat"))
	if etat not in ["vise", "preparer"]: return
	var cible: Vector2 = logique.get("_point_vise") if cerveau != "veloce" else logique.global_position + Vector2(logique.get("_direction_charge")) * 650.0
	var debut := to_local(Pont3D.vers_monde(logique.global_position, 0.035))
	var fin := to_local(Pont3D.vers_monde(cible, 0.035))
	maillage.surface_begin(Mesh.PRIMITIVE_LINES)
	maillage.surface_add_vertex(debut)
	maillage.surface_add_vertex(fin)
	maillage.surface_end()
