class_name CapacitesEnnemis
extends RefCounted

const ContactPhysique = preload("res://scripts/combat/contact_physique.gd")

var _recharge_esquive := 0.0
var _esquive_restante := 0.0
var _direction_esquive := Vector2.ZERO
var _trace_restante := 0.0

func avancer(ennemi: CharacterBody2D, delta: float) -> bool:
	_recharge_esquive = maxf(0.0, _recharge_esquive - delta)
	var d: Dictionary = ennemi.donnees
	if bool(d.get("esquive", false)) and _esquiver(ennemi, delta): return true
	match str(d["cerveau"]):
		"poursuivant":
			_poursuivre(ennemi)
			return true
		"artilleur":
			_artillerie(ennemi)
			return true
	return false

func _poursuivre(ennemi: CharacterBody2D) -> void:
	var distance := ennemi.global_position.distance_to(ennemi._cible.global_position)
	var portee := float(ennemi._distance_contact()) + Reglages.ENNEMI_CONTACT_MARGE
	if str(ennemi._etat) == "frappe":
		if float(ennemi._minuterie) <= 0.0:
			frapper_sur_segment(ennemi, ennemi.global_position, Reglages.ENNEMI_CONTACT_MARGE)
			ennemi._etat = "repos_contact"
			ennemi._minuterie = float(ennemi.donnees["repos_contact"])
		return
	if str(ennemi._etat) == "repos_contact":
		if float(ennemi._minuterie) <= 0.0: ennemi._etat = "repos"
		return
	if distance <= portee and float(ennemi._recharge_contact) <= 0.0 \
			and Geometrie.ligne_libre(ennemi.global_position, ennemi._cible.global_position, ennemi.get_parent().obstacles(), 0.0, ennemi.get_parent().contour_sol()):
		ennemi._etat = "frappe"
		ennemi._minuterie = float(ennemi.donnees.get("telegraphe_contact", Reglages.ENNEMI_CONTACT_ANNONCE))
		ennemi._direction_charge = ennemi.global_position.direction_to(ennemi._cible.global_position)
	elif distance > float(ennemi._distance_contact()):
		var avant := ennemi.global_position
		ennemi._avancer_vers(ennemi._cible.global_position, float(ennemi.donnees["vitesse"]))
		frapper_sur_segment(ennemi, avant)

static func frapper_sur_segment(ennemi: CharacterBody2D, avant: Vector2, marge := 0.0) -> bool:
	if float(ennemi._recharge_contact) > 0.0: return false
	if not ContactPhysique.frapper_sur_segment(ennemi, avant, float(ennemi.donnees["degats"]), marge): return false
	ennemi.attaque_contact.emit()
	ennemi._recharge_contact = BestiaireMondes.POURSUITE_CONTACT_RECHARGE
	return true

func _esquiver(ennemi: CharacterBody2D, delta: float) -> bool:
	if _esquive_restante > 0.0:
		_esquive_restante = maxf(0.0, _esquive_restante - delta)
		ennemi.velocity = _direction_esquive * float(ennemi.donnees["vitesse"]) * BestiaireMondes.ESQUIVE_VITESSE * float(ennemi._facteur_vitesse())
		ennemi.move_and_slide()
		return true
	if _recharge_esquive > 0.0 or str(ennemi._etat) != "repos": return false
	if ennemi.global_position.distance_to(ennemi._cible.global_position) < BestiaireMondes.ESQUIVE_SECURITE: return false
	for projectile in ennemi.get_tree().get_nodes_in_group("tirs_heros"):
		if not is_instance_valid(projectile) or projectile.is_queued_for_deletion(): continue
		var ecart: Vector2 = ennemi.global_position - projectile.global_position
		var direction: Vector2 = projectile.direction
		if ecart.length() > BestiaireMondes.ESQUIVE_DISTANCE or ecart.dot(direction) <= 0.0: continue
		if absf(ecart.cross(direction)) > BestiaireMondes.ESQUIVE_COULOIR: continue
		var salle := ennemi.get_parent()
		for sens in [1.0, -1.0]:
			var lateral := direction.orthogonal() * float(sens)
			var distance := float(ennemi.donnees["vitesse"]) * BestiaireMondes.ESQUIVE_VITESSE * BestiaireMondes.ESQUIVE_DUREE * float(ennemi._facteur_vitesse())
			var destination := ennemi.global_position + lateral * distance
			if not FormesSalles.contient_disque(destination, salle.contour_sol(), float(ennemi.donnees["rayon"])): continue
			if not Geometrie.ligne_libre(ennemi.global_position, destination, salle.obstacles(), float(ennemi.donnees["rayon"]), salle.contour_sol()): continue
			_direction_esquive = lateral
			_esquive_restante = BestiaireMondes.ESQUIVE_DUREE
			_recharge_esquive = BestiaireMondes.ESQUIVE_RECHARGE
			return true
	return false

