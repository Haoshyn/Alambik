class_name StyleAzur
extends RefCounted

const FOND := Color("12243f")
const PANNEAU := Color("203d62")
const CUIVRE := Color("edc77e")
const CORAIL := Color("f47787")
const MENTHE := Color("8fe5bd")
const LILAS := Color("bea0ff")
const TEXTE := Color("fff9ed")
const ATTENUE := Color("e3e8f5")
const MAGIE := Color("69e1da")
const IVOIRE := Color("fff9ed")
const ENCRE := Color("fff9ed")
const ATLAS := preload("res://assets/visual/azur/icones.png")
const HAUTEUR_NAVIGATION := 176.0
const VIOLET := Color("3a426c")
const FOND_ATELIER := preload("res://assets/visual/interface/scriptorium.png")
const TITRE_ATELIER := Polices.TITRE
const ARMES_ATELIER := preload("res://assets/visual/atelier/armes.png")
# Les ressources explicites restent incluses dans les exports Android.
const TEXTURES_INTERFACE := {
	"panneau": preload("res://assets/visual/interface/panneau.svg"),
	"cadre": preload("res://assets/visual/interface/cadre.svg"),
	"carte_augment": preload("res://assets/visual/interface/carte_augment.svg"),
	"bouton_principal": preload("res://assets/visual/interface/bouton_principal.svg"),
	"bouton_secondaire": preload("res://assets/visual/interface/bouton_secondaire.svg"),
	"medaillon": preload("res://assets/visual/interface/medaillon.svg"),
	"bandeau": preload("res://assets/visual/interface/bandeau.svg"),
	"separateur": preload("res://assets/visual/interface/separateur.svg"),
	"grimoire": preload("res://assets/visual/interface/grimoire.svg"),
	"forge": preload("res://assets/visual/interface/forge.svg"),
	"astrolabe": preload("res://assets/visual/interface/astrolabe.svg"),
	"fiole": preload("res://assets/visual/interface/fiole.svg"),
	"portail": preload("res://assets/visual/interface/portail.svg"),
	"victoire": preload("res://assets/visual/interface/victoire.svg"),
	"defaite": preload("res://assets/visual/interface/defaite.svg"),
	"couronne": preload("res://assets/visual/interface/couronne.svg"),
	"jauge_fond": preload("res://assets/visual/interface/jauge_fond.svg"),
	"jauge_plein": preload("res://assets/visual/interface/jauge_plein.svg"),
	"joystick_base": preload("res://assets/visual/interface/joystick_base.svg"),
	"joystick_curseur": preload("res://assets/visual/interface/joystick_curseur.svg"),
	"coffre_corps": preload("res://assets/visual/interface/coffre_corps.svg"),
	"coffre_couvercle": preload("res://assets/visual/interface/coffre_couvercle.svg"),
	"halo_recompense": preload("res://assets/visual/interface/halo_recompense.svg"),
}
static var _icones := {}
static var _cadres := {}
static var _theme: Theme

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
	var nom := "cadre" if couleur.a == 0.0 else ("medaillon" if rayon >= 60 else "panneau")
	var style := texture_etirable(nom, 24, 12 if rayon >= 60 else 48, 12 if rayon >= 60 else 36)
	style.draw_center = couleur.a > 0.0
	style.modulate_color = Color.WHITE.lerp(bord, 0.08)
	if couleur.a > 0.0:
		style.modulate_color = style.modulate_color.lerp(couleur.lightened(0.75), 0.18)
		style.modulate_color.a = couleur.a
	_cadres[cle] = style
	return style

static func bouton(texte: String, action := Callable(), principal := false) -> Button:
	var b := Button.new()
	HabillagePeint.appliquer(b)
	b.text = texte
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", Polices.CORPS)
	if principal: b.add_theme_font_override("font",TITRE_ATELIER)
	b.add_theme_font_size_override("font_size", 29)
	StyleInterface.styliser_bouton(b, MAGIE if principal else CUIVRE, not principal)
	b.add_theme_stylebox_override("normal",sceau(principal))
	b.add_theme_stylebox_override("hover",sceau(principal, Color("fff5db")))
	b.add_theme_stylebox_override("pressed",sceau(principal, Color("b9e5db")))
	b.add_theme_stylebox_override("disabled",sceau(principal, Color("73758d")))
	for etat in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(etat, ENCRE)
	b.add_theme_color_override("font_disabled_color", Color("e0dcea"))
	b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
	if principal:
		b.add_theme_font_size_override("font_size",34)
	b.add_theme_constant_override("outline_size",3)
	b.add_theme_color_override("font_outline_color",Color("160d30"))
	if action.is_valid(): b.pressed.connect(action)
	return b

