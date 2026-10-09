class_name StyleJeu
extends RefCounted

# Kit « email arcanique » : boutons bombes, panneaux sertis, textes epais a
# contour. Les ecrans gardent leurs conteneurs ; seules les surfaces et la
# typographie passent par ici, pour que le jeu garde une seule identite.

const TEINTES := {
	"ambre": {"haut": Color("ffd66b"), "bas": Color("f17a24"), "epaisseur": Color("a33c12"),
		"texte": Color("fffaf0"), "contour_texte": Color("7a2a0c")},
	"violet": {"haut": Color("a98bff"), "bas": Color("6b40dc"), "epaisseur": Color("3b1e8f"),
		"texte": Color("fbf8ff"), "contour_texte": Color("2b1366")},
	"azur": {"haut": Color("79dcff"), "bas": Color("2f84e3"), "epaisseur": Color("164a94"),
		"texte": Color("f6fdff"), "contour_texte": Color("0e3470")},
	"emeraude": {"haut": Color("7cf2b0"), "bas": Color("1ea86a"), "epaisseur": Color("0d6440"),
		"texte": Color("f4fff8"), "contour_texte": Color("0a4a2e")},
	"rubis": {"haut": Color("ff8a96"), "bas": Color("d8324f"), "epaisseur": Color("86172c"),
		"texte": Color("fff6f7"), "contour_texte": Color("66101f")},
	"nuit": {"haut": Color("3d3577"), "bas": Color("1f1a45"), "epaisseur": Color("100c28"),
		"texte": Color("fbf6ff"), "contour_texte": Color("120d2b")},
	"ardoise": {"haut": Color("9aa0bb"), "bas": Color("62678a"), "epaisseur": Color("393d57"),
		"texte": Color("eef0f8"), "contour_texte": Color("2a2d42")},
}
const MONTURE_HAUT := Color("fff0b8")
const MONTURE_BAS := Color("c07a2c")
const MONTURE_ARGENT_HAUT := Color("ffffff")
const MONTURE_ARGENT_BAS := Color("8f9bc4")
const CONTOUR := Color("1a1030")
const TEXTE := Color("fffaf0")
const TEXTE_DOUX := Color("e6defa")
const OR := Color("ffd25e")
const CONTOUR_TEXTE := Color("1b1236")
const RARETES := {"rare": "azur", "epique": "violet", "legendaire": "ambre"}

static var _caches := {}


# Le kit est aussi compile par les outils sans fenetre : les autoloads sont
# lus a l'execution plutot que par leur nom global.
static func _autoload(nom: String) -> Node:
	var arbre := Engine.get_main_loop() as SceneTree
	return arbre.root.get_node_or_null(nom) if arbre != null else null

static func effets_reduits() -> bool:
	var reglages := _autoload("ReglagesJoueur")
	return reglages != null and bool(reglages.get("effets_reduits"))

static func teinte(nom: String) -> Dictionary:
	return TEINTES.get(nom, TEINTES["violet"])


# Surface bombee : boutons, pastilles et medaillons.
static func boite(nom := "violet", rayon := 30.0, etat := "normal", argent := false) -> StyleBoxJeu:
	var cle := "boite/%s/%d/%s/%s" % [nom, roundi(rayon), etat, argent]
	if _caches.has(cle):
		return _caches[cle]
	var t := teinte(nom)
	var s := StyleBoxJeu.new()
	s.rayon = rayon
	s.face_haut = t["haut"]
	s.face_bas = t["bas"]
	s.epaisseur_couleur = t["epaisseur"]
	s.monture_haut = MONTURE_ARGENT_HAUT if argent else MONTURE_HAUT
	s.monture_bas = MONTURE_ARGENT_BAS if argent else MONTURE_BAS
	s.contour = CONTOUR
	match etat:
		"hover", "focus":
			s.face_haut = s.face_haut.lightened(0.12)
			s.face_bas = s.face_bas.lightened(0.10)
		"pressed":
			s.enfonce = true
			s.face_haut = s.face_haut.darkened(0.06)
			s.face_bas = s.face_bas.darkened(0.08)
			s.reflet = 0.18
		"disabled":
			var gris := teinte("ardoise")
			s.face_haut = gris["haut"]
			s.face_bas = gris["bas"]
			s.epaisseur_couleur = gris["epaisseur"]
			s.monture_haut = Color("d9dce8")
			s.monture_bas = Color("80869f")
			s.reflet = 0.16
	_caches[cle] = s
	return s


