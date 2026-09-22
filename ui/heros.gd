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
	_resume = StyleAzur.texte("", 30)
	_contenu.add_child(_resume)
	var scene := CompositionArcane.new()
	scene.hauteur = 1130
	scene.traces = [PackedVector2Array([Vector2(270,400),Vector2(715,120),Vector2(715,355),Vector2(715,580),Vector2(625,980),Vector2(205,980)])]
	_contenu.add_child(scene)
	var portrait := preload("res://ui/composants/portrait_heros_illustre.gd").new()
	scene.placer(portrait, Rect2(15, 100, 470, 675))
	_classe = StyleAzur.bouton("", _ouvrir_classes, true)
	scene.placer(_classe, Rect2(25, 725, 405, 116))
	var positions := [Vector2(520,20), Vector2(520,260), Vector2(520,495), Vector2(430,885), Vector2(10,885)]
	var index := 0
	for valeur in Personnage.ATTRIBUTS:
		var id := str(valeur)
		var donnees: Dictionary = Personnage.ATTRIBUTS[id]
		var contenu := VBoxContainer.new()
		contenu.add_theme_constant_override("separation", 10)
		scene.placer(contenu, Rect2(positions[index], Vector2(390,190)))
		index += 1
		var nom := StyleAzur.texte(str(donnees["nom"]), 30)
		nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		contenu.add_child(nom)
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
		commandes.add_child(sceau)
		var plus := StyleAzur.bouton_rond("+", func(): _modifier(id, 1))
		commandes.add_child(plus)
		_plus[id] = plus
		var rang := StyleAzur.texte("", 32, StyleAzur.MAGIE)
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
		rang.text = str(ReglagesJoueur.rang_attribut(id))
		var plus: Button = _plus[id]
		var moins: Button = _moins[id]
		plus.disabled = ReglagesJoueur.points_attributs_disponibles() <= 0
		moins.disabled = ReglagesJoueur.rang_attribut(id) <= 0
