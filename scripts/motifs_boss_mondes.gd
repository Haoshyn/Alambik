extends RefCounted

var annonce := 0.0
var cible := Vector2.ZERO
var _en_attente := false
var _salve := 0
var angles: Array[float] = []

func reinitialiser() -> void:
	annonce = 0.0
	_en_attente = false
	_salve = 0
	angles.clear()

func avancer(boss: CharacterBody2D, motif: String, delta: float) -> bool:
	if motif not in BestiaireMondes.BOSS_MOTIF_PAR_MONDE: return false
	boss._flotter(delta)
	if _en_attente:
		annonce = maxf(0.0, annonce - delta)
		if annonce <= 0.0:
			_en_attente = false
			_lancer(boss, motif)
	elif float(boss._cadence_motif) <= 0.0:
		# Ne pas annoncer une salve que le changement de motif annulerait.
		if float(boss._minuterie) <= BestiaireMondes.BOSS_ANNONCE_TIR: return true
		boss._cadence_motif = BestiaireMondes.BOSS_CADENCE_NOUVELLE
		cible = boss._cible.global_position
		_salve += 1
		angles.clear()
		var profil: Array = BestiaireMondes.BOSS_ANGLES_RESSERRES if _salve % 2 == 0 else BestiaireMondes.BOSS_ANGLES_NOUVEAUX
		var decalage := BestiaireMondes.BOSS_ALTERNANCE_ANGLE * (1.0 if _salve % 2 == 0 else -1.0) if int(boss._phase) == 2 else 0.0
		for angle: float in profil: angles.append(angle + decalage)
		annonce = BestiaireMondes.BOSS_ANNONCE_TIR
		_en_attente = true
	return true

func _lancer(boss: CharacterBody2D, motif: String) -> void:
	var donnees: Dictionary = boss.donnees
	var monde := int(donnees["monde_visuel"])
	if motif in ["encrage_cible", "foyers_cibles"]:
		var profil: Dictionary = BestiaireMondes.ZONES[BestiaireMondes.BOSS_ZONE_PAR_MONDE[monde]].duplicate()
		profil["rayon"] = float(profil["rayon"]) * BestiaireMondes.BOSS_ZONE_RAYON_MULT
		profil["lob"] = true
		boss.zone_demandee.emit(cible, boss.global_position, profil, float(donnees["degats"]))
		return
	var tir := Tir.new()
	tir.degats = float(donnees["degats"]) * BestiaireMondes.BOSS_DEGATS_NOUVEAUX
	tir.vitesse = float(donnees["vitesse_projectile"]) * Reglages.BOSS_PROJECTILE_VITESSE_MULT
	tir.portee = BestiaireMondes.BOSS_PORTEE_PROJECTILE
	tir.portee_limitee = true
	tir.silhouette = "eclat" if motif == "pierres_rebondissantes" else ("lame" if motif == "lames_ondulees" else "vrille")
	tir.rebonds_murs = BestiaireMondes.BOSS_REBONDS_MURS if motif == "pierres_rebondissantes" else 0
	tir.trajectoire = "droite" if motif == "pierres_rebondissantes" else "sinus"
	tir.amplitude = BestiaireMondes.BOSS_ONDULATION_AMPLITUDE
	tir.frequence = BestiaireMondes.BOSS_ONDULATION_FREQUENCE
	var direction := boss.global_position.direction_to(cible)
	for angle: float in angles:
		boss.tir_demande.emit(tir, boss.global_position, direction.rotated(angle))
