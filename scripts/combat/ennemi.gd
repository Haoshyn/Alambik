extends CharacterBody2D

# Les decisions des familles viennent de Cerveaux et les capacites specialisees
# de CapacitesEnnemis. Le monde fournit les variantes de leur profil.

signal mort(qui: Node, position: Vector2, couleur: Color)
signal tir_demande(tir_ennemi: Tir, origine: Vector2, direction: Vector2)
signal invocation_demandee(id: String, position: Vector2)
signal touche(position: Vector2, couleur: Color)
signal degats_recus(position: Vector2, montant: float, continu: bool)
signal zone_demandee(point: Vector2, origine: Vector2, profil: Dictionary, degats: float)
signal attaque_contact

var donnees: Dictionary
var pv := 0.0
var pv_max := 1.0
var limites := Rect2(Vector2(80, 300), Vector2(920, 1400))

var _cible: Node2D
var _recharge := 0.0
var _recharge_contact := 0.0
var _braise := 0.0
var _braise_dps := 0.0
var _givre := 0.0
var _puissance_givre := 1.0
var _ralentissement_passif := 0.0
var _ralentissement_passif_part := 0.0
var _acide := 0.0
var _puissance_acide := 1.0
var _gel := 0.0
var _etat := "repos"
var _point_vise := Vector2.ZERO
var _minuterie := 0.0
var _annonce_projectile := false
var _direction_charge := Vector2.ZERO
var _charge := preload("res://scripts/combat/trajet_charge.gd").new()
var _anim := 0.0
var _flash := 0.0
var _apparition := 0.0
var _invocations := 0
var _contournement := 0.0
var _sens_contournement := 1.0
var _salves: Array[Dictionary] = []
var _anneau_index := 0
var _charges_effectuees := 0
var _capacites := CapacitesEnnemis.new()
var _destination_phase := Vector2.ZERO
func configurer(donnees_: Dictionary) -> void:
	donnees = donnees_.duplicate(true)
	for cle in ["telegraphe", "preparation"]:
		if donnees.has(cle):
			donnees[cle] = maxf(Reglages.ENNEMI_TELEGRAPHE_MIN, float(donnees[cle]))
	pv = donnees["pv"]
	pv_max = donnees["pv"]

func _ready() -> void:
	add_to_group("ennemis")
	if bool(donnees.get("elite", false)): add_to_group("elites")
	collision_layer = 2
	collision_mask = 4
	_cible = get_tree().get_first_node_in_group("heros")
	# Les familles n'ont pas le meme rayon : la ressource partagee de la scene
	# ne doit pas remplacer les collisions de tous les ennemis a chaque apparition.
	var forme := CircleShape2D.new()
	forme.radius = float(donnees["rayon"]) * Reglages.ENNEMI_HITBOX_MULT
	$CollisionShape2D.shape = forme
	_recharge = float(donnees.get("recharge", 1.0)) * 0.5

func _physics_process(delta: float) -> void:
	_anim += delta
	_flash = maxf(0.0, _flash - delta * 6.0)
	_apparition = minf(1.0, _apparition + delta / Reglages.ENNEMI_APPARITION_DUREE)
	_appliquer_effets(delta)
	if pv <= 0.0: return
	_contournement = maxf(0.0, _contournement - delta)
	queue_redraw()
	if _apparition < 1.0:
		velocity = Vector2.ZERO
		return
	_cible = _cible_la_plus_proche()
	if _cible == null:
		return
	_recharge = maxf(0.0, _recharge - delta)
	_recharge_contact = maxf(0.0, _recharge_contact - delta)
	if _gel <= 0.0: _minuterie = maxf(0.0, _minuterie - delta)
	if _gel > 0.0:
		velocity = Vector2.ZERO
		return
	velocity = Vector2.ZERO
	# Traverser le corps d'un poursuivant ou d'un chargeur est deja un contact.
	if str(donnees["cerveau"]) in ["poursuivant", "rampant", "veloce"]:
		CapacitesEnnemis.frapper_sur_segment(self, global_position)
	# Les relances conservent leur origine et leur visee pendant l'annonce.
	if _relancer_salves(delta): return
	if _capacites.avancer(self, delta):
		_contraindre_aux_murs()
		_capacites.laisser_trace(self, delta)
		return
	match donnees["cerveau"]:
		"rampant": _agir_rampant(delta)
		"sentinelle": _agir_sentinelle()
		"veloce": _agir_veloce(delta)
		"essaimeur": _agir_essaimeur(delta)
		"orbiteur": _agir_orbiteur(delta)
		"harceleur": _agir_harceleur(delta)
		"miroir": _agir_miroir(delta)
		"phaseur": _agir_phaseur(delta)
		"tisseur": _agir_tisseur(delta)
		"volatile": _agir_volatile(delta)
	_contraindre_aux_murs()
	_capacites.laisser_trace(self, delta)

