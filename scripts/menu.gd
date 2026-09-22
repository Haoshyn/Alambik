extends Control

const ARBRE := preload("res://ui/arbre_competences.tscn")
const MENU_SORTS := preload("res://ui/sorts.tscn")
const SELECTION_GRIMOIRE := preload("res://ui/selection_grimoire.tscn")
const REGLAGES := preload("res://ui/reglages.tscn")
const EQUIPEMENT := preload("res://ui/equipement.tscn")
const TRANSITION := preload("res://ui/transition_grimoire.tscn")
const ONGLET_MENU := preload("res://ui/onglet_menu.gd")
const PAGES := ["equipement", "aventure", "maitrises", "sorts"]

var _conteneur_pages: Control
var _page_actuelle: Control
var _navigation: Control
var _superposition: Control
var _transition_page := false
var _onglets: Array[Button] = []
var _page := 1
var _lancement := false
var _selection_initiale := ""
var _guide_tutoriel: GuideAccueil


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if OS.get_name() == "Android":
		get_tree().set_auto_accept_quit(false)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	Sons.musique_menu()
	print("Alambic pret")
	_construire_structure()
	var destination := Jeu.destination_menu.duplicate()
	Jeu.destination_menu.clear()
	_selection_initiale = str(destination.get("selection", ""))
	var page_initiale := PAGES.find(str(destination.get("page", "aventure")))
	_afficher_page(page_initiale if page_initiale >= 0 else 1, false)
	_selection_initiale = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--page-menu="):
			var page_capture := PAGES.find(argument.trim_prefix("--page-menu="))
			if page_capture >= 0:
				_afficher_page(page_capture, false)
	StyleInterface.animer_entree(_conteneur_pages, 28.0)
	if "--ouvrir-reglages" in OS.get_cmdline_user_args():
		call_deferred("_ouvrir_reglages")
	Capture.programmer(self)
	if not Capture.demandee() and DisplayServer.get_name() != "headless":
		_guide_tutoriel = preload("res://ui/guide_accueil.gd").new()
		add_child(_guide_tutoriel)
		_guide_tutoriel.action_demandee.connect(_action_tutoriel)
		_guide_tutoriel.passe.connect(_actualiser_tutoriel)
		ReglagesJoueur.maitrise_changee.connect(_actualiser_tutoriel)
		call_deferred("_presenter_tutoriel")

func _construire_structure() -> void:
	_conteneur_pages = Control.new()
	_conteneur_pages.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_conteneur_pages)
	_construire_navigation()

func _construire_navigation() -> void:
	_navigation = Control.new()
	_navigation.set_anchors_preset(Control.PRESET_FULL_RECT)
	_navigation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_navigation)
	var socle := Panel.new()
	HabillagePeint.appliquer(socle)
	socle.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	socle.offset_top = -StyleAzur.HAUTEUR_NAVIGATION - Ecran.marge_basse()
	socle.offset_left = 12
	socle.offset_right = -12
	socle.add_theme_stylebox_override("panel", StyleAzur.texture_etirable("navigation", 40, 24, 16))
	socle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_navigation.add_child(socle)
	var barre := HBoxContainer.new()
	barre.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	barre.offset_top = -StyleAzur.HAUTEUR_NAVIGATION - Ecran.marge_basse()
	barre.offset_bottom = -Ecran.marge_basse()
	barre.offset_left = 24
	barre.offset_right = -24
	barre.add_theme_constant_override("separation", 8)
	_navigation.add_child(barre)
	var donnees := [
		["stuff", "ÉQUIPEMENT", 2],
		["aventure", "AVENTURE", 0],
		["arbre", "MAÎTRISES", 3],
		["sorts", "SORTS", 4],
	]
	for index in donnees.size():
		var onglet := OngletMenu.new()
		onglet.configurer(donnees[index][0], donnees[index][1], index)
		onglet.pressed.connect(func() -> void: _afficher_page(index))
		barre.add_child(onglet)
		_onglets.append(onglet)

