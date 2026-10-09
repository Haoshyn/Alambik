extends CharacterBody2D

# L'alchimiste. Elle ne lit jamais Input : joystick et bot headless passent par
# la meme porte, definir_intention(). Piloter des entrees simulees a deja fait
# rapporter des succes faux ailleurs.

signal tir_demande(tir_courant: Tir, origine: Vector2, direction: Vector2)
signal attaque_preparee(direction: Vector2)
signal touchee(position: Vector2)
signal bouclier_brise(position: Vector2)
signal morte

var stats := Stats.depuis_reglages(ReglagesJoueur.rangs_competences_effectifs(),
	ReglagesJoueur.passifs_equipes_effectifs(), ReglagesJoueur.bonus_objets_effectifs(),
	ReglagesJoueur.niveau_compte_effectif(), ReglagesJoueur.attributs, ReglagesJoueur.specialisation_effective())
var tir_courant: Tir
var bouclier := 0
var _boucliers_accordes := 0
var limites := Rect2(Vector2(80, 300), Vector2(920, 1400))

var _intention := Vector2.ZERO
var _intensite := 0.0
var _temps_immobile := 0.0
var _recharge := 0.0
var _invulnerable := 0.0
var _rafale_restante := 0
var _rafale_minuterie := 0.0
var _rafale_direction := Vector2.RIGHT
var _visee := Vector2.UP
var _flottement := 0.0
var _secousse := 0.0
var _vie_retard := 1.0
var dernier_critique := false
var dernier_degat_recu := 0.0
var _inclinaison := 0.0
var _attaque := 0.0
var _tirs_prepares: Array[Dictionary] = []
var _temps_depuis_degats := 0.0
var _elan_objet_cumuls := 0
var _elan_objet_restant := 0.0
var _sursis_disponible := true
var _egide_active := false
var _courage_vie_disponible := true
var _elan_mouvement := 0.0
var _elan_chargee := false
var _puissance_attaque_elan := 1.0
var _satellites: SatellitesAlchimiques
var _effets_periodiques: EffetsPeriodiquesAugments

func _ready() -> void:
	add_to_group("heros")
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.shape = collision.shape.duplicate()
		(collision.shape as CircleShape2D).radius = Reglages.HEROS_RAYON
	add_to_group("cibles_ennemis")
	tir_courant = Tir.de_base(stats)
	recalculer()
	_satellites = SatellitesAlchimiques.new()
	_satellites.name = "SatellitesAlchimiques"
	_satellites.heros = self
	add_child(_satellites)
	_effets_periodiques = EffetsPeriodiquesAugments.new()
	_effets_periodiques.name = "EffetsPeriodiquesAugments"
	_effets_periodiques.heros = self
	add_child(_effets_periodiques)
	stats.soin_restant = stats.pv_max * Reglages.SOIN_COMBAT_PAR_SALLE * stats.soin_mult

func definir_intention(direction: Vector2, intensite := 1.0) -> void:
	_intention = direction
	_intensite = intensite

var _pv_max_sans_augments := 0.0
var _critique_sans_augments := 0.0
var _degats_critiques_sans_augments := 0.0
var _soin_sans_augments := 1.0
var _vitesse_sans_augments := 0.0