# Panneau serti : fond d'email sombre, monture fine et faible relief.
static func panneau(accent := Color(), rayon := 30.0, opacite := 0.96) -> StyleBoxJeu:
	var cle := "panneau/%s/%d/%d" % [accent.to_html(), roundi(rayon), roundi(opacite * 100.0)]
	if _caches.has(cle):
		return _caches[cle]
	var t := teinte("nuit")
	var s := StyleBoxJeu.new()
	s.rayon = rayon
	var haut: Color = t["haut"]
	var bas: Color = t["bas"]
	if accent.a > 0.0:
		haut = haut.lerp(accent.darkened(0.35), 0.22)
		bas = bas.lerp(accent.darkened(0.6), 0.16)
	s.face_haut = Color(haut, opacite)
	s.face_bas = Color(bas, opacite)
	s.epaisseur_couleur = Color(t["epaisseur"], opacite)
	s.monture_haut = MONTURE_HAUT if accent.a <= 0.0 else MONTURE_HAUT.lerp(accent.lightened(0.4), 0.35)
	s.monture_bas = MONTURE_BAS if accent.a <= 0.0 else MONTURE_BAS.lerp(accent, 0.3)
	s.largeur_monture = 3.0
	s.epaisseur = 6.0
	s.reflet = 0.07
	s.liseret = 0.22
	s.content_margin_left = 30.0
	s.content_margin_right = 30.0
	s.content_margin_top = 24.0
	s.content_margin_bottom = 28.0
	_caches[cle] = s
	return s


# Carte d'augment ou de recompense : la rarete colore la face et la lueur.
static func carte(rarete: String, selection := false) -> StyleBoxJeu:
	var cle := "carte/%s/%s" % [rarete, selection]
	if _caches.has(cle):
		return _caches[cle]
	var nom := str(RARETES.get(rarete, "azur"))
	var t := teinte(nom)
	var s := StyleBoxJeu.new()
	s.rayon = 30.0
	var sombre := teinte("nuit")
	s.face_haut = (t["bas"] as Color).darkened(0.18).lerp(sombre["haut"], 0.35)
	s.face_bas = (sombre["bas"] as Color).lerp(t["epaisseur"], 0.35)
	s.epaisseur_couleur = (t["epaisseur"] as Color).darkened(0.35)
	s.monture_haut = (t["haut"] as Color).lightened(0.45)
	s.monture_bas = t["bas"]
	s.largeur_monture = 5.0
	s.epaisseur = 9.0
	s.reflet = 0.12
	s.liseret = 0.4
	if rarete == "legendaire" or selection:
		s.lueur = (t["haut"] as Color) if not selection else Color("fff4c2")
		s.lueur.a = 0.9
		s.lueur_taille = 22.0 if selection else 16.0
	s.content_margin_left = 34.0
	s.content_margin_right = 34.0
	s.content_margin_top = 28.0
	s.content_margin_bottom = 34.0
	_caches[cle] = s
	return s


static func habiller_bouton(b: Button, nom := "violet", taille := 32, rayon := 30.0, argent := false) -> void:
	for etat in ["normal", "hover", "pressed", "disabled", "focus"]:
		b.add_theme_stylebox_override(etat, boite(nom, rayon, etat, argent))
	var t := teinte(nom)
	b.add_theme_font_override("font", Polices.JEU)
	b.add_theme_font_size_override("font_size", taille)
	for etat in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(etat, t["texte"])
	b.add_theme_color_override("font_disabled_color", Color("e9ebf3"))
	b.add_theme_color_override("font_outline_color", t["contour_texte"])
	b.add_theme_constant_override("outline_size", maxi(6, roundi(float(taille) * 0.24)))
	b.add_theme_color_override("icon_normal_color", Color.WHITE)
	b.add_theme_color_override("icon_pressed_color", Color.WHITE)
	b.add_theme_color_override("icon_hover_color", Color.WHITE)
	animer_appui(b)