func _creer_page(index: int) -> Control:
	match PAGES[index]:
		"equipement":
			var equipement := EQUIPEMENT.instantiate()
			equipement.integre_menu = true
			equipement.objet_initial = _selection_initiale
			return equipement
		"maitrises":
			var arbre := ARBRE.instantiate()
			arbre.integre_menu = true
			arbre.maitrise_initiale = _selection_initiale
			return arbre
		"sorts":
			var sorts := MENU_SORTS.instantiate()
			sorts.integre_menu = true
			return sorts
	return _creer_aventure()

func _afficher_page(index: int, anime := true) -> void:
	if _superposition != null or _lancement or _transition_page:
		return
	index = clampi(index, 0, PAGES.size() - 1)
	if _page_actuelle != null and index == _page:
		return
	var ancienne := _page_actuelle
	var ancienne_page := _page
	_page = index
	# La navigation reste visible et identique sur toutes les pages.
	_navigation.modulate.a = 1.0
	_navigation.visible = true
	var nouvelle := _creer_page(index)
	_page_actuelle = nouvelle
	_conteneur_pages.add_child(nouvelle)
	for i in _onglets.size():
		_onglets[i].actif = i == _page
	if ancienne == null:
		return
	Sons.jouer("choix", -17.0, 1.08)
	if not anime:
		ancienne.queue_free()
		return
	_transition_page = true
	ancienne.process_mode = Node.PROCESS_MODE_DISABLED
	var direction := 1.0 if index > ancienne_page else -1.0
	var distance := 32.0 if ReglagesJoueur.effets_reduits else 180.0
	nouvelle.position.x = distance * direction
	nouvelle.modulate.a = 0.0
	var sortie := ancienne.create_tween().set_parallel(true)
	sortie.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	sortie.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	sortie.tween_property(ancienne, "position:x", -distance * direction, 0.22)
	sortie.tween_property(ancienne, "modulate:a", 0.0, 0.16)
	var entree := nouvelle.create_tween().set_parallel(true)
	entree.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	entree.tween_property(nouvelle, "position:x", 0.0, 0.34)
	entree.tween_property(nouvelle, "modulate:a", 1.0, 0.24)
	await sortie.finished
	if is_instance_valid(ancienne):
		ancienne.queue_free()
	await entree.finished
	_transition_page = false

func _creer_aventure() -> Control:
	var page := Control.new()
	page.set_script(preload("res://ui/accueil_3d.gd"))
	page.campagne.connect(_ouvrir_campagne)
	page.mine.connect(func(): _ouvrir_campagne("mine"))
	page.epreuve.connect(func(): _ouvrir_campagne("epreuve_sorts"))
	page.reglages.connect(_ouvrir_reglages)
	page.jouer.connect(_jouer_immediatement)
	page.page_demandee.connect(_afficher_page)
	page.tutoriel_demande.connect(_presenter_tutoriel)
	return page

func _jouer_immediatement() -> void:
	var chapitre := Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
	var mode := ReglagesJoueur.mode_run_choisi
	_lancer_mode(mode, chapitre if mode == "grimoire" else {"nom":"La Mine" if mode == "mine" else "Épreuves de magie"})

func _lancer_mode(mode: String, destination: Dictionary) -> void:
	if _lancement or not ReglagesJoueur.mode_debloque(mode):
		return
	if ParcoursTutoriel.niveau_a_faire() and mode != DonneesTutoriel.MODE:
		_presenter_tutoriel()
		return
	if mode != DonneesTutoriel.MODE and ReglagesJoueur.specialisation.is_empty():
		# Le premier choix est gratuit et structure tout le build ; une aventure
		# ne doit pas commencer avec une specialisation choisie en silence.
		if _superposition != null:
			_fermer_superposition(_superposition)
		_afficher_page(PAGES.find("maitrises"))
		return
	_lancement = true
	if is_instance_valid(_guide_tutoriel):
		_guide_tutoriel.hide()
	if mode == DonneesTutoriel.MODE:
		ParcoursTutoriel.commencer()
		Jeu.nouvelle_tentative = {"mode": mode, "chapitre": 0, "epreuve": 1}
	ReglagesJoueur.choisir_mode_run(mode)
	Sons.jouer("choix", -10.0)
	Sons.demarrer_musique_combat()
	var transition := TRANSITION.instantiate()
	transition.configurer(destination)
	add_child(transition)
	transition.terminee.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/run.tscn"))

