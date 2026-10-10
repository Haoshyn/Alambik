extends Control

const JAUGE := preload("res://ui/composants/jauge_attribut.gd")
const GLYPHES := {
	"force": preload("res://assets/visual/interface/menu/glyphes/offensif/force.svg"),
	"vitalite": preload("res://assets/visual/interface/menu/glyphes/defensif/constitution.svg"),
	"agilite": preload("res://assets/visual/interface/menu/glyphes/offensif/cadence.svg"),
	"intelligence": preload("res://assets/visual/interface/menu/glyphes/utilitaire/fortune.svg"),
	"sagesse": preload("res://assets/visual/interface/menu/glyphes/utilitaire/sagesse.svg"),
}

const SOCLE := preload("res://ui/composants/socle_heros.gd")
const PORTRAIT := preload("res://ui/composants/portrait_heros_3d.gd")
const FOND_RANG := preload("res://assets/visual/interface/menu/rang_maitrise.svg")
const ACCENTS := {"force": StyleAzur.ROUGE_VIF, "vitalite": StyleAzur.VERT_VIF,
	"agilite": StyleAzur.BLEU_VIF, "intelligence": StyleAzur.MAUVE_VIF, "sagesse": StyleAzur.OR_VIF}
# Constellation autour du heros, dans le repere 960 de CompositionArcane.
const PLACES := {"force": Vector2(140, 190), "agilite": Vector2(820, 190),
	"vitalite": Vector2(118, 580), "intelligence": Vector2(842, 580), "sagesse": Vector2(480, 862)}
const ORDRE_TRACE := ["force", "agilite", "intelligence", "sagesse", "vitalite", "force"]
const DIAMETRE := 196.0

var _resume: Label
var _message: Label
var _classe: Button
var _selection := "force"
var _rangs: Dictionary = {}
var _plus: Dictionary = {}
var _moins: Button
var _plus_selection: Button
var _medaillons: Dictionary = {}
var _descriptions: Dictionary = {}
var _detail: PanelContainer
var _titre_detail: Label
var _icone_detail: TextureRect
var _jauge: ProgressBar
var _contenu: VBoxContainer
var _page_principale: Control
var _sous_menu: Control

func _ready() -> void:
	var col := StyleAzur.page(self, "Héros", true)
	_page_principale = col.get_parent() as Control
	_contenu = StyleAzur.defilement(col)
	# La constellation deduit sa hauteur de sa largeur : une barre de defilement
	# qui apparait puis disparait relancerait la mise en page sans fin.
	(_contenu.get_parent() as ScrollContainer).vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_contenu.add_theme_constant_override("separation", 14)
	_construire_entete()
	_construire_vitrine()
	_construire_detail()
	_message = StyleAzur.texte("", 26, StyleAzur.MENTHE)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contenu.add_child(_message)
	rafraichir()

func _construire_entete() -> void:
	var entete := HBoxContainer.new()
	entete.name = "ClasseEtPoints"
	entete.add_theme_constant_override("separation", 16)
	_contenu.add_child(entete)
	_classe = StyleAzur.bouton("", _ouvrir_classes, true)
	_classe.name = "Classe"
	_classe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_classe.custom_minimum_size.y = 104
	_classe.size_flags_stretch_ratio = 2.0
	StyleJeu.habiller_bouton(_classe, "violet", 34)
	_classe.add_theme_font_override("font", Polices.JEU_FORT)
	entete.add_child(_classe)
	# Reserve de points en joyau : le chiffre est la premiere lecture de l'ecran.
	var points := PanelContainer.new()
	points.name = "ReservePoints"
	points.custom_minimum_size = Vector2(250, 104)
	points.add_theme_stylebox_override("panel", StyleJeu.boite("ambre", 30.0))
	entete.add_child(points)
	var reserve := HBoxContainer.new()
	reserve.alignment = BoxContainer.ALIGNMENT_CENTER
	reserve.add_theme_constant_override("separation", 10)
	points.add_child(reserve)
	_resume = StyleJeu.texte("", 54, StyleJeu.TEXTE, Color("7a2a0c"), true)
	_resume.name = "PointsDisponibles"
	_resume.autowrap_mode = TextServer.AUTOWRAP_OFF
	reserve.add_child(_resume)
	var titre_points := StyleJeu.texte("points", 28, StyleJeu.TEXTE, Color("7a2a0c"), true)
	titre_points.autowrap_mode = TextServer.AUTOWRAP_OFF
	reserve.add_child(titre_points)
	var reset := StyleAzur.bouton("↺", _reinitialiser_attributs)
	reset.name = "ReinitialiserAttributs"
	reset.tooltip_text = "Réinitialiser les attributs · Gratuit"
	reset.custom_minimum_size = Vector2.ONE * 104
	reset.size_flags_horizontal = Control.SIZE_SHRINK_END
	StyleJeu.habiller_bouton(reset, "azur", 48, 52.0)
	entete.add_child(reset)

