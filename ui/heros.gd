extends Control

const JAUGE := preload("res://ui/composants/jauge_attribut.gd")
const GLYPHES := {
	"force": preload("res://assets/visual/interface/menu/glyphes/offensif/force.svg"),
	"vitalite": preload("res://assets/visual/interface/menu/glyphes/defensif/constitution.svg"),
	"agilite": preload("res://assets/visual/interface/menu/glyphes/offensif/cadence.svg"),
	"intelligence": preload("res://assets/visual/interface/menu/glyphes/utilitaire/fortune.svg"),
	"sagesse": preload("res://assets/visual/interface/menu/glyphes/utilitaire/sagesse.svg"),
}

var _resume: Label
var _message: Label
var _classe: Button
var _rangs: Dictionary = {}
var _plus: Dictionary = {}
var _moins: Dictionary = {}
var _jauges: Dictionary = {}
var _lignes_attributs: Array[PanelContainer] = []
var _contenu: VBoxContainer
var _page_principale: Control
var _sous_menu: Control

func _ready() -> void:
	var col := StyleAzur.page(self, "Héros", true)
	_page_principale = col.get_parent() as Control
	_contenu = StyleAzur.defilement(col)
	_contenu.add_theme_constant_override("separation", 18)
	var entete := BoxContainer.new()
	entete.name = "ClasseEtPoints"
	entete.add_theme_constant_override("separation", 24)
	_contenu.add_child(entete)
	var gauche := VBoxContainer.new()
	gauche.name = "Identite"
	gauche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gauche.add_theme_constant_override("separation", 14)
	entete.add_child(gauche)
	_classe = StyleAzur.bouton("", _ouvrir_classes, true)
	_classe.name = "Classe"
	_classe.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_classe.custom_minimum_size.y = 96
	StyleAzur.bouton_enlumine(_classe, StyleAzur.LILAS, 40)
	gauche.add_child(_classe)
	var reset := StyleAzur.bouton("Réinitialiser · Gratuit", _reinitialiser_attributs)
	reset.name = "ReinitialiserAttributs"
	reset.alignment = HORIZONTAL_ALIGNMENT_LEFT
	reset.custom_minimum_size.y = 80
	StyleAzur.bouton_enlumine(reset, StyleAzur.MENTHE, 34)
	gauche.add_child(reset)
	var points := HBoxContainer.new()
	points.name = "ReservePoints"
	points.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	points.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	points.add_theme_constant_override("separation", 20)
	entete.add_child(points)
	var sceau := PanelContainer.new()
	sceau.name = "SceauPoints"
	sceau.custom_minimum_size = Vector2(144, 144)
	sceau.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var fond_points := StyleAzur.cercle(true)
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: fond_points.set_content_margin(cote, 0)
	sceau.add_theme_stylebox_override("panel", fond_points)
	points.add_child(sceau)
	_resume = StyleAzur.texte("", 58, StyleAzur.OR_VIF)
	_resume.name = "PointsDisponibles"
	_resume.add_theme_font_override("font", Polices.CHIFFRES)
	_resume.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resume.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_resume.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_resume.autowrap_mode = TextServer.AUTOWRAP_OFF
	sceau.add_child(_resume)
	var titre_points := StyleAzur.calligraphie("Points à\nrépartir", 38, StyleAzur.OR_VIF)
	titre_points.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	points.add_child(titre_points)
	var accents := {"force": StyleAzur.ROUGE_VIF, "vitalite": StyleAzur.VERT_VIF,
		"agilite": StyleAzur.BLEU_VIF, "intelligence": StyleAzur.MAUVE_VIF, "sagesse": StyleAzur.OR_VIF}
	for valeur in Personnage.ATTRIBUTS:
		var id := str(valeur)
		var donnees: Dictionary = Personnage.ATTRIBUTS[id]
		var accent: Color = accents[id]
		var panneau := PanelContainer.new()
		panneau.name = "Attribut_" + id
		panneau.add_theme_stylebox_override("panel", StyleAzur.cadre_grimoire(accent))
		_contenu.add_child(panneau)
		_lignes_attributs.append(panneau)
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 20)
		panneau.add_child(ligne)
		var icone := TextureRect.new()
		icone.texture = GLYPHES[id]
		icone.custom_minimum_size = Vector2(100, 100)
		icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne.add_child(icone)
		var lecture := VBoxContainer.new()
		lecture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lecture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lecture.add_theme_constant_override("separation", 10)
		ligne.add_child(lecture)
		var titre_valeur := HBoxContainer.new()
		lecture.add_child(titre_valeur)
		var nom := StyleAzur.calligraphie(str(donnees["nom"]), 40, accent)
		nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		titre_valeur.add_child(nom)
		var rang := StyleAzur.texte("", 42, accent.lightened(0.16))
		rang.add_theme_font_override("font", Polices.CHIFFRES)
		rang.name = "Rang_" + id
		rang.autowrap_mode = TextServer.AUTOWRAP_OFF
		titre_valeur.add_child(rang)
		_rangs[id] = rang
		var jauge := JAUGE.new()
		jauge.name = "Jauge_" + id
		jauge.accent = accent
		jauge.tooltip_text = "Part des points investis dans %s" % str(donnees["nom"])
		lecture.add_child(jauge)
		_jauges[id] = jauge
		lecture.add_child(StyleAzur.texte(str(donnees["description"]), 30, accent.lightened(0.28)))
		var commandes := BoxContainer.new()
		commandes.name = "Commandes"
		commandes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		commandes.add_theme_constant_override("separation", 10)
		ligne.add_child(commandes)
		var moins := _bouton_attribut(false, accent, func(): _modifier(id, -1))
		moins.name = "Moins_" + id
		moins.tooltip_text = "Retirer un point de " + str(donnees["nom"])
		commandes.add_child(moins)
		_moins[id] = moins
		var plus := _bouton_attribut(true, accent, func(): _modifier(id, 1))
		plus.name = "Plus_" + id
		plus.tooltip_text = "Ajouter un point en " + str(donnees["nom"])
		commandes.add_child(plus)
		_plus[id] = plus
	_message = StyleAzur.texte("", 26, StyleAzur.MENTHE)
	_contenu.add_child(_message)
	var adapter := func() -> void:
		entete.vertical = _contenu.size.x < 760
		var hauteur := (_contenu.get_parent() as Control).size.y - entete.size.y - 150.0
		for ligne_attribut in _lignes_attributs:
			ligne_attribut.custom_minimum_size.y = clampf(hauteur / 5.0, 190.0, 300.0)
			var commandes := ligne_attribut.find_child("Commandes", true, false) as BoxContainer
			commandes.vertical = _contenu.size.x < 820
	_contenu.get_parent().resized.connect(adapter)
	adapter.call_deferred()
	rafraichir()

