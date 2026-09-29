extends SceneTree

class CibleTest extends CharacterBody2D:
	var coups := 0
	func recevoir_degats(_montant: float, _effets: Array = []) -> void: coups += 1

var _erreurs: Array[String] = []
var _controles := 0
var _jeu: Node
var _salle: Node2D
var _cible: CibleTest

func _init() -> void:
	call_deferred("_executer")

func _verifier(condition: bool, message: String) -> void:
	_controles += 1
	if not condition and message not in _erreurs: _erreurs.append(message)

func _executer() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Profil APPDATA isole requis pour verifier les patterns")
		quit(1)
		return
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	_jeu = root.get_node("Jeu")
	_salle = load("res://scenes/salle.tscn").instantiate()
	root.add_child(_salle)
	_salle.set_process(false)
	_salle.limites = Rect2(Vector2.ZERO, Reglages.ARENE_TAILLE)
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	_cible = CibleTest.new()
	_cible.add_to_group("cibles_ennemis")
	root.add_child(_cible)
	seed(28092026)
	_verifier_progression()
	_verifier_ajustements_monstres()
	_verifier_premier_boss()
	_verifier_cadence_tison()
	_verifier_tisseur()
	_verifier_annonces_monstres()
	_verifier_esquive_tirs_rapides()
	_verifier_interceptions_charges()
	_verifier_charges()
	_verifier_charges_boss()
	await _verifier_trajets_charges()
	_verifier_teleportations()
	_verifier_portees_attaques()
	_verifier_choix_boss()
	_verifier_contact_boss()
	_verifier_mobilite_boss()
	_verifier_eventails_retour()
	_verifier_geometrie()
	await _verifier_alcoves()
	await _verifier_tirs_de_bord()
	await _verifier_boss()
	await _verifier_annonces_boss()
	_cible.free()
	_salle.free()
	for erreur in _erreurs: push_error(erreur)
	print("Verification patterns : %d controles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _profil(id: String, chapitre: int, salle := 1) -> Dictionary:
	_jeu.mode_run = "grimoire"
	_jeu.chapitre = chapitre
	_salle.numero = salle
	return _salle._mis_a_l_echelle(CatalogueEnnemis.par_id(id), id)

func _verifier_progression() -> void:
	for id: String in CatalogueEnnemis.TOUS:
		var source := CatalogueEnnemis.par_id(id).duplicate(true)
		var precedent := 0.0
		var vitesse_reelle_precedente := 0.0
		for chapitre in Chapitres.nombre():
			var d := _profil(id, chapitre)
			if d.has("vitesse_projectile"):
				var vitesse := float(d["vitesse_projectile"])
				_verifier(vitesse >= precedent and is_finite(vitesse), "Vitesse croissante : " + id)
				precedent = vitesse
				var tir := Tir.new()
				tir.vitesse = vitesse * (Reglages.BOSS_PROJECTILE_VITESSE_MULT if str(d["cerveau"]) == "boss" else 1.0)
				ProjectilesEnnemis.appliquer(tir, d)
				_verifier(tir.vitesse >= vitesse_reelle_precedente, "Vitesse reelle croissante apres plafonds : " + id)
				vitesse_reelle_precedente = tir.vitesse
			for cle: String in ["telegraphe", "preparation"]:
				if d.has(cle): _verifier(float(d[cle]) >= Reglages.ENNEMI_TELEGRAPHE_MIN, "Annonce lisible : " + id)
		var debut := _profil(id, 0)
		var fin := _profil(id, Chapitres.nombre() - 1, Reglages.SALLES_PAR_RUN)
		if debut.has("vitesse_projectile"):
			_verifier(float(fin["vitesse_projectile"]) > float(debut["vitesse_projectile"]) * 1.4,
				"Hausse sensible en fin de campagne : " + id)
		_verifier(source == CatalogueEnnemis.par_id(id), "Catalogue preserve : " + id)
	var premier := _profil("plume_sentinelle", 0)
	var dernier := _profil("plume_sentinelle", 0, Reglages.SALLES_PAR_RUN)
	_verifier(float(dernier["vitesse_projectile"]) > float(premier["vitesse_projectile"]), "Rythme croissant dans une tentative")
	var hors_limites := EvolutionEnnemis.facteurs_rythme(1000, 1000.0)
	_verifier(hors_limites == EvolutionEnnemis.facteurs_rythme(Chapitres.nombre() - 1, 1.0), "Rythme plafonne hors campagne")
	for mode: String in ["mine", "epreuves"]:
		_jeu.mode_run = mode
		_jeu.niveau_mine = 0
		_jeu.niveau_epreuve = 0
		_salle.numero = 1
		_salle._mine_temps = 0.0
		var debut: Dictionary = _salle._mis_a_l_echelle(CatalogueEnnemis.par_id("plume_sentinelle"), "plume_sentinelle")
		_salle.numero = 5
		_salle._mine_temps = Reglages.MINE_DUREE
		var fin: Dictionary = _salle._mis_a_l_echelle(CatalogueEnnemis.par_id("plume_sentinelle"), "plume_sentinelle")
		_verifier(float(fin["vitesse_projectile"]) > float(debut["vitesse_projectile"]), "Progression du rythme : " + mode)

func _verifier_ajustements_monstres() -> void:
	for id: String in CatalogueEnnemis.TOUS:
		var source := CatalogueEnnemis.par_id(id).duplicate(true)
		for monde in Chapitres.MONDES.size():
			var d := BestiaireMondes.appliquer(source, id, monde * Chapitres.CHAPITRES_PAR_MONDE)
			var boss := str(source["cerveau"]) == "boss"
			var tison := id == "plume_sentinelle" and monde == 4
			var cadence := 1.0 if boss else (0.90 if tison else 1.05)
			var mouvement := 1.0 if boss or tison else 1.05
			var rush := str(source["cerveau"]) in ["poursuivant", "rampant", "veloce"]
			if rush: mouvement *= 0.90
			var contexte := "%s monde %d" % [id, monde + 1]
			_verifier(is_equal_approx(float(d["vitesse"]), float(source["vitesse"]) * mouvement), "Renfort de mouvement mesure : " + contexte)
			if rush and d.has("duree_charge"):
				_verifier(is_equal_approx(Cerveaux.longueur_charge(d, Reglages.ENNEMI_VITESSE_MULT),
					Cerveaux.longueur_charge(source, Reglages.ENNEMI_VITESSE_MULT) * 1.05), "Charge ralentit sans perdre sa portee : " + contexte)
			for cle: String in ["recharge", "repos", "repos_contact"]:
				if not source.has(cle): continue
				_verifier(is_equal_approx(float(source[cle]) / float(d[cle]), cadence), "Cadence ajustee sans cumul : %s %s" % [contexte, cle])
			for cle: String in ["pv", "degats", "telegraphe", "preparation"]:
				if source.has(cle): _verifier(source[cle] == d[cle], "Statistique conservee : %s %s" % [contexte, cle])
		_verifier(source == CatalogueEnnemis.par_id(id), "Ajustements sans mutation du catalogue : " + id)
	for chapitre in range(28, Chapitres.nombre()):
		for salle: int in [1, Reglages.SALLES_PAR_RUN]:
			var d := _profil("plume_sentinelle", chapitre, salle)
			var source := CatalogueEnnemis.par_id("plume_sentinelle")
			var facteurs := EvolutionEnnemis.facteurs_rythme(chapitre, 0.0 if salle == 1 else 1.0)
			var ancienne_recharge := float(source["recharge"]) * Reglages.ENNEMI_RECHARGE_MULT * float(facteurs["recharge"])
			_verifier(is_equal_approx(ancienne_recharge / float(d["recharge"]), 0.90), "Tison cadence reduite exactement de 10 % en jeu")
			_verifier(int(d["projectiles"]) == 5, "Tison conserve ses cinq projectiles")
			var elite := RangsEnnemis.renforcer(d)
			_verifier(is_equal_approx(ancienne_recharge * RangsEnnemis.ELITE_RECHARGE / float(elite["recharge"]), 0.90), "Tison elite conserve la baisse de cadence")

func _verifier_premier_boss() -> void:
	for chapitre in Chapitres.nombre():
		for salle: int in [5, 10, 15, 20]:
			var d := _profil("le_correcteur", chapitre, salle)
			var renfort := ProgressionStatistiques.facteur_boss(Chapitres.palier(chapitre))
			var ancienne_courbe := float(Chapitres.par_index(chapitre)["pv_mult"]) * renfort \
				* ProgressionStatistiques.facteur_salle(salle, Reglages.CAMPAGNE_PV_BOSS_PAR_SALLE, Reglages.CAMPAGNE_PV_BOSS_PALIERS)
			var ancien_pv := float(CatalogueEnnemis.par_id("le_correcteur")["pv"]) * ancienne_courbe \
				* ProgressionStatistiques.facteur_miniboss(Chapitres.palier(chapitre)) * Reglages.BOSS_ENDURANCE_MULT
			var attendu := 0.70 if salle == 5 else 1.0
			_verifier(is_equal_approx(float(d["pv"]) / ancien_pv, attendu), "PV du premier boss reduits de 30 %% uniquement a l'etage 5 : %d/%d" % [chapitre, salle])
			_verifier(is_equal_approx(Chapitres.facteur_pv(chapitre, salle), float(Chapitres.par_index(chapitre)["pv_mult"]) \
				* ProgressionStatistiques.facteur_salle(salle, Reglages.CAMPAGNE_PV_PAR_SALLE, Reglages.CAMPAGNE_PV_PALIERS)), "PV ordinaires preserves a tous les etages")

func _verifier_cadence_tison() -> void:
	for chapitre: int in [28, 34]:
		for salle: int in [1, Reglages.SALLES_PAR_RUN]:
			for elite: bool in [false, true]:
				var d := _profil("plume_sentinelle", chapitre, salle)
				if elite: d = RangsEnnemis.renforcer(d)
				var reference := d.duplicate(true)
				reference["recharge"] = float(reference["recharge"]) * BestiaireMondes.CADENCE_TISON_MULT
				reference["cadence_monstre_mult"] = 1.0
				for frequence: int in [60, 120]:
					var ancien_cycle := _mesurer_cycle_sentinelle(reference, frequence)
					var nouveau_cycle := _mesurer_cycle_sentinelle(d, frequence)
					var contexte := "niveau %d salle %d elite %s a %d Hz" % [chapitre + 1, salle, elite, frequence]
					_verifier(absf(nouveau_cycle - ancien_cycle / .90) <= 2.0 / frequence, "Tison cycle reel ralenti de 10 % : " + contexte)
	_cible.velocity = Vector2.ZERO
	print("Tison : cadence reelle reduite de 10 %, avec relances et elites a 60/120 Hz.")

func _mesurer_cycle_sentinelle(donnees: Dictionary, frequence: int) -> float:
	var ennemi: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
	ennemi.configurer(donnees)
	ennemi.position = Vector2(300, 300)
	ennemi.limites = _salle.limites
	_salle.add_child(ennemi)
	ennemi.set_physics_process(false)
	ennemi._apparition = 1.0
	ennemi._recharge = 0.0
	_cible.position = Vector2(300, 850)
	_cible.velocity = Vector2.ZERO
	var temps: Array[float] = [0.0]
	var salves: Array[int] = [0]
	var cycles: Array[float] = []
	var nombre_salves := int(donnees.get("salves", 1))
	ennemi.tir_demande.connect(func(_tir: Tir, _origine: Vector2, _direction: Vector2) -> void:
		if salves[0] % nombre_salves == 0: cycles.append(temps[0])
		salves[0] += 1)
	for image in frequence * 15:
		temps[0] += 1.0 / frequence
		ennemi._physics_process(1.0 / frequence)
		if cycles.size() >= 4: break
	ennemi.free()
	_verifier(cycles.size() >= 4, "Sentinelle termine quatre cycles complets")
	return (cycles[-1] - cycles[0]) / float(cycles.size() - 1) if cycles.size() >= 4 else INF

func _verifier_tisseur() -> void:
	for chapitre in [0, 17, 34]:
		var d := _profil("fuseau_tisseur", chapitre, Reglages.SALLES_PAR_RUN if chapitre == 34 else 1)
		if chapitre == 34: d = RangsEnnemis.renforcer(d)
		var ennemi: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
		ennemi.configurer(d)
		_salle.add_child(ennemi)
		ennemi.set_physics_process(false)
		ennemi.position = Vector2(600, 400)
		_cible.position = ennemi.position + Vector2(0, 600)
		_cible.velocity = Vector2(300, 0)
		ennemi._cible = _cible
		ennemi._recharge = 0.0
		var tirs: Array[Dictionary] = []
		ennemi.tir_demande.connect(func(tir: Tir, origine: Vector2, direction: Vector2) -> void:
			tirs.append({"tir": tir, "origine": origine, "direction": direction}))
		ennemi._agir_tisseur(0.0)
		_verifier(tirs.size() == 1, "Tisseur declenche sans attendre une annonce")
		_verifier(str(ennemi._etat) == "repos" and ennemi._salves.is_empty(), "Tisseur sans annonce ni relance cachee")
		if not tirs.is_empty():
			var tir: Tir = tirs[0]["tir"]
			_verifier((tirs[0]["direction"] as Vector2).is_equal_approx(Vector2.DOWN), "Tisseur sans prediction")
			_verifier(tir.nb_projectiles == 2 and is_zero_approx(tir.angle_eventail), "Deux rubans paralleles a tous les niveaux")
			_verifier(tir.ecart_lateral - maxf(tir.rayon * 2.0, tir.longueur) > Reglages.HEROS_RAYON * 2.0,
				"Passage physique entre les rubans")
			_verifier_passage_droit(tir, chapitre)
		var distance_minimale := float(d["vitesse_projectile"]) * BestiaireMondes.TISSEUR_REACTION_MIN
		_verifier(Cerveaux.tisseur(distance_minimale - 1.0, float(d["portee"]), 0.0, distance_minimale) == "reculer",
			"Tisseur ne tire pas a bout portant")
		ennemi.free()

func _verifier_annonces_monstres() -> void:
	var anciennes_limites: Rect2 = _salle.limites
	var ancien_contour: PackedVector2Array = _salle._contour
	# Les tireurs a longue portee doivent viser une cible encore dans la salle.
	_salle.limites.size.y = Reglages.ARENE_TAILLE.y * FormesSalles.LONGUEUR_MAX
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	for chapitre in [0, 17, 34]:
		for id: String in ["plume_sentinelle", "folio_orbiteur", "miroir_encre", "cachet_phaseur"]:
			var d := _profil(id, chapitre)
			var ennemi: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
			ennemi.configurer(d)
			_salle.add_child(ennemi)
			ennemi.set_physics_process(false)
			ennemi.position = Vector2(600, 400)
			_cible.position = ennemi.position + Vector2(0, float(d["portee"]))
			_cible.velocity = Vector2.ZERO
			ennemi._cible = _cible
			ennemi._recharge = 0.0
			var tirs: Array[Dictionary] = []
			ennemi.tir_demande.connect(func(tir: Tir, origine: Vector2, direction: Vector2) -> void:
				tirs.append({"tir": tir, "origine": origine, "direction": direction}))
			var methode := "_agir_" + str(d["cerveau"])
			if id == "cachet_phaseur":
				ennemi._etat = "phase"
				ennemi._destination_phase = ennemi.position
				ennemi.position.x -= 300.0
			if id == "plume_sentinelle": ennemi.call(methode)
			else: ennemi.call(methode, 0.0)
			var annonce_attendue: bool = id in ["plume_sentinelle", "cachet_phaseur"]
			var contexte := "%s niveau %d" % [id, chapitre + 1]
			_verifier(bool(ennemi._annonce_projectile) == annonce_attendue, "Annonce selon la vitesse reelle : " + contexte)
			if annonce_attendue:
				_verifier(tirs.is_empty() and float(ennemi._minuterie) >= Reglages.ENNEMI_TELEGRAPHE_MIN, "Tir rapide attend la fin de son annonce : " + contexte)
				var visee: Vector2 = ennemi._point_vise
				_cible.position.x += 120.0
				ennemi._minuterie = 0.0
				if id == "plume_sentinelle": ennemi.call(methode)
				else: ennemi.call(methode, 0.0)
				_verifier(not tirs.is_empty(), "Annonce suivie d'un tir : " + contexte)
				if not tirs.is_empty():
					_verifier((tirs[-1]["direction"] as Vector2).is_equal_approx(ennemi.global_position.direction_to(visee)), "Visee verrouillee malgre le mouvement : " + contexte)
			else:
				_verifier(not tirs.is_empty() and str(ennemi._etat) == "repos", "Tir lent immediat sans etat d'annonce : " + contexte)
			for salve: Dictionary in ennemi._salves:
				_verifier(bool(salve["annonce"]) == annonce_attendue, "Relance avec la meme lisibilite : " + contexte)
			if id == "miroir_encre":
				ennemi._salves.clear()
				ennemi._recharge = 0.0
				_cible.position = ennemi.position + Vector2(0, 60)
				ennemi._agir_miroir(0.0)
				_verifier(str(ennemi._etat) == "pulse" and float(ennemi._minuterie) > 0.0, "Depart proche protege le temps de reaction")
			ennemi.free()
	_salle.limites = anciennes_limites
	_salle._contour = ancien_contour

func _verifier_esquive_tirs_rapides() -> void:
	for chapitre: int in [0, 6, 17, 27, 34]:
		for elite: bool in [false, true]:
			for salle: int in [1, Reglages.SALLES_PAR_RUN]:
				var d := _profil("plume_sentinelle", chapitre, salle)
				if elite: d = RangsEnnemis.renforcer(d)
				var ennemi: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
				ennemi.configurer(d)
				ennemi._cible = _cible
				var tir: Tir = ennemi._creer_tir()
				_verifier(tir.vitesse > Reglages.HEROS_VITESSE * 8.0, "Sentinelle au moins huit fois plus rapide que la course")
				for distance: float in [500.0, 800.0, 1000.0, 2000.0]:
					for sens: float in [-1.0, 1.0]:
						var course := Vector2(sens * Reglages.HEROS_VITESSE, 0)
						var debut := Vector2(0, distance)
						_cible.position = debut
						_cible.velocity = course
						ennemi._preparer_tir("vise", float(d["telegraphe"]))
						var visee: Vector2 = ennemi._point_vise.normalized()
						var marge := _marge_course(tir, visee, debut, course, float(d["telegraphe"]))
						var contexte := "niveau %d, salle %d, elite %s, distance %d" % [chapitre + 1, salle, elite, distance]
						_verifier(marge <= 0.0, "Course constante touchee jusqu'au fond de salle : " + contexte)
						# Une inversion peut croiser une branche de l'eventail ; une
						# autre direction doit permettre de sortir des couloirs annonces.
						var marge_esquive := maxf(
							_marge_course(tir, visee, debut, course, float(d["telegraphe"]), -course),
							_marge_course(tir, visee, debut, course, float(d["telegraphe"]), Vector2(0, -Reglages.HEROS_VITESSE)))
						marge_esquive = maxf(marge_esquive,
							_marge_course(tir, visee, debut, course, float(d["telegraphe"]), Vector2(0, Reglages.HEROS_VITESSE)))
						_verifier(marge_esquive > 0.0,
							"Changement de direction avec acceleration permet l'esquive : " + contexte)
				ennemi.free()
	_cible.velocity = Vector2.ZERO
	print("Sentinelle : course constante touchee jusqu'au fond de salle, esquive par changement de direction sur les cinq mondes et les elites.")

func _verifier_interceptions_charges() -> void:
	_verifier(not Cerveaux.charge_atteignable(Vector2.ZERO, Vector2(0, 500),
		Vector2(0, 600), Vector2.ZERO, .6, 300.0, 40.0), "Aucune charge contre une cible statique au-dela du trait annonce")
	_verifier(Cerveaux.charge_atteignable(Vector2.ZERO, Vector2(0, 500),
		Vector2(0, 535), Vector2.ZERO, .6, 300.0, 40.0), "Le contact du corps au bout du trait compte dans la portee")
	_verifier(not Cerveaux.charge_atteignable(Vector2.ZERO, Vector2(0, 500),
		Vector2(0, 300), Vector2(0, 200), .6, 300.0, 40.0), "Cible proche qui fuit hors du trajet ne provoque pas une charge inutile")
	_salle.limites = Rect2(Vector2.ZERO, Reglages.ARENE_TAILLE)
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	for chapitre: int in [0, 17, 34]:
		for id: String in ["tache_veloce", "sceau_belier"]:
			for sens: float in [-1.0, 1.0]:
				for changer: bool in [false, true]:
					var ennemi := _acteur_test(id, chapitre, Vector2(540, 300))
					_cible.position = Vector2(540, 650)
					var course := Vector2(sens * Reglages.HEROS_VITESSE * .30, 0)
					_cible.velocity = course
					ennemi._agir_veloce(0.0)
					var fin: Vector2 = ennemi._charge.fin
					var direction: Vector2 = ennemi._direction_charge
					var contexte := "%s niveau %d sens %d" % [id, chapitre + 1, sens]
					_verifier(str(ennemi._etat) == "preparer" and direction.x * sens > 0.0, "Charge anticipe une course laterale : " + contexte)
					var coups := _cible.coups
					var duree := float(ennemi.donnees["preparation"]) + float(ennemi.donnees["duree_charge"])
					for image in ceili(duree * 120.0) + 10:
						if changer and float(image) / 120.0 >= .25:
							_cible.velocity = _cible.velocity.move_toward(-course, Reglages.HEROS_ACCELERATION / 120.0)
						_cible.position += _cible.velocity / 120.0
						ennemi._physics_process(1.0 / 120.0)
						_verifier((ennemi._charge.fin as Vector2).is_equal_approx(fin), "Charge garde le trajet annonce : " + contexte)
						if ennemi._charge.terminee: break
					_verifier(_cible.coups == coups if changer else _cible.coups > coups, "Interception touche la course reguliere et laisse esquiver : " + contexte)
					ennemi.free()
	# Au debut de campagne, une course rapide peut depasser la portee d'interception.
	var ennemi := _acteur_test("tache_veloce", 0, Vector2(300, 300))
	_cible.position = Vector2(300, 650)
	_cible.velocity = Vector2(Reglages.HEROS_VITESSE, 0)
	ennemi._agir_veloce(0.0)
	_verifier(str(ennemi._etat) != "preparer" and ennemi.velocity.y > 0.0, "Charge impossible contre une course rapide remplacee par approche")
	ennemi.free()
	# Le joueur reste visible ; seule sa destination anticipee est derriere un couvert.
	ennemi = _acteur_test("tache_veloce", 0, Vector2(300, 300))
	_cible.position = Vector2(300, 650)
	_cible.velocity = Vector2(220, 0)
	_salle._obstacles.assign([Rect2(365, 420, 260, 80)])
	ennemi._agir_veloce(0.0)
	_verifier(str(ennemi._etat) != "preparer" and ennemi.velocity.y > 0.0, "Interception bloquee ne declenche pas une charge directe qui raterait")
	ennemi.free()
	_salle._obstacles.clear()
	_cible.velocity = Vector2.ZERO

func _marge_course(tir: Tir, visee: Vector2, debut: Vector2, course: Vector2,
		preparation: float, course_apres := Vector2.INF) -> float:
	var marge := INF
	var heros := debut
	var vitesse := course
	var pas_temps := 1.0 / 1200.0
	for pas in ceili((preparation + 1.0) / pas_temps):
		var temps := float(pas) * pas_temps
		if course_apres.is_finite() and temps >= .25:
			vitesse = vitesse.move_toward(course_apres, Reglages.HEROS_ACCELERATION * pas_temps)
		heros += vitesse * pas_temps
		if temps < preparation: continue
		for angle: float in tir.angles():
			var axe := visee.rotated(angle)
			var projectile := axe * tir.vitesse * (temps - preparation)
			var demi_segment := axe * maxf(0.0, tir.longueur * .5 - tir.rayon)
			var proche := Geometry2D.get_closest_point_to_segment(heros, projectile - demi_segment, projectile + demi_segment)
			marge = minf(marge, heros.distance_to(proche) - tir.rayon - Reglages.HEROS_RAYON)
	return marge

func _verifier_charges() -> void:
	_salle.limites = Rect2(Vector2.ZERO, Reglages.ARENE_TAILLE)
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	for chapitre: int in [0, 17, 34]:
		for id: String in ["tache_veloce", "sceau_belier"]:
			var ennemi: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
			ennemi.configurer(_profil(id, chapitre))
			ennemi.limites = _salle.limites
			_salle.add_child(ennemi)
			ennemi.set_physics_process(false)
			ennemi._cible = _cible
			ennemi.position = Vector2(600, 200)
			var portee: float = ennemi.portee_charge()
			_verifier(portee >= 900.0, "Charge longue des le debut : " + id)
			_cible.position = ennemi.position + Vector2(0, portee + 100)
			ennemi._agir_veloce(.016)
			_verifier(ennemi._etat != "preparer" and ennemi.velocity.y > 0, "Charge hors portee remplacee par approche : " + id)
			_cible.position = ennemi.position + Vector2(0, portee - 60)
			ennemi._agir_veloce(.016)
			_verifier(ennemi._etat == "preparer", "Charge preparee quand elle peut atteindre : " + id)
			_cible.position = ennemi.position + Vector2(0, portee + 100)
			ennemi._minuterie = 0.0
			ennemi._agir_veloce(.016)
			_verifier(ennemi._etat != "charger", "Pas d'elan si la cible sort de portee pendant l'annonce : " + id)
			ennemi._givre = 2.0
			_verifier(float(ennemi.portee_charge()) < portee, "Portee recalculee sous ralentissement : " + id)
			ennemi._etat = "charger"
			ennemi._charge.terminee = true
			ennemi._minuterie = 0.0
			ennemi._charges_effectuees = 1
			ennemi.donnees["charges"] = 2
			ennemi._agir_veloce(.016)
			_verifier(ennemi._etat == "repos", "Enchainement abandonne hors portee : " + id)
			ennemi._givre = 0.0
			ennemi._minuterie = 0.0
			_cible.position = ennemi.position + Vector2(0, 450)
			_salle._obstacles.assign([Rect2(500, 350, 200, 100)])
			ennemi._agir_veloce(.016)
			_verifier(ennemi._etat != "preparer", "Pas de charge preparee a travers un obstacle : " + id)
			_salle._obstacles.clear()
			ennemi.free()

func _verifier_charges_boss() -> void:
	var boss: CharacterBody2D = load("res://scenes/boss.tscn").instantiate()
	boss.configurer(_profil("le_correcteur", 0))
	boss.limites = _salle.limites
	boss.position = Vector2(600, 200)
	_salle.add_child(boss)
	boss.set_physics_process(false)
	boss._cible = _cible
	boss._motif = "charge"
	boss._minuterie = boss._duree_du_motif("charge")
	_cible.position = Vector2(600, 1900)
	boss._commencer_motif("charge")
	_verifier(boss._charge_approche and not boss._annonce_charge(), "Boss approche sans annoncer une charge hors portee")
	var avant := boss.position
	boss._executer_motif("charge", 1.0 / 60.0)
	_verifier(boss.position.y > avant.y and not boss._charge_debutee, "Approche normale avant le dash du boss")
	_cible.position = Vector2(600, 10000)
	for image in 125: boss._executer_motif("charge", 1.0 / 60.0)
	_verifier(float(boss._minuterie) <= 0.0, "Cible inaccessible ne bloque pas le cycle des boss")
	boss.position = Vector2(600, 200)
	_cible.position = Vector2(600, 950)
	boss._minuterie = boss._duree_du_motif("charge")
	boss._commencer_motif("charge")
	_verifier(boss._annonce_charge(), "Boss annonce une cible a portee")
	_cible.position = Vector2(600, 1900)
	boss._minuterie = float(boss._duree_du_motif("charge")) - BestiaireMondes.BOSS_CHARGE_ANNONCE - .01
	boss._executer_motif("charge", 1.0 / 60.0)
	_verifier(not boss._charge_debutee and boss.position.is_equal_approx(Vector2(600, 200)), "Boss annule le depart lorsque la cible sort de portee")
	_cible.position = Vector2(600, 950)
	boss._commencer_motif("charge")
	boss._minuterie = float(boss._duree_du_motif("charge")) - BestiaireMondes.BOSS_CHARGE_ANNONCE - .01
	for image in 120: boss._executer_motif("charge", 1.0 / 60.0)
	_verifier(boss._charge_terminee and boss.position.y >= 1300.0, "Dash de boss depasse nettement l'ancienne portee")
	boss.free()

func _acteur_test(id: String, chapitre: int, point: Vector2) -> CharacterBody2D:
	var d := _profil(id, chapitre)
	var scene := "boss" if str(d["cerveau"]) == "boss" else "ennemi"
	var acteur: CharacterBody2D = load("res://scenes/%s.tscn" % scene).instantiate()
	acteur.configurer(d)
	acteur.position = point
	acteur.limites = _salle.limites
	_salle.add_child(acteur)
	acteur.set_physics_process(false)
	acteur._cible = _cible
	acteur._apparition = 1.0
	return acteur

func _verifier_trajets_charges() -> void:
	for forme in FormesSalles.PROFILS.size():
		_salle._contour = FormesSalles.contour(_salle.limites, forme)
		_salle._construire_murs_perimetre()
		await physics_frame
		for frequence: int in [30, 60, 120]:
			for id: String in ["tache_veloce", "sceau_belier", "le_correcteur"]:
				var acteur := _acteur_test(id, 0, _salle.limites.get_center())
				var debut := acteur.position
				_cible.position = debut + Vector2(200, -500)
				var boss := id == "le_correcteur"
				if boss:
					acteur._motif = "charge"
					acteur._minuterie = acteur._duree_du_motif("charge")
					acteur._commencer_motif("charge")
				else:
					acteur._agir_veloce(0.0)
				var fin: Vector2 = acteur._charge.fin
				var rayon: float = acteur.get_node("CollisionShape2D").shape.radius
				var contexte := "%s forme %d a %d Hz" % [id, forme, frequence]
				_verifier(debut.distance_to(fin) > 600.0, "Dash conserve sa longueur : " + contexte)
				_verifier(FormesSalles.contient_disque(fin, _salle._contour, rayon), "Annonce arretee au vrai mur : " + contexte)
				# Esquiver lateralement ne deplace jamais la destination annoncee.
				_cible.position += Vector2(200, 0)
				var coups := _cible.coups
				var ralenti := false
				for image in frequence * 8:
					acteur._physics_process(1.0 / frequence)
					if frequence == 60 and not ralenti and acteur.position.distance_to(debut) > 80.0:
						ralenti = true
						acteur._givre = 3.0
						if boss: acteur.pv = acteur.pv_max * .4
					if acteur._charge.terminee: break
				_verifier(acteur._charge.terminee and acteur.position.distance_to(fin) < .2, "Dash rejoint le bout de son annonce : " + contexte)
				_verifier(_cible.coups == coups, "Esquive laterale conservee : " + contexte)
				_verifier((acteur._charge.fin as Vector2).is_equal_approx(fin), "Pas de correction cachee de trajectoire : " + contexte)
				acteur.free()
		for enfant in _salle.get_children():
			if enfant is StaticBody2D: enfant.free()
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	var chargeur := _acteur_test("tache_veloce", 0, Vector2(600, 250))
	_salle._obstacles.assign([Rect2(400, 1050, 400, 100)])
	_cible.position = Vector2(600, 750)
	chargeur._agir_veloce(0.0)
	var fin: Vector2 = chargeur._charge.fin
	_verifier(fin.y < 1050 and fin.y > 1000, "Le bloc raccourcit le trace avant le depart")
	for image in 240:
		chargeur._physics_process(1.0 / 60.0)
		if chargeur._charge.terminee: break
	_verifier(chargeur.position.distance_to(fin) < .2, "Dash et annonce s'arretent devant le meme bloc")
	chargeur.free()
	_salle._obstacles.clear()
	print("Charges : trajets annonces et parcourus concordants, neuf contours, 30/60/120 Hz et ralentissements.")

func _verifier_alcoves() -> void:
	var largeurs: Dictionary = {}
	var longueurs: Dictionary = {}
	for mode: String in ["mine", "epreuves"]:
		_verifier(FormesSalles.taille(8, 0, 0, mode) == Reglages.ARENE_TAILLE, "Dimensions conservees hors campagne : " + mode)
	for chapitre in Chapitres.nombre():
		var salles_larges := 0
		var salles_etroites := 0
		for numero in range(1, Reglages.SALLES_PAR_RUN + 1):
			var taille := FormesSalles.taille(numero, chapitre, 0, "grimoire")
			var limites := Rect2(Vector2(-87, 231), taille)
			var contour := FormesSalles.contour_salle(limites, numero, chapitre, 0, "grimoire")
			var contexte := "%d/%d" % [chapitre, numero]
			largeurs[roundi(taille.x)] = true
			longueurs[roundi(taille.y)] = true
			if taille.x > Reglages.ARENE_TAILLE.x: salles_larges += 1
			else: salles_etroites += 1
			_verifier(taille.x >= Reglages.ARENE_TAILLE.x * FormesSalles.LARGEUR_MIN and taille.x <= Reglages.ARENE_TAILLE.x * FormesSalles.LARGEUR_MAX, "Largeur dans la plage prevue : " + contexte)
			_verifier(taille.y >= Reglages.ARENE_TAILLE.y and taille.y <= Reglages.ARENE_TAILLE.y * FormesSalles.LONGUEUR_MAX, "Longueur dans la plage prevue : " + contexte)
			_verifier(taille == FormesSalles.taille(numero, chapitre, 12345, "grimoire"), "Dimensions stables apres changement de graine")
			_verifier(not Geometry2D.triangulate_polygon(contour).is_empty(), "Contour triangulable : " + contexte)
			_verifier(Geometry2D.offset_polygon(contour, -Reglages.HEROS_RAYON - 2.0).size() == 1, "Toute la salle reste accessible au heros : " + contexte)
			var entree := Vector2(limites.get_center().x, limites.end.y - 120.0)
			var portail := Vector2(limites.get_center().x, limites.position.y + 180.0)
			_verifier(Geometrie.ligne_libre(entree, portail, [], FormesSalles.MARGE_APPARITION, contour), "Passage central ouvert jusqu'au portail : " + contexte)
			for point in contour:
				_verifier(limites.grow(.01).has_point(point), "Alcove contenue dans la largeur de salle : " + contexte)
			for definition: Dictionary in TerrainsMondes.obstacles(numero, chapitre):
				var rect: Rect2 = definition["rect"]
				rect = Rect2(limites.position + rect.position * taille, rect.size * taille)
				for point: Vector2 in [rect.position, rect.end, Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.end.y)]:
					_verifier(Geometry2D.is_point_in_polygon(point, contour), "Couvert entier dans les nouvelles parois : " + contexte)
		_verifier(salles_larges > Reglages.SALLES_PAR_RUN / 2 and salles_etroites > 0, "Majorite de salles larges et quelques salles etroites : chapitre %d" % chapitre)
	_verifier(largeurs.size() > 30 and longueurs.size() > 30, "Proportions variees sur le parcours")
	# Deux baies sont reliees par le centre, avec un mur entre elles sur la gauche.
	var ancien_contour: PackedVector2Array = _salle._contour
	var anciennes_limites: Rect2 = _salle.limites
	_salle.limites = Rect2(0, 0, 1000, 1600)
	_salle._contour = PackedVector2Array([Vector2(0,0), Vector2(1000,0), Vector2(1000,1600), Vector2(0,1600),
		Vector2(0,1100), Vector2(140,1100), Vector2(140,500), Vector2(0,500)])
	var contour: PackedVector2Array = _salle._contour
	var a := Vector2(70,350)
	var b := Vector2(70,1250)
	_verifier(Geometry2D.is_point_in_polygon(a, contour) and Geometry2D.is_point_in_polygon(b, contour), "Deux extremites sur le sol des baies")
	_verifier(not Geometrie.ligne_libre(a, b, [], 0.0, contour), "Le mur protege entre deux alcoves")
	_verifier(Geometrie.ligne_libre(Vector2(500,350), Vector2(500,1250), [], 40.0, contour), "Trajet central libre entre les alcoves")
	_verifier(not Geometrie.ligne_libre(Vector2(170,600), Vector2(170,1000), [], 40.0, contour), "Encombrement du projectile contre le renfoncement")
	for enfant in _salle.get_children():
		if enfant is StaticBody2D: enfant.free()
	_salle._construire_murs_perimetre()
	await physics_frame
	for frequence: int in [30, 60, 120]:
		var acteur := _acteur_test("tache_veloce", 0, a)
		var rayon: float = acteur.get_node("CollisionShape2D").shape.radius
		acteur._charge.preparer(acteur, Vector2.DOWN, 1100.0, rayon)
		var fin: Vector2 = acteur._charge.fin
		_verifier(absf(fin.y - (500.0 - rayon - acteur.safe_margin)) < .1, "Charge arretee au premier mur, avant la seconde baie")
		for image in frequence * 4:
			acteur._charge.avancer(acteur, 350.0, 1.0 / frequence)
			if acteur._charge.terminee: break
		_verifier(acteur._charge.terminee and acteur.position.distance_to(fin) < .2, "Charge physique conforme au trace dans une salle concave")
		acteur.free()
	for id: String in ["encrier_rampant", "tache_veloce"]:
		for sens in 2:
			_cible.position = b if sens == 0 else a
			var acteur := _acteur_test(id, 0, a if sens == 0 else b)
			for image in 60 * 30:
				acteur._physics_process(1.0 / 60.0)
				if acteur.position.distance_to(_cible.position) < 100.0: break
			_verifier(acteur.position.distance_to(_cible.position) < 100.0, "Ennemi contourne le mur entre les alcoves : " + id)
			_verifier(FormesSalles.contient_disque(acteur.position, contour, acteur._rayon_collision() - .1), "Ennemi reste dans le sol pendant le contournement")
			acteur.free()
	for enfant in _salle.get_children():
		if enfant is StaticBody2D: enfant.free()
	_salle._contour = ancien_contour
	_salle.limites = anciennes_limites
	print("Salles : proportions bornees, acces, couverts et alcoves sur toute la campagne ; charges concaves a 30/60/120 Hz.")