func _construire_vitrine() -> void:
	var vitrine := CompositionArcane.new()
	vitrine.name = "Constellation"
	vitrine.hauteur = 1010
	var trace := PackedVector2Array()
	for id: String in ORDRE_TRACE: trace.append(PLACES[id])
	vitrine.traces = [trace]
	_contenu.add_child(vitrine)
	var socle := SOCLE.new()
	socle.name = "Socle"
	vitrine.placer(socle, Rect2(220, 412, 520, 190))
	var portrait := PORTRAIT.new()
	portrait.name = "PortraitHeros"
	vitrine.placer(portrait, Rect2(210, 0, 540, 800))
	for valeur in Personnage.ATTRIBUTS:
		var id := str(valeur)
		var donnees: Dictionary = Personnage.ATTRIBUTS[id]
		var accent: Color = ACCENTS[id]
		var centre: Vector2 = PLACES[id]
		var medaillon := Button.new()
		medaillon.name = "Medaillon_" + id
		medaillon.tooltip_text = str(donnees["nom"])
		medaillon.focus_mode = Control.FOCUS_NONE
		medaillon.pressed.connect(_selectionner.bind(id))
		StyleJeu.animer_appui(medaillon)
		var icone := TextureRect.new()
		icone.texture = GLYPHES[id]
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icone.position = Vector2.ONE * DIAMETRE * .1
		icone.size = Vector2.ONE * DIAMETRE * .8
		medaillon.add_child(icone)
		vitrine.placer(medaillon, Rect2(centre - Vector2.ONE * DIAMETRE * .5, Vector2.ONE * DIAMETRE))
		_medaillons[id] = medaillon
		# Badge de rang pose sur le bas du sceau, comme dans les Maitrises.
		var badge := Panel.new()
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style_badge := StyleBoxTexture.new()
		style_badge.texture = FOND_RANG
		for cote in [SIDE_LEFT, SIDE_RIGHT]: style_badge.set_texture_margin(cote, 28)
		for cote in [SIDE_TOP, SIDE_BOTTOM]: style_badge.set_texture_margin(cote, 18)
		badge.add_theme_stylebox_override("panel", style_badge)
		var rang := StyleAzur.texte("", 32, Color("ffe9bd"))
		rang.name = "Rang_" + id
		rang.add_theme_font_override("font", Polices.CHIFFRES)
		rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rang.autowrap_mode = TextServer.AUTOWRAP_OFF
		badge.add_child(rang)
		rang.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vitrine.placer(badge, Rect2(centre + Vector2(-60, DIAMETRE * .5 - 30), Vector2(120, 48)))
		_rangs[id] = rang
		var nom := StyleAzur.calligraphie(str(donnees["nom"]), 36, accent)
		nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nom.autowrap_mode = TextServer.AUTOWRAP_OFF
		vitrine.placer(nom, Rect2(centre + Vector2(-140, DIAMETRE * .5 + 20), Vector2(280, 50)))
		# Ajout direct : un point se place d'un geste, sans ouvrir de fiche.
		var plus := _bouton_attribut(true, accent, func():
			_selection = id
			_modifier(id, 1))
		plus.name = "Plus_" + id
		plus.tooltip_text = "Ajouter un point en " + str(donnees["nom"])
		plus.custom_minimum_size = Vector2.ONE * 92
		vitrine.placer(plus, Rect2(centre + Vector2(DIAMETRE * .5 - 58, -DIAMETRE * .5 - 18), Vector2.ONE * 92))
		_plus[id] = plus

