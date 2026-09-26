extends Control

signal ferme
signal selection_changee

const TRANSITION := preload("res://ui/transition_grimoire.tscn")
var selection_seulement := false
var _monde := 0
var _chapitre_monde := 0
var _lancement := false
var _zones_chapitres: Array[RepereCampagne] = []
var _bouton_selectionner: Button
var _titre: Label
var _indice_monde: Label
var _sous_titre: Label
var _progression: Label
var _selection_titre: Label
var _details: Label
var _progression_etage: ProgressBar
var _carte: CarteCampagne
var _panneau_selection: PanelContainer
var _panneau_monde: PanelContainer
var _precedent: Button
var _suivant: Button
var _apercu: Control
var _marges: MarginContainer
var _zone_monde: Control
var _defilement: DefilementTactile
var _glissement_depart := Vector2.ZERO
var _glissement_actif := false

func _ready() -> void:
	_monde = clampi(ReglagesJoueur.chapitre_choisi / Chapitres.CHAPITRES_PAR_MONDE, 0, Chapitres.MONDES.size() - 1)
	_chapitre_monde = posmod(ReglagesJoueur.chapitre_choisi, Chapitres.CHAPITRES_PAR_MONDE)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	theme = StyleAzur.theme_interface()
	_marges = MarginContainer.new()
	_marges.name = "MargesCampagne"
	add_child(_marges)
	_marges.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var contenu := VBoxContainer.new()
	contenu.add_theme_constant_override("separation", 14)
	_marges.add_child(contenu)
	var entete := HBoxContainer.new()
	entete.name = "EnteteCampagne"
	entete.custom_minimum_size.y = 104
	contenu.add_child(entete)
	var retour := StyleAzur.bouton_rond("", _fermer, 104.0)
	retour.name = "RetourCampagne"
	retour.icon = StyleAzur.texture_interface("fleche_gauche")
	retour.expand_icon = true
	retour.add_theme_constant_override("icon_max_width", 62)
	retour.tooltip_text = "Retour à l’aventure"
	retour.accessibility_name = "Retour à l’aventure"
	entete.add_child(retour)
	var titre_campagne := StyleAzur.calligraphie("Campagne", 52, StyleAzur.OR_VIF)
	titre_campagne.name = "TitreCampagne"
	titre_campagne.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titre_campagne.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(titre_campagne)
	var espace_retour := Control.new()
	espace_retour.custom_minimum_size.x = 104
	entete.add_child(espace_retour)
	_defilement = preload("res://ui/composants/defilement_tactile.gd").new()
	_defilement.name = "DefilementCampagne"
	_defilement.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_defilement.follow_focus = true
	_defilement.verrou_vertical = true
	contenu.add_child(_defilement)
	var corps := VBoxContainer.new()
	corps.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corps.add_theme_constant_override("separation", 14)
	_defilement.add_child(corps)
	_defilement.resized.connect(func(): corps.custom_minimum_size.y = _defilement.size.y)
	var textes := VBoxContainer.new()
	textes.name = "EnteteMonde"
	textes.add_theme_constant_override("separation", 6)
	_panneau_monde = PanelContainer.new()
	_panneau_monde.name = "CartoucheMondeEtNiveau"
	_panneau_monde.add_theme_stylebox_override("panel", StyleAzur.cadre_enlumine(StyleAzur.LILAS))
	corps.add_child(_panneau_monde)
	_panneau_monde.add_child(textes)
	_indice_monde = StyleAzur.texte("", 28, StyleAzur.CUIVRE)
	_indice_monde.add_theme_font_override("font", Polices.CHIFFRES)
	_titre = StyleAzur.calligraphie("", 52, StyleAzur.OR_VIF)
	_sous_titre = StyleAzur.texte("", 28, StyleAzur.LILAS)
	_progression = StyleAzur.texte("", 26, StyleAzur.MAGIE)
	for etiquette in [_indice_monde, _titre, _sous_titre, _progression]:
		etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		textes.add_child(etiquette)
	_zone_monde = Control.new()
	_zone_monde.name = "ZoneMonde"
	_zone_monde.custom_minimum_size.y = 420
	_zone_monde.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_zone_monde.size_flags_vertical = Control.SIZE_EXPAND_FILL
	corps.add_child(_zone_monde)
	_carte = CarteCampagne.new()
	_carte.name = "CarteMonde"
	_zone_monde.add_child(_carte)
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var etape := RepereCampagne.new()
		_carte.ajouter_etape(etape)
		etape.activee.connect(_choisir_chapitre)
		_zones_chapitres.append(etape)
	_precedent = _creer_fleche_monde("MondePrecedent", "fleche_gauche", -1)
	_suivant = _creer_fleche_monde("MondeSuivant", "fleche_droite", 1)
	_zone_monde.resized.connect(_replacer_monde)
	resized.connect(_cadrer)
	_cadrer()
	_replacer_monde.call_deferred()
	_panneau_selection = PanelContainer.new()
	_panneau_selection.add_theme_stylebox_override("panel", _style_selection(StyleAzur.VIOLET))
	corps.add_child(_panneau_selection)
	var selection := VBoxContainer.new()
	selection.add_theme_constant_override("separation", 10)
	_panneau_selection.add_child(selection)
	var presentation := HBoxContainer.new()
	presentation.add_theme_constant_override("separation", 14)
	textes.add_child(presentation)
	presentation.add_child(StyleAzur.illustration("fiole", 64))
	var textes_selection := VBoxContainer.new()
	textes_selection.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	presentation.add_child(textes_selection)
	_selection_titre = StyleAzur.texte("", 32, StyleAzur.CUIVRE)
	_selection_titre.name = "NiveauSelectionne"
	_selection_titre.add_theme_font_override("font", Polices.CHIFFRES)
	textes_selection.add_child(_selection_titre)
	_details = StyleAzur.texte("", 30, StyleAzur.MENTHE)
	_details.name = "MeilleurEtage"
	textes_selection.add_child(_details)
	_progression_etage = ProgressBar.new()
	_progression_etage.show_percentage = false
	_progression_etage.custom_minimum_size.y = 16
	_progression_etage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes_selection.add_child(_progression_etage)
	var actions := BoxContainer.new()
	StyleAzur.adapter_ligne(actions, 390.0)
	actions.add_theme_constant_override("separation", 10)
	selection.add_child(actions)
	_bouton_selectionner = StyleAzur.bouton("Choisir ce niveau" if selection_seulement else "Jouer ce niveau", _selectionner, true)
	StyleAzur.habiller_accueil(_bouton_selectionner, true)
	_bouton_selectionner.add_theme_font_size_override("font_size", 36)
	_bouton_selectionner.custom_minimum_size.y = 102
	actions.add_child(_bouton_selectionner)
	var butin := StyleAzur.bouton("", func(): _voir_loots(_index_selectionne()))
	butin.icon = preload("res://assets/visual/interface/menu/coffre_butin.svg")
	butin.custom_minimum_size = Vector2(128, 88)
	butin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	butin.add_theme_constant_override("icon_max_width", 48)
	butin.accessibility_name = "Voir le butin"
	butin.tooltip_text = "Butin du niveau"
	actions.add_child(butin)
	_rafraichir()
	Capture.programmer(self)

func _cadrer() -> void:
	if not is_instance_valid(_marges):
		return
	var lateral := maxi(28, int((size.x - 1080.0) * 0.5))
	_marges.add_theme_constant_override("margin_left", maxi(lateral, int(Ecran.marge_gauche())))
	_marges.add_theme_constant_override("margin_right", maxi(lateral, int(Ecran.marge_droite())))
	_marges.add_theme_constant_override("margin_top", int(Ecran.marge_haute()) + (150 if size.x >= 880.0 else 264))
	_marges.add_theme_constant_override("margin_bottom", int(Ecran.marge_basse() + StyleAzur.HAUTEUR_NAVIGATION + StyleAzur.MARGE_NAVIGATION_BAS + 24))

func _creer_fleche_monde(nom: String, symbole: String, direction: int) -> Button:
	var bouton := StyleAzur.bouton_rond("", func(): _changer_monde(direction), 112.0)
	bouton.name = nom
	bouton.icon = StyleAzur.texture_interface(symbole)
	bouton.expand_icon = true
	bouton.add_theme_constant_override("icon_max_width", 68)
	bouton.tooltip_text = "Monde précédent" if direction < 0 else "Monde suivant"
	bouton.accessibility_name = bouton.tooltip_text
	var normal := StyleAzur.cercle(true)
	normal.modulate_color = Color("e9c79b")
	bouton.add_theme_stylebox_override("normal", normal)
	_zone_monde.add_child(bouton)
	return bouton