func _cible_la_plus_proche() -> Node2D:
	var meilleure: Node2D = null
	var distance := INF
	for cible in get_tree().get_nodes_in_group("cibles_ennemis"):
		if not is_instance_valid(cible) or not cible.visible:
			continue
		var d := global_position.distance_squared_to(cible.global_position)
		if d < distance:
			distance = d
			meilleure = cible
	return meilleure

func _facteur_vitesse() -> float:
	var facteur := maxf(Reglages.MODS_PLANCHER, 1.0 - (1.0 - Reglages.GIVRE_RALENTISSEMENT) * _puissance_givre) if _givre > 0.0 else 1.0
	if _ralentissement_passif > 0.0:
		facteur = minf(facteur, 1.0 - _ralentissement_passif_part)
	return Reglages.ENNEMI_VITESSE_MULT * facteur

func _avancer_vers(cible: Vector2, vitesse: float) -> void:
	var direction := global_position.direction_to(cible)
	# Sans ca, un ennemi pousse indefiniment contre un bloc d'encre sechee et la
	# salle ne se vide jamais : c'est un blocage, pas une difficulte.
	if _contournement > 0.0:
		direction = direction.rotated(_sens_contournement * PI * 0.5).lerp(direction, 0.25).normalized()
	var avant := global_position
	velocity = direction * vitesse * _facteur_vitesse()
	move_and_slide()
	_contraindre_aux_murs()
	var attendu := vitesse * _facteur_vitesse() * get_physics_process_delta_time()
	if _contournement <= 0.0 and avant.distance_to(global_position) < attendu * 0.35:
		_contournement = 0.8
		_sens_contournement = 1.0 if randf() < 0.5 else -1.0

func _agir_rampant(delta: float) -> void:
	var distance := global_position.distance_to(_cible.global_position)
	if _etat == "frappe":
		if _minuterie <= 0.0:
			CapacitesEnnemis.frapper_sur_segment(self, global_position, Reglages.ENNEMI_CONTACT_MARGE)
			_etat = "repos_contact"
			_minuterie = float(donnees.get("repos_contact", 0.72))
			_recharge = float(donnees.get("recharge", 2.1))
		return
	if _etat == "repos_contact":
		if _minuterie <= 0.0:
			_etat = "repos"
		return
	if _etat == "crache":
		if _minuterie <= 0.0:
			_tirer_vers(_point_vise)
			_etat = "repos"
			_recharge = float(donnees.get("recharge", 2.1))
		return
	if _etat == "preparer":
		if _minuterie <= 0.0:
			if distance > portee_charge() or _charge.longueur > _longueur_charge():
				_etat = "repos"
				return
			_etat = "charger"
			_minuterie = EvolutionEnnemis.ELAN_DUREE
		return
	if _etat == "charger":
		var avant := global_position
		_charge.avancer(self, float(donnees["vitesse"]) * EvolutionEnnemis.ELAN_VITESSE * _facteur_vitesse(), delta)
		CapacitesEnnemis.frapper_sur_segment(self, avant)
		if _charge.terminee:
			_etat = "repos"
			_recharge = float(donnees["recharge"])
		return
	if distance > _distance_contact() and distance <= minf(float(donnees.get("elan_distance",0.0)), portee_charge()) \
			and _recharge <= 0.0 and Geometrie.ligne_libre(global_position, _cible.global_position, get_parent().obstacles(), _rayon_collision()):
		_etat = "preparer"
		_minuterie = float(donnees["preparation"])
		_direction_charge = global_position.direction_to(_viser())
		_preparer_trajet_charge()
		return
	if distance <= _distance_contact() and _recharge_contact <= 0.0:
		_etat = "frappe"
		_minuterie = float(donnees.get("telegraphe_contact", 0.48))
		_direction_charge = global_position.direction_to(_cible.global_position)
		return
	if distance <= float(donnees.get("portee_tir", 0.0)) \
			and distance > float(donnees["portee"]) * 2.0 and _recharge <= 0.0:
		if not _preparer_tir("crache", float(donnees.get("telegraphe", 0.62))):
			_tirer_vers(_point_vise)
			_recharge = float(donnees.get("recharge", 2.1))
		return
	if Cerveaux.rampant(distance, _distance_contact()) == "avancer":
		var avant := global_position
		_avancer_vers(_cible.global_position, donnees["vitesse"])
		CapacitesEnnemis.frapper_sur_segment(self, avant)