func _verifier_teleportations() -> void:
	for chapitre: int in [0, 7, 14, 21, 34]:
		for position_cible: Vector2 in [Vector2(600, 1500), Vector2(100, 1750)]:
			var phaseur := _acteur_test("cachet_phaseur", chapitre, Vector2(600, 250))
			_cible.position = position_cible
			phaseur._recharge = 0.0
			_salle._obstacles.assign([Rect2(300, 850, 600, 100)])
			phaseur._agir_phaseur(0.0)
			var destination: Vector2 = phaseur._destination_phase
			_verifier(phaseur._etat == "phase" and destination.is_finite(), "Teleportation engagee de loin et derriere un obstacle")
			_verifier(phaseur.position.is_equal_approx(Vector2(600, 250)), "Depart attend son annonce de teleportation")
			_verifier(_salle._place_libre(destination, float(phaseur.donnees["rayon"])), "Arrivee du phaseur dans une place libre")
			_cible.position.x += 60.0
			phaseur._minuterie = 0.0
			phaseur._agir_phaseur(0.0)
			_verifier(phaseur.position.is_equal_approx(destination), "Teleportation vers la destination annoncee malgre le mouvement du joueur")
			phaseur.free()
			_salle._obstacles.clear()
	var phaseur := _acteur_test("cachet_phaseur", 0, Vector2(600, 250))
	_cible.position = Vector2(600, 1500)
	phaseur._recharge = 0.0
	phaseur._agir_phaseur(0.0)
	var destination: Vector2 = phaseur._destination_phase
	_salle._obstacles.assign([Rect2(destination - Vector2(50, 50), Vector2(100, 100))])
	phaseur._minuterie = 0.0
	phaseur._agir_phaseur(0.0)
	_verifier(phaseur.position.is_equal_approx(Vector2(600, 250)) and phaseur._etat == "repos", "Arrivee devenue occupee annule le saut")
	_salle._obstacles.assign([_salle.limites])
	phaseur._recharge = 0.0
	phaseur._agir_phaseur(0.0)
	_verifier(phaseur._etat != "phase" and phaseur.position.is_finite(), "Pas de fausse teleportation quand toutes les arrivees sont bloquees")
	phaseur.free()
	_salle._obstacles.clear()

