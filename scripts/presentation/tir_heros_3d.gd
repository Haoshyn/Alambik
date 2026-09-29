extends Node3D
## Tir a l'arret : bras vif, accompagnement du buste plus amorti.
## Le bassin et les pieds ne sont jamais modifies par cette couche.
const OS_BRAS := ["UpperArm.R", "Forearm.R", "Hand.R"]
const OS_BUSTE := ["Spine", "Chest", "UpperChest", "Head", "UpperArm.L"]
const OS_CONTROLES := OS_BRAS + OS_BUSTE
const POINTE_REPOS := Vector3(-0.683, 1.360, 0.468)
const OMEGA_GESTE := 44.0
const OMEGA_VISEE := 40.0
const OMEGA_BUSTE := 26.0
var maintien := 0.8
var poids := 0.0
var vitesse_poids := 0.0
var geste := 0.0
var vitesse_geste := 0.0
var recul := 0.0
var vitesse_recul := 0.0
var temps_maintien := 0.0
var visee_forcee := false
var suspendu := false
var origine_baguette := Vector3.ZERO
var _pret: Dictionary = {}
var _retrait: Dictionary = {}
var _projection: Dictionary = {}
var _indices: Array[int] = []
var _baguette := -1
var _base: Dictionary = {}

func obtenir_squelette() -> Skeleton3D:
	return get_parent() as Skeleton3D

func restaurer() -> void:
	# Restaurer les os geres avant la prochaine evaluation, sans accumulation.
	var squelette := obtenir_squelette()
	for index: int in _base:
		squelette.set_bone_pose(index,_base[index])

func preparer(lecteur: AnimationPlayer) -> void:
	var squelette := obtenir_squelette()
	_indices.clear()
	for nom: String in OS_CONTROLES:
		var index := squelette.find_bone(nom)
		assert(index >= 0, "Os manquant : " + nom)
		_indices.append(index)
	_baguette = squelette.find_bone("Wand")
	_pret = _lire_pose(lecteur.get_animation("visee"), 0.0)
	_retrait = _lire_pose(lecteur.get_animation("attaque"), 0.025)
	_projection = _lire_pose(lecteur.get_animation("attaque"), 0.05)

func _lire_pose(clip: Animation, temps: float) -> Dictionary:
	var resultat: Dictionary = {}
	var squelette := obtenir_squelette()
	for index: int in _indices: resultat[index] = squelette.get_bone_rest(index)
	for piste in range(clip.get_track_count()):
		var chemin := clip.track_get_path(piste)
		if chemin.get_subname_count() == 0: continue
		var nom := str(chemin.get_subname(0))
		if nom not in OS_CONTROLES: continue
		var index := squelette.find_bone(nom)
		var pose: Transform3D = resultat[index]
		if clip.track_get_type(piste) == Animation.TYPE_POSITION_3D:
			pose.origin = clip.position_track_interpolate(piste, temps)
		elif clip.track_get_type(piste) == Animation.TYPE_ROTATION_3D:
			pose.basis = Basis(clip.rotation_track_interpolate(piste, temps))
		resultat[index] = pose
	return resultat

func armer() -> void:
	# Une impulsion change la vitesse, jamais la position du geste en cours.
	temps_maintien = maintien
	vitesse_geste -= OMEGA_GESTE * 0.80
	vitesse_recul -= OMEGA_BUSTE * 0.35

func projeter() -> void:
	temps_maintien = maintien
	vitesse_geste += OMEGA_GESTE * 2.50
	vitesse_recul += OMEGA_BUSTE * 1.80

func relacher() -> void:
	visee_forcee = false
	temps_maintien = 0.0

func reinitialiser() -> void:
	restaurer()
	_base.clear()
	poids = 0.0
	vitesse_poids = 0.0
	geste = 0.0
	vitesse_geste = 0.0
	recul = 0.0
	vitesse_recul = 0.0
	temps_maintien = 0.0
	visee_forcee = false

func _ressort(position: float, vitesse: float, cible: float, omega: float, delta: float) -> Vector2:
	# Solution exacte du ressort amorti critique : stable aussi a 30 images/s.
	var ecart := position-cible
	var auxiliaire := vitesse+omega*ecart
	var attenuation := exp(-omega*delta)
	return Vector2(cible+(ecart+auxiliaire*delta)*attenuation,
		(vitesse-omega*auxiliaire*delta)*attenuation)

func appliquer(delta: float, influence := 1.0) -> void:
	if _indices.is_empty(): return
	if not suspendu and delta > 0:
		var actif := delta if visee_forcee else minf(delta,temps_maintien)
		var resultat := Vector2(poids,vitesse_poids)
		if actif > 0: resultat = _ressort(resultat.x,resultat.y,1.0,OMEGA_VISEE,actif)
		if delta > actif: resultat = _ressort(resultat.x,resultat.y,0.0,25.0,delta-actif)
		poids = clampf(resultat.x, 0.0, 1.0)
		vitesse_poids = resultat.y
		resultat = _ressort(geste, vitesse_geste, 0.0, OMEGA_GESTE, delta)
		geste = resultat.x
		vitesse_geste = resultat.y
		resultat = _ressort(recul, vitesse_recul, 0.0, OMEGA_BUSTE, delta)
		recul = resultat.x
		vitesse_recul = resultat.y
		temps_maintien = maxf(0.0, temps_maintien-delta)
	var squelette := obtenir_squelette()
	for index: int in _indices:
		var mouvement := geste if squelette.get_bone_name(index) in OS_BRAS else recul
		var amplitude := tanh(absf(mouvement))
		var extremite: Dictionary = _projection if mouvement >= 0 else _retrait
		var base := squelette.get_bone_pose(index)
		_base[index] = base
		var pret: Transform3D = _pret[index]
		var bout: Transform3D = extremite[index]
		var cible := pret.interpolate_with(bout, amplitude)
		squelette.set_bone_pose(index, base.interpolate_with(cible, poids*clampf(influence,0.0,1.0)))
	# Les poses finales restent appliquees jusqu a la prochaine avance du lecteur.
	squelette.force_update_all_bone_transforms()
	var skin := squelette.get_bone_global_pose(_baguette) * squelette.get_bone_global_rest(_baguette).affine_inverse()
	origine_baguette = squelette.global_transform * (skin * POINTE_REPOS)
