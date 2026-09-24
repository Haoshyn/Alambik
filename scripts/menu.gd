extends Control

const ARBRE := preload("res://ui/arbre_competences.tscn")
const MENU_SORTS := preload("res://ui/sorts.tscn")
const SELECTION_GRIMOIRE := preload("res://ui/selection_grimoire.tscn")
const SELECTION_MODE := preload("res://ui/selection_mode.gd")
const REGLAGES := preload("res://ui/reglages.tscn")
const EQUIPEMENT := preload("res://ui/equipement.tscn")
const TRANSITION := preload("res://ui/transition_grimoire.tscn")
const ACCUEIL := preload("res://ui/accueil_clairiere.tscn")
const FOND_MENU := preload("res://ui/composants/fond_menu_vivant.gd")
const NAVIGATION := preload("res://ui/composants/navigation_principale.tscn")
const PAGES := ["heros", "equipement", "aventure", "maitrises", "sorts"]

var _fond_menu: FondMenuVivant
var _chapitre_fond := -1
var _conteneur_pages: Control
var _page_actuelle: Control
var _navigation: NavigationPrincipale
var _superposition: Control
var _transition_page := false
var _page := 2
var _lancement := false
var _selection_initiale := ""
var _mode_apres_classe := ""
var _destination_apres_classe := {}
var _arrondi_controles_avant := true
var _arrondi_transformations_avant := true
var _arrondi_sommets_avant := true


func _ready() -> void:
	_configurer_rendu_lisse()
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
	_afficher_page(page_initiale if page_initiale >= 0 else 2, false)
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
	if OS.get_cmdline_user_args().is_empty() \
			and ReglagesJoueur.specialisation_effective().is_empty() and not ReglagesJoueur.tutoriel_vu:
		_demarrer_premiers_pas.call_deferred()

func _configurer_rendu_lisse() -> void:
	var vue := get_viewport()
	_arrondi_controles_avant = vue.gui_snap_controls_to_pixels
	_arrondi_transformations_avant = vue.snap_2d_transforms_to_pixel
	_arrondi_sommets_avant = vue.snap_2d_vertices_to_pixel
	# Les images peintes animees ont besoin de positions inferieures au pixel.
	vue.gui_snap_controls_to_pixels = false
	vue.snap_2d_transforms_to_pixel = false
	vue.snap_2d_vertices_to_pixel = false

func _exit_tree() -> void:
	var vue := get_viewport()
	vue.gui_snap_controls_to_pixels = _arrondi_controles_avant
	vue.snap_2d_transforms_to_pixel = _arrondi_transformations_avant
	vue.snap_2d_vertices_to_pixel = _arrondi_sommets_avant

func _process(_delta: float) -> void:
	if not is_instance_valid(_fond_menu):
		return
	if _chapitre_fond != ReglagesJoueur.chapitre_choisi:
		_chapitre_fond = ReglagesJoueur.chapitre_choisi
		var chapitre: Dictionary = Chapitres.par_index(_chapitre_fond)
		_fond_menu.afficher_monde(int(chapitre["monde"]))
	if _page == 2 and _page_actuelle is AccueilClairiere:
		_fond_menu.suivre_accueil((_page_actuelle as AccueilClairiere).cadre_monde_global())

func _ouvrir_classes_initiales(mode := "", destination := {}) -> void:
	if _superposition != null:
		_fermer_superposition(_superposition)
	_mode_apres_classe = mode
	_destination_apres_classe = destination
	var choix := preload("res://ui/choix_classe.gd").new()
	choix.obligatoire = true
	_ouvrir_superposition(choix)
	if _superposition == choix:
		choix.ferme.connect(_reprendre_apres_classe)

func _reprendre_apres_classe() -> void:
	if ReglagesJoueur.specialisation_effective().is_empty() or _mode_apres_classe.is_empty():
		return
	var mode := _mode_apres_classe
	var destination: Dictionary = _destination_apres_classe
	_mode_apres_classe = ""
	_destination_apres_classe = {}
	_lancer_mode.call_deferred(mode, destination)

