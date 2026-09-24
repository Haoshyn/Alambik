class_name StyleAzur
extends RefCounted

const FOND := Color("253459")
const PANNEAU := Color("344c7b")
const CUIVRE := Color("dbc4a0")
const CORAIL := Color("ee9482")
const MENTHE := Color("a7d8e8")
const LILAS := Color("d0baf3")
const TEXTE := Color("f8f6ff")
const ATTENUE := Color("edf2ff")
const MAGIE := Color("8fe5f1")
const OMBRE_CLAIRIERE := Color("263154")
const IVOIRE := Color("f8f6ff")
const ENCRE := Color("253052")
const ENCRE_ATTENUE := Color("53617d")
const ICONES_OBJETS := [
	"anneau_azur", "anneau_amethyste", "pendentif_azur", "anneau_givre",
	"anneau_ambre", "pendentif_lune", "anneau_emeraude", "pendentif_soleil",
	"feu", "egide", "grimoire", "pierres", "vitalite", "temps_suspendu", "astrolabe", "savoir",
]
const HAUTEUR_NAVIGATION := 146.0
const MARGE_NAVIGATION_BAS := 12.0
const VIOLET := Color("735aad")
const FOND_ATELIER := preload("res://assets/visual/interface/academie_arcanique.png")
const FOND_SCRIPTORIUM := preload("res://assets/visual/interface/scriptorium.png")
const TITRE_ATELIER := Polices.TITRE
# Les ressources explicites restent incluses dans les exports Android.
const TEXTURES_INTERFACE := {
	"fleche_bas": preload("res://assets/visual/interface/fleche_bas.svg"),
	"validation": preload("res://assets/visual/interface/validation.svg"),
	"selection": preload("res://assets/visual/interface/selection.svg"),
	"oui": preload("res://assets/visual/interface/oui.svg"),
	"non": preload("res://assets/visual/interface/non.svg"),
	"curseur": preload("res://assets/visual/interface/curseur.svg"),
	"fleche_gauche": preload("res://assets/visual/interface/fleche_gauche.svg"),
	"fleche_droite": preload("res://assets/visual/interface/fleche_droite.svg"),
	"cadenas": preload("res://assets/visual/interface/cadenas.svg"),
	"pause": preload("res://assets/visual/interface/pause.svg"),
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
	"halo_recompense": preload("res://assets/visual/interface/halo_recompense.svg"),
}
static var _icones := {}
static var _cadres := {}
static var _theme: Theme

static func icone(index: int) -> Texture2D:
	index = posmod(index, ICONES_OBJETS.size())
	if not _icones.has(index):
		var nom: String = ICONES_OBJETS[index]
		if index < 8:
			_icones[index] = load("res://assets/visual/interface/equipement/" + nom + ".svg")
		elif nom in HabillagePeint.ICONES:
			_icones[index] = HabillagePeint.texture(nom)
		else:
			_icones[index] = IconesArcane.texture(nom)
	return _icones[index]

static func icone_objet(id: String) -> int:
	if not CatalogueObjets.OBJETS.has(id):
		return 0
	var d: Dictionary = CatalogueObjets.OBJETS[id]
	if d["slot"] == "collier":
		return [2,5,7][int(d["monde"]) % 3]
	return [0,1,3,4,6][int(d["chapitre"]) % 5]

static func icone_arme(id: String) -> Texture2D:
	var cle := "arme/"+id
	if not _icones.has(cle):
		var variantes := {"prisme":"veloce","resonant":"lourd","draconique":"explosif","neant":"chercheur","royal":"lourd"}
		var nom := str(variantes.get(id, id))
		if nom not in ["standard", "veloce", "lourd", "chercheur", "explosif"]:
			nom = "standard"
		_icones[cle] = load("res://assets/visual/interface/armes/" + nom + ".svg")
	return _icones[cle]

static func cadre(couleur := PANNEAU, bord := CUIVRE, rayon := 28) -> StyleBox:
	var cle := couleur.to_html()+bord.to_html()+str(rayon)
	if _cadres.has(cle): return _cadres[cle]
	var nom := "cadre" if couleur.a == 0.0 else ("medaillon" if rayon >= 60 else "panneau")
	var style := texture_etirable(nom, 24, 12 if rayon >= 60 else 48, 12 if rayon >= 60 else 36)
	style.draw_center = couleur.a > 0.0
	style.modulate_color = Color.WHITE.lerp(bord, 0.08)
	if couleur.a > 0.0:
		style.modulate_color = style.modulate_color.lerp(couleur.lightened(0.75), 0.06)
		style.modulate_color.a = couleur.a
	_cadres[cle] = style
	return style