func _verifier_portees_attaques() -> void:
	var anciennes_limites: Rect2 = _salle.limites
	var ancien_contour: PackedVector2Array = _salle._contour
	_salle.limites.size.y = Reglages.ARENE_TAILLE.y * FormesSalles.LONGUEUR_MAX
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	for chapitre: int in [0, 17, 34]:
		for id: String in ["plume_sentinelle", "folio_orbiteur", "marge_harceleuse", "miroir_encre", "fuseau_tisseur"]:
			var ennemi := _acteur_test(id, chapitre, Vector2(600, 250))
			var tirs: Array[Tir] = []
			ennemi.tir_demande.connect(func(tir: Tir, _origine: Vector2, _direction: Vector2): tirs.append(tir))
			var tir: Tir = ennemi._creer_tir()
			var portee := minf(tir.portee, tir.distance_retour) if tir.trajectoire == "aller_retour" else tir.portee
			var methode := "_agir_" + str(ennemi.donnees["cerveau"])
			_cible.position = ennemi.position + Vector2(0, portee - 100.0)
			ennemi._recharge = 0.0
			if id == "plume_sentinelle": ennemi.call(methode)
			else: ennemi.call(methode, 0.0)
			_verifier(not tirs.is_empty() or ennemi._etat != "repos", "Tireur actif au-dela de sa distance de placement : " + id)
			ennemi._etat = "repos"
			ennemi._recharge = 0.0
			tirs.clear()
			_cible.position = ennemi.position + Vector2(0, portee + 100.0)
			if id == "plume_sentinelle": ennemi.call(methode)
			else: ennemi.call(methode, 0.0)
			_verifier(tirs.is_empty() and ennemi._etat == "repos", "Pas de cast hors portee physique : " + id)
			_cible.position = ennemi.position + Vector2(0, portee - 100.0)
			_salle._obstacles.assign([Rect2(450, 450, 300, 100)])
			if id == "plume_sentinelle": ennemi.call(methode)
			else: ennemi.call(methode, 0.0)
			_verifier(tirs.is_empty() and ennemi._etat == "repos", "Pas de cast dans un obstacle : " + id)
			_salle._obstacles.clear()
			ennemi.free()
	_salle.limites = anciennes_limites
	_salle._contour = ancien_contour
	var scribe := _acteur_test("scribe_essaimeur", 0, Vector2(600, 250))
	_cible.position = Vector2(600, 1700)
	scribe._recharge = 0.0
	scribe._agir_essaimeur(0.0)
	_verifier(scribe._etat == "invoque", "Invocateur actif meme avec un joueur lointain")
	var tirs: Array[Tir] = []
	scribe.tir_demande.connect(func(tir: Tir, _origine: Vector2, _direction: Vector2): tirs.append(tir))
	scribe._invocations = int(scribe.donnees["max_invocations"])
	scribe._etat = "repos"
	scribe._recharge = 0.0
	scribe._agir_essaimeur(0.0)
	_verifier(scribe._etat == "repos", "Invocateur epuise approche avant sa salve hors portee")
	_cible.position = scribe.position + Vector2(0, 800)
	scribe._agir_essaimeur(0.0)
	scribe._minuterie = 0.0
	scribe._agir_essaimeur(0.0)
	_verifier(not tirs.is_empty(), "Invocateur reste dangereux quand sa reserve est epuisee")
	scribe.free()

