extends Control

var _resume: Label
var _message: Label
var _classe: Button
var _rangs: Dictionary = {}
var _plus: Dictionary = {}
var _moins: Dictionary = {}
var _jauges: Dictionary = {}
var _lignes_attributs: Array[HBoxContainer] = []
var _contenu: VBoxContainer
var _sous_menu: Control

func _ready() -> void:
	var col := StyleAzur.page(self, "Héros", true)
	_contenu = StyleAzur.defilement(col)
	var plateau := BoxContainer.new()
	plateau.name = "PortraitEtAttributs"
	plateau.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plateau.add_theme_constant_override("separation", 20)
	_contenu.add_child(plateau)
	var gauche := VBoxContainer.new()
	gauche.name = "Identite"
	gauche.custom_minimum_size.x = 430
	gauche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gauche.add_theme_constant_override("separation", 16)
	plateau.add_child(gauche)
	var cadre_portrait := PanelContainer.new()
	cadre_portrait.name = "CadrePortrait"
	var style_portrait := StyleBoxFlat.new()
	style_portrait.bg_color = Color("17253ec9")
	style_portrait.border_color = Color("bda981b8")
	style_portrait.set_border_width_all(2)
	style_portrait.set_corner_radius_all(28)
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style_portrait.set_content_margin(cote, 8)
	cadre_portrait.add_theme_stylebox_override("panel", style_portrait)
	gauche.add_child(cadre_portrait)
	var portrait := preload("res://ui/composants/portrait_heros_illustre.gd").new()
	portrait.name = "PortraitHeros"
	portrait.custom_minimum_size = Vector2(420, 785)
	cadre_portrait.add_child(portrait)
	var identite := StyleAzur.texte("L’ALCHIMISTE", 38, Color("f4d7a9"))
	identite.name = "NomHeros"
	identite.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gauche.add_child(identite)
	_classe = StyleAzur.bouton("", _ouvrir_classes, true)
	_classe.name = "Classe"
	_classe.custom_minimum_size.y = 92
	gauche.add_child(_classe)
	var reset := StyleAzur.bouton("Réinitialiser · Gratuit", _reinitialiser_attributs)
	reset.name = "ReinitialiserAttributs"
	reset.custom_minimum_size.y = 78
	gauche.add_child(reset)
	var droite := VBoxContainer.new()
	droite.name = "Attributs"
	droite.custom_minimum_size.x = 480
	droite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	droite.add_theme_constant_override("separation", 10)
	plateau.add_child(droite)
	var panneau := PanelContainer.new()
	panneau.name = "ColonneAttributs"
	panneau.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var fond := StyleBoxFlat.new()
	fond.bg_color = Color("152341f2")
	fond.border_color = Color("a3b9e1c9")
	fond.set_border_width_all(2)
	fond.set_corner_radius_all(25)
	fond.shadow_color = Color("0a102980")
	fond.shadow_size = 14
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		fond.set_content_margin(cote, 21)
	panneau.add_theme_stylebox_override("panel", fond)
	droite.add_child(panneau)
	var colonne := VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 0)
	panneau.add_child(colonne)
	_resume = StyleAzur.texte("", 31, Color("b8edff"))
	_resume.name = "PointsDisponibles"
	colonne.add_child(_resume)
	var explication := StyleAzur.texte("Répartissez vos points. Vous pouvez les récupérer librement.", 21, Color("c9d6ec"))
	colonne.add_child(explication)
	var entete_separateur := ColorRect.new()
	entete_separateur.color = Color("83a8d37a")
	entete_separateur.custom_minimum_size.y = 2
	colonne.add_child(entete_separateur)
	var accents := {"force": StyleAzur.ROUGE_VIF, "vitalite": StyleAzur.VERT_VIF,
		"agilite": StyleAzur.BLEU_VIF, "intelligence": StyleAzur.MAUVE_VIF,
		"sagesse": StyleAzur.OR_VIF}
	for valeur in Personnage.ATTRIBUTS:
		var id := str(valeur)
		var donnees: Dictionary = Personnage.ATTRIBUTS[id]
		var accent: Color = accents.get(id, StyleAzur.MENTHE)
		var ligne := HBoxContainer.new()
		ligne.name = "Attribut_" + id
		ligne.custom_minimum_size.y = 147
		ligne.add_theme_constant_override("separation", 10)
		colonne.add_child(ligne)
		_lignes_attributs.append(ligne)
		var lecture := VBoxContainer.new()
		lecture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lecture.add_theme_constant_override("separation", 5)
		ligne.add_child(lecture)
		var titre_valeur := HBoxContainer.new()
		lecture.add_child(titre_valeur)
		var nom := StyleAzur.texte(str(donnees["nom"]), 32, Color("edf3ff"))
		nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nom.autowrap_mode = TextServer.AUTOWRAP_OFF
		titre_valeur.add_child(nom)
		var rang := StyleAzur.texte("", 34, accent)
		rang.name = "Rang_" + id
		rang.autowrap_mode = TextServer.AUTOWRAP_OFF
		titre_valeur.add_child(rang)
		_rangs[id] = rang
		var description := StyleAzur.texte(str(donnees["description"]), 20, Color("bfcee4"))
		lecture.add_child(description)
		var jauge := ProgressBar.new()
		jauge.name = "Jauge_" + id
		jauge.custom_minimum_size.y = 9
		jauge.show_percentage = false
		jauge.tooltip_text = "Part des points investis dans %s" % str(donnees["nom"])
		var rail := StyleBoxFlat.new()
		rail.bg_color = Color("33486a")
		rail.set_corner_radius_all(5)
		jauge.add_theme_stylebox_override("background", rail)
		var remplissage := StyleBoxFlat.new()
		remplissage.bg_color = accent
		remplissage.set_corner_radius_all(5)
		jauge.add_theme_stylebox_override("fill", remplissage)
		lecture.add_child(jauge)
		_jauges[id] = jauge
		var commandes := VBoxContainer.new()
		commandes.add_theme_constant_override("separation", 5)
		ligne.add_child(commandes)
		var plus := _bouton_attribut(true, accent, func(): _modifier(id, 1))
		plus.name = "Plus_" + id
		plus.tooltip_text = "Ajouter un point en " + str(donnees["nom"])
		commandes.add_child(plus)
		_plus[id] = plus
		var moins := _bouton_attribut(false, accent, func(): _modifier(id, -1))
		moins.name = "Moins_" + id
		moins.tooltip_text = "Retirer un point de " + str(donnees["nom"])
		commandes.add_child(moins)
		_moins[id] = moins
		var separateur := ColorRect.new()
		separateur.color = Color(accent, 0.29)
		separateur.custom_minimum_size.y = 1
		colonne.add_child(separateur)
	_message = StyleAzur.texte("", 25, StyleAzur.MENTHE)
	droite.add_child(_message)
	var adapter := func() -> void:
		var large := size.x >= 850.0
		plateau.vertical = not large
		gauche.custom_minimum_size.x = 485 if large else 430
		portrait.custom_minimum_size = Vector2(485, 1090) if large else Vector2(420, 785)
		for ligne_attribut in _lignes_attributs:
			ligne_attribut.custom_minimum_size.y = 210 if large else 172
	resized.connect(adapter)
	adapter.call_deferred()
	rafraichir()

