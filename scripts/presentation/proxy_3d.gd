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
		logique.connect("tir_demande", func(_tir, _origine, _direction): _temps_attaque = 0.25)
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
	scale = Vector3(facteur, facteur, facteur / sin(deg_to_rad(Pont3D.INCLINAISON)))
	_temps_attaque = maxf(0.0, _temps_attaque - delta)
	_temps_touche = maxf(0.0, _temps_touche - delta)
	var direction := Vector2.DOWN
	var vitesse := 0.0
	if logique is CharacterBody2D:
		vitesse = (logique as CharacterBody2D).velocity.length()
		if vitesse > 1.0:
			direction = (logique as CharacterBody2D).velocity.normalized()
	if genre == "heros":
		direction = logique.get("_visee")
	elif genre == "ennemi":
		var cible: Node2D = logique.get("_cible")
		if is_instance_valid(cible):
			direction = logique.global_position.direction_to(cible.global_position)
	elif genre == "projectile":
		direction = logique.get("direction")
	# Les GLB regardent +Z (Blender -Y). La rotation ne touche que le modele.
	modele.rotation.y = atan2(direction.x, direction.y)
	var animation := "course" if vitesse > 4.0 else "repos"
	if _temps_attaque > 0.0:
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

func _exit_tree() -> void:
	if is_instance_valid(logique):
		logique.remove_meta("visuel_3d")
		logique.queue_redraw()
