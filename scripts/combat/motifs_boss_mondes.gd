extends RefCounted

var annonce := 0.0
var cible := Vector2.ZERO
var _en_attente := false
var _salve := 0
var _tir: Tir
var angles: Array[float] = []

func reinitialiser() -> void:
	annonce = 0.0
	_en_attente = false
	_salve = 0
	_tir = null
	angles.clear()

func avancer(boss: CharacterBody2D, motif: String, delta: float) -> bool:
	if motif not in BestiaireMondes.BOSS_MOTIF_PAR_MONDE: return false
	if _en_attente:
		# La trajectoire annoncee garde son origine jusqu'au depart du tir.
		boss.velocity = Vector2.ZERO
		annonce = maxf(0.0, annonce - delta)
		if annonce <= 0.0:
			_en_attente = false
			_lancer(boss, motif)
		return true
	boss._flotter(delta)
	if float(boss._cadence_motif) <= 0.0:
		_tir = _creer_tir(boss.donnees)
		cible = boss._cible.global_position
		var doit_annoncer := motif in ["encrage_cible", "foyers_cibles"] \
			or ProjectilesEnnemis.annonce_necessaire(_tir, boss.global_position.distance_to(cible))
		# Ne pas annoncer une salve que le changement de motif annulerait.
		if doit_annoncer and float(boss._minuterie) <= BestiaireMondes.BOSS_ANNONCE_TIR: return true
		boss._cadence_motif = BestiaireMondes.BOSS_CADENCE_NOUVELLE
		_salve += 1
		angles.clear()
		var profil: Array = BestiaireMondes.BOSS_ANGLES_RESSERRES if _salve % 2 == 0 else BestiaireMondes.BOSS_ANGLES_NOUVEAUX
		var decalage := BestiaireMondes.BOSS_ALTERNANCE_ANGLE * (1.0 if _salve % 2 == 0 else -1.0) if int(boss._phase) == 2 else 0.0
		if _tir.trajectoire == "aller_retour":
			profil = ProjectilesEnnemis.RETOUR_BOSS_ANGLES
			decalage = 0.0
		for angle: float in profil: angles.append(angle + decalage)
		if doit_annoncer:
			annonce = BestiaireMondes.BOSS_ANNONCE_TIR
			_en_attente = true
		else:
			_lancer(boss, motif)
	return true

func _lancer(boss: CharacterBody2D, motif: String) -> void:
	var donnees: Dictionary = boss.donnees
	var monde := int(donnees["monde_visuel"])
	if motif in ["encrage_cible", "foyers_cibles"]:
		var profil: Dictionary = BestiaireMondes.ZONES[BestiaireMondes.BOSS_ZONE_PAR_MONDE[monde]].duplicate()
		profil["rayon"] = float(profil["rayon"]) * BestiaireMondes.BOSS_ZONE_RAYON_MULT
		profil["lob"] = true
		profil["projectile_id"] = str(donnees["projectile_id"])
		boss.zone_demandee.emit(cible, boss.global_position, profil, float(donnees["degats"]))
		return
	var direction := boss.global_position.direction_to(cible)
	for angle: float in angles:
		boss.tir_demande.emit(_tir, boss.global_position, direction.rotated(angle))

func _creer_tir(donnees: Dictionary) -> Tir:
	var tir := Tir.new()
	tir.degats = float(donnees["degats"]) * BestiaireMondes.BOSS_DEGATS_NOUVEAUX
	tir.vitesse = float(donnees["vitesse_projectile"]) * Reglages.BOSS_PROJECTILE_VITESSE_MULT
	tir.portee = BestiaireMondes.BOSS_PORTEE_PROJECTILE
	tir.portee_limitee = true
	ProjectilesEnnemis.appliquer(tir, donnees)
	return tir
