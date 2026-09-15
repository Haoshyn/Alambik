class_name StyleAzur
extends RefCounted

const FOND := Color("201b40")
const PANNEAU := Color("30243f")
const CUIVRE := Color("ffc77c")
const CORAIL := Color("f47787")
const MENTHE := Color("8fe5bd")
const LILAS := Color("bea0ff")
const TEXTE := Color("eff2ff")
const ATTENUE := Color("c6cbea")
const MAGIE := Color("68e5eb")
const IVOIRE := Color("e6ecff")
const ENCRE := Color("eff2ff")
const ATLAS := preload("res://assets/visual/azur/icones.png")
const HAUTEUR_NAVIGATION := 176.0
const VIOLET := Color("493459")
const FOND_ATELIER := preload("res://assets/visual/arcane/fond.png")
const TITRE_ATELIER := preload("res://assets/fonts/DMSans-Variable.ttf")
const ARMES_ATELIER := preload("res://assets/visual/atelier/armes.png")
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

static func icone_arme(id: String) -> AtlasTexture:
	var cle := "arme/"+id
	if not _icones.has(cle):
		if id == "standard":
			var baguette := AtlasTexture.new()
			baguette.atlas = preload("res://assets/visual/manga/baguette_atelier.png")
			baguette.region = Rect2(Vector2.ZERO, baguette.atlas.get_size())
			_icones[cle] = baguette
			return baguette
		var variantes := {"prisme":"veloce","resonant":"lourd","draconique":"explosif","neant":"chercheur","royal":"lourd"}
		var index := ["standard","veloce","lourd","chercheur","explosif"].find(str(variantes.get(id,id)))
		index = maxi(index,0)
		var texture := AtlasTexture.new()
		texture.atlas = ARMES_ATELIER
		var cellule := Vector2(ARMES_ATELIER.get_width()/3.0,ARMES_ATELIER.get_height()/2.0)
		texture.region = Rect2(Vector2(index%3,index/3)*cellule,cellule)
		texture.filter_clip = true
		_icones[cle] = texture
	return _icones[cle]

static func cadre(couleur := PANNEAU, bord := CUIVRE, rayon := 28) -> StyleBox:
	var cle := couleur.to_html()+bord.to_html()+str(rayon)
	if _cadres.has(cle): return _cadres[cle]
	var style := StyleInterface.panneau(couleur, Color(bord,0.8), rayon, 5)
	style.set_border_width_all(3)
	style.set_corner_radius_all(mini(rayon, 32))
	style.corner_detail = 12
	style.shadow_color = Color("21172eee")
	style.shadow_size = 3
	style.shadow_offset = Vector2(0,6)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	_cadres[cle] = style
	return style

static func bouton(texte: String, action := Callable(), principal := false) -> Button:
	var b := Button.new()
	b.text = texte
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", Polices.CORPS)
	if principal: b.add_theme_font_override("font",TITRE_ATELIER)
	b.add_theme_font_size_override("font_size", 29)
	StyleInterface.styliser_bouton(b, MAGIE if principal else CUIVRE, not principal)
	b.add_theme_stylebox_override("normal",cadre(Color("773f61") if principal else PANNEAU,CORAIL if principal else LILAS))
	b.add_theme_stylebox_override("hover",cadre(Color("654d79"),CUIVRE))
	b.add_theme_stylebox_override("pressed",cadre(Color("453052"),MENTHE))
	b.add_theme_stylebox_override("disabled",cadre(Color("252943"),Color("707c9d")))
	for etat in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(etat, ENCRE)
	b.add_theme_color_override("font_disabled_color", Color("98a3c6"))
	b.add_theme_stylebox_override("focus",cadre(Color.TRANSPARENT,MAGIE))
	if principal:
		b.add_theme_font_size_override("font_size",34)
	b.add_theme_constant_override("outline_size",0)
	if action.is_valid(): b.pressed.connect(action)
	return b

static func sceau(principal := false, teinte := Color.WHITE) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = preload("res://assets/visual/manga/jouer.svg") if principal else preload("res://assets/visual/manga/ruban.svg")
	for cote in [SIDE_LEFT, SIDE_RIGHT]:
		style.set_texture_margin(cote, 64)
		style.set_content_margin(cote, 64)
	for cote in [SIDE_TOP, SIDE_BOTTOM]:
		style.set_texture_margin(cote, 24)
		style.set_content_margin(cote, 18)
	style.modulate_color = teinte
	return style

static func habiller_accueil(b: Button, principal := false) -> void:
	if principal:
		# Le depart reprend la magie du heros avec un contour discret.
		b.add_theme_stylebox_override("normal", cadre(Color("654899"), Color("d7bafc"), 22))
		b.add_theme_stylebox_override("hover", cadre(Color("795aae"), Color("ffe5af"), 22))
		b.add_theme_stylebox_override("pressed", cadre(Color("4f3777"), Color("bfeeda"), 22))
		b.add_theme_font_size_override("font_size", 40)
		return
	b.add_theme_stylebox_override("normal", sceau(principal))
	b.add_theme_stylebox_override("hover", sceau(principal, Color("fff2cf")))
	b.add_theme_stylebox_override("pressed", sceau(principal, Color("cfb9db")))
	b.add_theme_font_size_override("font_size", 44 if principal else 30)
	if principal:
		for etat in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(etat, Color("30243f"))

