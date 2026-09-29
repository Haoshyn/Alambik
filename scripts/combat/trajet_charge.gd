extends RefCounted

var fin := Vector2.ZERO
var debut := Vector2.ZERO
var longueur := 0.0
var terminee := true

func preparer(acteur: CharacterBody2D, direction: Vector2, distance: float, rayon: float) -> void:
	var salle := acteur.get_parent()
	var contour: PackedVector2Array = salle.contour_sol()
	var obstacles: Array = salle.obstacles()
	debut = acteur.global_position
	var libre := 0.0
	var borne := distance
	# Le segment complet s'arrete au premier mur, meme si une alcove permet
	# de retrouver du sol plus loin. L'annonce et le mouvement partagent ce trajet.
	for i in 18:
		var essai := (libre + borne) * .5
		var point := debut + direction * essai
		if FormesSalles.contient_disque(point, contour, rayon + acteur.safe_margin) \
				and Geometrie.ligne_libre(debut, point, obstacles, rayon, contour):
			libre = essai
		else:
			borne = essai
	longueur = libre
	fin = debut + direction * longueur
	terminee = false

func contient_cible(cible: Vector2, marge: float) -> bool:
	return Geometry2D.get_closest_point_to_segment(cible, debut, fin).distance_to(cible) <= marge

func avancer(acteur: CharacterBody2D, vitesse: float, delta: float) -> void:
	if terminee:
		acteur.velocity = Vector2.ZERO
		return
	var ecart := fin - acteur.global_position
	var pas := minf(vitesse * delta, ecart.length())
	acteur.velocity = ecart.normalized() * vitesse
	var collision := acteur.move_and_collide(ecart.normalized() * pas)
	terminee = collision != null or acteur.global_position.distance_to(fin) < .1
	if terminee: acteur.velocity = Vector2.ZERO
