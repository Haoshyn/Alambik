extends Node2D

# Une salle est une arene fermee a plusieurs vagues. Les compositions sont des donnees
# (data/vagues.gd), jamais
# du code.

signal terminee
signal ennemi_abattu(experience: int)
signal experience_ramassee(experience: int, fin_run: bool)

const PROJECTILE := preload("res://scenes/projectile.tscn")
const ENNEMI := preload("res://scenes/ennemi.tscn")
const BOSS := preload("res://scenes/boss.tscn")
const PLANCHE_OBSTACLES := preload("res://assets/visual/obstacles.png")
const PORTAIL_PREMIUM := preload("res://assets/visual/portail_sortie_premium.png")
const RECTS_OBSTACLES := [
	Rect2(79, 317, 546, 248),
	Rect2(707, 266, 498, 300),
	Rect2(1297, 302, 494, 259),
]

var effets: Node2D
var limites := Rect2()
var numero := 1

var _vagues: Array = []
var _vague_courante := -1
var _alea_elites := RandomNumberGenerator.new()
var _finie := false
var _portail_ouvert := false
var _portail: Area2D
var _obstacles: Array[Rect2] = []
var _types_obstacles := {}
var _retraits: Array[Rect2] = []
var _contour := PackedVector2Array()
var _anim := 0.0
var _attente_vague := 0.0
var _mine_active := false
var _mine_temps := 0.0
var _mine_prochain_spawn := 0.0
var _mine_boss_apparu := false
var _terrain: Node2D
var _budgets_experience: Array[int] = []
var _experience_au_sol := 0
var _depots_experience: Node2D
var _collecte_en_cours := false
var _collecte_mine: Node2D

func _ready() -> void:
	add_to_group("salle")

func obstacles() -> Array[Rect2]:
	return _obstacles

func portail_ouvert() -> bool:
	return _portail_ouvert

func position_portail() -> Vector2:
	return Vector2(limites.get_center().x, limites.position.y + 180.0)

func demarrer(numero_: int, limites_: Rect2) -> void:
	numero = numero_
	limites = limites_
	_vagues = Vagues.pour_salle(numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run)
	_budgets_experience = Vagues.budgets_experience(numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run)
	_experience_au_sol = 0
	_collecte_en_cours = false
	_collecte_mine = null
	_depots_experience = preload("res://scripts/presentation/experience_sol.gd").new()
	add_child(_depots_experience)
	_vague_courante = -1
	_alea_elites.seed = Jeu.graine + Jeu.chapitre * 104729 + numero * 7919
	_finie = false
	_portail_ouvert = false
	_portail = null
	_mine_active = false
	_mine_temps = 0.0
	_mine_prochain_spawn = 0.0
	_mine_boss_apparu = false
	_construire_obstacles()
	if is_instance_valid(_terrain):
		_terrain.set_physics_process(false)
		_terrain.queue_free()
	_terrain = preload("res://scripts/terrain_elementaire.gd").new()
	add_child(_terrain)
	_terrain.configurer(self)
	if Jeu.mode_run == "mine":
		_demarrer_mine()
		return
	if _vagues.is_empty():
		_finie = true
		terminee.emit()
		return
	_vague_suivante()

func _construire_obstacles() -> void:
	for enfant in get_children():
		if enfant is StaticBody2D:
			enfant.queue_free()
	_obstacles.clear()
	_types_obstacles.clear()
	_retraits.clear()
	_contour = FormesSalles.contour(limites, FormesSalles.indice(numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run))
	var combat_de_boss := Jeu.mode_run == "grimoire" and Chapitres.est_boss(Jeu.chapitre, numero) \
		or Jeu.mode_run == "epreuve_sorts"
	if combat_de_boss or _vagues.is_empty() and Jeu.mode_run != "mine":
		_construire_murs_perimetre()
		return
	if Jeu.mode_run == "grimoire":
		_construire_murs_perimetre()
		for definition: Dictionary in TerrainsMondes.obstacles(numero, Jeu.chapitre):
			var bloc: Rect2 = definition["rect"]
			_ajouter_obstacle(Rect2(limites.position + bloc.position * limites.size, bloc.size * limites.size), str(definition["type"]))
		return
	var motif := posmod(Jeu.graine+numero+Jeu.chapitre,Reglages.ARENE_COMPOSITIONS.size())
	for retrait: Rect2 in Reglages.ARENE_RETRAITS[motif]:
		# La Mine fait apparaitre ses ennemis le long des quatre bords.
		if Jeu.mode_run == "mine" or FormesSalles.indice(numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run) != 0: break
		var rect := Rect2(limites.position+retrait.position*limites.size,retrait.size*limites.size)
		_retraits.append(rect)
		_ajouter_obstacle(rect)
	if not _retraits.is_empty():
		_contour = _contour_avec_retraits()
	_construire_murs_perimetre()
	for bloc: Rect2 in Reglages.ARENE_COMPOSITIONS[motif]:
		_ajouter_obstacle(Rect2(limites.position+bloc.position*limites.size,bloc.size*limites.size))