func recalculer() -> void:
	var mods_run := Jeu.mods()
	# Repartir des bases evite de reappliquer les bonus a chaque choix ou salle.
	if _pv_max_sans_augments <= 0.0:
		_pv_max_sans_augments = stats.pv_max
		_critique_sans_augments = stats.critique + stats.critique_excedentaire
		_degats_critiques_sans_augments = stats.degats_critiques
		_soin_sans_augments = stats.soin_mult
		_vitesse_sans_augments = stats.vitesse
	stats.pv_max = _pv_max_sans_augments * Mods.facteur_heros(mods_run, "pv_max_mult")
	stats.pv = minf(stats.pv, stats.pv_max)
	var chance_critique := _critique_sans_augments + Mods.bonus_heros(mods_run, "critique_add")
	stats.critique = clampf(chance_critique, 0.0, 1.0)
	stats.critique_excedentaire = maxf(0.0, chance_critique - 1.0)
	stats.degats_critiques = _degats_critiques_sans_augments + Mods.bonus_degats_critiques(mods_run, chance_critique)
	stats.soin_mult = _soin_sans_augments * Mods.facteur_heros(mods_run, "soin_mult")
	var tir_de_run := Mods.appliquer(Tir.de_base(stats), mods_run)
	tir_courant = CatalogueProjectiles.appliquer(ReglagesJoueur.projectile_equipe_effectif(), tir_de_run)
	if "egide" in tir_courant.drapeaux and not _egide_active:
		_egide_active = true
		if not stats.est_mort():
			stats.pv = stats.pv_max
	stats.vitesse = _vitesse_sans_augments * Mods.facteur_heros(mods_run, "deplacement_mult")
	var boucliers_par_salle := int(ArbreCompetences.donne_bouclier(ReglagesJoueur.rangs_competences_effectifs())) \
		+ maxi(0, roundi(Mods.bonus_heros(mods_run, "boucliers_salle_add")))
	# Une nouvelle source accorde sa charge, mais un recalcul ne recharge pas un coup bloque.
	if boucliers_par_salle > _boucliers_accordes:
		bouclier += boucliers_par_salle - _boucliers_accordes
		_boucliers_accordes = boucliers_par_salle

func preparer_nouvelle_salle() -> void:
	if is_instance_valid(_satellites): _satellites.preparer_nouvelle_salle()
	if is_instance_valid(_effets_periodiques): _effets_periodiques.preparer_nouvelle_salle()
	bouclier = 0
	_boucliers_accordes = 0
	_tirs_prepares.clear()
	_rafale_restante = 0
	_elan_mouvement = 0.0
	_elan_chargee = false
	_puissance_attaque_elan = 1.0
	recalculer()
	stats.soin_restant = stats.pv_max * Reglages.SOIN_COMBAT_PAR_SALLE * stats.soin_mult
	var soin := ArbreCompetences.soin_par_salle(ReglagesJoueur.rangs_competences_effectifs()) + Passifs.soin_par_salle(ReglagesJoueur.passifs_equipes_effectifs())
	if soin > 0.0:
		stats.soigner(stats.pv_max * soin)

func _physics_process(delta: float) -> void:
	var terrain := Vector3(0, 0, 1)
	var salle := get_tree().get_first_node_in_group("salle")
	if is_instance_valid(salle): terrain = salle.mouvement_terrain(global_position)
	# Meme une commande legere au joystick permet de remonter le vent. Sans
	# commande, la rafale peut faire deriver le heros sans interrompre son tir.
	var influence_vent := clampf(_intensite,0.0,1.0) if _intention != Vector2.ZERO else 1.0
	var vise := (_intention * _intensite * terrain.z + Vector2(terrain.x, terrain.y) * influence_vent) * stats.vitesse
	var reponse := Reglages.HEROS_ACCELERATION if vise != Vector2.ZERO else Reglages.HEROS_FREINAGE
	velocity = velocity.move_toward(vise, reponse * delta)
	move_and_slide()
	global_position = Geometrie.contraindre_dans_rect(global_position, limites, Reglages.HEROS_RAYON)

func peut_tirer() -> bool:
	# Un ordre de marche interrompt aussi les salves deja preparees. Le vent
	# reste une poussee subie et ne desarme pas un heros sans commande.
	return not stats.est_mort() and (_intention == Vector2.ZERO or _intensite <= 0.0)