func _agir_sentinelle() -> void:
	if _etat == "vise":
		if _minuterie <= 0.0:
			_etat = "repos"
			_tirer_vers(_point_vise)
		return
	if _recharge > 0.0 or not _peut_tirer(): return
	_recharge = float(donnees.get("recharge", 1.8))
	if not _preparer_tir("vise", float(donnees.get("telegraphe", 0.6))):
		_tirer_vers(_point_vise)

func _preparer_tir(etat: String, duree: float, cercle := false) -> bool:
	_point_vise = _viser()
	_annonce_projectile = _doit_annoncer_tir(cercle)
	if not _annonce_projectile: return false
	if str(donnees["cerveau"]) == "sentinelle" and _cible is CharacterBody2D:
		_point_vise = Cerveaux.visee_rapide(global_position, _cible.global_position,
			(_cible as CharacterBody2D).velocity, duree, _creer_tir().vitesse)
	_etat = etat
	_minuterie = duree
	return true

func _doit_annoncer_tir(cercle := false) -> bool:
	return ProjectilesEnnemis.annonce_necessaire(_creer_tir(cercle), global_position.distance_to(_cible.global_position))

func _peut_tirer(cercle := false) -> bool:
	var tir := _creer_tir(cercle)
	var portee := minf(tir.portee, tir.distance_retour) if tir.trajectoire == "aller_retour" else tir.portee
	return global_position.distance_to(_cible.global_position) <= portee \
		and Geometrie.ligne_libre(global_position, _cible.global_position, get_parent().obstacles(), tir.rayon)

func _viser() -> Vector2:
	var point := _cible.global_position
	if _cible is CharacterBody2D:
		point += (_cible as CharacterBody2D).velocity*float(donnees.get("anticipation",0.0))
	return point

func _relancer_salves(delta: float) -> bool:
	if _salves.is_empty(): return false
	var restantes: Array[Dictionary] = []
	for salve in _salves:
		salve["delai"] = float(salve["delai"])-delta
		if float(salve["delai"]) <= 0.0:
			if int(salve["cercle"]) > 0: _tirer_cercle(int(salve["cercle"]),true)
			else: _tirer_vers(salve["cible"],true)
			salve["reste"] = int(salve["reste"])-1
			salve["delai"] = EvolutionEnnemis.INTERVALLE_SALVES
		if int(salve["reste"]) > 0: restantes.append(salve)
	_salves = restantes
	return true

func _programmer_salves(cible: Vector2, cercle: int, tir: Tir) -> void:
	var nombre := int(donnees.get("salves",1))-1
	if nombre > 0:
		var annonce := ProjectilesEnnemis.annonce_necessaire(tir, global_position.distance_to(_cible.global_position))
		_salves.append({"cible":cible,"cercle":cercle,"reste":nombre,"delai":EvolutionEnnemis.INTERVALLE_SALVES,"annonce":annonce})