# Retour tactile commun : le bouton s'ecrase sous le doigt puis rebondit.
static func animer_appui(b: Control) -> void:
	if b.has_meta("micro_animation_installee"):
		return
	b.set_meta("micro_animation_installee", true)
	var recentrer := func() -> void: b.pivot_offset = b.size * 0.5
	b.resized.connect(recentrer)
	recentrer.call()
	if b is BaseButton:
		var bouton := b as BaseButton
		bouton.button_down.connect(func() -> void:
			_rebondir(b, Vector2(0.94, 0.92), 0.06)
			var sons := _autoload("Sons")
			if sons != null: sons.jouer("clic", -14.0, randf_range(0.97, 1.04)))
		bouton.button_up.connect(func() -> void: _rebondir(b, Vector2.ONE, 0.22, true))


static func _rebondir(c: Control, echelle: Vector2, duree: float, elastique := false) -> void:
	if not c.is_inside_tree():
		return
	if effets_reduits():
		c.scale = Vector2.ONE
		return
	var ancienne: Tween = c.get_meta("tween_appui") if c.has_meta("tween_appui") else null
	if ancienne != null and ancienne.is_valid():
		ancienne.kill()
	var tween := c.create_tween()
	if elastique:
		tween.tween_property(c, "scale", echelle, duree).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(c, "scale", echelle, duree).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	c.set_meta("tween_appui", tween)


static func texte(contenu: String, taille := 30, couleur := TEXTE, contour := CONTOUR_TEXTE, fort := false) -> Label:
	var l := Label.new()
	l.text = contenu
	habiller_texte(l, taille, couleur, contour, fort)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func habiller_texte(l: Label, taille := 30, couleur := TEXTE, contour := CONTOUR_TEXTE, fort := false) -> void:
	l.add_theme_font_override("font", Polices.JEU_FORT if fort else Polices.JEU)
	l.add_theme_font_size_override("font_size", taille)
	l.add_theme_color_override("font_color", couleur)
	l.add_theme_color_override("font_outline_color", contour)
	l.add_theme_constant_override("outline_size", maxi(4, roundi(float(taille) * (0.24 if fort else 0.16))))
	l.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.08, 0.55))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", maxi(2, roundi(float(taille) * 0.08)))
	l.add_theme_constant_override("shadow_outline_size", maxi(4, roundi(float(taille) * 0.2)))
	l.add_theme_stylebox_override("normal", StyleBoxEmpty.new())


# Apparition « carte distribuee » avec un leger depassement. Dans un conteneur,
# la position appartient a la mise en page : seuls l'echelle, la rotation et
# l'opacite sont animes.
static func entree_rebond(c: Control, delai := 0.0, distance := 90.0, rotation_initiale := 0.0) -> void:
	if effets_reduits() or not c.is_inside_tree():
		return
	c.modulate.a = 0.0
	c.pivot_offset = c.size * 0.5
	c.scale = Vector2(0.72, 0.72)
	c.rotation = rotation_initiale
	var tween := c.create_tween().set_parallel(true)
	tween.tween_property(c, "modulate:a", 1.0, 0.16).set_delay(delai)
	tween.tween_property(c, "scale", Vector2.ONE, 0.46).set_delay(delai) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(c, "rotation", 0.0, 0.4).set_delay(delai) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if not c.get_parent() is Container:
		var cible := c.position
		c.position = cible + Vector2(0.0, distance)
		tween.tween_property(c, "position", cible, 0.46).set_delay(delai) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func pulser(c: CanvasItem, amplitude := 0.06, periode := 1.1) -> Tween:
	if effets_reduits() or not c.is_inside_tree():
		return null
	var tween := c.create_tween().set_loops()
	tween.tween_property(c, "scale", Vector2.ONE * (1.0 + amplitude), periode * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(c, "scale", Vector2.ONE, periode * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween
