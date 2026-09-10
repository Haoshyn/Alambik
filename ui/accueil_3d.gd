extends Control
signal campagne
signal mine
signal epreuve
signal reglages
signal jouer
signal page_demandee(index: int)

const IMAGE := preload("res://assets/visual/azur/accueil_valide.png")
const FOND := preload("res://assets/visual/azur/accueil_fond_portrait.png")
var _surface: Control
var _matiere: ShaderMaterial
var _gouttes: Label
var _pierres: Label
var _chapitre: Label
var _haut: Control
var _bas: Control
var _illustration: TextureRect
var _temps := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_surface = Control.new()
	_surface.size = Vector2(1024,1536)
	add_child(_surface)
	_illustration = TextureRect.new()
	_illustration.texture = FOND
	_illustration.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_matiere = ShaderMaterial.new()
	_matiere.shader = preload("res://shaders/accueil_portrait.gdshader")
	_illustration.material = _matiere
	_surface.add_child(_illustration)
	_haut = Control.new()
	_surface.add_child(_haut)
	var entete := Panel.new()
	entete.position = Vector2(20,0)
	entete.size = Vector2(984,112)
	entete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entete.add_theme_stylebox_override("panel",StyleAzur.cadre(Color("082d40e8")))
	_haut.add_child(entete)
	var titre := StyleAzur.texte("ALAMBIC",48)
	titre.position = Vector2(42,23)
	titre.size = Vector2(390,66)
	_haut.add_child(titre)
	_gouttes = _valeur(Rect2(536,30,160,52),30,_haut)
	_pierres = _valeur(Rect2(728,30,138,52),30,_haut)
	var parametres := StyleAzur.bouton("⚙",func(): reglages.emit())
	parametres.position = Vector2(888,0)
	parametres.size = Vector2(112,112)
	parametres.tooltip_text = "Paramètres"
	_haut.add_child(parametres)
	_bas = Control.new()
	_surface.add_child(_bas)
	_image_region(Rect2(496,837,486,313),Vector2(496,0))
	_image_region(Rect2(453,1169,530,138),Vector2(453,332))
	_zone(Rect2(496,0,486,313),func(): campagne.emit(),"Campagne et modes de jeu")
	_zone(Rect2(453,332,530,138),func(): jouer.emit(),"Jouer")
	var masque := ColorRect.new()
	masque.position = Vector2(525,14)
	masque.size = Vector2(433,119)
	masque.color = Color("082d40")
	masque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bas.add_child(masque)
	_chapitre = _valeur(Rect2(530,22,418,46),29,_bas)
	_chapitre.add_theme_color_override("font_color",StyleAzur.CUIVRE)
	var modes := _valeur(Rect2(530,72,418,54),28,_bas)
	modes.text = "Campagne & modes"
	resized.connect(_cadrer)
	_cadrer()
	rafraichir()

func _image_region(rect: Rect2, position_: Vector2) -> void:
	var image := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = IMAGE
	atlas.region = rect
	image.texture = atlas
	image.position = position_
	image.size = rect.size
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bas.add_child(image)

func _valeur(rect: Rect2, taille: int, parent: Control) -> Label:
	var fond := ColorRect.new()
	fond.color = Color("082d40")
	fond.position = rect.position
	fond.size = rect.size
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(fond)
	var texte := StyleAzur.texte("",taille)
	texte.position = rect.position
	texte.size = rect.size
	texte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
	var facteur := size.x/1024.0
	var hauteur := (size.y-Ecran.marge_basse()-StyleAzur.HAUTEUR_NAVIGATION)/facteur
	_surface.scale = Vector2.ONE*facteur
	_surface.size = Vector2(1024,hauteur)
	_surface.position = Vector2.ZERO
	_illustration.size = _surface.size
	_haut.position.y = Ecran.marge_haute()/facteur
	_bas.position.y = hauteur-490

func rafraichir() -> void:
	if _gouttes == null: return
	_gouttes.text = "● %s" % ReglagesJoueur.gouttes_affichees()
	_gouttes.add_theme_color_override("font_color",Color("f7cc79"))
	_pierres.text = "◆ %s" % ReglagesJoueur.pierres_forge
	_pierres.add_theme_color_override("font_color",StyleAzur.MAGIE)
	var mode := ReglagesJoueur.mode_run_choisi
	_chapitre.text = "CHAPITRE %d" % (ReglagesJoueur.chapitre_choisi+1) if mode == "grimoire" else ("LA MINE" if mode == "mine" else "ÉPREUVES")

func _process(delta: float) -> void:
	_temps += delta
	_matiere.set_shader_parameter("temps",_temps)
	_matiere.set_shader_parameter("amplitude",0.12 if ReglagesJoueur.effets_reduits else 1.0)