func _demarrer_premiers_pas() -> void:
	if ReglagesJoueur.tutoriel_vu or not ReglagesJoueur.specialisation_effective().is_empty():
		return
	ReglagesJoueur.choisir_chapitre(0)
	_lancer_mode("grimoire", Chapitres.par_index(0), true)

func _construire_structure() -> void:
	_fond_menu = FOND_MENU.new()
	_fond_menu.name = "FondPartage"
	_fond_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fond_menu)
	_conteneur_pages = Control.new()
	_conteneur_pages.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_conteneur_pages)
	_construire_navigation()

func _construire_navigation() -> void:
	_navigation = NAVIGATION.instantiate() as NavigationPrincipale
	_navigation.page_demandee.connect(_afficher_page)
	add_child(_navigation)

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
		"heros":
			return preload("res://ui/heros.gd").new()
		"sorts":
			var sorts := MENU_SORTS.instantiate()
			sorts.integre_menu = true
			sorts.page_demandee.connect(_afficher_page)
			sorts.reglages.connect(_ouvrir_reglages)
			return sorts
	return _creer_aventure()

func _afficher_page(index: int, anime := true) -> void:
	if _superposition != null:
		if bool(_superposition.get_meta("carte_campagne", false)):
			_fermer_superposition(_superposition)
		else:
			return
	if _lancement or _transition_page:
		return
	if is_instance_valid(_page_actuelle) and _page_actuelle.has_method("fermer_fiche") and bool(_page_actuelle.call("fermer_fiche")):
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
	_navigation.selectionner(_page)
	_fond_menu.presenter_page(index != 2, index != 2)
	if ancienne == null:
		return
	Sons.jouer("choix", -17.0, 1.08)
	if not anime or ReglagesJoueur.effets_reduits:
		ancienne.queue_free()
		return
	_transition_page = true
	ancienne.process_mode = Node.PROCESS_MODE_DISABLED
	var direction := 1.0 if index > ancienne_page else -1.0
	var distance := 96.0
	nouvelle.position.x = distance * direction
	nouvelle.modulate.a = 0.0
	var sortie := ancienne.create_tween().set_parallel(true)
	sortie.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	sortie.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	sortie.tween_property(ancienne, "position:x", -distance * direction, 0.16)
	sortie.tween_property(ancienne, "modulate:a", 0.0, 0.12)
	var entree := nouvelle.create_tween().set_parallel(true)
	entree.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	entree.tween_property(nouvelle, "position:x", 0.0, 0.24)
	entree.tween_property(nouvelle, "modulate:a", 1.0, 0.18)
	await sortie.finished
	if is_instance_valid(ancienne):
		ancienne.queue_free()
	await entree.finished
	_transition_page = false

func _creer_aventure() -> Control:
	var page := ACCUEIL.instantiate() as AccueilClairiere
	page.get_node("Illustration").set("fond_externe", true)
	var scene: SceneAccueil = page.get_node("ZoneSure/Defilement/Composition/Scene")
	scene.ile_externe = true
	page.campagne.connect(_ouvrir_campagne)
	page.mine.connect(_ouvrir_mine)
	page.epreuve.connect(_ouvrir_epreuves)
	page.reglages.connect(_ouvrir_reglages)
	page.jouer.connect(_jouer_immediatement)
	page.page_demandee.connect(_afficher_page)
	return page

func _jouer_immediatement() -> void:
	var chapitre := Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
	_lancer_mode("grimoire", chapitre)

func _lancer_mode(mode: String, destination: Dictionary, apprentissage_initial := false) -> void:
	if _lancement or not ReglagesJoueur.mode_debloque(mode):
		return
	if ReglagesJoueur.specialisation_effective().is_empty() and not apprentissage_initial:
		_ouvrir_classes_initiales(mode, destination)
		return
	_lancement = true
	ReglagesJoueur.choisir_mode_run(mode)
	Sons.jouer("choix", -10.0)
	Sons.demarrer_musique_combat()
	var transition := TRANSITION.instantiate()
	transition.configurer(destination)
	add_child(transition)
	transition.terminee.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/run.tscn"))

