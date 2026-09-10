extends Control
signal ferme
var _confirmation_reset := false
var _bouton_reset: Button

func _ready() -> void:
	var col := StyleAzur.page(self,"Paramètres")
	var contenu := StyleAzur.defilement(col)
	contenu.add_child(StyleAzur.texte("Audio",36))
	_volume(contenu,"Musique",ReglagesJoueur.volume_musique,func(v): ReglagesJoueur.definir_reglages_audio(v,ReglagesJoueur.volume_effets))
	_volume(contenu,"Effets sonores",ReglagesJoueur.volume_effets,func(v): ReglagesJoueur.definir_reglages_audio(ReglagesJoueur.volume_musique,v))
	contenu.add_child(StyleAzur.texte("Musique des runs",29))
	var pistes := _selecteur(contenu)
	for d in Sons.pistes_disponibles():
		pistes.add_item(str(d["nom"]))
		var index := pistes.item_count-1
		pistes.set_item_metadata(index,str(d["id"]))
		if str(d["id"]) == ReglagesJoueur.piste_musique: pistes.selected = index
	pistes.item_selected.connect(func(i): ReglagesJoueur.definir_piste_musique(str(pistes.get_item_metadata(i))))
	contenu.add_child(StyleAzur.texte("Musique du menu",29))
	var pistes_menu := _selecteur(contenu)
	for d in Sons.pistes_menu_disponibles():
		pistes_menu.add_item(str(d["nom"]))
		var index := pistes_menu.item_count-1
		pistes_menu.set_item_metadata(index,str(d["id"]))
		if str(d["id"]) == ReglagesJoueur.piste_menu: pistes_menu.selected = index
	pistes_menu.item_selected.connect(func(i): ReglagesJoueur.definir_piste_menu(str(pistes_menu.get_item_metadata(i))))
	contenu.add_child(StyleAzur.texte("Affichage & confort",36))
	_option(contenu,"Secousses d’écran",ReglagesJoueur.secousses_ecran,func(v): ReglagesJoueur.definir_accessibilite(v,ReglagesJoueur.effets_reduits))
	_option(contenu,"Animations et flashes réduits",ReglagesJoueur.effets_reduits,func(v): ReglagesJoueur.definir_accessibilite(ReglagesJoueur.secousses_ecran,v))
	contenu.add_child(StyleAzur.texte("Raccourci du sort actif",29))
	var raccourci := _selecteur(contenu)
	for mode in RaccourciTactile.MODES:
		raccourci.add_item(RaccourciTactile.nom_mode(mode))
		var index := raccourci.item_count-1
		raccourci.set_item_metadata(index,mode)
		if mode == ReglagesJoueur.raccourci_sort: raccourci.selected = index
	raccourci.item_selected.connect(func(i): ReglagesJoueur.definir_raccourci_sort(str(raccourci.get_item_metadata(i))))
	contenu.add_child(StyleAzur.texte("Progression",36))
	_bouton_reset = StyleAzur.bouton("Réinitialiser la progression",_sur_reset)
	contenu.add_child(_bouton_reset)
	var developpement := StyleAzur.plaque(contenu)
	developpement.get_parent().visible = false
	var ouvrir := StyleAzur.bouton("Outils de développement",func(): developpement.get_parent().visible = not developpement.get_parent().visible)
	contenu.add_child(ouvrir)
	_option(developpement,"Mode développeur",ReglagesJoueur.mode_dev,func(v): ReglagesJoueur.definir_mode_dev(v))
	Capture.programmer(self)

func _selecteur(parent: Node) -> OptionButton:
	var b := OptionButton.new()
	b.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	StyleInterface.styliser_selecteur(b,StyleAzur.MAGIE)
	b.add_theme_font_size_override("font_size",29)
	parent.add_child(b)
	return b

func _volume(parent: Node, titre: String, valeur: float, action: Callable) -> void:
	var col := StyleAzur.plaque(parent)
	var label := StyleAzur.texte("%s · %d %%" % [titre,roundi(valeur*100)],29)
	col.add_child(label)
	var slider := HSlider.new()
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = valeur
	slider.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	col.add_child(slider)
	slider.value_changed.connect(func(v):
		label.text = "%s · %d %%" % [titre,roundi(v*100)]
		action.call(v))

func _option(parent: Node, titre: String, valeur: bool, action: Callable) -> void:
	var b := StyleAzur.bouton(titre)
	b.toggle_mode = true
	b.button_pressed = valeur
	b.text = titre+ (" · Oui" if valeur else " · Non")
	b.toggled.connect(func(v):
		b.text = titre+ (" · Oui" if v else " · Non")
		action.call(v))
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
