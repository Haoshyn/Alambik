extends Node

signal consigne_changee(numero: int)
signal visibilite_changee(visible: bool)
signal termine

enum Etape { DEPLACEMENT, TIR, COMBAT, PORTAIL, TERMINE }

var _etape := Etape.DEPLACEMENT
var _heros: CharacterBody2D
var _salle: Node2D
var _position_precedente := Vector2.ZERO
var _distance_parcourue := 0.0
var _intention := Vector2.ZERO
var _suspendu := true
var _conseil_visible := false
var _noeuds_suspendus: Array[Dictionary] = []

static func disponible(arguments: PackedStringArray) -> bool:
	if Jeu.mode_auto or Capture.demandee() or DisplayServer.get_name() == "headless" \
			or ReglagesJoueur.tutoriel_vu or Jeu.mode_run != "grimoire" \
			or Jeu.chapitre != 0 or Jeu.salle_courante != 1:
		return false
	for argument in arguments:
		if argument.begins_with("--ouvrir-") or argument == "--hud-complet":
			return false
	return true

func configurer(heros: CharacterBody2D, salle: Node2D) -> void:
	_heros = heros
	_salle = salle
	_position_precedente = _heros.global_position
	_heros.configurer_apprentissage(true, true)
	_heros.tir_demande.connect(_sur_tir)
	_salle.terminee.connect(_sur_portail_traverse)
	# Les collisions restent actives : meme pendant l'explication, les murs
	# doivent enseigner les vrais chemins de la salle.
	_suspendre_noeud(_salle)
	_suspendre_noeud(_salle.terrain_elementaire())
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		_suspendre_noeud(ennemi)
	consigne_changee.emit(0)

func definir_intention(direction: Vector2, intensite: float) -> void:
	_intention = direction if intensite > 0.0 else Vector2.ZERO

func suspendre(suspendu: bool) -> void:
	_suspendu = suspendu
	_actualiser_visibilite()

func combat_suspendu() -> bool:
	return _etape in [Etape.DEPLACEMENT, Etape.TIR]

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_heros) or _etape == Etape.TERMINE:
		return
	var position_courante := _heros.global_position
	if not _suspendu and _etape == Etape.DEPLACEMENT and _intention != Vector2.ZERO:
		_distance_parcourue += position_courante.distance_to(_position_precedente)
		if _distance_parcourue >= Reglages.APPRENTISSAGE_DISTANCE_DEPLACEMENT:
			_etape = Etape.TIR
			_heros.configurer_apprentissage(true, false)
			consigne_changee.emit(1)
	_position_precedente = position_courante

func _process(_delta: float) -> void:
	if _suspendu or _etape == Etape.TERMINE:
		return
	if _etape == Etape.COMBAT and _salle.portail_ouvert() \
			and get_tree().get_nodes_in_group("tirs_ennemis").is_empty():
		_etape = Etape.PORTAIL
		_heros.configurer_apprentissage(true, false)
		consigne_changee.emit(3)
		_actualiser_visibilite()

func _sur_tir(_tir: Tir, _origine: Vector2, _direction: Vector2) -> void:
	# Aucun tir ne peut etre prepare avant le deplacement ; le premier vient
	# donc d'un vrai arret, meme si le pouce repart pendant son animation.
	if _suspendu or _etape != Etape.TIR:
		return
	_etape = Etape.COMBAT
	_reprendre_combat()
	_heros.configurer_apprentissage(false, false)
	consigne_changee.emit(2)
	_actualiser_visibilite()

func _sur_portail_traverse() -> void:
	# Le joueur peut atteindre le portail avant la disparition du dernier
	# projectile. Le passage reel valide aussi ce cas, sans attendre l'UI.
	if _etape in [Etape.COMBAT, Etape.PORTAIL] and _salle.portail_ouvert():
		_terminer(true)

func passer() -> void:
	_terminer(true)

func interrompre() -> void:
	_terminer(false)

func _terminer(enregistrer: bool) -> void:
	if _etape == Etape.TERMINE:
		return
	_etape = Etape.TERMINE
	_reprendre_combat()
	if is_instance_valid(_heros):
		_heros.configurer_apprentissage(false, false)
	_actualiser_visibilite()
	if enregistrer:
		ReglagesJoueur.tutoriel_vu = true
		ReglagesJoueur.sauvegarder()
	termine.emit()
	queue_free()

func _suspendre_noeud(noeud: Node) -> void:
	if not is_instance_valid(noeud):
		return
	_noeuds_suspendus.append({"noeud": noeud, "process": noeud.is_processing(),
		"physique": noeud.is_physics_processing()})
	noeud.set_process(false)
	noeud.set_physics_process(false)

func _reprendre_combat() -> void:
	for etat: Dictionary in _noeuds_suspendus:
		var noeud: Node = etat["noeud"]
		if is_instance_valid(noeud):
			noeud.set_process(bool(etat["process"]))
			noeud.set_physics_process(bool(etat["physique"]))
	_noeuds_suspendus.clear()

func _actualiser_visibilite() -> void:
	var afficher := not _suspendu and not get_tree().paused \
		and _etape in [Etape.DEPLACEMENT, Etape.TIR, Etape.COMBAT, Etape.PORTAIL]
	if afficher == _conseil_visible:
		return
	_conseil_visible = afficher
	visibilite_changee.emit(afficher)

func _notification(quoi: int) -> void:
	if quoi == NOTIFICATION_PAUSED and _conseil_visible:
		_conseil_visible = false
		visibilite_changee.emit(false)

func _exit_tree() -> void:
	_reprendre_combat()
	if is_instance_valid(_heros):
		_heros.configurer_apprentissage(false, false)
