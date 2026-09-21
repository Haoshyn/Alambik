extends Control
signal ferme
signal reprise_demandee
var _confirmation_reset := false
var _bouton_reset: Button

func _ready() -> void:
	var col := StyleAzur.page(self,"Paramètres")
	var contenu := StyleAzur.defilement(col)
	StyleAzur.banniere(contenu, "À votre mesure", "L’ambiance et le confort de votre atelier.", "astrolabe")
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
	confort.add_child(StyleAzur.texte("Raccourci du sort actif",27,StyleAzur.ATTENUE))
	var raccourci := _selecteur(confort)
	for mode in RaccourciTactile.MODES:
		raccourci.add_item(RaccourciTactile.nom_mode(mode))
		var index := raccourci.item_count-1
		raccourci.set_item_metadata(index,mode)
		if mode == ReglagesJoueur.raccourci_sort: raccourci.selected = index
	raccourci.item_selected.connect(func(i): ReglagesJoueur.definir_raccourci_sort(str(raccourci.get_item_metadata(i))))
	confort.add_child(StyleAzur.texte("Visée libre après l’icône, cible la plus proche par l’icône, ou tape courte n’importe où dans l’arène.",24,StyleAzur.ATTENUE))
	StyleAzur.separateur(contenu)
	var progression := StyleAzur.plaque(contenu)
	progression.get_parent().visible = false
	var ouvrir_progression := StyleAzur.bouton("Progression ›",func(): progression.get_parent().visible = not progression.get_parent().visible)
	contenu.add_child(ouvrir_progression)
	contenu.move_child(ouvrir_progression,progression.get_parent().get_index())
	_bouton_reset = StyleAzur.bouton("Réinitialiser la progression",_sur_reset)
	progression.add_child(_bouton_reset)
	if ReglagesJoueur.outils_developpement_disponibles():
		var developpement := StyleAzur.plaque(contenu)
		developpement.get_parent().visible = false
		var ouvrir := StyleAzur.bouton("Outils de développement",func(): developpement.get_parent().visible = not developpement.get_parent().visible)
		contenu.add_child(ouvrir)
		contenu.move_child(ouvrir,developpement.get_parent().get_index())
		_option(developpement,"Mode développeur",ReglagesJoueur.mode_dev,func(v): ReglagesJoueur.definir_mode_dev(v))
	# Le retour reste accessible meme quand les options sont longues a faire defiler.
	col.add_child(StyleAzur.bouton("Reprendre", _reprendre, true))
	Capture.programmer(self)

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
		_bouton_reset.text = "Progression réinitialisée"
		_bouton_reset.disabled = true
		return
	_confirmation_reset = true
	_bouton_reset.text = "Toucher à nouveau pour tout effacer"
	await get_tree().create_timer(4.0,true).timeout
	if _confirmation_reset:
		_confirmation_reset = false
		_bouton_reset.text = "Réinitialiser la progression"