func terrain_elementaire() -> Node2D:
	return _terrain if is_instance_valid(_terrain) and not _terrain.is_queued_for_deletion() else null

func mouvement_terrain(position_heros: Vector2, direction_voulue := Vector2.ZERO) -> Vector3:
	var terrain := terrain_elementaire()
	return terrain.mouvement(position_heros, direction_voulue) if terrain != null else Vector3(0, 0, 1)

func tir_bloque_par_terrain(position_heros: Vector2) -> bool:
	var terrain := terrain_elementaire()
	return terrain != null and terrain.tir_bloque(position_heros)

func retraits() -> Array[Rect2]:
	return _retraits

func contour_sol() -> PackedVector2Array:
	return _contour

func _contour_avec_retraits() -> PackedVector2Array:
	var points := PackedVector2Array([limites.position])
	var gauche: Array[Rect2] = []
	var droite: Array[Rect2] = []
	for rect in _retraits:
		if is_equal_approx(rect.position.x,limites.position.x): gauche.append(rect)
		else: droite.append(rect)
	gauche.sort_custom(func(a: Rect2,b: Rect2): return a.position.y < b.position.y)
	droite.sort_custom(func(a: Rect2,b: Rect2): return a.position.y > b.position.y)
	for rect in gauche:
		points.append(rect.position)
		points.append(Vector2(rect.end.x,rect.position.y))
		points.append(rect.end)
		points.append(Vector2(rect.position.x,rect.end.y))
	points.append(Vector2(limites.position.x,limites.end.y))
	points.append(limites.end)
	for rect in droite:
		points.append(rect.end)
		points.append(Vector2(rect.position.x,rect.end.y))
		points.append(rect.position)
		points.append(Vector2(rect.end.x,rect.position.y))
	points.append(Vector2(limites.end.x,limites.position.y))
	return points

func type_obstacle(rect: Rect2) -> String:
	return str(_types_obstacles.get(rect, "muret"))

func _ajouter_obstacle(rect: Rect2, type := "muret") -> void:
	_obstacles.append(rect)
	_types_obstacles[rect] = type
	var corps := StaticBody2D.new()
	corps.collision_layer = 4
	corps.collision_mask = 0
	corps.position = rect.get_center()
	var forme := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect.size
	forme.shape = rectangle
	corps.add_child(forme)
	add_child(corps)

func _construire_murs_perimetre() -> void:
	var e := Reglages.ARENE_MUR_EPAISSEUR
	var aire := 0.0
	for i in _contour.size():
		aire += _contour[i].cross(_contour[(i+1)%_contour.size()])
	for i in _contour.size():
		var a := _contour[i]
		var b := _contour[(i+1)%_contour.size()]
		var direction := b-a
		if direction.length_squared() < 0.01: continue
		var dehors := Vector2(direction.y, -direction.x).normalized() * signf(aire)
		var corps := StaticBody2D.new()
		corps.name = "MurPerimetre"
		corps.collision_layer = 4
		corps.collision_mask = 0
		var forme := CollisionPolygon2D.new()
		forme.polygon = PackedVector2Array([a, b, b+dehors*e, a+dehors*e])
		corps.add_child(forme)
		add_child(corps)

