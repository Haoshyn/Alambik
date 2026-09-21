class_name Tir
extends RefCounted

# Description d'un tir, pas un comportement : le projectile lit ces champs et
# les execute.

var arme := "standard"
var degats: float
var attaque_base := 0.0
var bonus_attaque := 0.0
var vitesse: float
var portee: float
var portee_limitee := false
var cadence: float
var nb_projectiles := 1
var projectiles_lateraux := 0
var angle_eventail := 0.0
var ecart_lateral := 0.0
var rebonds := 0
var perforations := 0
var fragments := 0
var rayon_explosion := 0.0
var degats_zone_mult := 0.0
var degats_projectiles_supplementaires := 1.0
var degats_finaux_projectile_mult := 1.0
var cible_verrouillee := 0
var effets: Array[String] = []
var drapeaux: Array[String] = []

static func de_base(stats: Stats) -> Tir:
	var t := Tir.new()
	t.degats = stats.degats
	t.attaque_base = stats.attaque_base
	t.bonus_attaque = stats.bonus_attaque
	t.vitesse = stats.vitesse_projectile
	t.portee = stats.portee
	t.cadence = stats.cadence
	return t

# Decalages angulaires, centres sur la visee, quel que soit le nombre.
func angles() -> Array[float]:
	var resultat: Array[float] = []
	if projectiles_lateraux > 0:
		var lateraux := mini(projectiles_lateraux,nb_projectiles-1)
		for i in nb_projectiles-lateraux: resultat.append(0.0)
		for i in lateraux:
			var rang := i/2+1
			resultat.append((-1.0 if i%2 == 0 else 1.0)*angle_eventail*0.5*float(rang)/ceilf(lateraux/2.0))
		return resultat
	if nb_projectiles <= 1:
		resultat.append(0.0)
		return resultat
	var pas := angle_eventail / float(nb_projectiles - 1)
	var depart := -angle_eventail / 2.0
	for i in nb_projectiles:
		resultat.append(depart + pas * i)
	return resultat

# Decalages perpendiculaires, centres comme les angles. Un eventail large fait
# rater les deux projectiles a distance moyenne : des tirs presque paralleles,
# simplement ecartes, touchent la ou l'eventail passait de chaque cote.
func decalages() -> Array[float]:
	var resultat: Array[float] = []
	if projectiles_lateraux > 0:
		var lateraux := mini(projectiles_lateraux,nb_projectiles-1)
		var frontaux := nb_projectiles-lateraux
		for i in frontaux: resultat.append((i-(frontaux-1)/2.0)*ecart_lateral)
		for i in lateraux: resultat.append(0.0)
		return resultat
	if nb_projectiles <= 1:
		resultat.append(0.0)
		return resultat
	var largeur := ecart_lateral * float(nb_projectiles - 1)
	var pas := largeur / float(nb_projectiles - 1)
	for i in nb_projectiles:
		resultat.append(-largeur / 2.0 + pas * i)
	return resultat

func copie() -> Tir:
	var t := Tir.new()
	t.arme = arme
	t.degats = degats
	t.attaque_base = attaque_base
	t.bonus_attaque = bonus_attaque
	t.vitesse = vitesse
	t.portee = portee
	t.portee_limitee = portee_limitee
	t.cadence = cadence
	t.nb_projectiles = nb_projectiles
	t.projectiles_lateraux = projectiles_lateraux
	t.angle_eventail = angle_eventail
	t.ecart_lateral = ecart_lateral
	t.rebonds = rebonds
	t.perforations = perforations
	t.fragments = fragments
	t.rayon_explosion = rayon_explosion
	t.degats_zone_mult = degats_zone_mult
	t.degats_projectiles_supplementaires = degats_projectiles_supplementaires
	t.degats_finaux_projectile_mult = degats_finaux_projectile_mult
	t.cible_verrouillee = cible_verrouillee
	t.effets = effets.duplicate()
	t.drapeaux = drapeaux.duplicate()
	return t
