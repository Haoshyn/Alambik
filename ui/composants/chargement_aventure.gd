extends Control

const ILE := preload("res://ui/composants/ile_animee.gd")
const MINE := preload("res://assets/visual/interface/mine.svg")
const EPREUVES := preload("res://assets/visual/interface/epreuves.svg")

var _livre: Dictionary = {}
var _mode := ""
var _etage_courant := 0
var _total_etages := 0
var _temps := 0.0
var _accent := Color("a7d8e8")
var _illustration: Control
var _halo: TextureRect
var _entete: Label
var _titre: Label
var _etape: Label
var _numero: Label
var _description: Label
var _attente: Label
var _indicateur: HBoxContainer
var _points: Array[Panel] = []

func configurer(livre: Dictionary) -> void:
	_livre = livre.duplicate()
	var mode: String = str(_livre.get("mode", ""))
	_mode = mode if not mode.is_empty() else ReglagesJoueur.mode_run_choisi
	_etage_courant = int(_livre.get("etage", 0))
	_total_etages = int(_livre.get("total_etages", 0))
	_temps = 0.0
	if is_node_ready():
		_actualiser_etage()
		_cadrer()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_construire_fond()
	_construire_destination()
	_attente = _ajouter_texte("Attente", "Préparation de l’aventure…", Polices.CORPS, Color("e0e6fa"))
	_actualiser_etage()
	_construire_indicateur()
	resized.connect(_cadrer)
	visibility_changed.connect(func() -> void: set_process(is_visible_in_tree()))
	_cadrer()
	# Les etiquettes recalent leur hauteur apres le premier calcul de police.
	_cadrer.call_deferred()

func _construire_fond() -> void:
	var degrade := Gradient.new()
	degrade.colors = PackedColorArray([Color("182444"), Color("324779"), Color("171f40")])
	degrade.offsets = PackedFloat32Array([0.0, 0.44, 1.0])
	var texture_fond := GradientTexture2D.new()
	texture_fond.gradient = degrade
	texture_fond.width = 4
	texture_fond.height = 256
	texture_fond.fill_to = Vector2(0, 1)
	var fond := TextureRect.new()
	fond.name = "FondIndigo"
	fond.texture = texture_fond
	fond.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fond)
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_halo = TextureRect.new()
	_halo.name = "LumiereDuMonde"
	_halo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_halo)

func _construire_destination() -> void:
	var mode := _mode if not _mode.is_empty() else ReglagesJoueur.mode_run_choisi
	var titre := ""
	var etape := ""
	var description := ""
	if mode == "mine" or mode == "epreuves":
		var image := TextureRect.new()
		image.texture = MINE if mode == "mine" else EPREUVES
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_illustration = image
		titre = "La Mine" if mode == "mine" else "Épreuve"
		var niveau := ReglagesJoueur.niveau_mine_choisi if mode == "mine" else ReglagesJoueur.niveau_epreuve_choisi
		etape = "Niveau %d" % niveau
		_accent = Color("f3c778") if mode == "mine" else Color("d0baf3")
	else:
		var chapitre: Dictionary = Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
		var index := clampi(int(_livre.get("monde", chapitre["monde"])), 0, Chapitres.MONDES.size() - 1)
		var monde: Dictionary = Chapitres.MONDES[index]
		var ile := ILE.new() as IleAnimee
		_illustration = ile
		add_child(ile)
		ile.afficher_monde(index)
		titre = str(monde["nom"])
		etape = "Monde %d · Niveau %d" % [index + 1, int(_livre.get("chapitre_monde", chapitre["chapitre_monde"]))]
		description = str(monde["sous_titre"])
		_accent = monde["teinte"]
	if _illustration.get_parent() == null:
		add_child(_illustration)
	_illustration.name = "Destination"
	_illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_entete = _ajouter_texte("Entete", "EXPLORATION" if mode == "mine" else ("DÉFI" if mode == "epreuves" else "AVENTURE"), Polices.CORPS, Color("dbc4a0"))
	_titre = _ajouter_texte("Titre", titre, Polices.GRIMOIRE, Color("fff6e9"))
	_etape = _ajouter_texte("Etape", etape, Polices.TITRE, _accent.lightened(0.45))
	_numero = _ajouter_texte("Etage", "", Polices.TITRE, Color("fff0c8"))
	_description = _ajouter_texte("Description", description, Polices.CORPS, Color("e0e6fa"))
	var lumiere := Gradient.new()
	lumiere.colors = PackedColorArray([Color(_accent, 0.30), Color(_accent, 0.0)])
	var texture_halo := GradientTexture2D.new()
	texture_halo.gradient = lumiere
	texture_halo.width = 128
	texture_halo.height = 128
	texture_halo.fill = GradientTexture2D.FILL_RADIAL
	texture_halo.fill_from = Vector2(0.5, 0.5)
	texture_halo.fill_to = Vector2(0.5, 0.0)
	_halo.texture = texture_halo

func _actualiser_etage() -> void:
	_numero.visible = _etage_courant > 0
	_numero.text = "Étage %d / %d" % [_etage_courant, _total_etages] if _total_etages > 1 else "Étage %d" % _etage_courant
	_attente.text = "Préparation de l’étage…" if _etage_courant > 0 else "Préparation de l’aventure…"