func _process(delta: float) -> void:
	_anim += delta
	queue_redraw()
	if _mine_active:
		_avancer_mine(delta)
		return
	if _attente_vague > 0.0:
		_attente_vague -= delta
		if _attente_vague <= 0.0:
			_vague_suivante()

func _demarrer_mine() -> void:
	_mine_active = true
	_collecte_mine = preload("res://scripts/collecte_experience.gd").new()
	_collecte_mine.configurer(get_tree().get_first_node_in_group("heros"), _depots_experience, self)
	_collecte_mine.ramassee.connect(func(experience: int) -> void:
		if _mine_active and not _finie:
			experience_ramassee.emit(experience, false))
	add_child(_collecte_mine)
	Jeu.temps_mine_restant = Reglages.MINE_DUREE
	# Quelques adversaires installent immediatement la boucle de combat, sans
	# transformer le depart en mur compact.
	for i in Reglages.MINE_PLAFOND_DEBUT:
		faire_apparaitre(Vagues.ennemi_mine(Jeu.rng, 0.0), _position_d_apparition())
	_mine_prochain_spawn = Reglages.MINE_INTERVALLE_DEBUT

func _avancer_mine(delta: float) -> void:
	_mine_temps = minf(Reglages.MINE_DUREE, _mine_temps + delta)
	Jeu.temps_mine_restant = maxf(0.0, Reglages.MINE_DUREE - _mine_temps)
	var progression := clampf(_mine_temps / Reglages.MINE_DUREE, 0.0, 1.0)
	if _mine_temps >= Reglages.MINE_DUREE and not _mine_boss_apparu:
		_apparaitre_boss_mine()
	_mine_prochain_spawn -= delta
	if _mine_prochain_spawn > 0.0:
		return
	var plafond := _plafond_mine()
	if get_tree().get_nodes_in_group("ennemis").size() < plafond:
		faire_apparaitre(Vagues.ennemi_mine(Jeu.rng, progression), _position_d_apparition())
	_mine_prochain_spawn = lerpf(Reglages.MINE_INTERVALLE_DEBUT,
		Reglages.MINE_INTERVALLE_FIN, progression)

func _apparaitre_boss_mine() -> void:
	if _mine_boss_apparu:
		return
	Jeu.temps_mine_restant = 0.0
	_mine_boss_apparu = true
	var id := Vagues.boss_mine(Jeu.graine)
	faire_apparaitre(id,
		Vector2(limites.get_center().x, limites.position.y + 180.0))
	if Jeu.mode_auto:
		print("mine : boss final %s" % id)
	Sons.musique_boss()

func _vague_suivante() -> void:
	# Une vague entiere attend sa place : le retard ne deborde pas le plafond.
	var suivante := _vague_courante + 1
	if suivante < _vagues.size():
		var a_venir: Array = _vagues[suivante]
		if get_tree().get_nodes_in_group("ennemis").size() + a_venir.size() > Vagues.plafond_salle(numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run):
			_attente_vague = Reglages.DELAI_VAGUE_SATUREE
			return
	_vague_courante += 1
	if _vague_courante >= _vagues.size():
		_attente_vague = -1.0
		if get_tree().get_nodes_in_group("ennemis").is_empty():
			_ouvrir_portail()
		return
	var vague: Array = _vagues[_vague_courante]
	var index_elite := -1
	if Jeu.mode_run == "grimoire" and Jeu.chapitre >= RangsEnnemis.PREMIER_CHAPITRE_ELITES \
			and numero >= RangsEnnemis.PREMIERE_SALLE_ELITES \
			and not Chapitres.est_boss(Jeu.chapitre, numero) and get_tree().get_nodes_in_group("elites").is_empty():
		if not vague.is_empty() and _alea_elites.randf() < RangsEnnemis.CHANCE_ELITE_PAR_VAGUE:
			index_elite = _alea_elites.randi_range(0, vague.size() - 1)
	for i in vague.size():
		var budget := _budgets_experience[_vague_courante]
		var experience := floori(float(budget * (i + 1)) / vague.size()) - floori(float(budget * i) / vague.size())
		faire_apparaitre(str(vague[i]), _position_d_apparition(), null, i == index_elite, experience)
	_attente_vague = Reglages.DELAI_VAGUE_FORCE + maxi(0, vague.size() - Vagues.EFFECTIF_REFERENCE_DELAI) * Reglages.DELAI_VAGUE_PAR_RENFORT \
		if _vague_courante < _vagues.size() - 1 else -1.0

