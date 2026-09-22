extends Control
signal ferme
signal reprise_demandee
var _confirmation_reset := false
var _bouton_reset: Button
var section_tutoriel := ""
var _avance: Control

func _ready() -> void:
	var col := StyleAzur.page(self,"Paramètres")
	var contenu := StyleAzur.defilement(col)
	StyleAzur.banniere(contenu, "À votre mesure", "L’ambiance et le confort de votre atelier.", "astrolabe")
	var tutoriel_commandes := ParcoursTutoriel.actif() and section_tutoriel == "commandes" \
		and not ParcoursTutoriel.sort_a_expliquer().is_empty()
	if tutoriel_commandes:
		var aide := StyleAzur.plaque(contenu)
		aide.add_child(StyleAzur.texte("Choisissez votre geste de lancement", 32, StyleAzur.CUIVRE))
		aide.add_child(StyleAzur.texte("Votre sort actif est équipé. Comparez les trois modes ci-dessous ; vous pourrez toujours revenir sur votre choix depuis la pause.", 27))
		_construire_commandes(aide)
		call_deferred("_noter_section_tutoriel", "commandes_vues")
	elif ParcoursTutoriel.actif() and section_tutoriel == "musique":
		contenu.add_child(StyleAzur.texte("Essayez les listes de morceaux ci-dessous : la musique de l’aventure et celle de l’atelier se choisissent séparément.", 28, StyleAzur.MENTHE))
		call_deferred("_noter_section_tutoriel", "musique_vue")
	var audio := StyleAzur.plaque(contenu)
	audio.add_child(StyleAzur.texte("AMBIANCE SONORE", 25, StyleAzur.CUIVRE))
	_volume(audio,"Musique",ReglagesJoueur.volume_musique,func(v): ReglagesJoueur.definir_reglages_audio(v,ReglagesJoueur.volume_effets))
	_volume(audio,"Effets sonores",ReglagesJoueur.volume_effets,func(v): ReglagesJoueur.definir_reglages_audio(ReglagesJoueur.volume_musique,v))
	audio.add_child(StyleAzur.texte("Pendant l’aventure",27,StyleAzur.ATTENUE))
	var pistes := _selecteur(audio)
	for d in Sons.pistes_disponibles():
		pistes.add_item(str(d["nom"]))
		var index := pistes.item_count-1
		pistes.set_item_metadata(index,str(d["id"]))
		if str(d["id"]) == ReglagesJoueur.piste_musique: pistes.selected = index
	pistes.item_selected.connect(func(i): ReglagesJoueur.definir_piste_musique(str(pistes.get_item_metadata(i))))
	audio.add_child(StyleAzur.texte("Dans l’atelier",27,StyleAzur.ATTENUE))
	var pistes_menu := _selecteur(audio)
	for d in Sons.pistes_menu_disponibles():
		pistes_menu.add_item(str(d["nom"]))
		var index := pistes_menu.item_count-1
		pistes_menu.set_item_metadata(index,str(d["id"]))
		if str(d["id"]) == ReglagesJoueur.piste_menu: pistes_menu.selected = index
	pistes_menu.item_selected.connect(func(i): ReglagesJoueur.definir_piste_menu(str(pistes_menu.get_item_metadata(i))))
	StyleAzur.separateur(contenu)
	var confort := StyleAzur.plaque(contenu)
	confort.add_child(StyleAzur.texte("CONFORT DE JEU",25,StyleAzur.MAGIE))
	_option(confort,"Secousses de l’écran",ReglagesJoueur.secousses_ecran,func(v): ReglagesJoueur.definir_accessibilite(v,ReglagesJoueur.effets_reduits))
	_option(confort,"Animations et flashes réduits",ReglagesJoueur.effets_reduits,func(v): ReglagesJoueur.definir_accessibilite(ReglagesJoueur.secousses_ecran,v))
	if OS.has_feature("android"):
		_option(confort,"Vibrations",ReglagesJoueur.vibrations,func(v): ReglagesJoueur.definir_vibrations(v))
		confort.add_child(StyleAzur.texte("Un retour bref lors des dégâts et des récompenses importantes.",24,StyleAzur.ATTENUE))
	if not tutoriel_commandes:
		_construire_commandes(confort)
	StyleAzur.separateur(contenu)
	var progression := StyleAzur.plaque(contenu)
	_bouton_reset = StyleAzur.bouton("Réinitialiser la progression",_sur_reset)
	progression.add_child(_bouton_reset)
	progression.add_child(StyleAzur.texte("Efface le compte et relance le tutoriel. Vos préférences audio et de commandes sont conservées.", 24, StyleAzur.ATTENUE))
	if ReglagesJoueur.outils_developpement_disponibles():
		var developpement := StyleAzur.plaque(contenu)
		developpement.get_parent().visible = false
		var ouvrir := StyleAzur.bouton("Outils de développement",func(): developpement.get_parent().visible = not developpement.get_parent().visible)
		contenu.add_child(ouvrir)
		contenu.move_child(ouvrir,developpement.get_parent().get_index())
		_option(developpement,"Mode développeur",ReglagesJoueur.mode_dev,func(v): ReglagesJoueur.definir_mode_dev(v))
		developpement.add_child(StyleAzur.bouton("Avancer à…", _ouvrir_avance))
	# Le retour reste accessible meme quand les options sont longues a faire defiler.
	col.add_child(StyleAzur.bouton("Reprendre", _reprendre, true))
	Capture.programmer(self)