func _construire_detail() -> void:
	_detail = PanelContainer.new()
	_detail.name = "DetailAttribut"
	_contenu.add_child(_detail)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 18)
	_detail.add_child(ligne)
	_icone_detail = TextureRect.new()
	_icone_detail.custom_minimum_size = Vector2(120, 120)
	_icone_detail.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icone_detail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icone_detail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icone_detail.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	ligne.add_child(_icone_detail)
	var lecture := VBoxContainer.new()
	lecture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lecture.add_theme_constant_override("separation", 8)
	ligne.add_child(lecture)
	_titre_detail = StyleAzur.calligraphie("", 40, StyleAzur.IVOIRE)
	lecture.add_child(_titre_detail)
	_jauge = JAUGE.new()
	_jauge.name = "JaugeSelection"
	lecture.add_child(_jauge)
	for valeur in Personnage.ATTRIBUTS:
		var id := str(valeur)
		var description := StyleAzur.texte("", 28, StyleAzur.IVOIRE)
		description.name = "Description_" + id
		description.visible = false
		lecture.add_child(description)
		_descriptions[id] = description
	var commandes := VBoxContainer.new()
	commandes.name = "Commandes"
	commandes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	commandes.add_theme_constant_override("separation", 10)
	ligne.add_child(commandes)
	_plus_selection = _bouton_attribut(true, StyleAzur.OR_VIF, func(): _modifier(_selection, 1))
	_plus_selection.name = "PlusSelection"
	commandes.add_child(_plus_selection)
	_moins = _bouton_attribut(false, StyleAzur.OR_VIF, func(): _modifier(_selection, -1))
	_moins.name = "MoinsSelection"
	commandes.add_child(_moins)

func _selectionner(id: String) -> void:
	_selection = id
	Sons.jouer("choix", -17.0)
	rafraichir()

func _bouton_attribut(ajouter: bool, accent: Color, action: Callable) -> Button:
	var bouton := StyleAzur.bouton("+" if ajouter else "−", action, ajouter)
	bouton.custom_minimum_size = Vector2.ONE * Ecran.CIBLE_TACTILE
	bouton.add_theme_font_override("font", Polices.TITRE)
	bouton.add_theme_font_size_override("font_size", 42)
	StyleJeu.habiller_bouton(bouton, StyleAzur.teinte_proche(accent) if ajouter else "nuit", 46, 26.0)
	bouton.add_theme_font_override("font", Polices.JEU_FORT)
	bouton.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
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
	var niveau := ReglagesJoueur.niveau_compte_effectif()
	var classe := ReglagesJoueur.specialisation_effective()
	_classe.text = "Classe · " + (str(Personnage.SPECIALISATIONS[classe]["nom"]) if not classe.is_empty() else "À choisir")
	var disponibles := ReglagesJoueur.points_attributs_disponibles()
	_resume.text = str(disponibles)
	_message.visible = not _message.text.is_empty()
	for id: String in _rangs:
		var points := ReglagesJoueur.rang_attribut(id)
		(_rangs[id] as Label).text = "+%d" % points
		var accent: Color = ACCENTS[id]
		var medaillon: Button = _medaillons[id]
		var choisi := id == _selection
		for etat in ["normal", "hover", "pressed", "disabled"]:
			medaillon.add_theme_stylebox_override(etat, StyleAzur.cercle_teinte(accent, choisi or etat == "pressed"))
		var description: Label = _descriptions[id]
		description.text = Personnage.description_attribut(id, points, niveau)
		description.tooltip_text = str(Personnage.ATTRIBUTS[id]["description"])
		description.visible = choisi
		var plus: Button = _plus[id]
		plus.disabled = disponibles <= 0
	var accent_selection: Color = ACCENTS[_selection]
	_detail.add_theme_stylebox_override("panel", StyleJeu.panneau(accent_selection, 30.0, .95))
	_icone_detail.texture = GLYPHES[_selection]
	_titre_detail.text = "%s · +%d" % [str(Personnage.ATTRIBUTS[_selection]["nom"]), ReglagesJoueur.rang_attribut(_selection)]
	_titre_detail.add_theme_color_override("font_color", accent_selection.lightened(.2))
	_jauge.accent = accent_selection
	_jauge.afficher(ReglagesJoueur.rang_attribut(_selection), Personnage.points_totaux(niveau))
	_plus_selection.disabled = disponibles <= 0
	_moins.disabled = ReglagesJoueur.rang_attribut(_selection) <= 0