func _bouton_attribut(ajouter: bool, accent: Color, action: Callable) -> Button:
	var bouton := StyleAzur.bouton("+" if ajouter else "−", action, ajouter)
	bouton.custom_minimum_size = Vector2.ONE * Ecran.CIBLE_TACTILE
	bouton.add_theme_font_override("font", Polices.TITRE)
	bouton.add_theme_font_size_override("font_size", 42)
	for etat in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleAzur.sceau(ajouter, Color.WHITE.lerp(accent, 0.3), etat == "pressed")
		for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(cote, 8)
		if etat == "disabled": style.modulate_color = Color("797386")
		bouton.add_theme_stylebox_override(etat, style)
	StyleAzur.texte_bouton_colore(bouton, accent.lightened(0.2))
	return bouton

func _modifier(id: String, sens: int) -> void:
	var change := ReglagesJoueur.augmenter_attribut(id) if sens > 0 else ReglagesJoueur.diminuer_attribut(id)
	if change: Sons.jouer("choix", -15)
	_message.text = ""
	rafraichir()

func _reinitialiser_attributs() -> void:
	ReglagesJoueur.reinitialiser_attributs()
	_message.text = "Tous vos points sont disponibles."
	rafraichir()

func _ouvrir_classes() -> void:
	if is_instance_valid(_sous_menu): return
	_sous_menu = preload("res://ui/choix_classe.gd").new()
	_page_principale.hide()
	_contenu.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_sous_menu)
	_sous_menu.ferme.connect(func():
		_sous_menu.queue_free()
		_contenu.process_mode = Node.PROCESS_MODE_INHERIT
		_page_principale.show()
		rafraichir())

func rafraichir() -> void:
	var classe := ReglagesJoueur.specialisation_effective()
	_classe.text = "Classe · " + (str(Personnage.SPECIALISATIONS[classe]["nom"]) if not classe.is_empty() else "À choisir")
	_resume.text = str(ReglagesJoueur.points_attributs_disponibles())
	_message.visible = not _message.text.is_empty()
	for id: String in _rangs:
		var rang: Label = _rangs[id]
		rang.text = "+%d" % ReglagesJoueur.rang_attribut(id)
		var jauge: ProgressBar = _jauges[id]
		jauge.afficher(ReglagesJoueur.rang_attribut(id), Personnage.points_totaux(ReglagesJoueur.niveau_compte_effectif()))
		var plus: Button = _plus[id]
		var moins: Button = _moins[id]
		plus.disabled = ReglagesJoueur.points_attributs_disponibles() <= 0
		moins.disabled = ReglagesJoueur.rang_attribut(id) <= 0