func _ouvrir_portail() -> void:
	if _finie or _portail_ouvert or _collecte_en_cours:
		return
	_attente_vague = -1.0
	if is_instance_valid(_terrain): _terrain.set_physics_process(false)
	if Jeu.mode_run == "mine":
		_mine_active = false
		_collecte_mine.set_physics_process(false)
		_nettoyer_dangers()
	else:
		await _ramasser_experience(numero >= Jeu.salles_du_chapitre())
	if not is_inside_tree(): return
	Jeu.marquer_salle_terminee(numero)
	if numero >= Jeu.salles_du_chapitre() or Jeu.mode_run == "epreuve_sorts":
		_finie = true
		terminee.emit()
		return
	_portail_ouvert = true
	if Jeu.mode_auto:
		print("salle %d nettoyee : portail ouvert" % numero)
	_portail = Area2D.new()
	_portail.name = "PortailSortie"
	_portail.collision_layer = 0
	_portail.collision_mask = 1
	_portail.global_position = position_portail()
	var collision := CollisionShape2D.new()
	var cercle := CircleShape2D.new()
	cercle.radius = Reglages.PORTAIL_RAYON
	collision.shape = cercle
	_portail.add_child(collision)
	_portail.body_entered.connect(_sur_corps_dans_portail)
	add_child(_portail)
	if effets != null:
		effets.onde(position_portail(), 180.0, Palette.OR, 0.35)
	Sons.jouer("portail", -14.0, 1.1)
	queue_redraw()

func _sur_corps_dans_portail(corps: Node) -> void:
	if _finie or not corps.is_in_group("heros"):
		return
	_finie = true
	terminee.emit()

func faire_apparaitre(id: String, position: Vector2, invocateur: Node = null, elite := false, experience := -1) -> void:
	var donnees: Dictionary = CatalogueEnnemis.par_id(id)
	if donnees.is_empty():
		push_error("Ennemi inconnu : " + id)
		return
	donnees = _mis_a_l_echelle(donnees, id)
	if elite and invocateur == null and str(donnees["cerveau"]) != "boss":
		donnees = RangsEnnemis.renforcer(donnees)
		donnees["incendiaire"] = _alea_elites.randf() < RangsEnnemis.CHANCE_ELITE_INCENDIAIRE
	if experience >= 0: donnees["experience"] = experience
	var noeud: Node2D
	if donnees["cerveau"] == "boss":
		noeud = BOSS.instantiate()
	else:
		noeud = ENNEMI.instantiate()
	if is_instance_valid(invocateur):
		donnees["pv"] = float(donnees["pv"]) * Reglages.INVOCATION_PV_MULT
		donnees["degats"] = float(donnees["degats"]) * Reglages.INVOCATION_DEGATS_MULT
		donnees["experience"] = 0
		noeud.set_meta("invocateur", invocateur.get_instance_id())
		if invocateur.is_in_group("boss"): noeud.add_to_group("invocations_boss")
	noeud.configurer(donnees)
	noeud.limites = limites
	noeud.global_position = position
	noeud.mort.connect(_sur_mort_ennemi)
	noeud.tir_demande.connect(_sur_tir_ennemi)
	noeud.invocation_demandee.connect(_sur_invocation.bind(noeud))
	noeud.touche.connect(_sur_ennemi_touche)
	noeud.zone_demandee.connect(_sur_zone_demandee)
	add_child(noeud)
	if effets != null:
		effets.apparition(noeud.global_position, donnees["couleur"], donnees["rayon"],
			donnees["cerveau"] == "boss")