static func bouton(texte: String, action := Callable(), principal := false) -> Button:
	var b := Button.new()
	HabillagePeint.appliquer(b)
	b.text = texte
	if texte.begins_with("‹") or texte.ends_with("›"):
		var retour := texte.begins_with("‹")
		b.text = texte.trim_prefix("‹").trim_suffix("›").strip_edges()
		b.icon = texture_interface("fleche_gauche" if retour else "fleche_droite")
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT if retour else HORIZONTAL_ALIGNMENT_RIGHT
		b.tooltip_text = "Retour" if retour else "Suivant"
	if b.text.is_empty():
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", Polices.CORPS)
	if principal: b.add_theme_font_override("font",TITRE_ATELIER)
	b.add_theme_font_size_override("font_size", 29)
	StyleInterface.styliser_bouton(b, MAGIE if principal else CUIVRE, not principal)
	b.add_theme_stylebox_override("normal",sceau(principal))
	b.add_theme_stylebox_override("hover",sceau(principal, Color("eee7ff")))
	b.add_theme_stylebox_override("pressed",sceau(principal, Color.WHITE, true))
	b.add_theme_stylebox_override("disabled",sceau(principal, Color("8993aa")))
	for etat in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(etat, IVOIRE)
	b.add_theme_color_override("font_disabled_color", Color("c1c7d8"))
	b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
	if principal:
		b.add_theme_font_size_override("font_size",34)
	b.add_theme_constant_override("outline_size",1)
	b.add_theme_color_override("font_outline_color",OMBRE_CLAIRIERE)
	if b.icon != null: b.add_theme_constant_override("icon_max_width", 34)
	if action.is_valid(): b.pressed.connect(action)
	return b

static func sceau(principal := false, teinte := Color.WHITE, enfonce := false) -> StyleBoxTexture:
	var nom := "bouton_principal" if principal else "bouton_secondaire"
	if enfonce: nom = "action_pressee" if principal else "secondaire_pressee"
	var style := texture_etirable(nom, 24, 36, 24)
	style.modulate_color = teinte
	return style

static func habiller_accueil(b: Button, principal := false) -> void:
	if principal:
		for etat in ["normal", "hover", "pressed"]:
			var style := texture_etirable("action_depart", 24, 36, 24)
			for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
				style.set_texture_margin(cote, 58)
			style.modulate_color = Color("f4edff") if etat == "hover" else Color("c4bed2") if etat == "pressed" else Color.WHITE
			b.add_theme_stylebox_override(etat, style)
	else:
		b.add_theme_stylebox_override("normal", sceau(false))
		b.add_theme_stylebox_override("hover", sceau(false, Color("eee7ff")))
		b.add_theme_stylebox_override("pressed", sceau(false, Color.WHITE, true))
	b.add_theme_font_size_override("font_size", 44 if principal else 30)

static func habiller_mode(b: Button, mode: String) -> void:
	var nom := "secondaire_mine" if mode == "mine" else "secondaire_epreuves"
	for etat in ["normal", "hover", "pressed", "disabled"]:
		var style := texture_etirable(nom, 24, 36, 24)
		style.modulate_color = Color("edf6fa") if etat == "hover" else Color("b6bac7") if etat == "disabled" else Color("c6c0d1") if etat == "pressed" else Color.WHITE
		b.add_theme_stylebox_override(etat, style)

static func texte(contenu: String, taille := 30, couleur := TEXTE) -> Label:
	var l := Label.new()
	l.text = contenu
	l.add_theme_font_override("font",Polices.LOGO if taille >= 40 else (Polices.TITRE if taille >= 34 else Polices.CORPS))
	l.add_theme_font_size_override("font_size",taille)
	l.add_theme_color_override("font_color",couleur)
	l.add_theme_color_override("font_outline_color", Color("1a2644e8"))
	l.add_theme_constant_override("outline_size", 1)
	l.add_theme_color_override("font_shadow_color",Color("17233bd9"))
	l.add_theme_constant_override("shadow_offset_x",0)
	l.add_theme_constant_override("shadow_offset_y",2)
	l.add_theme_constant_override("line_spacing",4)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.tree_entered.connect(func(): _adapter_encre(l, couleur))
	return l

