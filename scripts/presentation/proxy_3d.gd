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
var _arme_tenue: Node3D
var _animation_ennemi: Node3D
const RenduCombat = preload("res://data/animations_combat.gd")

func preparer(cible: Node2D, scene: PackedScene, type: String) -> void:
	logique = cible
	genre = type
	_installer_modele(scene)
	if genre == "ennemi":
		var donnees: Dictionary = logique.get("donnees")
		preload("res://scripts/presentation/habillage_ennemis_3d.gd").appliquer(modele, donnees)
		_animation_ennemi = preload("res://scripts/presentation/animation_ennemis_3d.gd").new()
		add_child(_animation_ennemi)
		_animation_ennemi.preparer(donnees)
		modele.reparent(_animation_ennemi, false)
		facteur = float(donnees["rayon"]) / (65.0 if donnees.get("cerveau", "") == "boss" else 30.0)
		if bool(donnees.get("elite", false)):
			var insigne := MeshInstance3D.new()
			var forme := PrismMesh.new()
			forme.size = Vector3(.22,.30,.12)
			insigne.mesh = forme
			insigne.position.y = 1.5
			var mat := StandardMaterial3D.new()
			mat.albedo_color = RangsEnnemis.COULEUR_ELITE
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			insigne.material_override = mat
			if bool(donnees.get("incendiaire", false)):
				mat.albedo_color = Color("ff7347")
			insigne.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(insigne)
	if genre == "heros":
		facteur = Reglages.HEROS_ECHELLE
		suivi = load("res://scripts/presentation/suivi_visuel_2d.gd").new()
		suivi.name = "SuiviVisuel3D"
		logique.add_child(suivi)
		ReglagesJoueur.maitrise_changee.connect(_actualiser_arme)
		logique.connect("tir_demande", _jouer_tir)
		logique.connect("attaque_preparee", _armer_tir)
		logique.connect("touchee", func(_position):
			if animation_heros != null:
				animation_heros.toucher())
		logique.connect("morte", func(): _mort = true)
	elif genre == "ennemi":
		logique.connect("tir_demande", func(_tir, _origine, _direction): _projeter_ennemi())
		logique.connect("zone_demandee", func(_point, _origine, profil: Dictionary, _degats):
			if bool(profil.get("lob", false)): _projeter_ennemi())
		logique.connect("invocation_demandee", func(_id, _position): _projeter_ennemi())
		logique.connect("touche", func(_position, _couleur): _animation_ennemi.toucher())
	elif genre == "gardien":
		logique.connect("attaque_portee", func(origine: Vector2, cible_attaque: Vector2):
			_orientation = origine.direction_to(cible_attaque)
			_temps_attaque = 0.22)
	logique.set_meta("visuel_3d", true)
	logique.queue_redraw()
	mettre_a_jour(0.0)

func _installer_modele(scene: PackedScene) -> void:
	modele = scene.instantiate()
	add_child(modele)
	lecteur = modele.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if lecteur != null:
		for nom in lecteur.get_animation_list():
			if str(nom) in ["repos", "course"]:
				lecteur.get_animation(nom).loop_mode = Animation.LOOP_LINEAR
	if genre == "heros":
		preload("res://scripts/presentation/materiaux_apprenti.gd").appliquer(modele)
		_arme_tenue = preload("res://scripts/presentation/arme_tenue_3d.gd").installer(modele, ReglagesJoueur.projectile_equipe_effectif())
		if lecteur != null:
			animation_heros = load("res://scripts/presentation/animation_heros_3d.gd").new()
			add_child(animation_heros)
			animation_heros.preparer(lecteur)

func _actualiser_arme() -> void:
	if is_instance_valid(_arme_tenue):
		_arme_tenue.changer(ReglagesJoueur.projectile_equipe_effectif())

func mettre_a_jour(delta: float) -> void:
	if not is_instance_valid(logique) or logique.is_queued_for_deletion():
		queue_free()
		return
	visible = logique.is_visible_in_tree()
	position = Pont3D.vers_monde(suivi.position_affichee() if is_instance_valid(suivi) else logique.global_position)
	# Le mage conserve ses volumes dans toutes les orientations.
	scale = Vector3.ONE * facteur if genre == "heros" else Vector3(facteur, facteur, facteur / sin(deg_to_rad(Pont3D.INCLINAISON)))
	var fige := genre == "ennemi" and float(logique.get("_gel")) > 0.0
	if not fige:
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
		var donnees: Dictionary = logique.get("donnees")
		var boss := str(donnees["cerveau"]) == "boss"
		var etat := str(logique.get("_motif" if boss else "_etat"))
		if etat in ["preparer", "charger", "charge"]:
			direction = logique.get("_direction_charge")
		elif not boss and etat in ["vise", "vise_orbite", "tisser", "crache", "bombarde", "phase"]:
			direction = logique.global_position.direction_to(logique.get("_point_vise"))
		elif boss and float(logique._motifs_mondes.annonce) > 0.0:
			direction = logique.global_position.direction_to(logique._motifs_mondes.cible)
	elif genre == "gardien" and _temps_attaque > 0.0:
		direction = _orientation
	elif genre == "projectile":
		direction = logique.get("direction")
	# Les GLB regardent +Z (Blender -Y). La rotation ne touche que le modele.
	var direction_monde := Pont3D.vers_monde(direction)
	var angle := atan2(direction_monde.x, direction_monde.z) if genre == "heros" else atan2(direction.x, direction.y)
	var ecart := angle_difference(modele.rotation.y, angle)
	modele.rotation.y = lerp_angle(modele.rotation.y, angle, 1.0-exp(-Visuels3D.HEROS_LISSAGE_ORIENTATION*delta)) if genre == "heros" and delta > 0.0 else angle
	if genre == "ennemi":
		if fige:
			modele.rotation.y = angle - ecart
			if lecteur != null: lecteur.speed_scale = 0.0
			return
		modele.rotation.y = angle - ecart * exp(-RenduCombat.LISSAGE_ORIENTATION * delta) if delta > 0.0 else angle
		_animation_ennemi.mettre_a_jour(logique, delta, modele.rotation.y, vitesse)
		if lecteur != null:
			var donnees: Dictionary = logique.get("donnees")
			var cadence := clampf(vitesse / maxf(float(donnees["vitesse"]) * Reglages.ENNEMI_VITESSE_MULT, 1.0), RenduCombat.CADENCE_MIN, RenduCombat.CADENCE_MAX)
			lecteur.speed_scale = cadence if vitesse > 4.0 and _temps_attaque <= 0.0 else 1.0
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

func _projeter_ennemi() -> void:
	if _temps_attaque <= RenduCombat.ATTAQUE_DUREE - RenduCombat.ATTAQUE_REARMEMENT:
		_derniere_animation = ""
	_temps_attaque = RenduCombat.ATTAQUE_DUREE
	_animation_ennemi.projeter()

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