func _replacer_monde() -> void:
	if not is_instance_valid(_zone_monde) or not is_instance_valid(_carte) or _zone_monde.size.x <= 0.0:
		return
	var marge_fleche := 86.0
	_carte.position = Vector2(marge_fleche, 0)
	_carte.size = Vector2(maxf(0.0, _zone_monde.size.x - marge_fleche * 2.0), _zone_monde.size.y)
	var hauteur_fleches := _zone_monde.size.y * 0.42 - 56.0
	_precedent.position = Vector2(0, hauteur_fleches)
	_suivant.position = Vector2(_zone_monde.size.x - 112.0, hauteur_fleches)

func _input(evenement: InputEvent) -> void:
	if _lancement or not is_instance_valid(_zone_monde) or not visible:
		return
	if evenement is InputEventScreenTouch:
		var toucher := evenement as InputEventScreenTouch
		if toucher.pressed:
			_glissement_actif = _zone_monde.get_global_rect().has_point(toucher.position)
			_glissement_depart = toucher.position
		elif _glissement_actif:
			_terminer_glissement(toucher.position)
	elif evenement is InputEventMouseButton:
		var souris := evenement as InputEventMouseButton
		if souris.button_index != MOUSE_BUTTON_LEFT:
			return
		if souris.pressed:
			_glissement_actif = _zone_monde.get_global_rect().has_point(souris.position)
			_glissement_depart = souris.position
		elif _glissement_actif:
			_terminer_glissement(souris.position)

func _terminer_glissement(fin: Vector2) -> void:
	_glissement_actif = false
	var mouvement := fin - _glissement_depart
	if absf(mouvement.x) < 90.0 or absf(mouvement.x) < absf(mouvement.y) * 1.25:
		return
	_changer_monde(-1 if mouvement.x > 0.0 else 1)
	get_viewport().set_input_as_handled()

func _style_selection(teinte: Color) -> StyleBoxTexture:
	return StyleAzur.cadre_enlumine(teinte)