func _artillerie(ennemi: CharacterBody2D) -> void:
	var d: Dictionary = ennemi.donnees
	if str(ennemi._etat) == "bombarde":
		if float(ennemi._minuterie) <= 0.0:
			var profil: Dictionary = BestiaireMondes.ZONES[str(d.get("zone", "impact"))].duplicate()
			profil["lob"] = true
			profil["projectile_id"] = str(d.get("projectile_id", "fiole_volatile"))
			ennemi.zone_demandee.emit(ennemi._point_vise, ennemi.global_position, profil, float(d["degats"]))
			ennemi._etat = "repos"
		return
	if ennemi.global_position.distance_to(ennemi._cible.global_position) > float(d["portee"]):
		ennemi._avancer_vers(ennemi._cible.global_position, float(d["vitesse"]))
	elif float(ennemi._recharge) <= 0.0:
		ennemi._etat = "bombarde"
		ennemi._point_vise = ennemi._cible.global_position
		ennemi._minuterie = float(d["telegraphe"])
		ennemi._recharge = float(d["recharge"])

func laisser_trace(ennemi: CharacterBody2D, delta: float) -> void:
	_trace_restante = maxf(0.0, _trace_restante - delta)
	var d: Dictionary = ennemi.donnees
	var charge_elementaire := str(ennemi._etat) == "charger" and d.has("zone_charge")
	if not charge_elementaire and not bool(d.get("incendiaire", false)): return
	if _trace_restante > 0.0 or ennemi.velocity.is_zero_approx(): return
	_trace_restante = BestiaireMondes.ZONE_CHARGE_INTERVALLE
	var type := str(d.get("zone_charge", "braise"))
	var profil: Dictionary = BestiaireMondes.ZONES[type].duplicate()
	profil.merge({"rayon": BestiaireMondes.ZONE_CHARGE_RAYON, "delai": BestiaireMondes.ZONE_CHARGE_DELAI,
		"duree": BestiaireMondes.ZONE_CHARGE_DUREE, "part_degats": BestiaireMondes.ZONE_CHARGE_DEGATS}, true)
	ennemi.zone_demandee.emit(ennemi.global_position, ennemi.global_position, profil, float(d["degats"]))

static func configurer_tir(tir: Tir, d: Dictionary) -> void:
	ProjectilesEnnemis.appliquer(tir, d)

func destination_phase(ennemi: CharacterBody2D) -> Vector2:
	var cible: Vector2 = ennemi._cible.global_position
	var radial := cible.direction_to(ennemi.global_position)
	if radial.is_zero_approx(): radial = Vector2.UP
	var salle := ennemi.get_parent()
	var rayon := float(ennemi.donnees["rayon"])
	for distance: float in BestiaireMondes.DISTANCES_PHASE:
		for angle: float in BestiaireMondes.ANGLES_PHASE:
			var point := cible + radial.rotated(angle) * float(ennemi.donnees["portee"]) * distance
			if point.distance_to(ennemi.global_position) < BestiaireMondes.PHASE_DEPLACEMENT_MIN: continue
			if salle._place_libre(point, rayon) and Geometrie.ligne_libre(point, cible, salle.obstacles(), 0.0, salle.contour_sol()): return point
	return Vector2.INF