# La creature d'une salle avancee est plus lourde que celle d'une salle 5, et celle du
# troisieme chapitre plus que celle du premier. Le catalogue reste la reference :
# on n'y touche pas, on met a l'echelle une copie.
func _mis_a_l_echelle(donnees: Dictionary, id: String) -> Dictionary:
	var chapitre_patterns := Jeu.chapitre if Jeu.mode_run == "grimoire" else (Epreuves.palier(Jeu.niveau_epreuve) if Jeu.mode_run == "epreuve_sorts" else ReglagesJoueur.palier_atteint())
	donnees = BestiaireMondes.appliquer(donnees, id, chapitre_patterns)
	var copie := donnees.duplicate(true)
	copie["id"] = id
	if Jeu.mode_run == "epreuve_sorts":
		var progression_defi := clampf(float(numero - 1) / 4.0, 0.0, 1.0)
		var palier_defi := Epreuves.palier(Jeu.niveau_epreuve)
		copie["pv"] = float(donnees["pv"]) * Reglages.facteur_annexe_pv(palier_defi) \
			* Reglages.DEFI_PV_BASE * pow(1.0 + Reglages.DEFI_MONTEE_PV, progression_defi)
		copie["degats"] = float(donnees["degats"]) * Reglages.facteur_annexe_degats(palier_defi) \
			* Reglages.DEFI_DEGATS_BASE * pow(1.0 + Reglages.DEFI_MONTEE_DEGATS, progression_defi)
	elif Jeu.mode_run == "mine":
		var progression_mine := clampf(_mine_temps / Reglages.MINE_DUREE, 0.0, 1.0)
		var palier_mine := ReglagesJoueur.palier_atteint()
		copie["pv"] = float(donnees["pv"]) * Reglages.facteur_annexe_pv(palier_mine) \
			* Reglages.MINE_PV_MULT * pow(1.0 + Reglages.MINE_MONTEE_PV, progression_mine)
		copie["degats"] = float(donnees["degats"]) * Reglages.facteur_annexe_degats(palier_mine) \
			* Reglages.MINE_DEGATS_MULT * pow(1.0 + Reglages.MINE_MONTEE_DEGATS, progression_mine)
		if donnees["cerveau"] == "boss":
			copie["pv"] *= Reglages.MINE_BOSS_PV_MULT
			copie["degats"] *= Reglages.MINE_BOSS_DEGATS_MULT
	else:
		copie["pv"] = float(donnees["pv"]) * Chapitres.facteur_pv(Jeu.chapitre, numero)
		copie["degats"] = float(donnees["degats"]) * Chapitres.facteur_degats(Jeu.chapitre, numero)
		if donnees["cerveau"] == "boss":
			var signature := str(donnees.get("rang_boss", "miniboss")) == "signature"
			copie["pv"] *= Reglages.BOSS_SIGNATURE_PV_MULT if signature \
				else ProgressionStatistiques.facteur_miniboss(Chapitres.palier(Jeu.chapitre))
			copie["degats"] *= Reglages.BOSS_SIGNATURE_DEGATS_MULT if signature else Reglages.MINIBOSS_DEGATS_MULT
	# Les differences de robustesse viennent du catalogue, puis du palier fixe.
	if donnees["cerveau"] != "boss":
		copie["degats"] = float(copie["degats"]) * Reglages.ENNEMI_DEGATS_MULT
		if copie.has("vitesse_projectile"):
			copie["vitesse_projectile"] = float(copie["vitesse_projectile"]) * Reglages.ENNEMI_PROJECTILE_VITESSE_MULT
		if copie.has("recharge"):
			copie["recharge"] = float(copie["recharge"]) * Reglages.ENNEMI_RECHARGE_MULT
	copie = EvolutionEnnemis.appliquer(copie,chapitre_patterns)
	if donnees["cerveau"] == "boss" and Jeu.mode_run != "grimoire":
		copie["pv"] = float(copie["pv"])*EvolutionEnnemis.ANNEXE_PV_BOSS
	if donnees["cerveau"] == "boss":
		copie["pv"] = float(copie["pv"]) * Reglages.BOSS_ENDURANCE_MULT
	return copie

func _sur_ennemi_touche(position: Vector2, couleur: Color) -> void:
	if effets != null:
		effets.eclats(position, couleur.lightened(0.3), 3, 140.0, 0.5)