func _ouvrir_campagne(mode := "") -> void:
	var selection := SELECTION_GRIMOIRE.instantiate()
	selection.selection_seulement = true
	selection.mode_initial = mode
	_ouvrir_superposition(selection)

func _ouvrir_reglages(section := "") -> void:
	var reglages := REGLAGES.instantiate()
	reglages.section_tutoriel = section
	_ouvrir_superposition(reglages)

func _presenter_tutoriel() -> void:
	if is_instance_valid(_guide_tutoriel) and not _lancement and _superposition == null \
			and not _transition_page:
		_guide_tutoriel.presenter()

func _actualiser_tutoriel() -> void:
	if is_instance_valid(_guide_tutoriel):
		_guide_tutoriel.actualiser()
	if is_instance_valid(_page_actuelle) and _page_actuelle.has_method("rafraichir"):
		_page_actuelle.rafraichir()

func _action_tutoriel(action: String) -> void:
	match action:
		"combat":
			_lancer_mode(DonneesTutoriel.MODE, {"nom": "Premiers pas · Tutoriel"})
		"accueil", "maitrises":
			ParcoursTutoriel.noter("accueil_vu")
			_selection_initiale = DonneesTutoriel.MAITRISE
			_afficher_page(PAGES.find("maitrises"))
			_selection_initiale = ""
		"musique":
			_ouvrir_reglages("musique")
		"mine":
			_lancer_mode("mine", {"nom": "La Mine"})
		"epreuve_sorts":
			ReglagesJoueur.choisir_epreuve(1)
			_lancer_mode("epreuve_sorts", {"nom": "Épreuve de magie · niveau 1"})
		"commandes":
			ReglagesJoueur.equiper_sort(ParcoursTutoriel.sort_a_expliquer(), "actif")
			_ouvrir_reglages("commandes")
		"sort":
			_afficher_page(PAGES.find("sorts"))
		"campagne":
			_lancer_mode("grimoire", Chapitres.par_index(ReglagesJoueur.chapitre_choisi))
		"fin":
			ParcoursTutoriel.conclure()
		"plus_tard":
			if ParcoursTutoriel.prochaine_etape() == "accueil":
				ParcoursTutoriel.noter("accueil_vu")
	_actualiser_tutoriel()

func _ouvrir_superposition(panneau: Control) -> void:
	if _superposition != null or _lancement or _transition_page:
		panneau.free()
		return
	Sons.jouer("choix", -12.0)
	_superposition = panneau
	# Les _input des inventaires ne doivent pas reagir sous une fenetre modale.
	_conteneur_pages.process_mode = Node.PROCESS_MODE_DISABLED
	_navigation.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(panneau)
	move_child(panneau, get_child_count() - 1)
	if panneau.has_signal("ferme"):
		panneau.ferme.connect(_fermer_superposition.bind(panneau))

func _fermer_superposition(panneau: Control) -> void:
	if _superposition != panneau:
		return
	_superposition = null
	panneau.queue_free()
	_conteneur_pages.process_mode = Node.PROCESS_MODE_INHERIT
	_navigation.process_mode = Node.PROCESS_MODE_INHERIT
	if is_instance_valid(_page_actuelle) and _page_actuelle.has_method("rafraichir"):
		_page_actuelle.rafraichir()
	queue_redraw()

func _notification(quoi: int) -> void:
	if is_instance_valid(_guide_tutoriel) and _guide_tutoriel.est_ouvert():
		return
	if quoi != NOTIFICATION_WM_GO_BACK_REQUEST or _lancement or _transition_page:
		return
	if _superposition != null and is_instance_valid(_superposition):
		var cible := _superposition
		StyleInterface.sortir_puis(cible, _fermer_superposition.bind(cible))
	elif _page != 1:
		_afficher_page(1)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _draw() -> void:
	var taille := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, taille), StyleAzur.FOND)