func _noter_section_tutoriel(cle: String) -> void:
	ParcoursTutoriel.noter(cle)

func _construire_commandes(parent: Node) -> void:
	parent.add_child(StyleAzur.texte("Raccourci du sort actif", 27, StyleAzur.ATTENUE))
	var raccourci := _selecteur(parent)
	for mode in RaccourciTactile.MODES:
		raccourci.add_item(RaccourciTactile.nom_mode(mode))
		var index := raccourci.item_count - 1
		raccourci.set_item_metadata(index, mode)
		if mode == ReglagesJoueur.raccourci_sort:
			raccourci.selected = index
	raccourci.item_selected.connect(func(i): ReglagesJoueur.definir_raccourci_sort(str(raccourci.get_item_metadata(i))))
	parent.add_child(StyleAzur.texte("Visée libre après l’icône, cible la plus proche par l’icône, ou tape courte n’importe où dans l’arène.", 24, StyleAzur.ATTENUE))

func _reprendre() -> void:
	if not reprise_demandee.get_connections().is_empty():
		reprise_demandee.emit()
		return
	Sons.jouer("choix", -12.0)
	ferme.emit()

func _selecteur(parent: Node) -> OptionButton:
	var b := OptionButton.new()
	b.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	StyleInterface.styliser_selecteur(b,StyleAzur.MAGIE)
	b.fit_to_longest_item = false
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font",Polices.CORPS)
	for etat in ["normal","hover","pressed"]:
		b.add_theme_stylebox_override(etat,StyleAzur.cadre())
	for etat in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		b.add_theme_color_override(etat,StyleAzur.ENCRE)
	b.add_theme_font_size_override("font_size",29)
	b.add_theme_stylebox_override("focus",StyleAzur.cadre(Color.TRANSPARENT,StyleAzur.MAGIE))
	var liste := b.get_popup()
	liste.add_theme_font_override("font",Polices.CORPS)
	liste.add_theme_font_size_override("font_size",29)
	liste.add_theme_stylebox_override("panel",StyleAzur.cadre())
	liste.add_theme_stylebox_override("hover",StyleAzur.cadre(Color("436a9f"),StyleAzur.MAGIE))
	for etat in ["font_color","font_hover_color","font_accelerator_color"]:
		liste.add_theme_color_override(etat,StyleAzur.ENCRE)
	liste.add_theme_color_override("font_disabled_color",StyleAzur.ATTENUE)
	liste.add_theme_constant_override("v_separation",64)
	liste.add_theme_icon_override("radio_checked",preload("res://assets/visual/atelier/oui.svg"))
	liste.add_theme_icon_override("radio_unchecked",preload("res://assets/visual/atelier/non.svg"))
	liste.about_to_popup.connect(func():
		# La liste defile au lieu de depasser la zone accessible du telephone.
		liste.max_size = Vector2i(int(get_viewport_rect().size.x-72),int(get_viewport_rect().size.y-Ecran.marge_haute()-Ecran.marge_basse()-96)))
	parent.add_child(b)
	return b