func _sur_mort_ennemi(qui: Node, position: Vector2, couleur: Color) -> void:
	if _finie: return
	if qui.is_in_group("boss"):
		Jeu.marquer_boss_vaincu(numero)
		# Les renforts ne prolongent pas artificiellement la rencontre terminee.
		for renfort in get_tree().get_nodes_in_group("ennemis"):
			if int(renfort.get_meta("invocateur", 0)) == qui.get_instance_id():
				renfort.remove_from_group("ennemis")
				renfort.queue_free()
	if not qui.has_meta("invocateur"):
		if bool(qui.donnees.get("elite", false)):
			Jeu.elites_par_salle[numero] = int(Jeu.elites_par_salle.get(numero, 0)) + 1
		Jeu.ennemis_abattus += 1
		var experience := int(qui.donnees.get("experience", 0))
		if Jeu.mode_run == "mine":
			_collecte_mine.deposer(position, experience)
		else:
			_experience_au_sol += experience
			_depots_experience.deposer(position)
		ennemi_abattu.emit(int(qui.donnees.get("experience", 1)))
	if effets != null:
		effets.mort(position, couleur)
	if Jeu.mode_run == "mine":
		if qui.is_in_group("boss"):
			# La victoire depend du boss, pas du nettoyage d'une horde continue.
			_mine_active = false
			for survivant in get_tree().get_nodes_in_group("ennemis"):
				survivant.set_physics_process(false)
				survivant.remove_from_group("ennemis")
				survivant.queue_free()
			_ouvrir_portail()
		return
	# Le noeud mort est encore dans l'arbre a cet instant : on attend une frame
	# avant de compter, sinon la vague ne se termine jamais.
	await get_tree().process_frame
	if _finie or not is_inside_tree():
		return
	if get_tree().get_nodes_in_group("ennemis").is_empty():
		if Jeu.mode_auto:
			print("derniere creature retiree salle %d vague %d/%d" % [numero,
				_vague_courante + 1, _vagues.size()])
		if _vague_courante < _vagues.size() - 1:
			_attente_vague = Reglages.DELAI_VAGUE_NETTOYEE
		else:
			_ouvrir_portail()

func _sur_invocation(id: String, position: Vector2, invocateur: Node = null) -> void:
	if _collecte_en_cours or _portail_ouvert or _finie: return
	if Jeu.mode_run != "mine" and get_tree().get_nodes_in_group("ennemis").size() >= Vagues.plafond_salle(numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run): return
	if Jeu.mode_run == "mine" and get_tree().get_nodes_in_group("ennemis").size() >= _plafond_mine():
		return
	var p := position
	p.x = clampf(p.x, limites.position.x, limites.end.x)
	p.y = clampf(p.y, limites.position.y, limites.end.y)
	if not _place_libre(p):
		p = _position_d_apparition()
	faire_apparaitre(id, p, invocateur)

func _nettoyer_dangers() -> void:
	for groupe in ["tirs_ennemis", "zones_hostiles"]:
		for danger in get_tree().get_nodes_in_group(groupe):
			danger.set_physics_process(false)
			danger.queue_free()

func _ramasser_experience(fin_run := false) -> void:
	_collecte_en_cours = true
	_nettoyer_dangers()
	var heros := get_tree().get_first_node_in_group("heros") as Node2D
	_depots_experience.ramasser(heros)
	await get_tree().create_timer(Reglages.XP_RAMASSAGE_DUREE, false).timeout
	var experience := _experience_au_sol
	_experience_au_sol = 0
	experience_ramassee.emit(experience, fin_run)
	_collecte_en_cours = false

func _sur_zone_demandee(point: Vector2, origine: Vector2, profil: Dictionary, degats: float) -> void:
	if _collecte_en_cours or _portail_ouvert or _finie: return
	if get_tree().get_nodes_in_group("zones_hostiles").size() >= BestiaireMondes.ZONES_PLAFOND: return
	var zone := preload("res://scripts/zone_hostile.gd").new()
	zone.profil = profil.duplicate(true)
	zone.degats = degats
	zone.origine = origine
	zone.position = Geometrie.contraindre_dans_rect(point, limites, 0.0)
	add_child(zone)