func _creer_tir(cercle := false) -> Tir:
	var t := Tir.new()
	t.degats = donnees["degats"] * float(donnees.get("part_degats_projectile", 1.0))
	t.vitesse = float(donnees.get("vitesse_projectile", 320.0 if cercle else 420.0))
	t.portee = float(donnees.get("portee_projectile", 900.0 if cercle else float(donnees["portee"]) * 1.4))
	t.cadence = 1.0
	if not cercle:
		t.nb_projectiles = int(donnees.get("projectiles", 1))
		t.angle_eventail = float(donnees.get("angle_eventail", 0.0))
		t.ecart_lateral = float(donnees.get("ecart_lateral", 0.0))
	CapacitesEnnemis.configurer_tir(t, donnees)
	return t

func _tirer_vers(cible: Vector2, relance := false) -> void:
	var t := _creer_tir()
	tir_demande.emit(t, global_position, global_position.direction_to(cible))
	if not relance: _programmer_salves(cible, 0, t)

func _tirer_cercle(nombre: int, relance := false) -> void:
	var t := _creer_tir(true)
	var decalage := decalage_anneau()
	_anneau_index += 1
	for i in nombre:
		var direction := Vector2.RIGHT.rotated(TAU * float(i) / float(nombre)+decalage)
		tir_demande.emit(t, global_position, direction)
	if not relance and nombre > 0: _programmer_salves(Vector2.ZERO, nombre, t)

func decalage_anneau() -> float:
	return _anneau_index * EvolutionEnnemis.DECALAGE_ANNEAU if int(donnees.get("evolution", 0)) > 0 else 0.0

func _agir_veloce(delta: float) -> void:
	var distance := global_position.distance_to(_cible.global_position)
	var decision := Cerveaux.veloce(distance, _etat, _minuterie,
		portee_charge())
	# Un trajet annonce se termine a son extremite, meme sous un ralentissement.
	if _etat == "charger" and not _charge.terminee: decision = "charger"
	if _etat == "preparer" and decision == "charger" and _charge.longueur > _longueur_charge():
		decision = "avancer"
	if decision in ["preparer", "charger"] and _etat != "charger" \
			and not Geometrie.ligne_libre(global_position, _cible.global_position, get_parent().obstacles(), float(donnees["rayon"])):
		decision = "avancer"
	match decision:
		"avancer":
			_etat = "repos"
			_minuterie = 0.0
			_charges_effectuees = 0
			_avancer_vers(_cible.global_position,
				float(donnees["vitesse"]) * float(donnees.get("vitesse_approche_mult", 0.45)))
		"preparer":
			if _etat != "preparer":
				_etat = "preparer"
				_minuterie = donnees.get("preparation", 0.7)
				_direction_charge = global_position.direction_to(_cible.global_position)
				_preparer_trajet_charge()
		"charger":
			if _etat != "charger":
				_etat = "charger"
				_charges_effectuees += 1
				_minuterie = donnees.get("duree_charge", 0.5)
			var avant := global_position
			_charge.avancer(self, float(donnees["vitesse"]) * _facteur_vitesse(), delta)
			CapacitesEnnemis.frapper_sur_segment(self, avant)
			if _charge.terminee:
				_minuterie = 0.0
		"repos":
			if _etat != "repos":
				if _charges_effectuees < int(donnees.get("charges",1)) and distance <= portee_charge() \
						and Geometrie.ligne_libre(global_position, _cible.global_position, get_parent().obstacles(), float(donnees["rayon"])):
					_etat = "preparer"
					_minuterie = float(donnees["preparation"])
					_direction_charge = global_position.direction_to(_cible.global_position)
					_preparer_trajet_charge()
					return
				_charges_effectuees = 0
				_etat = "repos"
				_minuterie = donnees.get("repos", 0.8)