func _verifier_choix_boss() -> void:
	for id: String in DeplacementsBoss.IDENTITES:
		for phase in [1, 2]:
			var boss := _acteur_test(id, 0, Vector2(600, 250))
			boss._phase = phase
			_cible.position = Vector2(600, 1900)
			var vus: Array[String] = []
			var precedent := ""
			for choix in 18:
				var motif: String = boss._choisir_motif()
				boss._motif = motif
				_verifier(motif not in ["assaut_contact", "charge"], "Boss lointain choisit un motif atteignable : " + id)
				if motif == "pause": continue
				_verifier(motif != precedent, "Pas de repetition immediate du meme motif : " + id)
				precedent = motif
				if motif not in vus: vus.append(motif)
			_verifier(vus.size() >= 2, "Repertoire a distance conserve plusieurs attaques : " + id)
			boss.free()
	# A mi-distance, charges, frappes et tirs restent dans le repertoire.
	var boss := _acteur_test("la_rature", 0, Vector2(600, 700))
	_cible.position = Vector2(600, 1000)
	var cycles: Array[String] = []
	for cycle in 5:
		var vus: Array[String] = []
		for choix in 8:
			var motif: String = boss._choisir_motif()
			boss._motif = motif
			if motif == "pause": break
			_verifier(motif not in vus, "Un repertoire entier avant de rejouer le meme motif")
			vus.append(motif)
		_verifier("charge" in vus and "assaut_contact" in vus and "griffure" in vus and "encrage_cible" in vus,
			"La Rature conserve ses quatre attaques distinctes")
		var ordre := ",".join(vus)
		if ordre not in cycles: cycles.append(ordre)
	_verifier(cycles.size() > 1, "L'ordre des cycles du boss varie")
	boss.free()
	boss = _acteur_test("choeur_infini", 0, _salle.limites.get_center())
	_cible.position = boss.position + Vector2(0, -500)
	var directions: Array[Vector2] = []
	boss.tir_demande.connect(func(_tir: Tir, _origine: Vector2, direction: Vector2): directions.append(direction))
	boss._motif = "barrage_horizontal"
	boss._minuterie = boss._duree_du_motif("barrage_horizontal")
	boss._executer_motif("barrage_horizontal", .016)
	for attente: Dictionary in boss._tirs_annonces.attentes: directions.append(attente["direction"])
	_verifier(not directions.is_empty(), "Barrage actif avec un joueur derriere le boss")
	for direction: Vector2 in directions:
		_verifier(direction.y < 0.0, "Barrage dirige vers le joueur au lieu de tirer dans son dos")
	boss.free()

