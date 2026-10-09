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
var salves := 1
var projectiles_lateraux := 0
var angle_eventail := 0.0
var ecart_lateral := 0.0
var ecart_lateral_min := 0.0
var rebonds := 0
var perforations := 0
var degats_projectiles_supplementaires := 1.0
var degats_projectiles_lateraux := 1.0
var degats_finaux_projectile_mult := 1.0
var cible_verrouillee := 0
var trajectoire := "droite"
var silhouette := "trait"
var variante_visuelle := 0
var rayon := Reglages.TIR_RAYON
var longueur := Reglages.TIR_RAYON * 2.0
var traverse_murs := false
var distance_retour := 0.0
var pause_retour := 0.0
var amplitude := 0.0
var frequence := 0.0
var rebonds_murs := 0
var effets: Array[String] = []
var drapeaux: Array[String] = []
# Tire au moment de l'attaque ; sert uniquement au retour visuel et sonore.
var critique := false

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
	# Le minimum d'un augment garde les tirs distincts sans elargir chaque copie.
	var ecart := maxf(ecart_lateral, ecart_lateral_min)
	if projectiles_lateraux > 0:
		var lateraux := mini(projectiles_lateraux,nb_projectiles-1)
		var frontaux := nb_projectiles-lateraux
		for i in frontaux: resultat.append((i-(frontaux-1)/2.0)*ecart)
		for i in lateraux: resultat.append(0.0)
		return resultat
	if nb_projectiles <= 1:
		resultat.append(0.0)
		return resultat
	var largeur := ecart * float(nb_projectiles - 1)
	var pas := largeur / float(nb_projectiles - 1)
	for i in nb_projectiles:
		resultat.append(-largeur / 2.0 + pas * i)
	return resultat

# Les projectiles frontaux de l'arme restent independants des diagonales ajoutees.
func facteur_projectile(index: int) -> float:
	if index <= 0:
		return 1.0
	var lateraux := clampi(projectiles_lateraux, 0, maxi(0, nb_projectiles - 1))
	if index >= nb_projectiles - lateraux:
		return degats_projectiles_lateraux
	return degats_projectiles_supplementaires

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
	t.critique = critique
	t.nb_projectiles = nb_projectiles
	t.salves = salves
	t.projectiles_lateraux = projectiles_lateraux
	t.angle_eventail = angle_eventail
	t.ecart_lateral = ecart_lateral
	t.ecart_lateral_min = ecart_lateral_min
	t.rebonds = rebonds
	t.perforations = perforations
	t.degats_projectiles_supplementaires = degats_projectiles_supplementaires
	t.degats_projectiles_lateraux = degats_projectiles_lateraux
	t.degats_finaux_projectile_mult = degats_finaux_projectile_mult
	t.cible_verrouillee = cible_verrouillee
	t.trajectoire = trajectoire
	t.silhouette = silhouette
	t.variante_visuelle = variante_visuelle
	t.rayon = rayon
	t.longueur = longueur
	t.traverse_murs = traverse_murs
	t.distance_retour = distance_retour
	t.pause_retour = pause_retour
	t.amplitude = amplitude
	t.frequence = frequence
	t.rebonds_murs = rebonds_murs
	t.effets = effets.duplicate()
	t.drapeaux = drapeaux.duplicate()
	return t