func _volume(parent: Node, titre: String, valeur: float, action: Callable) -> void:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	parent.add_child(col)
	var label := StyleAzur.texte("%s · %d %%" % [titre,roundi(valeur*100)],29)
	col.add_child(label)
	var slider := HSlider.new()
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = valeur
	slider.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	var rail := StyleAzur.jauge(false)
	var rempli := StyleAzur.jauge(true,StyleAzur.MAGIE)
	# Les sliders mesurent leur rail depuis les marges du style.
	for style in [rail, rempli]:
		style.content_margin_top = 8
		style.content_margin_bottom = 8
	slider.add_theme_stylebox_override("slider",rail)
	for etat in ["grabber_area","grabber_area_highlight"]:
		slider.add_theme_stylebox_override(etat,rempli)
	for etat in ["grabber","grabber_highlight","grabber_disabled"]:
		slider.add_theme_icon_override(etat,preload("res://assets/visual/atelier/curseur.svg"))
	col.add_child(slider)
	slider.value_changed.connect(func(v):
		label.text = "%s · %d %%" % [titre,roundi(v*100)]
		action.call(v))

func _option(parent: Node, titre: String, valeur: bool, action: Callable) -> void:
	var b := CheckButton.new()
	HabillagePeint.appliquer(b)
	b.text = titre
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.button_pressed = valeur
	b.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	b.add_theme_font_override("font",Polices.CORPS)
	b.add_theme_font_size_override("font_size",28)
	for etat in ["normal","hover","pressed","hover_pressed"]:
		b.add_theme_stylebox_override(etat,StyleAzur.cadre())
	b.add_theme_stylebox_override("focus",StyleAzur.cadre(Color.TRANSPARENT,StyleAzur.MAGIE))
	for etat in ["font_color","font_hover_color","font_pressed_color","font_hover_pressed_color"]:
		b.add_theme_color_override(etat,StyleAzur.ENCRE)
	b.add_theme_icon_override("checked",preload("res://assets/visual/atelier/oui.svg"))
	b.add_theme_icon_override("unchecked",preload("res://assets/visual/atelier/non.svg"))
	b.toggled.connect(func(v): action.call(v))
	parent.add_child(b)

func _sur_reset() -> void:
	if _confirmation_reset:
		_confirmation_reset = false
		ReglagesJoueur.reinitialiser_progression()
		_bouton_reset.disabled = true
		_retour_apres_progression()
		return
	_confirmation_reset = true
	_bouton_reset.text = "Toucher à nouveau pour tout effacer"
	await get_tree().create_timer(4.0,true).timeout
	if _confirmation_reset:
		_confirmation_reset = false
		_bouton_reset.text = "Réinitialiser la progression"

func _ouvrir_avance() -> void:
	if is_instance_valid(_avance) or not ReglagesJoueur.outils_developpement_disponibles():
		return
	_avance = preload("res://ui/avance_developpement.gd").new()
	_avance.ferme.connect(func():
		_avance.queue_free()
		_avance = null)
	_avance.progression_appliquee.connect(_retour_apres_progression)
	add_child(_avance)

func _retour_apres_progression() -> void:
	# Une run ouverte avant le remplacement ne doit plus attribuer son coffre.
	Jeu.nouvelle_tentative.clear()
	Jeu.destination_menu.clear()
	Jeu.bilan_run.clear()
	get_tree().change_scene_to_file.call_deferred("res://scenes/menu.tscn")
	Engine.time_scale = 1.0
	get_tree().paused = false