# La surface la plus proche decide du contraste, meme dans les panneaux imbriques.
static func _adapter_encre(label: Label, couleur: Color) -> void:
	label.add_theme_color_override("font_color", couleur)
	label.add_theme_color_override("font_shadow_color", Color("17233bd9"))
	var ancetre := label.get_parent()
	while ancetre != null:
		if ancetre.has_meta("surface_lecture"):
			if bool(ancetre.get_meta("surface_lecture")):
				var encre := ENCRE_ATTENUE if couleur == ATTENUE else ENCRE
				if couleur not in [TEXTE, IVOIRE, ATTENUE, ENCRE]:
					encre = couleur.darkened(0.57)
				label.add_theme_color_override("font_color", encre)
				label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
				label.add_theme_constant_override("outline_size", 0)
			return
		if ancetre is BaseButton:
			return
		ancetre = ancetre.get_parent()

static func fond_legende(opacite := 0.78, rayon := 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(FOND, opacite)
	style.set_corner_radius_all(rayon)
	return style

static func habiller_lecture(controle: Control) -> void:
	controle.set_meta("surface_lecture", true)
	var style := texture_etirable("zone_texte", 24, 32, 28)
	style.modulate_color = Color("ece8f4")
	if controle is PanelContainer:
		controle.add_theme_stylebox_override("panel", style)
	elif controle is Button:
		for etat in ["normal", "hover", "pressed", "disabled"]:
			var variante := style.duplicate() as StyleBoxTexture
			variante.modulate_color = Color("c9c4e7") if etat == "pressed" else Color.WHITE
			controle.add_theme_stylebox_override(etat, variante)

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
	if not integre and not parent.has_meta("fond_menu_partage"):
		fond_atelier(parent, true, titre == "Campagne")
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var recadrer := func() -> void:
		var lateral := maxi(28, int((parent.size.x - 1080.0) * 0.5))
		marge.add_theme_constant_override("margin_left", maxi(lateral, int(Ecran.marge_gauche())))
		marge.add_theme_constant_override("margin_right", maxi(lateral, int(Ecran.marge_droite())))
		marge.add_theme_constant_override("margin_top", int(Ecran.marge_haute()) + 20)
		marge.add_theme_constant_override("margin_bottom", int(HAUTEUR_NAVIGATION + MARGE_NAVIGATION_BAS + Ecran.marge_basse() + 20) if integre else int(Ecran.marge_basse()) + 24)
	parent.resized.connect(recadrer)
	recadrer.call()
	parent.add_child(marge)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",22)
	marge.add_child(col)
	var cartouche := PanelContainer.new()
	HabillagePeint.appliquer(cartouche)
	cartouche.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	col.add_child(cartouche)
	var contenu_entete := VBoxContainer.new()
	contenu_entete.add_theme_constant_override("separation",12)
	cartouche.add_child(contenu_entete)
	var entete := HFlowContainer.new()
	entete.add_theme_constant_override("h_separation",16)
	entete.add_theme_constant_override("v_separation",12)
	contenu_entete.add_child(entete)
	var id_entete: String = {"Maîtrises":"astrolabe", "Sorts":"grimoire", "Équipement":"forge", "Héros":"heros", "Paramètres":"parametres", "Campagne":"portail", "La Mine":"mine", "Épreuves":"epreuves"}.get(titre, "grimoire")
	var embl := illustration(id_entete,72)
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
	separateur(contenu_entete)
	return col

static func defilement(col: VBoxContainer) -> VBoxContainer:
	var scroll := preload("res://ui/composants/defilement_tactile.gd").new()
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
	if claire:
		habiller_lecture(panneau)
	else:
		panneau.add_theme_stylebox_override("panel", texture_etirable("panneau", 24, 32, 28))
	parent.add_child(panneau)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",18)
	panneau.add_child(col)
	return col

static func cartouche_infos(parent: Node, accent: Color) -> VBoxContainer:
	var panneau := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("253459cf")
	style.border_color = Color(accent, 0.72)
	style.border_width_left = 3
	style.border_width_bottom = 1
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 12
	for cote in [SIDE_LEFT, SIDE_RIGHT]:
		style.set_content_margin(cote, 24)
	for cote in [SIDE_TOP, SIDE_BOTTOM]:
		style.set_content_margin(cote, 14)
	panneau.add_theme_stylebox_override("panel", style)
	parent.add_child(panneau)
	var contenu := VBoxContainer.new()
	panneau.add_child(contenu)
	return contenu

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

static func fond_atelier(parent: Control, calme := false, campagne := false) -> void:
	if campagne:
		var encre := ColorRect.new()
		encre.color = Color("172442")
		encre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		encre.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(encre)
	else:
		var fond := TextureRect.new()
		fond.texture = FOND_SCRIPTORIUM
		fond.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fond.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fond.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		parent.add_child(fond)
		if calme:
			var voile := ColorRect.new()
			voile.color = Color("17214355")
			voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			parent.add_child(voile)
	var ambiance := preload("res://ui/composants/ambiance_atelier.gd").new()
	ambiance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ambiance.configurer(campagne)
	parent.add_child(ambiance)

static func case_objet(b: Button, selection := false) -> void:
	b.add_theme_stylebox_override("normal",texture_etirable("case_selection" if selection else "case",24,28,24))
	b.add_theme_stylebox_override("hover",texture_etirable("case_selection",24,28,24))
	var pressee := texture_etirable("case_selection",24,28,24)
	pressee.modulate_color = Color("c8c1f0")
	b.add_theme_stylebox_override("pressed",pressee)
	var desactivee := texture_etirable("case",24,28,24)
	desactivee.modulate_color = Color("8995b5")
	b.add_theme_stylebox_override("disabled",desactivee)
	for etat in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		b.add_theme_color_override(etat,IVOIRE)
	b.add_theme_font_override("font",Polices.CORPS)

static func cercle(selection := false) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = preload("res://assets/visual/interface/cadres/rond_selection.svg") if selection else preload("res://assets/visual/interface/cadres/rond.svg")
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_content_margin(cote, 18)
	return style

static func cercle_mode(mode: String) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = preload("res://assets/visual/interface/cadres/mode_mine.svg") if mode == "mine" else preload("res://assets/visual/interface/cadres/mode_epreuves.svg")
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_content_margin(cote, 18)
	return style

static func bouton_rond(texte: String, action: Callable, cote := 88.0) -> Button:
	var b := bouton(texte, action)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	b.autowrap_mode = TextServer.AUTOWRAP_OFF
	b.custom_minimum_size = Vector2.ONE * cote
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for etat in ["normal", "disabled"]: b.add_theme_stylebox_override(etat, cercle())
	for etat in ["hover", "pressed"]: b.add_theme_stylebox_override(etat, cercle(true))
	return b

static func onglet_symbolique(b: Button, symbole: Texture2D, selection: bool) -> void:
	var espace := StyleBoxFlat.new()
	espace.bg_color = Color("594a80d9") if selection else Color("26315466")
	espace.corner_radius_top_left = 20
	espace.corner_radius_top_right = 20
	espace.corner_radius_bottom_left = 9
	espace.corner_radius_bottom_right = 9
	if selection:
		espace.border_color = Color("c1b4ddeb")
		espace.border_width_bottom = 2
		espace.shadow_color = Color("141c3870")
		espace.shadow_size = 3
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		espace.set_content_margin(cote, 12)
	for etat in ["normal", "hover", "pressed", "disabled", "focus"]:
		b.add_theme_stylebox_override(etat, espace)
	b.icon = symbole
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 56)
	b.add_theme_color_override("font_color", MAGIE if selection else ATTENUE)
	b.add_theme_color_override("icon_normal_color", Color.WHITE if selection else Color("a6b8da"))
	b.add_theme_font_override("font", Polices.TITRE if selection else Polices.CORPS)

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
	# Les cadres SVG ont une taille logique de 128 px ; leurs coins ne s'etirent pas.
	var peinte := HabillagePeint.CADRES.has(nom) or nom in HabillagePeint.SURFACES or nom == "bouton_principal"
	var marge_texture := 40 if peinte and coin > 0 else coin
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_texture_margin(cote, marge_texture)
	for cote in [SIDE_LEFT, SIDE_RIGHT]: style.set_content_margin(cote, maxi(44, marge_x) if peinte else marge_x)
	for cote in [SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(cote, maxi(42, marge_y) if peinte else marge_y)
	return style

static func carte_augment(accent: Color, selection := false) -> StyleBoxTexture:
	var style := texture_etirable("recompense_selection" if selection else "recompense",24,32,28)
	style.modulate_color = Color.WHITE.lerp(accent,0.24 if selection else 0.16)
	if selection: style.modulate_color = style.modulate_color.lightened(0.08)
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
	var fond := fond_legende(0.72, 18)
	fond.content_margin_left = 14
	fond.content_margin_right = 18
	fond.content_margin_top = 10
	fond.content_margin_bottom = 12
	panneau.add_theme_stylebox_override("panel", fond)
	parent.add_child(panneau)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation",24)
	panneau.add_child(ligne)
	var dessin := illustration(embleme,104)
	dessin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ligne.add_child(dessin)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation",8)
	ligne.add_child(col)
	col.add_child(texte(titre,36,IVOIRE))
	if not sous_titre.is_empty(): col.add_child(texte(sous_titre,28,ATTENUE))
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
	_theme.set_icon("arrow", "OptionButton", texture_interface("fleche_bas"))
	_theme.set_icon("submenu", "PopupMenu", texture_interface("fleche_droite"))
	for type in ["CheckButton", "CheckBox"]:
		for etat in ["checked", "checked_disabled"]:
			_theme.set_icon(etat, type, texture_interface("oui"))
		for etat in ["unchecked", "unchecked_disabled"]:
			_theme.set_icon(etat, type, texture_interface("non"))
	_theme.set_color("font_color","Label",TEXTE)
	_theme.set_color("font_shadow_color","Label",Color("263154b3"))
	_theme.set_constant("shadow_offset_x","Label",0)
	_theme.set_constant("shadow_offset_y","Label",2)
	_theme.set_stylebox("panel","TooltipPanel",cadre())
	_theme.set_color("font_color","TooltipLabel",ENCRE)
	_theme.set_font_size("font_size","TooltipLabel",25)
	for type in ["LineEdit", "TextEdit"]:
		_theme.set_stylebox("normal",type,texture_etirable("saisie",24,24,20))
		_theme.set_stylebox("read_only",type,texture_etirable("zone_texte",24,24,20))
		var focus := texture_etirable("saisie_focus",24,24,20)
		focus.draw_center = false
		_theme.set_stylebox("focus",type,focus)
		_theme.set_color("font_color",type,ENCRE)
		_theme.set_color("font_placeholder_color",type,ENCRE_ATTENUE)
		_theme.set_color("caret_color",type,ENCRE)
		_theme.set_color("selection_color",type,Color("b4a8e8"))
	for type in ["VScrollBar","HScrollBar"]:
		var rail := StyleBoxFlat.new()
		rail.bg_color = Color("2b3b66cc")
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

# Les colonnes se recomposent sans reduire les icones ni les cibles tactiles.
static func adapter_grille(grille: GridContainer, largeur_cellule: float, colonnes_max: int) -> void:
	var reference: WeakRef = weakref(grille)
	var adapter := func() -> void:
		var cible := reference.get_ref() as GridContainer
		if cible == null or not cible.is_inside_tree(): return
		var espace := cible.get_theme_constant("h_separation")
		cible.columns = clampi(floori((cible.size.x + espace) / (largeur_cellule + espace)), 1, colonnes_max)
	grille.resized.connect(adapter)
	adapter.call_deferred()

static func adapter_ligne(ligne: BoxContainer, seuil := 620.0) -> void:
	var reference: WeakRef = weakref(ligne)
	var adapter := func() -> void:
		var cible := reference.get_ref() as BoxContainer
		if cible == null or not cible.is_inside_tree(): return
		var largeur := minf(cible.size.x, cible.get_viewport_rect().size.x - Ecran.marge_gauche() - Ecran.marge_droite())
		cible.vertical = largeur < seuil
	ligne.resized.connect(adapter)
	ligne.tree_entered.connect(func(): adapter.call_deferred())
	adapter.call_deferred()
