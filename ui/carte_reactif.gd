class_name CarteReactif
extends Button

# Carte d'augment facon carte a collectionner : la rarete colore la monture,
# la lueur et le medaillon ; les valeurs chiffrees ressortent en or.

signal choisie(id: String)

const HAUTEUR := 250.0
const COULEUR_VALEUR := "ffd86b"

var reactif: Reactif
var pour_choix := false
var selectionnee := false:
	set(valeur):
		selectionnee = valeur
		if is_node_ready():
			_appliquer_cadre()
var desactivee := false:
	set(valeur):
		desactivee = valeur
		disabled = valeur
		if is_instance_valid(_contenu):
			_contenu.modulate.a = 0.45 if valeur else 1.0

var _contenu: MarginContainer
var _reflet: _Reflet


func configurer(reactif_: Reactif) -> void:
	reactif = reactif_
	custom_minimum_size = Vector2(0, HAUTEUR)
	if is_node_ready():
		_construire()


func _ready() -> void:
	custom_minimum_size = Vector2(0, HAUTEUR)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	StyleInterface.styliser_bouton(self)
	pressed.connect(_sur_appui)
	_construire()


static func teinte_rarete(rarete: String) -> String:
	return str(StyleJeu.RARETES.get(rarete, "azur"))


func _construire() -> void:
	if reactif == null:
		return
	if is_instance_valid(_contenu):
		remove_child(_contenu)
		_contenu.queue_free()
	_appliquer_cadre()
	var teinte := teinte_rarete(reactif.rarete)
	var couleurs := StyleJeu.teinte(teinte)
	_contenu = MarginContainer.new()
	_contenu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_contenu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contenu.modulate.a = 0.45 if desactivee else 1.0
	for cote in ["left", "right"]:
		_contenu.add_theme_constant_override("margin_" + cote, 40)
	for cote in ["top", "bottom"]:
		_contenu.add_theme_constant_override("margin_" + cote, 34)
	add_child(_contenu)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 28)
	_contenu.add_child(ligne)
	var illustration := _Medaillon.new()
	illustration.teinte = teinte
	illustration.legendaire = reactif.rarete == Reactif.LEGENDAIRE
	illustration.custom_minimum_size = Vector2(158, 158)
	illustration.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_child(illustration)
	var glyphe := StyleAzur.vignette(reactif.id, 96)
	glyphe.position = Vector2(31, 29)
	glyphe.size = Vector2(96, 96)
	illustration.add_child(glyphe)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.add_theme_constant_override("separation", 8)
	ligne.add_child(textes)
	var entete := HBoxContainer.new()
	entete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entete.add_theme_constant_override("separation", 10)
	textes.add_child(entete)
	entete.add_child(_pastille(reactif.nom_rarete().to_upper(), teinte))
	var possedees := Jeu.copies(reactif.id)
	if pour_choix and reactif.copies_permises() > 1 and not reactif.mods.has("soin_part"):
		entete.add_child(_pastille("RANG %d/%d" % [possedees + 1, reactif.copies_permises()], "nuit"))
	elif not pour_choix and possedees > 0:
		entete.add_child(_pastille("×%d" % possedees, "nuit"))
	var nom := StyleJeu.texte(reactif.nom, 40, StyleJeu.TEXTE, couleurs["contour_texte"], true)
	textes.add_child(nom)
	var details := DetailsReactif.texte(reactif, 1 if pour_choix else maxi(1, possedees))
	tooltip_text = "%s\n%s" % [reactif.nom, details]
	textes.add_child(_details(details))
	if reactif.rarete != Reactif.RARE and not ReglagesJoueur.effets_reduits:
		_reflet = _Reflet.new()
		_reflet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_reflet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_reflet.intensite = 0.22 if reactif.rarete == Reactif.LEGENDAIRE else 0.12
		add_child(_reflet)
	# Les descriptions longues agrandissent la carte au lieu de chevaucher la suivante.
	_contenu.minimum_size_changed.connect(_adapter_hauteur)
	_adapter_hauteur.call_deferred()


func _pastille(contenu: String, teinte: String) -> PanelContainer:
	var pastille := PanelContainer.new()
	pastille.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var boite := (StyleJeu.boite(teinte, 18.0) as StyleBoxJeu).duplicate() as StyleBoxJeu
	boite.epaisseur = 4.0
	boite.largeur_monture = 2.5
	boite.ombre_decalage = Vector2(0, 3)
	boite.content_margin_left = 16.0
	boite.content_margin_right = 16.0
	boite.content_margin_top = 4.0
	boite.content_margin_bottom = 8.0
	pastille.add_theme_stylebox_override("panel", boite)
	var texte := StyleJeu.texte(contenu, 22, StyleJeu.TEXTE, StyleJeu.teinte(teinte)["contour_texte"], true)
	texte.autowrap_mode = TextServer.AUTOWRAP_OFF
	pastille.add_child(texte)
	return pastille


