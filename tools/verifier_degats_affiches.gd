extends SceneTree

const Nombres = preload("res://scripts/presentation/nombres_degats.gd")
var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_verifier.call_deferred()

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)

func _verifier() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Profil de verification isole requis.")
		quit(1)
		return
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	_groupes()
	for id: String in ["encrier_rampant", "le_correcteur"]:
		await _degats_reels(id)
	for erreur: String in _erreurs: push_error(erreur)
	print("Degats affiches : %d controles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _groupes() -> void:
	var nombres := Nombres.new()
	nombres.ajouter(1, Vector2.ZERO, 12.4, 20.0)
	nombres.ajouter(1, Vector2.ZERO, 7.6, 20.0)
	nombres.ajouter(2, Vector2.ZERO, 31.0, 20.0)
	_exiger(nombres._nombres.size() == 2 and is_equal_approx(float(nombres._nombres[0]["montant"]), 20.0),
		"Salves non regroupees, ou deux ennemis melanges")
	nombres.avancer(Nombres.GROUPE_IMPACTS + 0.01)
	nombres.ajouter(1, Vector2.ZERO, 3.0, 20.0)
	_exiger(nombres._nombres.size() == 3, "Deux impacts espaces sont fusionnes")
	nombres.ajouter(1, Vector2.ZERO, 1.0, 20.0, true)
	_exiger(bool(nombres._nombres.back()["continu"]), "La braise est confondue avec un impact")
	for tick in 10:
		nombres.avancer(0.01)
		nombres.ajouter(1, Vector2.ZERO, 1.0, 20.0, true)
	_exiger(is_equal_approx(float(nombres._nombres.back()["montant"]), 11.0), "Les ticks de braise perdent leur montant")
	for index in 20:
		nombres.avancer(Nombres.GROUPE_IMPACTS + 0.01)
		nombres.ajouter(3, Vector2.ZERO, 1.0, 20.0)
	_exiger(nombres._nombres.size() <= Nombres.MAX_PAR_CIBLE, "Trop de nombres sur une seule cible")
	for index in 100: nombres.ajouter(index, Vector2.ZERO, 100.0, 20.0)
	_exiger(nombres._nombres.size() <= Nombres.MAX_NOMBRES, "Plafond visuel depasse")
	nombres.avancer(Nombres.DUREE + 0.01)
	_exiger(nombres._nombres.is_empty(), "Un texte persiste apres sa duree")
	for index in 100: nombres.ajouter(index, Vector2.ZERO, 100.0, 20.0, false, true)
	_exiger(nombres._nombres.size() == Nombres.MAX_REDUITS, "Plafond des effets reduits ignore")
	nombres.avancer(Nombres.GROUPE_REDUIT + 0.01)
	nombres.ajouter(99, Vector2.ZERO, 4.0, 20.0, false, true)
	nombres.ajouter(99, Vector2.ZERO, 1.0, 20.0, true, true)
	var compte := 0
	for nombre: Dictionary in nombres._nombres:
		if int(nombre["cible"]) == 99: compte += 1
	_exiger(compte == 1, "Les effets reduits empilent des nombres sur une meme cible")
	_exiger(is_equal_approx(float(nombres._nombres.back()["montant"]), 5.0)
		and not bool(nombres._nombres.back()["continu"]), "La braise efface un impact en effets reduits")
	nombres.avancer(Nombres.DUREE_REDUITE + 0.01)
	nombres.ajouter(1, Vector2.ZERO, 0.0, 20.0)
	nombres.ajouter(1, Vector2.ZERO, -10.0, 20.0)
	nombres.ajouter(1, Vector2.ZERO, NAN, 20.0)
	_exiger(nombres._nombres.is_empty(), "Un non-degat est affiche")
	_exiger(Nombres.formater(12.6) == "13" and Nombres.formater(1240.0) == "1,2k"
		and Nombres.formater(2.0e6) == "2M" and Nombres.formater(0.4) == "0,4", "Nombre compact incorrect")

func _degats_reels(id: String) -> void:
	var salle: Node2D = load("res://scripts/monde/salle.gd").new()
	var effets: Node2D = load("res://scripts/presentation/effets.gd").new()
	root.add_child(effets)
	root.add_child(salle)
	effets.set_process(false)
	salle.set_process(false)
	salle.set("effets", effets)
	var apparition: Node2D = load("res://scripts/monde/apparition_ennemi.gd").new()
	apparition.donnees = CatalogueEnnemis.par_id(id).duplicate(true)
	apparition.donnees["pv"] = 10000.0
	apparition.position = Vector2(500, 600)
	salle.call("_materialiser_ennemi", apparition)
	apparition.free()
	var ennemi: Node2D = salle.get_child(0)
	ennemi.set_physics_process(false)
	# La victoire de salle n'entre pas dans ce controle des impacts et de la mort.
	salle.set("_finie", true)
	var mesures: Array[Dictionary] = []
	ennemi.connect("degats_recus", func(_position: Vector2, montant: float, continu: bool) -> void:
		mesures.append({"montant": montant, "continu": continu}))
	ennemi.call("recevoir_degats", 10.0, ["acide"])
	var avant := float(ennemi.get("pv"))
	ennemi.call("recevoir_degats", 25.0)
	var reel := avant - float(ennemi.get("pv"))
	_exiger(is_equal_approx(float(mesures.back()["montant"]), reel) and reel > 25.0,
		"La vulnerabilite acide est absente du nombre : " + id)
	var nombres: RefCounted = effets.get("_nombres_degats")
	var textes: Array = nombres.get("_nombres")
	_exiger(textes.size() == 1 and is_equal_approx(float(textes[0]["montant"]), 10.0 + reel),
		"Le signal ennemi ne rejoint pas le rendu de salle : " + id)
	ennemi.call("recevoir_degats", 20.0, ["braise"])
	avant = float(ennemi.get("pv"))
	ennemi.call("_physics_process" if id == "le_correcteur" else "_appliquer_effets", 0.1)
	_exiger(bool(mesures.back()["continu"]) and is_equal_approx(float(mesures.back()["montant"]), avant - float(ennemi.get("pv"))),
		"Le degat continu affiche differe des PV retires : " + id)
	ennemi.set("pv", 1.0)
	ennemi.call("recevoir_degats", 123.0)
	_exiger(float(mesures.back()["montant"]) >= 123.0 and ennemi.is_queued_for_deletion(),
		"Le dernier coup est tronque aux PV restants : " + id)
	var nombre_mesures := mesures.size()
	ennemi.call("recevoir_degats", 50.0)
	ennemi.call("_physics_process" if id == "le_correcteur" else "_appliquer_effets", 0.1)
	_exiger(mesures.size() == nombre_mesures, "Un ennemi mort emet encore des degats : " + id)
	# Les deux branches de dessin utilisent le meme lot, sans nouvelle valeur de combat.
	effets.set_meta("visuel_3d", true)
	effets.queue_redraw()
	await process_frame
	effets.remove_meta("visuel_3d")
	effets.queue_redraw()
	await process_frame
	salle.queue_free()
	effets.queue_free()
	await process_frame