func _process(delta: float) -> void:
	if not peut_tirer():
		_tirs_prepares.clear()
		_rafale_restante = 0
	_avancer_tirs_prepares(delta)
	_flottement += delta
	_attaque = maxf(0.0, _attaque - delta)
	var inclinaison_visee := clampf(velocity.x / maxf(1.0, stats.vitesse), -1.0, 1.0) * 0.10
	_inclinaison = lerpf(_inclinaison, inclinaison_visee, minf(1.0, delta * 10.0))
	_secousse = maxf(0.0, _secousse - delta * 4.0)
	_invulnerable = maxf(0.0, _invulnerable - delta)
	_recharge = maxf(0.0, _recharge - delta)
	_temps_depuis_degats += delta
	_elan_objet_restant = maxf(0.0, _elan_objet_restant - delta)
	if _elan_objet_restant <= 0.0:
		_elan_objet_cumuls = 0
	_avancer_rafale(delta)
	var immobile := _intention == Vector2.ZERO
	if not immobile and _intensite > 0.0:
		if "elan_vital" in tir_courant.drapeaux and not _elan_chargee:
			_elan_mouvement += delta
			_elan_chargee = _elan_mouvement >= ReglagesAugments.ELAN_VITAL_CHARGE
	elif not _elan_chargee:
		_elan_mouvement = 0.0
	_temps_immobile = _temps_immobile + delta if immobile else 0.0
	queue_redraw()

	# Le tir automatique est la grammaire du genre : on s'arrete, on tire.
	if not immobile or not peut_tirer():
		return
	if immobile and _temps_immobile < Reglages.TIR_DELAI_ARRET:
		return
	if _recharge > 0.0 or _rafale_restante > 0:
		return
	var positions := cibles_visibles()
	var index := Ciblage.plus_proche(global_position, positions)
	if index == -1:
		return
	var direction := global_position.direction_to(_point_vise(index))
	_visee = direction
	var cadence_effective := cadence_effective_actuelle()
	_recharge = 1.0 / maxf(0.2, cadence_effective)
	if nombre_salves() > 1:
		_rafale_restante = nombre_salves()
		_rafale_minuterie = 0.0
		_rafale_direction = direction
		_avancer_rafale(0.0)
	else:
		_preparer_tir(direction)

func nombre_salves() -> int:
	return tir_courant.salves

func _avancer_rafale(delta: float) -> void:
	if not peut_tirer():
		_rafale_restante = 0
		return
	if _rafale_restante <= 0:
		return
	_rafale_minuterie -= delta
	# Garder tous les tirs lorsque la cadence augmente ou qu'une frame prend du retard.
	var intervalle := minf(Reglages.RAFALE_INTERVALLE,
		1.0 / (maxf(Reglages.MODS_PLANCHER, cadence_effective_actuelle()) * float(nombre_salves())))
	while _rafale_restante > 0 and _rafale_minuterie <= 0.0:
		_rafale_minuterie += intervalle
		_rafale_restante -= 1
		var positions := cibles_visibles()
		var index := Ciblage.plus_proche(global_position, positions)
		if index != -1:
			_rafale_direction = global_position.direction_to(_point_vise(index))
			_visee = _rafale_direction
		_preparer_tir(_rafale_direction, _rafale_restante < nombre_salves() - 1)

func _preparer_tir(direction: Vector2, salve_supplementaire := false) -> void:
	if stats.pv <= 0 or not peut_tirer(): return
	if not salve_supplementaire:
		_puissance_attaque_elan = 1.0
		if "elan_vital" in tir_courant.drapeaux and _elan_chargee:
			_puissance_attaque_elan += ReglagesAugments.ELAN_VITAL_BONUS_DEGATS
			_elan_chargee = false
			_elan_mouvement = 0.0
	var tir := tir_courant.copie()
	# Une charge appartient a l'attaque complete, y compris ses salves suivantes.
	tir.degats *= _puissance_attaque_elan
	_tirs_prepares.append({"reste": Reglages.TIR_PREPARATION, "direction": direction, "tir": tir})
	attaque_preparee.emit(direction)

func _avancer_tirs_prepares(delta: float) -> void:
	if stats.pv <= 0 or not peut_tirer():
		_tirs_prepares.clear()
		return
	var attentes: Array[Dictionary] = []
	var prets: Array[Dictionary] = []
	for preparation: Dictionary in _tirs_prepares:
		preparation["reste"] = float(preparation["reste"]) - delta
		if float(preparation["reste"]) <= 0.000001: prets.append(preparation)
		else: attentes.append(preparation)
	_tirs_prepares = attentes
	for preparation: Dictionary in prets:
		var direction: Vector2 = preparation["direction"]
		var tir: Tir = preparation["tir"]
		Jeu.tirs_emis += 1
		_attaque = 0.18
		tir_demande.emit(tir, global_position, direction)
		Sons.jouer("tir", -20.0, randf_range(0.95, 1.08))

func cibles_visibles() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for noeud in get_tree().get_nodes_in_group("ennemis"):
		if is_instance_valid(noeud):
			positions.append(noeud.global_position)
	return positions

