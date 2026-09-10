class_name StyleAzur
extends RefCounted

const FOND := Color("08232e")
const PANNEAU := Color("103441")
const CUIVRE := Color("bc9258")
const TEXTE := Color("f2e9d5")
const ATTENUE := Color("aac4cc")
const MAGIE := Color("64ccdb")
const IVOIRE := Color("eee0c5")
const ENCRE := Color("142b35")
const ATLAS := preload("res://assets/visual/azur/icones.png")
const HAUTEUR_NAVIGATION := 196.0
static var _icones := {}
static var _cadres := {}

static func icone(index: int) -> AtlasTexture:
	index = posmod(index, 16)
	if not _icones.has(index):
		var texture := AtlasTexture.new()
		texture.atlas = ATLAS
		var cote := ATLAS.get_width() / 4.0
		texture.region = Rect2((index % 4) * cote, (index / 4) * cote, cote, cote)
		_icones[index] = texture
	return _icones[index]

static func icone_objet(id: String) -> int:
	if not CatalogueObjets.OBJETS.has(id):
		return 0
	var d: Dictionary = CatalogueObjets.OBJETS[id]
	if d["slot"] == "collier":
		return [2,5,7][int(d["monde"]) % 3]
	return [0,1,3,4,6][int(d["chapitre"]) % 5]

static func cadre(couleur := PANNEAU, bord := CUIVRE, rayon := 16) -> StyleBoxFlat:
	var cle := couleur.to_html()+bord.to_html()+str(rayon)
	if _cadres.has(cle): return _cadres[cle]
	var style := StyleInterface.panneau(couleur, Color(bord,0.66), rayon, 5)
	style.set_border_width_all(2)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0,2)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	_cadres[cle] = style
	return style

static func bouton(texte: String, action := Callable(), principal := false) -> Button:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", Polices.CORPS)
	b.add_theme_font_size_override("font_size", 29)
	StyleInterface.styliser_bouton(b, MAGIE if principal else CUIVRE, not principal)
	b.add_theme_stylebox_override("normal",cadre(Color("0c4658") if principal else PANNEAU))
	b.add_theme_stylebox_override("hover",cadre(Color("154c5c"),MAGIE))
	b.add_theme_stylebox_override("pressed",cadre(Color("226274"),MAGIE))
	b.add_theme_stylebox_override("disabled",cadre(Color("142e38"),Color("50616b")))
	b.add_theme_constant_override("outline_size",0)
	if action.is_valid(): b.pressed.connect(action)
	return b

static func texte(contenu: String, taille := 30, couleur := TEXTE) -> Label:
	var l := Label.new()
	l.text = contenu
	l.add_theme_font_override("font",Polices.CORPS)
	l.add_theme_font_size_override("font_size",taille)
	l.add_theme_color_override("font_color",couleur)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func image(index: int, cote := 128.0) -> TextureRect:
	var t := TextureRect.new()
	t.texture = icone(index)
	t.custom_minimum_size = Vector2.ONE*cote
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func page(parent: Control, titre: String, integre := false) -> VBoxContainer:
	parent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var fond := ColorRect.new()
	fond.color = FOND
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/fond_azur.gdshader")
	fond.material = mat
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(fond)
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for nom in ["left","right"]: marge.add_theme_constant_override("margin_"+nom,40)
	marge.add_theme_constant_override("margin_top",int(Ecran.marge_haute())+20)
	marge.add_theme_constant_override("margin_bottom",int(HAUTEUR_NAVIGATION+Ecran.marge_basse()+20) if integre else int(Ecran.marge_basse())+24)
	parent.add_child(marge)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",22)
	marge.add_child(col)
	var entete := HBoxContainer.new()
	col.add_child(entete)
	var label := texte(titre,48)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(label)
	if not integre and parent.has_signal("ferme"):
		var retour := bouton("‹",func(): parent.emit_signal("ferme"))
		retour.size_flags_horizontal = 0
		retour.custom_minimum_size.x = 112
		entete.add_child(retour)
	var ligne := HSeparator.new()
	ligne.add_theme_color_override("separator",CUIVRE)
	col.add_child(ligne)
	return col

static func defilement(col: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	col.add_child(scroll)
	var contenu := VBoxContainer.new()
	contenu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_theme_constant_override("separation",18)
	scroll.add_child(contenu)
	return contenu

static func plaque(parent: Node, claire := false) -> VBoxContainer:
	var panneau := PanelContainer.new()
	panneau.add_theme_stylebox_override("panel",cadre(IVOIRE if claire else PANNEAU))
	parent.add_child(panneau)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",12)
	panneau.add_child(col)
	return col

static func glyphe(id: String) -> Texture2D:
	if CatalogueElements.est_fusion(id):
		id = CatalogueElements.augment_de_fusion(id)
	var cle := "glyphe/"+id
	if not _icones.has(cle):
		var chemin := "res://assets/visual/azur/glyphes/"+id+".svg"
		if not ResourceLoader.exists(chemin):
			push_warning("Glyphe absent : "+id)
			return icone(10)
		_icones[cle] = load(chemin)
	return _icones[cle]

static func vignette(id: String, cote := 128.0) -> TextureRect:
	var t := image(0,cote)
	t.texture = glyphe(id)
	return t