func _bouton_attribut(ajouter: bool, accent: Color, action: Callable) -> Button:
	var bouton := Button.new()
	bouton.icon = preload("res://assets/visual/interface/menu/fleche_attribut_haut.svg") if ajouter else preload("res://assets/visual/interface/menu/fleche_attribut_bas.svg")
	bouton.expand_icon = true
	bouton.custom_minimum_size = Vector2(75, 75)
	bouton.add_theme_constant_override("icon_max_width", 45)
	bouton.add_theme_color_override("icon_disabled_color", Color("70809a"))
	for etat in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("263247") if etat == "disabled" else Color("223452").lerp(accent, 0.43 if etat == "hover" else 0.26)
		style.border_color = Color("64738e") if etat == "disabled" else accent.lightened(0.18)
		style.set_border_width_all(2)
		style.set_corner_radius_all(38)
		style.shadow_color = Color(accent, 0.22 if etat == "normal" else 0.42)
		style.shadow_size = 4 if etat == "normal" else 9
		bouton.add_theme_stylebox_override(etat, style)
	bouton.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	bouton.pressed.connect(action)
	return bouton

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
	_resume.text = "%d points disponibles" % ReglagesJoueur.points_attributs_disponibles()
	for id: String in _rangs:
		var rang: Label = _rangs[id]
		rang.text = "+%d" % ReglagesJoueur.rang_attribut(id)
		var jauge: ProgressBar = _jauges[id]
		jauge.max_value = maxf(1.0, float(Personnage.points_totaux(ReglagesJoueur.niveau_compte_effectif())))
		jauge.value = float(ReglagesJoueur.rang_attribut(id))
		var plus: Button = _plus[id]
		var moins: Button = _moins[id]
		plus.disabled = ReglagesJoueur.points_attributs_disponibles() <= 0
		moins.disabled = ReglagesJoueur.rang_attribut(id) <= 0