# Viser ou la cible sera, pas ou elle est. Sans cette anticipation, un ennemi
# qui recule en ligne droite n'est presque jamais touche : la sonde a vu un
# scribe survivre deux minutes a trois cents projectiles.
func _point_vise(index: int) -> Vector2:
	var noeuds := get_tree().get_nodes_in_group("ennemis")
	var valides: Array[Node] = []
	for noeud in noeuds:
		if is_instance_valid(noeud):
			valides.append(noeud)
	if index < 0 or index >= valides.size():
		return global_position
	var cible: Node2D = valides[index]
	var vitesse: Vector2 = cible.velocity if "velocity" in cible else Vector2.ZERO
	return Geometrie.point_anticipe(cible.global_position, vitesse,
		global_position, tir_courant.vitesse)

func recevoir_degats(montant: float, _effets: Array = []) -> void:
	if _invulnerable > 0.0 or stats.est_mort():
		return
	var passifs := ReglagesJoueur.passifs_equipes_effectifs()
	var invulnerabilite := Reglages.HEROS_INVULNERABILITE \
		* (1.0 + Mods.bonus_heros(Jeu.mods(), "invulnerabilite_bonus"))
	if bouclier > 0:
		bouclier -= 1
		_invulnerable = invulnerabilite
		bouclier_brise.emit(global_position)
		Sons.jouer("impact", -8.0, 0.7)
		return
	_secousse = 1.0
	var degats_apres_defenses := montant * Mods.facteur_heros(Jeu.mods(), "degats_subis_mult") \
		* (1.0 + Passifs.bonus_audace(passifs)) \
		* (1.0 - ArbreCompetences.reduction_degats(ReglagesJoueur.rangs_competences_effectifs())) \
		* Reglages.DEFENSE_REFERENCE / (Reglages.DEFENSE_REFERENCE + maxf(0.0, stats.defense \
			* Mods.facteur_heros(Jeu.mods(), "defense_mult")))
	stats.blesser(degats_apres_defenses)
	_temps_depuis_degats = 0.0
	_invulnerable = invulnerabilite
	dernier_degat_recu = degats_apres_defenses
	touchee.emit(global_position)
	Sons.jouer("degat", -6.0)
	if stats.est_mort():
		if _courage_vie_disponible and "courageux" in tir_courant.drapeaux:
			_courage_vie_disponible = false
			stats.pv = stats.pv_max
			Sons.jouer("fusion", -7.0)
			return
		if _sursis_disponible and "sursis" in ReglagesJoueur.effets_objets_effectifs():
			_sursis_disponible = false
			stats.pv = EffetsBijoux.SURSIS_PV
			Sons.jouer("fusion", -7.0)
			return
		morte.emit()

func cadence_effective_actuelle() -> float:
	return tir_courant.cadence

func attaque_reelle() -> float:
	return BonusAttaque.attaque(stats, Jeu.mods())

func enregistrer_attaque_objet() -> void:
	if "elan_offensif" not in ReglagesJoueur.effets_objets_effectifs():
		return
	_elan_objet_cumuls = mini(EffetsBijoux.ELAN_CUMULS_MAX, _elan_objet_cumuls + 1)
	_elan_objet_restant = EffetsBijoux.ELAN_DUREE

func bonus_degats_passifs() -> float:
	var passifs := ReglagesJoueur.passifs_equipes_effectifs()
	var bonus := Passifs.bonus_audace(passifs)
	if passifs.has("rempart_initial") and _temps_depuis_degats >= Passifs.REPRISE_DELAI:
		bonus += Passifs.bonus_reprise(passifs)
	bonus += float(_elan_objet_cumuls) * EffetsBijoux.ELAN_BONUS_PAR_ATTAQUE
	return bonus

func degats_finaux(montant: float, source := "baguette", critique_autorise := true) -> float:
	var resultat := montant
	dernier_critique = false
	if critique_autorise and Jeu.rng.randf() < stats.critique:
		resultat *= Reglages.CRITIQUE_MULT_BASE + stats.degats_critiques
		dernier_critique = true
	resultat *= Personnage.multiplicateur_source(ReglagesJoueur.specialisation_effective(), source)
	resultat *= 1.0 + bonus_degats_passifs()
	resultat *= ReglagesJoueur.multiplicateur_coeurs_mana()
	return resultat