func _plafond_mine() -> int:
	var progression := clampf(_mine_temps / Reglages.MINE_DUREE, 0.0, 1.0)
	return roundi(lerpf(float(Reglages.MINE_PLAFOND_DEBUT),
		float(Reglages.MINE_PLAFOND_FIN), progression))

func _position_d_apparition() -> Vector2:
	var marge := 120.0
	if Jeu.mode_run == "mine":
		var cote := Jeu.rng.randi_range(0, 3)
		match cote:
			0: return Vector2(Jeu.rng.randf_range(limites.position.x + marge, limites.end.x - marge), limites.position.y + marge)
			1: return Vector2(Jeu.rng.randf_range(limites.position.x + marge, limites.end.x - marge), limites.end.y - marge)
			2: return Vector2(limites.position.x + marge, Jeu.rng.randf_range(limites.position.y + marge, limites.end.y - marge))
			_: return Vector2(limites.end.x - marge, Jeu.rng.randf_range(limites.position.y + marge, limites.end.y - marge))
	var candidate := Vector2.ZERO
	# Un ennemi apparu dans un bloc d'encre est intouchable : les projectiles
	# heurtent le bloc avant lui, et la salle ne se vide jamais.
	for essai in 12:
		candidate = Vector2(
			Jeu.rng.randf_range(limites.position.x + marge, limites.end.x - marge),
			Jeu.rng.randf_range(limites.position.y + marge, limites.position.y + limites.size.y * 0.45))
		if _place_libre(candidate):
			return candidate
	# Le pied du portail reste degage dans toutes les compositions.
	return position_portail()

func _place_libre(position: Vector2) -> bool:
	if not FormesSalles.contient_disque(position, _contour, FormesSalles.MARGE_APPARITION):
		return false
	for rect in _obstacles:
		if rect.grow(70.0).has_point(position):
			return false
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if is_instance_valid(ennemi) and ennemi.global_position.distance_to(position) < FormesSalles.MARGE_APPARITION + float(ennemi.donnees["rayon"]):
			return false
	return true

# Certains motifs de boss naissent volontairement depuis les bords de l'arene.
# Avec un projectile de rayon 10, une origine a 6 ou 8 px du bord chevauchait le
# MurPerimetre et le tir mourait avant d'exister. On replace seulement le point
# de depart ; la trajectoire garde ensuite toutes ses collisions normales.
func _origine_projectile_hostile(origine: Vector2, direction: Vector2) -> Vector2:
	var marge := Reglages.TIR_RAYON + 4.0
	var zone := limites.grow(-marge)
	var resultat := Vector2(clampf(origine.x, zone.position.x, zone.end.x),
		clampf(origine.y, zone.position.y, zone.end.y))
	var avance := direction.normalized()
	if avance == Vector2.ZERO:
		avance = Vector2.DOWN
	for _essai in 16:
		var bloque := false
		for rect in _obstacles:
			if rect.grow(marge).has_point(resultat):
				bloque = true
				break
		if not bloque:
			return resultat
		resultat += avance * (marge * 2.0)
		resultat.x = clampf(resultat.x, zone.position.x, zone.end.x)
		resultat.y = clampf(resultat.y, zone.position.y, zone.end.y)
	return resultat

func tirer(tir_source: Tir, origine: Vector2, direction: Vector2, hostile := false,
		cible_exclue := 0) -> void:
	var angles := tir_source.angles()
	var decalages := tir_source.decalages()
	for i in angles.size():
		var p := PROJECTILE.instantiate()
		p.tir = tir_source.copie()
		# Le premier trait porte l'attaque complete. Les traits simultanes suivants
		# gardent la couverture et les effets, sans multiplier gratuitement le
		# monocible. Les tirs hostiles conservent leur budget propre par projectile.
		if not hostile and i > 0:
			p.tir.degats *= tir_source.degats_projectiles_supplementaires
			p.tir.drapeaux.append("trait_supplementaire")
		p.hostile = hostile
		p.cible_exclue = cible_exclue
		var direction_projectile := direction.rotated(angles[i])
		var origine_projectile := origine + direction.orthogonal() * decalages[i]
		if hostile:
			origine_projectile = _origine_projectile_hostile(origine_projectile, direction_projectile)
		p.direction = direction_projectile
		p.global_position = origine_projectile
		p.fragments_demandes.connect(_sur_fragments)
		p.impact_visuel.connect(_sur_impact)
		add_child(p)