func _ajouter_texte(nom: String, texte: String, police: Font, couleur: Color) -> Label:
	var etiquette := Label.new()
	etiquette.name = nom
	etiquette.text = texte
	etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiquette.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiquette.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiquette.size.x = maxf(1.0, size.x - 96.0)
	etiquette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiquette.add_theme_font_override("font", police)
	etiquette.add_theme_color_override("font_color", couleur)
	etiquette.add_theme_color_override("font_shadow_color", Color("101a37bb"))
	etiquette.add_theme_constant_override("shadow_offset_y", 3)
	add_child(etiquette)
	return etiquette

func _construire_indicateur() -> void:
	_indicateur = HBoxContainer.new()
	_indicateur.name = "IndicateurAttente"
	_indicateur.alignment = BoxContainer.ALIGNMENT_CENTER
	_indicateur.add_theme_constant_override("separation", 19)
	_indicateur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_indicateur)
	var style := StyleBoxFlat.new()
	style.bg_color = _accent.lightened(0.40)
	style.set_corner_radius_all(6)
	for index in 3:
		var point := Panel.new()
		point.custom_minimum_size = Vector2(9, 9)
		point.mouse_filter = Control.MOUSE_FILTER_IGNORE
		point.add_theme_stylebox_override("panel", style)
		_indicateur.add_child(point)
		_points.append(point)

func _cadrer() -> void:
	if _illustration == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var debut := Vector2(maxf(48.0, Ecran.marge_gauche()), Ecran.marge_haute())
	var fin := Vector2(maxf(48.0, Ecran.marge_droite()), Ecran.marge_basse())
	var zone := Rect2(debut, (size - debut - fin).max(Vector2.ONE))
	var paysage := zone.size.x > zone.size.y * 0.9
	var avec_etage := _etage_courant > 0
	var largeur := minf(920.0, zone.size.x * (0.44 if paysage else 1.0))
	var echelle := minf(1.0, minf(largeur / 920.0, zone.size.y / 1700.0))
	var centre := zone.get_center().x if not paysage else zone.position.x + zone.size.x * 0.75
	var hauteur_image := minf(zone.size.y * (0.78 if paysage else 0.56), (zone.size.x * (0.46 if paysage else 0.90)) * 1.5)
	var dimensions := Vector2(hauteur_image / 1.5, hauteur_image)
	var centre_image := Vector2(zone.position.x + zone.size.x * 0.25, zone.get_center().y) if paysage else Vector2(centre, zone.position.y + zone.size.y * 0.38)
	if not _illustration is IleAnimee:
		dimensions = Vector2.ONE * minf(dimensions.x, 580.0 * echelle)
	_illustration.size = dimensions
	_illustration.position = centre_image - dimensions * 0.5
	_halo.size = Vector2.ONE * hauteur_image * 1.30
	_halo.position = centre_image - _halo.size * 0.5
	_placer_texte(_entete, centre, zone.position.y + zone.size.y * (0.25 if paysage else 0.075), largeur, 58.0 * echelle, roundi(28.0 * echelle))
	_placer_texte(_titre, centre, zone.position.y + zone.size.y * (0.38 if paysage else (0.70 if avec_etage else 0.715)), largeur, 174.0 * echelle, roundi(112.0 * echelle))
	_placer_texte(_etape, centre, zone.position.y + zone.size.y * (0.48 if paysage else (0.777 if avec_etage else 0.795)), largeur, 62.0 * echelle, roundi(36.0 * echelle))
	_placer_texte(_numero, centre, zone.position.y + zone.size.y * (0.55 if paysage else 0.825), largeur, 68.0 * echelle, roundi(44.0 * echelle))
	_placer_texte(_description, centre, zone.position.y + zone.size.y * ((0.62 if avec_etage else 0.56) if paysage else (0.878 if avec_etage else 0.845)), largeur, 88.0 * echelle, roundi(30.0 * echelle))
	_placer_texte(_attente, centre, zone.position.y + zone.size.y * ((0.77 if avec_etage else 0.72) if paysage else (0.94 if avec_etage else 0.93)), largeur, 60.0 * echelle, roundi(27.0 * echelle))
	_indicateur.size = Vector2(72, 9)
	_indicateur.position = Vector2(centre - 36.0, _attente.position.y + _attente.size.y + 20.0 * echelle)

func _placer_texte(etiquette: Label, centre: float, hauteur: float, largeur: float, taille: float, police: int) -> void:
	etiquette.add_theme_font_size_override("font_size", maxi(18, police))
	etiquette.size = Vector2(largeur, taille)
	etiquette.position = Vector2(centre - largeur * 0.5, hauteur - etiquette.size.y * 0.5)

func _process(delta: float) -> void:
	_temps += delta
	for index in _points.size():
		_points[index].modulate.a = 0.75 if ReglagesJoueur.effets_reduits else 0.35 + (sin(_temps * 3.5 - float(index) * 0.8) + 1.0) * 0.28