static func sceau(principal := false, teinte := Color.WHITE) -> StyleBoxTexture:
	var style := texture_etirable("bouton_principal" if principal else "bouton_secondaire", 44, 44, 30)
	style.modulate_color = teinte
	return style

static func habiller_accueil(b: Button, principal := false) -> void:
	b.add_theme_stylebox_override("normal", sceau(principal))
	b.add_theme_stylebox_override("hover", sceau(principal, Color("fff2cf")))
	b.add_theme_stylebox_override("pressed", sceau(principal, Color("b6dedc")))
	b.add_theme_font_size_override("font_size", 44 if principal else 30)

static func texte(contenu: String, taille := 30, couleur := TEXTE) -> Label:
	var l := Label.new()
	l.text = contenu
	l.add_theme_font_override("font",Polices.TITRE if taille >= 34 else Polices.CORPS)
	l.add_theme_font_size_override("font_size",taille)
	l.add_theme_color_override("font_color",couleur)
	l.add_theme_color_override("font_shadow_color",Color("160d30e6"))
	l.add_theme_constant_override("shadow_offset_x",0)
	l.add_theme_constant_override("shadow_offset_y",2)
	l.add_theme_constant_override("line_spacing",4)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func image(index: int, cote := 128.0) -> TextureRect:
	var t := TextureRect.new()
	HabillagePeint.appliquer(t)
	t.texture = icone(index)
	t.custom_minimum_size = Vector2.ONE*cote
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func page(parent: Control, titre: String, integre := false) -> VBoxContainer:
	parent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.theme = theme_interface()
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
	HabillagePeint.appliquer(cartouche)
	cartouche.add_theme_stylebox_override("panel",texture_etirable("bandeau",44,48,28))
	col.add_child(cartouche)
	var contenu_entete := VBoxContainer.new()
	contenu_entete.add_theme_constant_override("separation",12)
	cartouche.add_child(contenu_entete)
	var entete := HBoxContainer.new()
	entete.add_theme_constant_override("separation",16)
	contenu_entete.add_child(entete)
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
		var ressources := HBoxContainer.new()
		ressources.alignment = BoxContainer.ALIGNMENT_END
		ressources.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ressources.add_theme_constant_override("separation",12)
		entete.add_child(ressources)
		ressources.add_child(vignette("gouttes",56))
		var gouttes := texte(ReglagesJoueur.gouttes_affichees(),30,IVOIRE)
		gouttes.autowrap_mode = TextServer.AUTOWRAP_OFF
		ressources.add_child(gouttes)
		var espace := Control.new()
		espace.custom_minimum_size.x = 24
		ressources.add_child(espace)
		ressources.add_child(vignette("pierres",56))
		var pierres := texte(str(ReglagesJoueur.pierres_forge),30,IVOIRE)
		pierres.autowrap_mode = TextServer.AUTOWRAP_OFF
		ressources.add_child(pierres)
		var actualiser := func() -> void:
			gouttes.text = ReglagesJoueur.gouttes_affichees()
			pierres.text = str(ReglagesJoueur.pierres_forge)
		ReglagesJoueur.maitrise_changee.connect(actualiser)
		ressources.tree_exiting.connect(func() -> void:
			ReglagesJoueur.maitrise_changee.disconnect(actualiser), Object.CONNECT_ONE_SHOT)
	return col