func _sur_tir_ennemi(tir_ennemi: Tir, origine: Vector2, direction: Vector2) -> void:
	var projectile := tir_ennemi.copie()
	tirer(projectile, origine, direction, true)

func _sur_impact(position: Vector2, couleur: Color, ampleur: float) -> void:
	if effets != null:
		effets.impact(position, couleur, ampleur)

func _sur_fragments(origine: Vector2, direction: Vector2, tir_source: Tir, hostile: bool,
		cible_exclue: int) -> void:
	# Un fragment ne se refragmente pas : sinon un seul tir peut saturer la scene.
	var eclat := tir_source.copie()
	eclat.fragments = 0
	eclat.rebonds = 0
	eclat.perforations = 0
	eclat.nb_projectiles = 1
	eclat.angle_eventail = 0.0
	eclat.degats = tir_source.degats * Reglages.FRAGMENT_PART_DEGATS
	eclat.portee = Reglages.FRAGMENT_PORTEE
	eclat.drapeaux.append("fragment")
	# Le signal part d'un contact physique : ajouter des Area2D pendant que le
	# moteur vide ses collisions produit une erreur et une saccade visible.
	call_deferred("_tirer_fragments", eclat, tir_source.fragments, origine, direction, hostile,
		cible_exclue)

func _tirer_fragments(eclat: Tir, nombre: int, origine: Vector2, direction: Vector2, hostile: bool,
		cible_exclue: int) -> void:
	if not is_inside_tree():
		return
	for i in nombre:
		var angle := TAU * float(i) / float(nombre) + randf() * 0.3
		tirer(eclat, origine, direction.rotated(angle), hostile, cible_exclue)

func _draw() -> void:
	if has_meta("visuel_3d"):
		return
	# Le fond de l'arene est dessine par le noeud Fond ; ici on ne dessine que ce
	# qui doit passer par-dessus.
	for index in _obstacles.size():
		var rect: Rect2 = _obstacles[index]
		_dessiner_obstacle_peint(rect, (numero + index) % 3)
	if _portail_ouvert:
		_dessiner_portail()

func _dessiner_portail() -> void:
	var centre := position_portail()
	var pulsation := 1.0 + sin(_anim * 3.6) * 0.025
	Dessin.halo(self, centre + Vector2(0, -18), 165.0 * pulsation, Color(Palette.ESSENCE, 0.58), 7)
	var taille := Vector2(350, 350) * pulsation
	var destination := Rect2(centre + Vector2(-taille.x * 0.5, -taille.y * 0.55), taille)
	draw_texture_rect(PORTAIL_PREMIUM, destination, false)
	for i in 8:
		var a := _anim * (0.55 + i * 0.025) + float(i) * TAU / 8.0
		var p := centre + Vector2(cos(a) * 112.0, sin(a) * 92.0 - 22.0)
		draw_circle(Retro16.pixel(p), 3.0 + float(i % 2) * 2.0, Color(Palette.TEXTE, 0.72))
	var police := ThemeDB.fallback_font
	draw_string(police, centre + Vector2(-105, 158), "SORTIE", HORIZONTAL_ALIGNMENT_CENTER, 210, 23, Palette.TEXTE)

func _dessiner_obstacle_peint(rect: Rect2, type: int) -> void:
	var source: Rect2 = RECTS_OBSTACLES[type]
	# L'image depasse legerement la collision vers le haut, comme un vrai objet
	# vu en trois-quarts, mais sa base correspond exactement a l'obstacle.
	var largeur := rect.size.x / 0.76 * 1.08
	var hauteur := largeur * source.size.y / source.size.x
	var destination := Rect2(rect.get_center().x - largeur * 0.5,
		rect.end.y - hauteur, largeur, hauteur)
	draw_texture_rect_region(PLANCHE_OBSTACLES, destination, source)
