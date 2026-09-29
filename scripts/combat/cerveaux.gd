class_name Cerveaux
extends RefCounted

# Les decisions sont des fonctions pures : elles se testent sans scene, et le
# bot headless peut les rejouer a l'identique.

static func rampant(distance: float, portee_contact: float) -> String:
	return "frapper" if distance <= portee_contact else "avancer"

static func sentinelle(_distance: float, _portee: float, recharge: float) -> String:
	# Un tireur present a l'ecran est toujours une menace. La portee physique du
	# projectile couvre l'arene ; seule sa recharge cadence ses attaques.
	return "tirer" if recharge <= 0.0 else "attendre"

# La charge est telegraphiee : le joueur doit avoir le temps de se decaler.
static func veloce(distance: float, etat: String, minuterie: float,
		distance_charge: float) -> String:
	if etat == "preparer":
		if minuterie > 0.0: return "preparer"
		return "charger" if distance <= distance_charge else "avancer"
	if etat == "charger":
		return "charger" if minuterie > 0.0 else "repos"
	if etat == "repos" and minuterie > 0.0:
		return "repos"
	return "preparer" if distance <= distance_charge else "avancer"

static func portee_charge(donnees: Dictionary, facteur_vitesse: float) -> float:
	return longueur_charge(donnees, facteur_vitesse) \
		+ float(donnees["rayon"]) * Reglages.ENNEMI_HITBOX_MULT + Reglages.HEROS_RAYON

static func longueur_charge(donnees: Dictionary, facteur_vitesse: float) -> float:
	var duree := float(donnees.get("duree_charge", EvolutionEnnemis.ELAN_DUREE))
	var elan := EvolutionEnnemis.ELAN_VITESSE if str(donnees["cerveau"]) == "rampant" else 1.0
	return float(donnees["vitesse"]) * facteur_vitesse * duree * elan

static func visee_rapide(origine: Vector2, cible: Vector2, course: Vector2,
		preparation: float, vitesse_tir: float) -> Vector2:
	var decoche := cible + course * preparation
	var ecart := decoche - origine
	var a := course.length_squared() - vitesse_tir * vitesse_tir
	var b := 2.0 * ecart.dot(course)
	var c := ecart.length_squared()
	var vol := 0.0
	if a < 0.0:
		vol = (-b - sqrt(maxf(0.0, b * b - 4.0 * a * c))) / (2.0 * a)
	# Le point est fixe au debut de l'annonce, y compris au fond de la salle.
	# Une esquive change la course prevue, sans deplacer la trajectoire annoncee.
	return decoche + course * vol

static func charge_atteignable(debut: Vector2, fin: Vector2, cible: Vector2,
		course: Vector2, preparation: float, vitesse: float, marge: float) -> bool:
	if vitesse <= 0.0: return false
	var trajet := fin - debut
	var ecart := cible + course * preparation - debut
	var vitesse_relative := course - trajet.normalized() * vitesse
	var instant := 0.0
	if not vitesse_relative.is_zero_approx():
		instant = clampf(-ecart.dot(vitesse_relative) / vitesse_relative.length_squared(),
			0.0, trajet.length() / vitesse)
	# La proximite de la cible au debut ne suffit pas : les deux corps doivent
	# pouvoir se croiser avant la fin du segment reel, apres la preparation.
	return (ecart + vitesse_relative * instant).length_squared() <= marge * marge

static func essaimeur(distance: float, distance_voulue: float, recharge: float) -> String:
	if recharge <= 0.0: return "invoquer"
	if distance < distance_voulue * 0.6:
		return "reculer"
	if distance > distance_voulue:
		return "avancer"
	return "attendre"

static func harceleur(distance: float, distance_voulue: float, recharge: float,
		peut_tirer := true) -> String:
	if distance < distance_voulue * 0.72:
		return "reculer"
	if recharge <= 0.0 and peut_tirer: return "tirer"
	if distance > distance_voulue * 1.28:
		return "avancer"
	return "tourner" if peut_tirer else "avancer"

static func orbiteur(distance: float, distance_voulue: float, recharge: float,
		peut_tirer := true) -> String:
	if distance < distance_voulue * 0.70:
		return "reculer"
	if recharge <= 0.0 and peut_tirer: return "tirer"
	if distance > distance_voulue:
		return "avancer"
	return "orbiter" if peut_tirer else "avancer"

static func miroir(distance: float, distance_voulue: float, recharge: float,
		peut_tirer := true) -> String:
	if recharge <= 0.0 and peut_tirer: return "pulser"
	if distance > distance_voulue:
		return "avancer"
	return "attendre" if peut_tirer else "avancer"

static func phaseur(distance: float, distance_voulue: float, recharge: float,
		etat: String, minuterie: float) -> String:
	if etat == "phase":
		return "disparaitre" if minuterie > 0.0 else "reapparaitre"
	if recharge <= 0.0: return "phase"
	if distance > distance_voulue:
		return "avancer"
	return "tourner"

static func tisseur(distance: float, distance_voulue: float, recharge: float,
		distance_minimale := 0.0, peut_tirer := true) -> String:
	if distance < maxf(distance_voulue * 0.62, distance_minimale):
		return "reculer"
	if recharge <= 0.0 and peut_tirer: return "tisser"
	if distance > distance_voulue * 1.38:
		return "avancer"
	return "croiser" if peut_tirer else "avancer"

static func volatile(distance: float, distance_explosion: float, etat: String,
		minuterie: float) -> String:
	if etat == "gonfler":
		return "gonfler" if minuterie > 0.0 else "exploser"
	return "gonfler" if distance <= distance_explosion else "avancer"
