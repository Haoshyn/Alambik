extends Node3D

var logique: Node2D
var modele: Node3D
var lecteur: AnimationPlayer
var genre := ""
var facteur := 1.0
var _temps_attaque := 0.0
var _temps_touche := 0.0
var _mort := false
var _derniere_animation := ""
var _orientation := Vector2.DOWN

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
		logique.connect("tir_demande", _jouer_tir)
		logique.connect("touchee", func(_position): _temps_touche = 0.25)
		logique.connect("morte", func(): _mort = true)
	elif genre == "ennemi":
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
	position = Pont3D.vers_monde(logique.global_position)
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
	elif genre == "projectile":
		direction = logique.get("direction")
	# Les GLB regardent +Z (Blender -Y). La rotation ne touche que le modele.
	var angle := atan2(direction.x, direction.y)
	modele.rotation.y = lerp_angle(modele.rotation.y, angle, 1.0-exp(-18.0*delta)) if genre == "heros" and delta > 0.0 else angle
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
		lecteur.play(animation, 0.08)
		_derniere_animation = animation
	if lecteur != null and genre == "heros":
		lecteur.speed_scale = clampf(vitesse / Reglages.HEROS_VITESSE * 1.65, 0.7, 2.4) if animation == "course" else 1.0

func _jouer_tir(_tir, _origine: Vector2, direction: Vector2) -> void:
	_orientation = direction.normalized()
	_temps_attaque = 0.25
	if lecteur != null and lecteur.has_animation("attaque"):
		_temps_attaque = lecteur.get_animation("attaque").length
		# Chaque salve relance le geste du baton.
		lecteur.stop()
		lecteur.play("attaque", 0.04)
		_derniere_animation = "attaque"

func _exit_tree() -> void:
	if is_instance_valid(logique):
		logique.remove_meta("visuel_3d")
		logique.queue_redraw()