func portee_charge() -> float:
	return _longueur_charge() + _distance_contact()

func _longueur_charge() -> float:
	return Cerveaux.longueur_charge(donnees, _facteur_vitesse())

func _preparer_trajet_charge() -> void:
	_charge.preparer(self, _direction_charge, _longueur_charge(), _rayon_collision())
	if not _charge.contient_cible(_cible.global_position, _distance_contact()):
		_etat = "repos"
		_minuterie = 0.0
		_avancer_vers(_cible.global_position, float(donnees["vitesse"]) * float(donnees.get("vitesse_approche_mult", 1.0)))

func _agir_essaimeur(_delta: float) -> void:
	if _etat == "invoque":
		if _minuterie <= 0.0:
			_etat = "repos"
			_invoquer_essaimeur()
		return
	var distance := global_position.distance_to(_cible.global_position)
	var peut_invoquer := _invocations < int(donnees.get("max_invocations", 6)) \
		and int(get_parent().effectif_ennemis()) < Reglages.PLAFOND_ENNEMIS
	if not peut_invoquer and not _peut_tirer(true):
		_avancer_vers(_cible.global_position, float(donnees["vitesse"]))
		return
	match Cerveaux.essaimeur(distance, donnees["portee"], _recharge):
		"reculer":
			_avancer_vers(global_position * 2.0 - _cible.global_position, donnees["vitesse"])
		"avancer":
			_avancer_vers(_cible.global_position, donnees["vitesse"])
		"invoquer":
			_recharge = donnees.get("recharge", 3.5)
			_annonce_projectile = _doit_annoncer_tir(true)
			_etat = "invoque"
			_minuterie = float(donnees.get("telegraphe", 0.78))

func _invoquer_essaimeur() -> void:
	# Reserve d'encre finie : sans ce plafond, un scribe qu'on ne prend jamais
	# pour cible rend la salle litteralement infinie.
	if _invocations >= int(donnees.get("max_invocations", 6)):
		_tirer_cercle(int(donnees.get("projectiles_cercle", 0)))
		return
	if int(get_parent().effectif_ennemis()) >= Reglages.PLAFOND_ENNEMIS:
		_tirer_cercle(int(donnees.get("projectiles_cercle", 0)))
		return
	_invocations += int(donnees.get("nb_invoques", 2))
	for i in int(donnees.get("nb_invoques", 2)):
		var ecart := Vector2(randf_range(-90.0, 90.0), randf_range(-90.0, 90.0))
		invocation_demandee.emit(donnees.get("invoque", "encrier_rampant"), global_position + ecart)
	_tirer_cercle(int(donnees.get("projectiles_cercle", 0)))

func _agir_orbiteur(_delta: float) -> void:
	if _etat == "vise_orbite":
		velocity = Vector2.ZERO
		if _minuterie <= 0.0:
			_etat = "repos"
			_tirer_vers(_point_vise)
		return
	var distance := global_position.distance_to(_cible.global_position)
	match Cerveaux.orbiteur(distance, donnees["portee"], _recharge, _peut_tirer()):
		"reculer": _avancer_vers(global_position * 2.0 - _cible.global_position, donnees["vitesse"])
		"avancer": _avancer_vers(_cible.global_position, donnees["vitesse"])
		"orbiter":
			var radial := _cible.global_position.direction_to(global_position)
			var tangente := radial.rotated(float(donnees.get("sens_orbite", 1.0)) * PI * 0.5)
			velocity = tangente * donnees["vitesse"] * _facteur_vitesse()
			move_and_slide()
		"tirer":
			_recharge = donnees.get("recharge", 1.65)
			if not _preparer_tir("vise_orbite", float(donnees.get("telegraphe", 0.50))):
				_tirer_vers(_point_vise)