static func defilement(col: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.get_v_scroll_bar().custom_minimum_size.x = 14
	col.add_child(scroll)
	var contenu := VBoxContainer.new()
	contenu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_theme_constant_override("separation",18)
	scroll.add_child(contenu)
	return contenu

static func plaque(parent: Node, claire := false) -> VBoxContainer:
	var panneau := PanelContainer.new()
	HabillagePeint.appliquer(panneau)
	panneau.add_theme_stylebox_override("panel",cadre(VIOLET if claire else PANNEAU))
	parent.add_child(panneau)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",18)
	panneau.add_child(col)
	return col

static func glyphe(id: String) -> Texture2D:
	id = str(CatalogueReactifs.ICONES_COMMUNES.get(id, id))
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
	if ronde: t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
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
		voile.color = Color("10172f88")
		voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(voile)

static func case_objet(b: Button, selection := false) -> void:
	b.add_theme_stylebox_override("normal",carte_augment(MAGIE if selection else CUIVRE,selection))
	b.add_theme_stylebox_override("hover",carte_augment(CUIVRE,true))
	b.add_theme_stylebox_override("pressed",carte_augment(MAGIE,true))
	for etat in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		b.add_theme_color_override(etat,IVOIRE)
	b.add_theme_font_override("font",Polices.CORPS)

static func medaillon(index: int, cote := 128.0) -> PanelContainer:
	var socle := PanelContainer.new()
	HabillagePeint.appliquer(socle)
	socle.add_theme_stylebox_override("panel",cadre(VIOLET,CUIVRE,64))
	socle.add_child(image(index,cote))
	socle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return socle

static func texture_interface(nom: String) -> Texture2D:
	if HabillagePeint.contient(nom): return HabillagePeint.texture(nom)
	var texture: Texture2D = TEXTURES_INTERFACE.get(nom, TEXTURES_INTERFACE["grimoire"])
	return texture

static func texture_etirable(nom: String, coin := 32, marge_x := 24, marge_y := 16) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture_interface(nom)
	# Le kit importe a 128 px garde une dorure fine, independante des marges de lecture.
	var peinte := nom in HabillagePeint.SURFACES or nom == "bouton_principal"
	var marge_texture := 24 if peinte and coin > 0 else coin
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_texture_margin(cote, marge_texture)
	for cote in [SIDE_LEFT, SIDE_RIGHT]: style.set_content_margin(cote, marge_x)
	for cote in [SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(cote, marge_y)
	return style

static func carte_augment(accent: Color, selection := false) -> StyleBoxTexture:
	var style := texture_etirable("carte_augment",44,44,32)
	style.modulate_color = Color.WHITE.lerp(accent,0.35 if selection else 0.2)
	if selection: style.modulate_color = style.modulate_color.lightened(0.12)
	return style

static func jauge(remplie := false, teinte := Color.WHITE) -> StyleBoxTexture:
	var style := texture_etirable("jauge_plein" if remplie else "jauge_fond",12,0,0)
	style.modulate_color = teinte
	return style

static func illustration(nom: String, cote := 128.0) -> TextureRect:
	var t := TextureRect.new()
	HabillagePeint.appliquer(t)
	t.texture = texture_interface(nom)
	t.custom_minimum_size = Vector2.ONE * cote
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func banniere(parent: Node, titre: String, sous_titre: String, embleme := "grimoire") -> VBoxContainer:
	var panneau := PanelContainer.new()
	HabillagePeint.appliquer(panneau)
	panneau.add_theme_stylebox_override("panel",cadre(PANNEAU,CUIVRE))
	parent.add_child(panneau)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation",24)
	panneau.add_child(ligne)
	var dessin := illustration(embleme,132)
	dessin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ligne.add_child(dessin)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation",8)
	ligne.add_child(col)
	col.add_child(texte(titre,36,IVOIRE))
	if not sous_titre.is_empty(): col.add_child(texte(sous_titre,25,ATTENUE))
	return col

static func dessiner_icone(surface: CanvasItem, nom: String, rect: Rect2, teinte := Color.WHITE) -> void:
	surface.draw_texture_rect(texture_interface(nom), rect, false, teinte)

static func separateur(parent: Node) -> void:
	var image_separation := illustration("separateur",24)
	image_separation.custom_minimum_size = Vector2(0,24)
	image_separation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(image_separation)

static func theme_interface() -> Theme:
	if _theme != null: return _theme
	_theme = Theme.new()
	_theme.default_font = Polices.CORPS
	_theme.default_font_size = 28
	_theme.set_color("font_color","Label",TEXTE)
	_theme.set_color("font_shadow_color","Label",Color("160d30e6"))
	_theme.set_constant("shadow_offset_x","Label",0)
	_theme.set_constant("shadow_offset_y","Label",2)
	_theme.set_stylebox("panel","TooltipPanel",cadre())
	_theme.set_color("font_color","TooltipLabel",TEXTE)
	_theme.set_font_size("font_size","TooltipLabel",25)
	for type in ["VScrollBar","HScrollBar"]:
		var rail := StyleBoxFlat.new()
		rail.bg_color = Color("10172fcc")
		rail.set_corner_radius_all(6)
		rail.content_margin_left = 6 if type == "VScrollBar" else 1
		rail.content_margin_right = rail.content_margin_left
		rail.content_margin_top = 1 if type == "VScrollBar" else 6
		rail.content_margin_bottom = rail.content_margin_top
		_theme.set_stylebox("scroll",type,rail)
		for etat in ["grabber","grabber_highlight","grabber_pressed"]:
			var curseur := StyleBoxFlat.new()
			curseur.bg_color = MAGIE if etat == "grabber" else IVOIRE
			curseur.set_corner_radius_all(6)
			curseur.content_margin_left = 6 if type == "VScrollBar" else 20
			curseur.content_margin_right = curseur.content_margin_left
			curseur.content_margin_top = 20 if type == "VScrollBar" else 6
			curseur.content_margin_bottom = curseur.content_margin_top
			_theme.set_stylebox(etat,type,curseur)
	return _theme