func _verifier_contact_boss() -> void:
	for id: String in AttaquesContactBoss.PROFILS:
		var boss := _acteur_test(id, 0, Vector2(600, 500))
		boss._motif = "assaut_contact"
		_cible.position = Vector2(600, 1900)
		boss._commencer_motif("assaut_contact")
		boss._contact.reste = 0.0
		boss._executer_motif("assaut_contact", .016)
		_verifier(boss._contact.etat == "repos" and boss._minuterie == 0.0, "Approche expiree sans frappe hors de portee : " + id)
		_cible.position = Vector2(600, 650)
		boss._commencer_motif("assaut_contact")
		boss._executer_motif("assaut_contact", .016)
		_verifier(boss._contact.etat == "annonce", "Frappe annoncee seulement au contact : " + id)
		var direction: Vector2 = boss._contact.direction
		_cible.position = Vector2(600, 1800)
		var coups := _cible.coups
		boss._executer_motif("assaut_contact", 2.0)
		_verifier(_cible.coups == coups and boss._contact.direction == direction, "Fuite apres le cast reste une esquive valide : " + id)
		boss._commencer_motif("assaut_contact")
		_cible.position = Vector2(600, 650)
		_salle._obstacles.assign([Rect2(450, 570, 300, 20)])
		boss._contact.reste = 0.0
		boss._executer_motif("assaut_contact", .016)
		_verifier(boss._contact.etat == "repos", "Aucune melee annoncee a travers un obstacle : " + id)
		_salle._obstacles.clear()
		boss.free()