static func texte(contenu: String, taille := 30, couleur := TEXTE) -> Label:
	var l := Label.new()
	l.text = contenu
	l.add_theme_font_override("font",Polices.CORPS)
	if taille >= 34:
		var titre := FontVariation.new()
		titre.base_font = TITRE_ATELIER
		titre.variation_embolden = 0.6
		l.add_theme_font_override("font",titre)
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
	fond_atelier(parent, true)
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for nom in ["left","right"]: marge.add_theme_constant_override("margin_"+nom,36)
	marge.add_theme_constant_override("margin_top",int(Ecran.marge_haute())+20)
	marge.add_theme_constant_override("margin_bottom",int(HAUTEUR_NAVIGATION+Ecran.marge_basse()+20) if integre else int(Ecran.marge_basse())+24)
	parent.add_child(marge)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",22)
	marge.add_child(col)
	var cartouche := PanelContainer.new()
	cartouche.add_theme_stylebox_override("panel",cadre())
	col.add_child(cartouche)
	var entete := HBoxContainer.new()
	entete.add_theme_constant_override("separation",16)
	cartouche.add_child(entete)
	var id_entete: String = {"Maîtrises":"navigation_maitrises", "Sorts":"navigation_sorts", "Équipement":"navigation_equipement", "Paramètres":"parametres"}.get(titre, "grand_oeuvre")
	var embl := vignette(id_entete,64)
	entete.add_child(embl)
	var label := texte(titre,42)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(label)
	if not integre and parent.has_signal("ferme"):
		var retour := bouton("‹",func(): parent.emit_signal("ferme"))
		retour.size_flags_horizontal = 0
		retour.custom_minimum_size.x = 112
		entete.add_child(retour)
	if integre:
		var ressources := texte("%s gouttes   ·   %d pierres de forge" % [ReglagesJoueur.gouttes_affichees(),ReglagesJoueur.pierres_forge],25,IVOIRE)
		ressources.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		col.add_child(ressources)
	return col

static func defilement(col: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	var papier := PanelContainer.new()
	papier.size_flags_vertical = Control.SIZE_EXPAND_FILL
	papier.add_theme_stylebox_override("panel",cadre())
	col.add_child(papier)
	papier.add_child(scroll)
	var contenu := VBoxContainer.new()
	contenu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_theme_constant_override("separation",18)
	scroll.add_child(contenu)
	return contenu

static func plaque(parent: Node, claire := false) -> VBoxContainer:
	var panneau := PanelContainer.new()
	panneau.add_theme_stylebox_override("panel",cadre(VIOLET if claire else PANNEAU))
	parent.add_child(panneau)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",12)
	panneau.add_child(col)
	return col

static func glyphe(id: String) -> Texture2D:
	if CatalogueRecettes.est_fusion(id): id = CatalogueRecettes.augment_de(id)
	if CatalogueElements.est_fusion(id):
		id = CatalogueElements.augment_de_fusion(id)
	if IconesArcane.contient(id): return IconesArcane.texture(id)
	var cle := "glyphe/"+id
	if not _icones.has(cle):
		var chemin := "res://assets/visual/azur/glyphes/"+id+".svg"
		if not ResourceLoader.exists(chemin):
			push_warning("Glyphe absent : "+id)
			return icone(10)
		_icones[cle] = load(chemin)
	return _icones[cle]

static func vignette(id: String, cote := 128.0, ronde := false) -> TextureRect:
	var t := image(0,cote)
	t.texture = glyphe(id)
	# Les stickers detoures gardent leurs pointes, meme dans les maitrises.
	if ronde: t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return t

static func fond_atelier(parent: Control, calme := false) -> void:
	var fond := TextureRect.new()
	fond.texture = FOND_ATELIER
	fond.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fond.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fond.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(fond)
	if calme:
		var voile := ColorRect.new()
		voile.color = Color("161b3844")
		voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(voile)

static func case_objet(b: Button, selection := false) -> void:
	b.add_theme_stylebox_override("normal",cadre(Color("265d67") if selection else Color("503660"),MAGIE if selection else CUIVRE))
	b.add_theme_stylebox_override("hover",cadre(Color("65507b"),CUIVRE))
	b.add_theme_stylebox_override("pressed",cadre(Color("265d67"),MAGIE))
	for etat in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		b.add_theme_color_override(etat,IVOIRE)
	b.add_theme_font_override("font",Polices.CORPS)

static func medaillon(index: int, cote := 128.0) -> PanelContainer:
	var socle := PanelContainer.new()
	socle.add_theme_stylebox_override("panel",cadre(VIOLET,CUIVRE,64))
	socle.add_child(image(index,cote))
	socle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return socle