func _rafraichir() -> void:
	var monde: Dictionary = Chapitres.MONDES[_monde]
	_indice_monde.text = "Monde %d / %d" % [_monde + 1, Chapitres.MONDES.size()]
	_titre.text = str(monde["nom"])
	_sous_titre.text = str(monde["sous_titre"])
	var teinte: Color = monde["teinte"]
	_panneau_monde.add_theme_stylebox_override("panel", StyleAzur.cadre_enlumine(teinte))
	_titre.add_theme_color_override("font_color", StyleAzur.IVOIRE.lerp(teinte, 0.38))
	_indice_monde.add_theme_color_override("font_color", teinte.lightened(0.2))
	_sous_titre.add_theme_color_override("font_color", StyleAzur.IVOIRE.lerp(teinte, 0.16))
	_details.add_theme_color_override("font_color", StyleAzur.IVOIRE.lerp(teinte, 0.18))
	_progression_etage.add_theme_stylebox_override("background", _style_jauge(Color("1a2443")))
	_progression_etage.add_theme_stylebox_override("fill", _style_jauge(teinte.lightened(0.12)))
	_carte.afficher_monde(_monde)
	_panneau_selection.add_theme_stylebox_override("panel", _style_selection(teinte))
	_precedent.disabled = _monde == 0
	_suivant.disabled = _monde == Chapitres.MONDES.size() - 1
	var portes_franchies := 0
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var index := _monde * Chapitres.CHAPITRES_PAR_MONDE + i
		var chapitre: Dictionary = Chapitres.par_index(index)
		var accessible := ReglagesJoueur.chapitre_debloque(index)
		var termine := ReglagesJoueur.meilleure_du_chapitre(index) >= int(chapitre["salles"])
		if termine:
			portes_franchies += 1
		var statut := "Verrouillé" if not accessible else "Sélectionné" if i == _chapitre_monde else "Terminé" if termine else "Disponible"
		if i == Chapitres.CHAPITRES_PAR_MONDE - 1:
			statut = "Boss · " + statut
		_zones_chapitres[i].afficher(i + 1, i == _chapitre_monde, accessible, statut,
			i == Chapitres.CHAPITRES_PAR_MONDE - 1, termine, teinte)
	_progression.text = "%d / %d niveaux terminés" % [portes_franchies, Chapitres.CHAPITRES_PAR_MONDE]
	var index := _index_selectionne()
	var chapitre: Dictionary = Chapitres.par_index(index)
	var accessible := ReglagesJoueur.chapitre_debloque(index)
	_selection_titre.text = "Niveau %d%s" % [_chapitre_monde + 1,
		" · Boss du monde" if _chapitre_monde == Chapitres.CHAPITRES_PAR_MONDE - 1 else ""]
	_details.text = "Meilleur étage : %d / %d" % [
		ReglagesJoueur.meilleure_du_chapitre(index), int(chapitre["salles"])]
	_progression_etage.max_value = int(chapitre["salles"])
	_progression_etage.value = ReglagesJoueur.meilleure_du_chapitre(index)
	if not accessible:
		_details.text += "\nTerminez le niveau précédent pour ouvrir ce niveau."
	if accessible:
		_bouton_selectionner.text = "Choisir ce niveau" if selection_seulement else "Jouer ce niveau"
	else:
		_bouton_selectionner.text = "Niveau verrouillé"
	_bouton_selectionner.disabled = not accessible

func _style_jauge(couleur: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = couleur
	style.set_corner_radius_all(5)
	return style

func _index_selectionne() -> int:
	return _monde * Chapitres.CHAPITRES_PAR_MONDE + _chapitre_monde

func _changer_monde(direction: int) -> void:
	var nouveau := clampi(_monde + direction, 0, Chapitres.MONDES.size() - 1)
	if nouveau == _monde:
		return
	_monde = nouveau
	Sons.jouer("choix", -16.0, 1.0 + float(direction) * 0.04)
	_rafraichir()

func _choisir_chapitre(numero: int) -> void:
	if _lancement:
		return
	_chapitre_monde = clampi(numero - 1, 0, Chapitres.CHAPITRES_PAR_MONDE - 1)
	Sons.jouer("choix", -16.0)
	_rafraichir()

func _selectionner() -> void:
	if _lancement:
		return
	var index := _index_selectionne()
	if not ReglagesJoueur.chapitre_debloque(index):
		return
	ReglagesJoueur.choisir_mode_run("grimoire")
	ReglagesJoueur.choisir_chapitre(index)
	Sons.jouer("choix", -10.0)
	if selection_seulement:
		selection_changee.emit()
		_fermer()
	else:
		_lancer_chapitre(index)

func _lancer_chapitre(index: int) -> void:
	if _lancement:
		return
	_lancement = true
	Sons.demarrer_musique_combat()
	var transition := TRANSITION.instantiate()
	transition.configurer(Chapitres.par_index(index))
	add_child(transition)
	transition.terminee.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/run.tscn"))

func _fermer() -> void:
	if _lancement:
		return
	Sons.jouer("choix", -14.0)
	StyleInterface.sortir_puis(self, func() -> void: ferme.emit())

func _voir_loots(index: int) -> void:
	if is_instance_valid(_apercu):
		return
	_apercu = preload("res://ui/apercu_butin.gd").new()
	_apercu.mode = "grimoire"
	_apercu.chapitre = index
	add_child(_apercu)
	_apercu.ferme.connect(func():
		_apercu.queue_free()
		_apercu = null)