func _verifier_mobilite_boss() -> void:
	_salle.limites = Rect2(Vector2.ZERO, Reglages.ARENE_TAILLE)
	for forme in FormesSalles.PROFILS.size():
		_salle._contour = FormesSalles.contour(_salle.limites, forme)
		var d := _profil("grand_alambic", 34)
		var apparition: Vector2 = _salle._position_boss(d)
		_verifier(apparition.is_finite() and apparition.distance_to(_salle.limites.get_center()) < 120.0, "Boss apparait au milieu : forme %d" % forme)
		_verifier(FormesSalles.contient_disque(apparition, _salle._contour, float(d["rayon"])), "Boss entier dans le sol a l'arrivee")
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	_salle._obstacles.assign([Rect2(450, 800, 300, 400)])
	var repli: Vector2 = _salle._position_boss(_profil("grand_alambic", 34))
	_verifier(repli.is_finite() and _salle._place_libre(repli, 114.0), "Apparition contourne les blocs au milieu de la Mine")
	_salle._obstacles.clear()
	for id: String in DeplacementsBoss.IDENTITES:
		var boss: CharacterBody2D = load("res://scenes/boss.tscn").instantiate()
		boss.configurer(_profil(id, 0))
		boss.limites = _salle.limites
		boss.position = _salle._position_boss(boss.donnees)
		_salle.add_child(boss)
		boss.set_physics_process(false)
		boss._cible = _cible
		_cible.position = Vector2(600, 1850)
		var depart := boss.position
		for image in 120: boss._flotter(1.0 / 60.0)
		_verifier(boss.position.y > depart.y + 180.0, "Boss gagne de la profondeur vers le joueur : " + id)
		_verifier(boss.position.distance_to(_cible.position) < depart.distance_to(_cible.position), "Boss reduit la distance : " + id)
		_cible.position = Vector2(600, 200)
		depart = boss.position
		for image in 120: boss._flotter(1.0 / 60.0)
		_verifier(boss.position.y < depart.y - 180.0, "Boss suit aussi un joueur passe derriere : " + id)
		boss._apparition = 1.0
		_cible.position = Vector2(600, 1850)
		var tirs: Array[Tir] = []
		boss.tir_demande.connect(func(tir: Tir, _origine: Vector2, _direction: Vector2): tirs.append(tir))
		# Le repertoire inclut des charges et des frappes sans projectiles.
		var duree_cycle := 0.0
		for motif: String in boss.donnees["motifs_phase_1"]:
			duree_cycle += float(boss._duree_du_motif(motif)) + float(DeplacementsBoss.profil(boss.donnees)["repositionnement"])
		for image in ceili(duree_cycle * 60.0): boss._physics_process(1.0 / 60.0)
		_verifier(not tirs.is_empty(), "Cycle mobile conserve les attaques : " + id)
		for tir: Tir in tirs:
			_verifier(tir.portee >= _salle.limites.size.length() * 2.0, "Projectile de boss couvre la salle et le retour : " + id)
		boss.free()
	print("Boss : vingt identites avancees dans les deux sens et cycles de combat exerces.")