func _ouvrir_campagne() -> void:
	var selection := SELECTION_GRIMOIRE.instantiate()
	selection.selection_seulement = true
	selection.set_meta("carte_campagne", true)
	_ouvrir_superposition(selection)

func _ouvrir_mine() -> void:
	if not ReglagesJoueur.mode_debloque("mine"):
		return
	var selection := SELECTION_MODE.new()
	selection.mode = "mine"
	selection.lancement_demande.connect(func() -> void:
		_fermer_superposition(selection)
		_lancer_mode("mine", {"nom": "La Mine · niveau %d" % ReglagesJoueur.niveau_mine_choisi}))
	_ouvrir_superposition(selection)

func _ouvrir_epreuves() -> void:
	if not ReglagesJoueur.mode_debloque("epreuve_sorts"):
		return
	var selection := SELECTION_MODE.new()
	selection.mode = "epreuve_sorts"
	selection.lancement_demande.connect(func() -> void:
		_fermer_superposition(selection)
		_lancer_mode("epreuve_sorts", {"nom": "Épreuve de magie · niveau %d" % ReglagesJoueur.niveau_epreuve_choisi}))
	_ouvrir_superposition(selection)

func _ouvrir_reglages() -> void:
	_ouvrir_superposition(REGLAGES.instantiate())

func _ouvrir_superposition(panneau: Control) -> void:
	if _superposition != null or _lancement or _transition_page:
		panneau.free()
		return
	Sons.jouer("choix", -12.0)
	_superposition = panneau
	panneau.set_meta("fond_menu_partage", true)
	var carte_campagne := bool(panneau.get_meta("carte_campagne", false))
	if carte_campagne and _page_actuelle is AccueilClairiere:
		(_page_actuelle as AccueilClairiere).presenter_campagne(true)
	# Les _input des inventaires ne doivent pas reagir sous une fenetre modale.
	_conteneur_pages.process_mode = Node.PROCESS_MODE_DISABLED
	_navigation.process_mode = Node.PROCESS_MODE_INHERIT if carte_campagne else Node.PROCESS_MODE_DISABLED
	add_child(panneau)
	_fond_menu.presenter_superposition(true, carte_campagne)
	move_child(_navigation if carte_campagne else panneau, get_child_count() - 1)
	if panneau.has_signal("ferme"):
		panneau.ferme.connect(_fermer_superposition.bind(panneau))

func _fermer_superposition(panneau: Control) -> void:
	if _superposition != panneau:
		return
	_superposition = null
	panneau.queue_free()
	if bool(panneau.get_meta("carte_campagne", false)) and _page_actuelle is AccueilClairiere:
		(_page_actuelle as AccueilClairiere).presenter_campagne(false)
	_fond_menu.presenter_superposition(false)
	_conteneur_pages.process_mode = Node.PROCESS_MODE_INHERIT
	_navigation.process_mode = Node.PROCESS_MODE_INHERIT
	if is_instance_valid(_page_actuelle) and _page_actuelle.has_method("rafraichir"):
		_page_actuelle.rafraichir()
	queue_redraw()

func _notification(quoi: int) -> void:
	if quoi != NOTIFICATION_WM_GO_BACK_REQUEST or _lancement or _transition_page:
		return
	if is_instance_valid(_page_actuelle) and _page_actuelle.has_method("fermer_fiche") and bool(_page_actuelle.call("fermer_fiche")):
		return
	if _superposition != null and is_instance_valid(_superposition):
		if bool(_superposition.get("obligatoire")): return
		var cible := _superposition
		StyleInterface.sortir_puis(cible, _fermer_superposition.bind(cible))
	elif _page != 2:
		_afficher_page(2)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _draw() -> void:
	var taille := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, taille), StyleAzur.FOND)
