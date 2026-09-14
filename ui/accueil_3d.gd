extends Control
signal campagne
signal mine
signal epreuve
signal reglages
signal jouer
signal page_demandee(index: int)

var _surface: Control
var _gouttes: Label
var _pierres: Label
var _chapitre: Label
var _haut: Control
var _bas: Control
var _illustration: TextureRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	StyleAzur.fond_atelier(self)
	_surface = Control.new()
	_surface.size = Vector2(1024,1536)
	add_child(_surface)
	_illustration = TextureRect.new()
	_illustration.texture = preload("res://assets/visual/arcane/accueil.png")
	_illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_illustration.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_illustration)
	move_child(_illustration, 1)
	_illustration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_haut = Control.new()
	_surface.add_child(_haut)
	var entete := Panel.new()
	entete.position = Vector2(20,0)
	entete.size = Vector2(984,112)
	entete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entete.add_theme_stylebox_override("panel",StyleAzur.cadre(Color(StyleAzur.PANNEAU,0.94)))
	_haut.add_child(entete)
	var titre := StyleAzur.texte("ALAMBIK",48)
	titre.position = Vector2(42,23)
	titre.size = Vector2(390,66)
	_haut.add_child(titre)
	_gouttes = _valeur(Rect2(454,30,228,52),28,_haut)
	_pierres = _valeur(Rect2(696,30,170,52),28,_haut)
	var parametres := StyleAzur.bouton("",func(): reglages.emit())
	parametres.icon = IconesArcane.texture("parametres")
	parametres.expand_icon = true
	parametres.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parametres.add_theme_constant_override("icon_max_width",48)
	parametres.position = Vector2(888,0)
	parametres.size = Vector2(112,112)
	parametres.tooltip_text = "Paramètres"
	_haut.add_child(parametres)
	_bas = Control.new()
	_surface.add_child(_bas)
	var modes_bouton := StyleAzur.bouton("Campagne & modes", func(): campagne.emit())
	StyleAzur.habiller_accueil(modes_bouton)
	modes_bouton.position = Vector2(168, 128)
	modes_bouton.size = Vector2(688, 108)
	_bas.add_child(modes_bouton)
	var jouer_bouton := StyleAzur.bouton("JOUER", func(): jouer.emit(), true)
	StyleAzur.habiller_accueil(jouer_bouton, true)
	jouer_bouton.position = Vector2(200, 266)
	jouer_bouton.size = Vector2(624, 136)
	_bas.add_child(jouer_bouton)
	var masque := Panel.new()
	masque.position = Vector2(132,22)
	masque.size = Vector2(760,82)
	masque.add_theme_stylebox_override("panel",StyleAzur.cadre(Color("30243fe8"),StyleAzur.CUIVRE,40))
	masque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bas.add_child(masque)
	_chapitre = _valeur(Rect2(156,33,712,60),30,_bas)
	_chapitre.add_theme_color_override("font_color",StyleAzur.ENCRE)
	resized.connect(_cadrer)
	_cadrer()
	rafraichir()

func _valeur(rect: Rect2, taille: int, parent: Control) -> Label:
	var fond := ColorRect.new()
	fond.color = Color.TRANSPARENT
	fond.position = rect.position
	fond.size = rect.size
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(fond)
	var texte := StyleAzur.texte("",taille)
	texte.position = rect.position
	texte.size = rect.size
	texte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texte.autowrap_mode = TextServer.AUTOWRAP_OFF
	texte.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	parent.add_child(texte)
	return texte

func _zone(rect: Rect2, action: Callable, titre: String) -> void:
	var bouton := StyleInterface.zone_tactile()
	bouton.position = rect.position
	bouton.size = rect.size
	bouton.tooltip_text = titre
	bouton.pressed.connect(action)
	_bas.add_child(bouton)

func _cadrer() -> void:
	var facteur := minf(size.x/1024.0, size.y/1700.0)
	var hauteur := (size.y-Ecran.marge_basse()-StyleAzur.HAUTEUR_NAVIGATION)/facteur
	_surface.scale = Vector2.ONE*facteur
	_surface.size = Vector2(1024,hauteur)
	_surface.position = Vector2((size.x-1024.0*facteur)*0.5,0)
	_haut.position.y = Ecran.marge_haute()/facteur
	_bas.position.y = hauteur-450

func rafraichir() -> void:
	if _gouttes == null: return
	_gouttes.text = "%s gouttes" % ReglagesJoueur.gouttes_affichees()
	_gouttes.add_theme_color_override("font_color",StyleAzur.ENCRE)
	_pierres.text = "%s pierres" % ReglagesJoueur.pierres_forge
	_pierres.add_theme_color_override("font_color",StyleAzur.MAGIE)
	var mode := ReglagesJoueur.mode_run_choisi
	var chapitre: Dictionary = Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
	_chapitre.text = "%s · Chapitre %d" % [Chapitres.MONDES[int(chapitre["monde"])]["nom"],int(chapitre["chapitre_monde"])] if mode == "grimoire" else ("LA MINE" if mode == "mine" else "ÉPREUVE · NIVEAU %d" % ReglagesJoueur.niveau_epreuve_choisi)