func _verifier_eventails_retour() -> void:
	for chapitre: int in [0, 7, 14, 21, 34]:
		for id: String in ["l_errata", "virgule_noire", "souverain_ombres"]:
			var boss: CharacterBody2D = load("res://scenes/boss.tscn").instantiate()
			boss.configurer(_profil(id, chapitre))
			boss.limites = _salle.limites
			boss.position = Vector2(600, 800)
			_cible.position = Vector2(600, 1650)
			_salle.add_child(boss)
			boss.set_physics_process(false)
			boss._cible = _cible
			boss._motif = "calligraphie"
			boss._minuterie = 3.0
			boss._executer_motif("calligraphie", 1.0 / 60.0)
			var attentes: Array = boss._tirs_annonces.attentes
			_verifier(attentes.size() == 3, "Boss boomerang annonce exactement trois branches : " + id)
			if attentes.size() == 3:
				var origine: Vector2 = attentes[1]["origine"]
				var direction: Vector2 = attentes[1]["direction"]
				for i in 3:
					var tir: Tir = attentes[i]["tir"]
					var branche: Vector2 = attentes[i]["direction"]
					_verifier((attentes[i]["origine"] as Vector2).is_equal_approx(origine), "Les trois boomerangs partent du boss")
					_verifier(is_equal_approx(direction.angle_to(branche), ProjectilesEnnemis.RETOUR_BOSS_ANGLES[i]), "Eventail symetrique autour de la cible")
					_verifier(tir.distance_retour >= 2000.0 and tir.vitesse >= 1200.0, "Boomerang rapide et long depuis le premier niveau")
				var avant := boss.position
				boss._flotter(.1)
				_verifier(boss.position.is_equal_approx(avant), "Boss garde le depart annonce de ses boomerangs")
			boss._tirs_annonces.annuler()
			boss._cadence_motif = 0.0
			boss._motifs_mondes.avancer(boss, "lames_ondulees", .016)
			_verifier(boss._motifs_mondes.angles.size() == 3, "Motif de monde conserve trois branches de retour")
			boss.free()

func _verifier_passage_droit(tir: Tir, chapitre: int) -> void:
	# Une traversee rectiligne doit reussir sur une plage de timings, mais pas tous.
	var reussites := 0
	var suite := 0
	var suite_max := 0
	for choix in 101:
		var attente := float(choix) * .01
		var touche := false
		for pas in 480:
			var temps := float(pas) / 240.0
			var marche := maxf(0.0, temps - attente)
			var acceleration := minf(marche, Reglages.HEROS_VITESSE / Reglages.HEROS_ACCELERATION)
			var distance := .5 * Reglages.HEROS_ACCELERATION * acceleration * acceleration + (marche - acceleration) * Reglages.HEROS_VITESSE
			var heros := Vector2(0, 600.0 - distance)
			if heros.y < 0.0: break
			var oscillation := tir.amplitude * sin(temps * TAU * tir.frequence)
			var tangente := Vector2(tir.amplitude * TAU * tir.frequence * cos(temps * TAU * tir.frequence), tir.vitesse).normalized()
			var demi_segment := maxf(0.0, tir.longueur * .5 - tir.rayon)
			for cote in [-1.0, 1.0]:
				var projectile := Vector2(float(cote) * tir.ecart_lateral * .5 + oscillation, temps * tir.vitesse)
				var proche := Geometry2D.get_closest_point_to_segment(heros,
					projectile - tangente * demi_segment, projectile + tangente * demi_segment)
				if proche.distance_to(heros) <= Reglages.HEROS_RAYON + tir.rayon:
					touche = true
					break
			if touche: break
		if touche: suite = 0
		else:
			reussites += 1
			suite += 1
			suite_max = maxi(suite_max, suite)
	_verifier(reussites > 0 and reussites < 101, "Zigzag evitable mais dangereux au niveau %d" % (chapitre + 1))
	_verifier(suite_max >= 10, "Fenetre humaine de traversee au niveau %d" % (chapitre + 1))
	print("Zigzag niveau %d : %d timings sur 101 passent, plage continue %.2f s." % [chapitre + 1, reussites, suite_max * .01])

func _verifier_geometrie() -> void:
	var limites := Rect2(Vector2(78, 244), Reglages.ARENE_TAILLE)
	for profil in FormesSalles.PROFILS.size():
		var contour := FormesSalles.contour(limites, profil)
		for taille: float in [10.0, 24.0, 38.0]:
			var marge := taille + BestiaireMondes.PROJECTILE_MARGE_DEPART
			for bord in 4:
				for voie in range(1, 20):
					var fraction := float(voie) / 20.0
					var direction := [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT][bord] as Vector2
					var origine := limites.position + Vector2(limites.size.x * fraction, 0)
					if bord == 1: origine = limites.position + Vector2(limites.size.x, limites.size.y * fraction)
					elif bord == 2: origine.y = limites.end.y
					elif bord == 3: origine = limites.position + Vector2(0, limites.size.y * fraction)
					var depart := Geometrie.origine_projectile(origine, direction, limites, contour, [], marge, BestiaireMondes.PROJECTILE_DEGAGEMENT)
					_verifier(depart.is_finite(), "Voie de bord accessible dans le profil %d" % profil)
					if not depart.is_finite(): continue
					_verifier(FormesSalles.contient_disque(depart, contour, marge), "Projectile entier dans le contour")
					_verifier(absf((depart - origine).cross(direction)) < .1, "Recalage conserve la voie annoncee")
					_verifier(depart.is_equal_approx(Geometrie.origine_projectile(depart, direction, limites, contour, [], marge, BestiaireMondes.PROJECTILE_DEGAGEMENT)),
						"Origine identique entre annonce et depart")
	var contour := FormesSalles.contour(limites, 0)
	var bloc := Rect2(limites.get_center() - Vector2(60, 60), Vector2(120, 120))
	_verifier(not Geometrie.origine_projectile(bloc.get_center(), Vector2.DOWN, limites, contour, [bloc], 14.0, 60.0).is_finite(), "Aucun tir teleporte a travers un bloc")
	_verifier(not Geometrie.origine_projectile(limites.position, Vector2.UP, limites, contour, [], 14.0, 60.0).is_finite(), "Tir sortant omis avant son annonce")

