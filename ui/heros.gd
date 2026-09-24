extends Control

const GLYPHES := {"force":"force", "vitalite":"vitalite", "agilite":"celerite", "intelligence":"savoir", "sagesse":"sagesse"}
var _resume: Label
var _message: Label
var _classe: Button
var _rangs: Dictionary = {}
var _plus: Dictionary = {}
var _moins: Dictionary = {}
var _contenu: VBoxContainer
var _sous_menu: Control

func _ready() -> void:
	var col := StyleAzur.page(self, "Héros", true)
	_contenu = StyleAzur.defilement(col)
	# La hauteur du portrait depend de la largeur; une barre auto ferait osciller le cadrage.
	(_contenu.get_parent() as ScrollContainer).vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	var infos := StyleAzur.cartouche_infos(_contenu, StyleAzur.MENTHE)
	_resume = StyleAzur.texte("", 28, StyleAzur.IVOIRE)
	infos.add_child(_resume)
	var scene := CompositionArcane.new()
	scene.hauteur = 1130
	scene.traces = [PackedVector2Array([Vector2(270,400),Vector2(715,120),Vector2(715,355),Vector2(715,580),Vector2(625,980),Vector2(205,980)])]
	_contenu.add_child(scene)
	var portrait := preload("res://ui/composants/portrait_heros_illustre.gd").new()
	scene.placer(portrait, Rect2(15, 100, 470, 675))
	_classe = StyleAzur.bouton("", _ouvrir_classes, true)
	scene.placer(_classe, Rect2(25, 725, 405, 116))
	var positions := [Vector2(520,20), Vector2(520,260), Vector2(520,495), Vector2(430,885), Vector2(10,885)]
	var accents := {"force": StyleAzur.CORAIL, "vitalite": StyleAzur.MENTHE,
		"agilite": Color("a7d6f0"), "intelligence": StyleAzur.MAGIE,
		"sagesse": StyleAzur.CUIVRE}
	var index := 0
	for valeur in Personnage.ATTRIBUTS:
		var id := str(valeur)
		var donnees: Dictionary = Personnage.ATTRIBUTS[id]
		var accent: Color = accents.get(id, StyleAzur.MENTHE)
		var contenu := VBoxContainer.new()
		contenu.add_theme_constant_override("separation", 10)
		scene.placer(contenu, Rect2(positions[index], Vector2(390,190)))
		index += 1
		var nom := StyleAzur.texte(str(donnees["nom"]), 29, accent)
		nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		contenu.add_child(nom)
		var filet := ColorRect.new()
		filet.color = Color(accent, 0.78)
		filet.custom_minimum_size = Vector2(84, 3)
		filet.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		filet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contenu.add_child(filet)
		var commandes := HBoxContainer.new()
		commandes.alignment = BoxContainer.ALIGNMENT_CENTER
		commandes.add_theme_constant_override("separation", 16)
		contenu.add_child(commandes)
		var moins := StyleAzur.bouton_rond("−", func(): _modifier(id, -1))
		commandes.add_child(moins)
		_moins[id] = moins
		var sceau := StyleAzur.bouton_rond("", func(): _message.text = str(donnees["nom"]) + " · " + str(donnees["description"]), 126)
		sceau.icon = StyleAzur.glyphe(str(GLYPHES[id]))
		sceau.expand_icon = true
		sceau.add_theme_constant_override("icon_max_width", 74)
		var surface := StyleAzur.cercle()
		surface.modulate_color = Color.WHITE.lerp(accent, 0.19)
		sceau.add_theme_stylebox_override("normal", surface)
		commandes.add_child(sceau)
		var plus := StyleAzur.bouton_rond("+", func(): _modifier(id, 1))
		commandes.add_child(plus)
		_plus[id] = plus
		var rang := StyleAzur.texte("", 25, accent)
		rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		contenu.add_child(rang)
		_rangs[id] = rang
	var reset := StyleAzur.bouton("Réinitialiser · Gratuit", _reinitialiser_attributs)
	reset.size_flags_horizontal = Control.SIZE_SHRINK_END
	reset.autowrap_mode = TextServer.AUTOWRAP_OFF
	reset.custom_minimum_size.x = 460
	_contenu.add_child(reset)
	_message = StyleAzur.texte("Touchez un sceau pour consulter son effet.", 26, StyleAzur.MENTHE)
	_contenu.add_child(_message)
	rafraichir()

func _modifier(id: String, sens: int) -> void:
	var change := ReglagesJoueur.augmenter_attribut(id) if sens > 0 else ReglagesJoueur.diminuer_attribut(id)
	if change:
		Sons.jouer("choix", -15)
		_message.text = "Points redistribués."
	rafraichir()

func _reinitialiser_attributs() -> void:
	ReglagesJoueur.reinitialiser_attributs()
	_message.text = "Tous vos points sont disponibles."
	rafraichir()

func _ouvrir_classes() -> void:
	if is_instance_valid(_sous_menu): return
	_sous_menu = preload("res://ui/choix_classe.gd").new()
	_contenu.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_sous_menu)
	_sous_menu.ferme.connect(func():
		_sous_menu.queue_free()
		_contenu.process_mode = Node.PROCESS_MODE_INHERIT
		rafraichir())

func rafraichir() -> void:
	var classe := ReglagesJoueur.specialisation_effective()
	_classe.text = "Classe · " + (str(Personnage.SPECIALISATIONS[classe]["nom"]) if not classe.is_empty() else "À choisir") + ""
	_resume.text = "Niveau %d · %d points disponibles" % [ReglagesJoueur.niveau_compte_effectif(), ReglagesJoueur.points_attributs_disponibles()]
	for id: String in _rangs:
		var rang: Label = _rangs[id]
		rang.text = "Rang %d" % ReglagesJoueur.rang_attribut(id)
		var plus: Button = _plus[id]
		var moins: Button = _moins[id]
		plus.disabled = ReglagesJoueur.points_attributs_disponibles() <= 0
		moins.disabled = ReglagesJoueur.rang_attribut(id) <= 0