func _agir_harceleur(_delta: float) -> void:
	if _etat == "vise":
		if _minuterie <= 0.0:
			_etat = "repos"
			_tirer_vers(_point_vise)
		return
	var distance := global_position.distance_to(_cible.global_position)
	match Cerveaux.harceleur(distance, donnees["portee"], _recharge, _peut_tirer()):
		"reculer": _avancer_vers(global_position * 2.0 - _cible.global_position, donnees["vitesse"])
		"avancer": _avancer_vers(_cible.global_position, donnees["vitesse"])
		"tourner":
			var tangente := global_position.direction_to(_cible.global_position).rotated(PI * 0.5 * _sens_contournement)
			velocity = tangente * donnees["vitesse"] * 0.55 * _facteur_vitesse()
			move_and_slide()
		"tirer":
			_recharge = donnees.get("recharge", 1.45)
			if not _preparer_tir("vise", float(donnees.get("telegraphe", 0.48))):
				_tirer_vers(_point_vise)

func _agir_miroir(_delta: float) -> void:
	if _etat == "pulse":
		if _minuterie <= 0.0:
			_etat = "repos"
			_tirer_cercle(int(donnees.get("projectiles_cercle", 8)))
		return
	var distance := global_position.distance_to(_cible.global_position)
	match Cerveaux.miroir(distance, donnees["portee"], _recharge, _peut_tirer(true)):
		"avancer": _avancer_vers(_cible.global_position, donnees["vitesse"])
		"pulser":
			_recharge = donnees.get("recharge", 2.35)
			if not _preparer_tir("pulse", float(donnees.get("telegraphe", 0.65)), true):
				_tirer_cercle(int(donnees.get("projectiles_cercle", 8)))

func _agir_phaseur(_delta: float) -> void:
	if _etat == "vise_phase":
		if _minuterie <= 0.0:
			_tirer_cercle(int(donnees.get("projectiles_cercle", 6)))
			_tirer_vers(_point_vise)
			_etat = "repos"
			_recharge = float(donnees["recharge"])
		return
	var distance := global_position.distance_to(_cible.global_position)
	match Cerveaux.phaseur(distance, donnees["portee"], _recharge, _etat, _minuterie):
		"avancer": _avancer_vers(_cible.global_position, donnees["vitesse"])
		"tourner":
			var radial := _cible.global_position.direction_to(global_position)
			velocity = radial.rotated(PI * 0.5 * _sens_contournement) * donnees["vitesse"] * 0.55 * _facteur_vitesse()
			move_and_slide()
		"phase":
			_destination_phase = _capacites.destination_phase(self)
			if not _destination_phase.is_finite():
				_recharge = BestiaireMondes.PHASE_REESSAI
				_avancer_vers(_cible.global_position, float(donnees["vitesse"]))
				return
			_etat = "phase"
			_point_vise = _viser()
			_minuterie = Reglages.PHASE_ANNONCE
			_recharge = donnees.get("recharge", 2.55)
		"disparaitre":
			velocity = Vector2.ZERO
		"reapparaitre":
			# Une place occupee pendant l'annonce annule le saut sans deplacer son repere.
			if not get_parent()._place_libre(_destination_phase, float(donnees["rayon"])):
				_etat = "repos"
				_recharge = BestiaireMondes.PHASE_REESSAI
				return
			# La vitesse effective decide si le tir demande une annonce apres l'arrivee.
			global_position = _destination_phase
			reset_physics_interpolation()
			_etat = "repos"
			if not _peut_tirer():
				_recharge = BestiaireMondes.PHASE_REESSAI
				return
			if not _preparer_tir("vise_phase", Reglages.PHASE_PREPARATION_TIR, true):
				_tirer_cercle(int(donnees.get("projectiles_cercle", 6)))
				_tirer_vers(_point_vise)
				_recharge = float(donnees["recharge"])

func _rayon_collision() -> float:
	return ($CollisionShape2D.shape as CircleShape2D).radius

func _distance_contact() -> float:
	var collision := _cible.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var rayon := Reglages.HEROS_RAYON
	if collision != null and collision.shape is CircleShape2D:
		rayon = (collision.shape as CircleShape2D).radius
	return _rayon_collision() + rayon

