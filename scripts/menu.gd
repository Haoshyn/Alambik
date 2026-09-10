extends Control

const ARBRE := preload("res://ui/arbre_competences.tscn")
const MENU_SORTS := preload("res://ui/sorts.tscn")
const SELECTION_GRIMOIRE := preload("res://ui/selection_grimoire.tscn")
const REGLAGES := preload("res://ui/reglages.tscn")
const EQUIPEMENT := preload("res://ui/equipement.tscn")
const TRANSITION := preload("res://ui/transition_grimoire.tscn")
const ONGLET_MENU := preload("res://ui/onglet_menu.gd")
const DUREE_INTRO := 1.55
const PAGES := ["equipement", "aventure", "maitrises", "sorts"]

var _anim := 0.0
var _temps_intro := 0.0
var _intro_active := false
var _conteneur_pages: Control
var _page_actuelle: Control
var _navigation: Control
var _superposition: Control
var _transition_page := false
var _onglets: Array[Button] = []
var _page := 1
var _lancement := false

static var _intro_deja_vue := false

func _ready() -> void:
	if OS.get_name() == "Android":
		get_tree().set_auto_accept_quit(false)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	Sons.musique_menu()
	print("Alambic pret")
	_construire_structure()
	_afficher_page(1, false)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--page-menu="):
			var page_capture := PAGES.find(argument.trim_prefix("--page-menu="))
			if page_capture >= 0:
				_afficher_page(page_capture, false)
	_intro_active = not _intro_deja_vue
	_conteneur_pages.visible = not _intro_active
	_navigation.visible = not _intro_active
	if not _intro_active:
		StyleInterface.animer_entree(_conteneur_pages, 28.0)
	if "--ouvrir-reglages" in OS.get_cmdline_user_args():
		call_deferred("_ouvrir_reglages")
	Capture.programmer(self)

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
	var socle := ColorRect.new()
	socle.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	socle.offset_top = -StyleAzur.HAUTEUR_NAVIGATION - Ecran.marge_basse()
	socle.color = Color("002333")
	socle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_navigation.add_child(socle)
	var barre := HBoxContainer.new()
	barre.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	barre.offset_top = -StyleAzur.HAUTEUR_NAVIGATION - Ecran.marge_basse()
	barre.offset_bottom = -Ecran.marge_basse()
	barre.add_theme_constant_override("separation", 0)
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
			return equipement
		"maitrises":
			var arbre := ARBRE.instantiate()
			arbre.integre_menu = true
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
	page.mine.connect(func(): _lancer_mode("mine", {"nom": "Mine"}))
	page.epreuve.connect(func(): _lancer_mode("epreuve_sorts", {"nom": "Défi alchimique"}))
	page.reglages.connect(_ouvrir_reglages)
	page.jouer.connect(_jouer_immediatement)
	page.page_demandee.connect(_afficher_page)
	return page

func _jouer_immediatement() -> void:
	var chapitre := Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
	var mode := ReglagesJoueur.mode_run_choisi
	_lancer_mode(mode, chapitre if mode == "grimoire" else {"nom":"La Mine" if mode == "mine" else "Épreuves de magie"})

func _lancer_mode(mode: String, destination: Dictionary) -> void:
	if _lancement:
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
	_ouvrir_superposition(selection)

func _ouvrir_reglages() -> void:
	_ouvrir_superposition(REGLAGES.instantiate())

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
	if quoi != NOTIFICATION_WM_GO_BACK_REQUEST:
		return
	if _superposition != null and is_instance_valid(_superposition):
		var cible := _superposition
		StyleInterface.sortir_puis(cible, _fermer_superposition.bind(cible))
	elif _page != 1:
		_afficher_page(1)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _process(delta: float) -> void:
	_anim += delta
	if _intro_active:
		_temps_intro += delta
		if _temps_intro >= DUREE_INTRO:
			_intro_active = false
			_intro_deja_vue = true
			_conteneur_pages.visible = true
			_navigation.visible = true
			StyleInterface.animer_entree(_conteneur_pages, 34.0)
	queue_redraw()

func _draw() -> void:
	var taille := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, taille), Color("192c43"))
	if _intro_active:
		_dessiner_intro(Polices.CORPS, taille)
func _dessiner_intro(police: Font, taille: Vector2) -> void:
	var alpha := clampf(_temps_intro * 4.0, 0.0, 1.0) * clampf((DUREE_INTRO - _temps_intro) * 5.0, 0.0, 1.0)
	var y := taille.y * 0.46
	var centre := Vector2(taille.x * 0.5, y - 118.0)
	Dessin.halo(self, centre, 150.0, Color(Palette.ESSENCE, alpha * 0.32), 6)
	Dessin.glyphe(self, "fiole", centre, 28.0, Color(Palette.OR, alpha))
	draw_string(police, Vector2(0.0, y), "ALAMBIC", HORIZONTAL_ALIGNMENT_CENTER, taille.x, 92, Color(Palette.TEXTE, alpha))
	draw_string(police, Vector2(0.0, y + 72.0), "Le grimoire vivant s'éveille…", HORIZONTAL_ALIGNMENT_CENTER, taille.x, 29, Color(Palette.TEXTE_ATTENUE, alpha))