func _draw() -> void:
	if has_meta("visuel_3d"):
		if bouclier > 0:
			draw_arc(Vector2.ZERO, Reglages.HEROS_RAYON * 1.2, 0.0, TAU, 32, Palette.ESSENCE, 2.0, true)
		_dessiner_vie()
		return
	var r := Reglages.HEROS_RAYON
	var flotte := sin(_flottement * 2.6) * 3.0
	var tremble := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _secousse * 5.0
	var centre := Vector2(0, flotte) + tremble
	var vers := _visee
	var teinte := Palette.teinte_du_tir(tir_courant.effets if tir_courant != null else [])
	var vitesse_relative := clampf(velocity.length() / maxf(1.0, stats.vitesse), 0.0, 1.0)

	# Ombre portee : ancre la silhouette au sol, sinon elle flotte sans poids.
	draw_set_transform(Vector2(0, r * 0.85), 0.0, Vector2(1.0, 0.40))
	draw_circle(Vector2.ZERO, r * 1.05, Color(0, 0, 0, 0.26))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if _invulnerable > 0.0 and fmod(_invulnerable, 0.16) > 0.08:
		Dessin.halo(self, centre, r * 2.2, Palette.DANGER, 4)

	# Lueur du reactif en main : c'est la couleur de ce que le joueur a construit.
	Dessin.halo(self, centre + vers * r * 0.5, r * 2.4, Color(teinte, 0.9), 5)

	# Une compression tres legere et l'inclinaison donnent du poids aux changements
	# de direction sans deplacer la collision ni ralentir la commande.
	var echelle := Vector2(1.0 + vitesse_relative * 0.035, 1.0 - vitesse_relative * 0.025)
	draw_set_transform(centre + Vector2(0, vitesse_relative * 3.0), _inclinaison, echelle)
	Retro16.dessiner_heros(self, _flottement, _attaque > 0.0, vers, teinte)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# La couleur du tir reste visible au niveau de la fiole, meme si le sprite
	# est fixe : le joueur lit immediatement l'element equipe.
	var fiole := centre + Vector2(r * 0.72, -r * 0.08)
	Dessin.halo(self, fiole, r * 0.48, Color(teinte, 0.65), 3)
	draw_circle(fiole, r * 0.10, Color(teinte, 0.92))

	if bouclier > 0:
		var anneau := Dessin.polygone_regulier(centre, r * 1.65, 6, _flottement * 0.8)
		Dessin.contour(self, anneau, Color(0.88, 0.94, 1.0, 0.8), 3.5)
		Dessin.halo(self, centre, r * 2.0, Color(0.70, 0.85, 1.0, 0.55), 3)

	# La vie suit le mage : l'oeil ne quitte plus le combat pour lire le haut.
	_dessiner_vie()

func _dessiner_vie() -> void:
	var part := clampf(stats.pv/maxf(1.0,stats.pv_max),0.0,1.0)
	var hauteur := -133.0
	if has_meta("visuel_3d"):
		hauteur = -Visuels3D.HEROS_BARRE_VIE_HAUTEUR * Reglages.HEROS_ECHELLE - Visuels3D.HEROS_BARRE_VIE_MARGE
	_vie_retard = maxf(part, move_toward(_vie_retard, part, get_process_delta_time() * 0.7))
	var barre := Rect2(-74, hauteur - 4.0, 148, 24)
	# Vert, ambre puis rubis : la couleur suffit a lire le danger.
	var teinte := Color("7dffb0").lerp(Color("ffd25e"), clampf((0.75 - part) / 0.4, 0.0, 1.0))
	teinte = teinte.lerp(Color("ff5d6c"), clampf((0.4 - part) / 0.25, 0.0, 1.0))
	DessinJeu.jauge(self, barre, part, teinte.lightened(0.2), teinte.darkened(0.3), _vie_retard)
	for i in mini(bouclier, 4):
		DessinJeu.pastille(self, Vector2(barre.end.x + 14.0 + float(i) * 22.0, barre.get_center().y), 11.0, "azur")