# Les montants (+40 %, 3 s, 2 satellites...) passent en or dans le texte.
func _details(texte: String) -> RichTextLabel:
	var riche := RichTextLabel.new()
	riche.bbcode_enabled = true
	riche.fit_content = true
	riche.scroll_active = false
	riche.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	riche.mouse_filter = Control.MOUSE_FILTER_IGNORE
	riche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riche.add_theme_font_override("normal_font", Polices.JEU)
	riche.add_theme_font_override("bold_font", Polices.JEU_FORT)
	riche.add_theme_font_size_override("normal_font_size", 29)
	riche.add_theme_font_size_override("bold_font_size", 31)
	riche.add_theme_color_override("default_color", StyleJeu.TEXTE_DOUX)
	riche.add_theme_color_override("font_outline_color", StyleJeu.CONTOUR_TEXTE)
	riche.add_theme_constant_override("outline_size", 6)
	riche.add_theme_constant_override("line_separation", 2)
	var expression := RegEx.create_from_string("([+−-]?\\d+(?:\\s?%)?)")
	var lignes: Array[String] = []
	for ligne in texte.split("\n"):
		var echappee := ligne.replace("[", "[lb]")
		lignes.append(expression.sub(echappee, "[b][color=#%s]$1[/color][/b]" % COULEUR_VALEUR, true))
	riche.text = "\n".join(lignes)
	return riche


func _adapter_hauteur() -> void:
	if is_instance_valid(_contenu):
		custom_minimum_size.y = maxf(HAUTEUR, _contenu.get_combined_minimum_size().y)


func _appliquer_cadre() -> void:
	if reactif == null:
		return
	var normal := StyleJeu.carte(reactif.rarete, selectionnee)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", StyleJeu.carte(reactif.rarete, true))
	add_theme_stylebox_override("pressed", StyleJeu.carte(reactif.rarete, true))
	add_theme_stylebox_override("disabled", normal)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _sur_appui() -> void:
	if desactivee or reactif == null:
		return
	if not pour_choix:
		Sons.jouer("choix", -14.0)
	choisie.emit(reactif.id)


# Medaillon colore par la rarete ; les legendaires tournent dans des rayons.
class _Medaillon:
	extends Control
	var teinte := "azur"
	var legendaire := false
	var _temps := 0.0

	func _process(delta: float) -> void:
		if legendaire and not ReglagesJoueur.effets_reduits:
			_temps += delta
			queue_redraw()

	func _draw() -> void:
		var centre := size * 0.5
		var rayon := minf(size.x, size.y) * 0.5
		if legendaire:
			DessinJeu.rayons(self, centre, rayon * 1.35, Color(1.0, 0.85, 0.4, 0.45), _temps * 0.6, 12)
		var boite := StyleJeu.boite(teinte, rayon)
		draw_style_box(boite, Rect2(centre - Vector2.ONE * rayon, Vector2.ONE * rayon * 2.0))


# Bande lumineuse qui balaie les cartes epiques et legendaires.
class _Reflet:
	extends Control
	var intensite := 0.15
	var _temps := 0.0

	func _process(delta: float) -> void:
		_temps += delta
		queue_redraw()

	func _draw() -> void:
		var cycle := fmod(_temps, 2.6) / 1.1
		if cycle > 1.0:
			return
		var largeur := size.x * 0.09
		var haut := 14.0
		var bas := size.y - 22.0
		var inclinaison := (bas - haut) * 0.35
		var x := lerpf(-largeur * 2.0 - inclinaison, size.x + largeur, cycle)
		var bord := Color(1, 1, 1, 0.0)
		var plein := Color(1, 1, 1, intensite)
		for cote: float in [0.0, 1.0]:
			var a := x + largeur * cote
			var b := a + largeur
			draw_polygon(PackedVector2Array([Vector2(a + inclinaison, haut), Vector2(b + inclinaison, haut),
				Vector2(b, bas), Vector2(a, bas)]),
				PackedColorArray([bord if cote == 0.0 else plein, plein if cote == 0.0 else bord,
				plein if cote == 0.0 else bord, bord if cote == 0.0 else plein]))
