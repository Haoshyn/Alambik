extends RefCounted

var sens := 1.0

func avancer(boss: CharacterBody2D, distance_forcee := -1.0, vitesse_forcee := -1.0) -> void:
	boss.velocity = Vector2.ZERO
	# Les rayons restent attaches au lanceur jusqu'au depart de la salve annoncee.
	if not boss._tirs_annonces.attentes.is_empty(): return
	var profil := DeplacementsBoss.profil(boss.donnees)
	var distance_voulue := float(profil["distance"])
	if distance_forcee >= 0.0: distance_voulue = distance_forcee
	if boss._charge_approche:
		distance_voulue = minf(distance_voulue, float(boss.portee_charge()) * AttaquesContactBoss.DISTANCE_ARRET)
	var ecart: Vector2 = boss._cible.global_position - boss.global_position
	var vers := ecart.normalized()
	var tangente := vers.orthogonal() * sens
	var direction := tangente
	if ecart.length() > distance_voulue:
		var part := float(profil["tangente"]) if distance_forcee < 0.0 and ecart.length() < distance_voulue * DeplacementsBoss.APPROCHE_LOINTAINE else 0.0
		direction = (vers + tangente * part).normalized()
	var rayon: float = (boss.get_node("CollisionShape2D").shape as CircleShape2D).radius
	var salle := boss.get_parent()
	var obstacles: Array = salle.obstacles()
	var contour: PackedVector2Array = salle.contour_sol()
	var libre := false
	for angle: float in DeplacementsBoss.ECARTS_CONTOURNEMENT:
		var candidate := direction.rotated(angle * sens)
		var destination: Vector2 = boss.global_position + candidate * DeplacementsBoss.ANTICIPATION_OBSTACLE
		if not FormesSalles.contient_disque(destination, contour, rayon): continue
		if not Geometrie.ligne_libre(boss.global_position, destination, obstacles, rayon): continue
		direction = candidate
		libre = true
		break
	if not libre: return
	var vitesse := float(profil["vitesse"]) if vitesse_forcee < 0.0 else vitesse_forcee
	boss.velocity = direction * float(boss.donnees["vitesse"]) * vitesse \
		* Reglages.ENNEMI_VITESSE_MULT * float(boss._facteur_ralentissement())
	boss.move_and_slide()