func _verifier_tirs_de_bord() -> void:
	_salle.limites = Rect2(Vector2(78, 244), Reglages.ARENE_TAILLE)
	for profil in [0, 7, 8]:
		_salle._contour = FormesSalles.contour(_salle.limites, profil)
		_salle._construire_murs_perimetre()
		await physics_frame
		await physics_frame
		var tirs: Array[Node] = []
		for cote in [0.05, 0.5, 0.95]:
			for taille in [10.0, 38.0]:
				var tir := Tir.new()
				tir.vitesse = 1200.0
				tir.portee = 2600.0
				tir.rayon = taille
				tir.longueur = taille * 2.0
				var origine: Vector2 = _salle.limites.position + Vector2(_salle.limites.size.x * float(cote), 8.0)
				_salle.tirer(tir, origine, Vector2.DOWN, true)
		for projectile: Node in get_nodes_in_group("tirs_ennemis"): tirs.append(projectile)
		_verifier(tirs.size() == 6, "Six tirs de bord materialises dans le profil %d" % profil)
		for image in 4: await physics_frame
		for projectile in tirs:
			_verifier(is_instance_valid(projectile) and not projectile.is_queued_for_deletion(), "Tir de bord survit au depart, profil %d" % profil)
		for enfant in _salle.get_children(): enfant.queue_free()
		await process_frame
	_salle._contour = FormesSalles.contour(_salle.limites, 0)
	var ruban := Tir.new()
	ruban.vitesse = 900.0
	ruban.trajectoire = "sinus"
	ruban.amplitude = 96.0
	ruban.frequence = 1.0
	var bord: Vector2 = Vector2(_salle.limites.end.x - 15.0, _salle.limites.get_center().y)
	_verifier(not _salle._origine_projectile_hostile(bord, Vector2.DOWN, ruban.rayon, ruban).is_finite(),
		"Ondulation vers le mur omise avant le depart")
	_salle.tirer(ruban, bord, Vector2.DOWN, true)
	_verifier(get_nodes_in_group("tirs_ennemis").is_empty(), "Aucun projectile voue a casser des sa premiere ondulation")

func _verifier_boss() -> void:
	_salle._contour = FormesSalles.contour(_salle.limites, 7)
	_salle._construire_murs_perimetre()
	var boss: CharacterBody2D = load("res://scenes/boss.tscn").instantiate()
	boss.configurer(_profil("copiste_aveugle", 17))
	boss.limites = _salle.limites
	boss.position = _salle.limites.position + Vector2(_salle.limites.size.x * .5, 240)
	_cible.position = _salle.limites.get_center()
	_salle.add_child(boss)
	boss.set_physics_process(false)
	boss._cible = _cible
	var tirs_emis: Array[Dictionary] = []
	boss.tir_demande.connect(func(tir: Tir, origine: Vector2, direction: Vector2) -> void:
		tirs_emis.append({"tir": tir, "origine": origine, "direction": direction}))
	for motif: String in ["griffure", "frontieres_encre", "remparts_terre", "marees_eau", "quadrillage", "machoire", "pluie", "onde_marge"]:
		boss._motif = motif
		boss._minuterie = 3.0
		boss._cadence_motif = 0.0
		boss._telegraphe_signature = 0.0
		boss._tirs_annonces.annuler()
		tirs_emis.clear()
		boss._executer_motif(motif, .016)
		var tirs_du_motif: Array = tirs_emis + boss._tirs_annonces.attentes
		_verifier(not tirs_du_motif.is_empty(), "Motif de boss actif : " + motif)
		for attente: Dictionary in tirs_du_motif:
			var tir: Tir = attente["tir"]
			var origine: Vector2 = attente["origine"]
			var rayon := maxf(tir.rayon, tir.longueur * .5)
			_verifier(FormesSalles.contient_disque(origine, _salle._contour, rayon), "Annonce du boss hors des murs : " + motif)
			_verifier(origine.is_equal_approx(_salle._origine_projectile_hostile(origine, attente["direction"], rayon)), "Annonce et depart concordent : " + motif)
	var mondes: RefCounted = boss._motifs_mondes
	boss._motif = "lames_ondulees"
	boss._cadence_motif = 0.0
	boss._minuterie = 3.0
	mondes.reinitialiser()
	mondes.avancer(boss, boss._motif, .016)
	var origine := boss.position
	mondes.avancer(boss, boss._motif, .2)
	_verifier(boss.position.is_equal_approx(origine), "Origine du boss figee pendant l'annonce du monde")
	boss.free()
	await process_frame

func _verifier_annonces_boss() -> void:
	for cas: Array in [["copiste_aveugle", 0, true], ["copiste_aveugle", 17, true], ["la_rature", 0, false], ["l_errata", 34, true], ["gardien_runes", 34, false]]:
		var boss: CharacterBody2D = load("res://scenes/boss.tscn").instantiate()
		boss.configurer(_profil(str(cas[0]), int(cas[1])))
		boss.limites = _salle.limites
		boss.position = _salle.limites.get_center() - Vector2(0, 400)
		_cible.position = _salle.limites.get_center() + Vector2(0, 400)
		_salle.add_child(boss)
		boss.set_physics_process(false)
		boss._cible = _cible
		boss._apparition = 1.0
		boss._minuterie = 3.0
		var tirs: Array[Dictionary] = []
		boss.tir_demande.connect(func(tir: Tir, origine: Vector2, direction: Vector2) -> void:
			tirs.append({"tir": tir, "origine": origine, "direction": direction}))
		var annonce_attendue := bool(cas[2])
		var contexte := "%s niveau %d" % [str(cas[0]), int(cas[1]) + 1]
		boss._lancer(boss.global_position, Vector2.DOWN, 1.0)
		_verifier((not boss._tirs_annonces.attentes.is_empty()) == annonce_attendue, "Boss annonce selon vitesse apres plafonds : " + contexte)
		_verifier(tirs.is_empty() == annonce_attendue, "Boss lent tire sans attendre : " + contexte)
		if annonce_attendue:
			_cible.position.x += 150.0
			boss._physics_process(BestiaireMondes.BOSS_ANNONCE_TIR)
			_verifier(tirs.size() == 1 and boss._tirs_annonces.attentes.is_empty(), "Boss libere le tir apres l'annonce")
			if not tirs.is_empty():
				_verifier((tirs[0]["direction"] as Vector2).is_equal_approx(Vector2.DOWN), "Direction du boss verrouillee pendant l'annonce")
		tirs.clear()
		boss._minuterie = .1
		boss._lancer(boss.global_position, Vector2.DOWN, 1.0)
		_verifier(tirs.is_empty() == annonce_attendue and boss._tirs_annonces.attentes.is_empty(), "Fin de motif ne supprime que les annonces inachevables : " + contexte)
		tirs.clear()
		boss._minuterie = 3.0
		boss._lancer(_cible.global_position - Vector2(0, 60), Vector2.DOWN, 1.0)
		_verifier(tirs.is_empty() and boss._tirs_annonces.attentes.size() == 1, "Tir de bord proche garde un avertissement : " + contexte)
		boss._tirs_annonces.annuler()
		boss._motif = "lames_ondulees"
		boss._cadence_motif = 0.0
		var mondes: RefCounted = boss._motifs_mondes
		mondes.reinitialiser()
		mondes.avancer(boss, boss._motif, .016)
		_verifier((float(mondes.annonce) > 0.0) == annonce_attendue, "Motif de monde suit la meme regle : " + contexte)
		_verifier(tirs.is_empty() == annonce_attendue, "Salve de monde lente part immediatement : " + contexte)
		if annonce_attendue:
			var origine := boss.global_position
			var visee: Vector2 = mondes.cible
			_cible.position.x += 100.0
			mondes.avancer(boss, boss._motif, BestiaireMondes.BOSS_ANNONCE_TIR)
			_verifier(tirs.size() == mondes.angles.size() and boss.global_position.is_equal_approx(origine), "Salve de monde rapide conserve son origine")
			if not tirs.is_empty():
				_verifier((tirs[0]["direction"] as Vector2).is_equal_approx(origine.direction_to(visee).rotated(mondes.angles[0])), "Salve de monde conserve sa visee")
		boss._motif = "encrage_cible"
		boss._cadence_motif = 0.0
		mondes.reinitialiser()
		mondes.avancer(boss, boss._motif, .016)
		_verifier(float(mondes.annonce) > 0.0, "Impact de zone annonce meme pour un boss aux projectiles lents")
		boss.free()
	await process_frame