func _contraindre_aux_murs() -> void:
	global_position = Geometrie.contraindre_dans_rect(global_position, limites, _rayon_collision())

func _agir_tisseur(_delta: float) -> void:
	var distance := global_position.distance_to(_cible.global_position)
	var distance_minimale := float(donnees["vitesse_projectile"]) * BestiaireMondes.TISSEUR_REACTION_MIN
	match Cerveaux.tisseur(distance, donnees["portee"], _recharge, distance_minimale, _peut_tirer()):
		"reculer": _avancer_vers(global_position * 2.0 - _cible.global_position, donnees["vitesse"])
		"avancer": _avancer_vers(_cible.global_position, donnees["vitesse"])
		"croiser":
			var tangente := global_position.direction_to(_cible.global_position).rotated(PI * 0.5 * _sens_contournement)
			velocity = tangente * donnees["vitesse"] * _facteur_vitesse()
			move_and_slide()
		"tisser":
			# Le ruban se lit en mouvement : ni annonce ni anticipation du joueur.
			_tirer_vers(_cible.global_position)
			_recharge = float(donnees["recharge"])

func _agir_volatile(_delta: float) -> void:
	var distance := global_position.distance_to(_cible.global_position)
	match Cerveaux.volatile(distance, donnees.get("rayon_explosion", donnees["portee"]),
			_etat, _minuterie):
		"avancer": _avancer_vers(_cible.global_position, donnees["vitesse"])
		"gonfler":
			velocity = Vector2.ZERO
			if _etat != "gonfler":
				_etat = "gonfler"
				_annonce_projectile = _doit_annoncer_tir(true)
				_minuterie = donnees.get("preparation", 0.88)
		"exploser":
			_tirer_cercle(int(donnees.get("projectiles_cercle", 9)))
			if distance <= float(donnees.get("rayon_explosion", donnees["portee"])):
				_cible.recevoir_degats(donnees["degats"])
			pv = 0.0
			_mourir()

func recevoir_degats(montant: float, effets: Array = [], puissances: Dictionary = {}) -> void:
	if pv <= 0.0:
		return
	var facteur := (1.0 + (Reglages.ACIDE_VULNERABILITE - 1.0) * _puissance_acide) if _acide > 0.0 else 1.0
	var degats := montant * facteur
	pv -= degats
	degats_recus.emit(global_position, degats, false)
	_flash = 1.0
	touche.emit(global_position, donnees["couleur"])
	for effet in effets:
		match effet:
			"braise":
				_braise = Reglages.BRAISE_DUREE
				_braise_dps = maxf(_braise_dps, montant * Reglages.BRAISE_PART_DEGATS_PAR_SECONDE * float(puissances.get("braise", 1.0)))
			"givre":
				_puissance_givre = maxf(_puissance_givre if _givre > 0.0 else 1.0, float(puissances.get("givre", 1.0)))
				_givre = Reglages.GIVRE_DUREE
			"sang_froid_1", "sang_froid_2":
				_ralentissement_passif = Passifs.SANG_FROID_DUREE
				_ralentissement_passif_part = Passifs.SANG_FROID_RALENTISSEMENT \
					* (2.0 if effet == "sang_froid_2" else 1.0)
			"acide":
				_puissance_acide = maxf(_puissance_acide if _acide > 0.0 else 1.0, float(puissances.get("acide", 1.0)))
				_acide = Reglages.ACIDE_DUREE
	if pv <= 0.0:
		_mourir()

func geler(duree: float) -> void:
	_gel = maxf(_gel, duree)
	if _givre <= 0.0:
		_puissance_givre = 1.0
	_givre = maxf(_givre, duree)

func _appliquer_effets(delta: float) -> void:
	if pv <= 0.0: return
	_gel = maxf(0.0, _gel - delta)
	_givre = maxf(0.0, _givre - delta)
	_ralentissement_passif = maxf(0.0, _ralentissement_passif - delta)
	_acide = maxf(0.0, _acide - delta)
	var dot_dps := 0.0
	if _braise > 0.0:
		_braise = maxf(0.0, _braise - delta)
		dot_dps += _braise_dps
	else:
		_braise_dps = 0.0
	if dot_dps > 0.0:
		var degats := dot_dps * delta
		pv -= degats
		degats_recus.emit(global_position, degats, true)
		if pv <= 0.0:
			_mourir()

func _mourir() -> void:
	if not is_inside_tree():
		return
	remove_from_group("ennemis")
	remove_from_group("elites")
	mort.emit(self, global_position, donnees["couleur"])
	Sons.jouer("mort", -14.0, randf_range(0.85, 1.15))
	queue_free()

func _draw() -> void:
	if bool(donnees.get("elite", false)):
		var rayon := float(donnees["rayon"])
		draw_arc(Vector2.ZERO, rayon + 7.0, 0, TAU, 32, Color(RangsEnnemis.COULEUR_ELITE, .7), 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-23,-rayon-31), "ÉLITE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, RangsEnnemis.COULEUR_ELITE)
	if has_meta("visuel_3d"):
		_dessiner_telegraphe(float(donnees["rayon"]))
		_dessiner_barre_de_vie(float(donnees["rayon"]))
		if _gel > 0.0:
			draw_arc(Vector2.ZERO, float(donnees["rayon"]), 0.0, TAU, 24, Palette.GIVRE, 2.0, true)
		return
	var r: float = donnees["rayon"] * (0.4 + 0.6 * _apparition)
	var base: Color = donnees["couleur"]
	var couleur := base
	if _givre > 0.0 or _ralentissement_passif > 0.0:
		couleur = couleur.lerp(Palette.GIVRE, 0.45)
	if _acide > 0.0:
		couleur = couleur.lerp(Palette.ACIDE, 0.30)
	if _flash > 0.0:
		couleur = couleur.lerp(Color.WHITE, _flash * 0.8)

	draw_set_transform(Vector2(0, r * 0.85), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, r * 0.9, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# La menace est plus claire et plus saturee que le fond. Les telegraphes
	# restent proceduraux, mais les silhouettes sont maintenant peintes.
	Dessin.halo(self, Vector2.ZERO, r * 2.2, couleur, 4)
	_dessiner_telegraphe(r)
	var vers_retro := Vector2.DOWN if _cible == null else global_position.direction_to(_cible.global_position)
	Retro16.dessiner_ennemi(self, donnees, _anim, _etat, vers_retro)

	if _braise > 0.0:
		for i in 3:
			var a := _anim * 4.0 + float(i) * TAU / 3.0
			var p := Vector2(cos(a), sin(a * 1.3)) * r * 0.8 - Vector2(0, r * 0.6 + sin(_anim * 6.0 + i) * 6.0)
			draw_circle(p, r * 0.16, Palette.BRAISE)
	if _gel > 0.0:
		Dessin.contour(self, Dessin.etoile(Vector2.ZERO, r * 1.5, r * 0.7, 6, _anim * 0.4), Palette.GIVRE, 2.5)
	_dessiner_barre_de_vie(r)

func _dessiner_telegraphe(r: float) -> void:
	if not is_instance_valid(_cible): return
	preload("res://scripts/presentation/annonces_ennemis.gd").dessiner(self, r)

func _dessiner_barre_de_vie(r: float) -> void:
	if pv >= pv_max:
		return
	var largeur := maxf(56.0, r * 2.2)
	var haut := -r - 22.0
	var barre := Rect2(-largeur / 2.0, haut, largeur, 9.0)
	draw_rect(barre.grow(4.0), Color(0.008, 0.012, 0.022, 0.88))
	draw_rect(barre, Color(0.20, 0.035, 0.055, 0.94))
	var pleine := barre.grow(-2.0)
	pleine.size.x *= clampf(pv / pv_max, 0.0, 1.0)
	draw_rect(pleine, Palette.DANGER)
	draw_rect(barre, Color(Palette.OR, 0.62), false, 2.0)
