class_name BandeauAccueil
extends Control

signal profil_demande
signal reglages_demandes

const COMPTEUR := preload("res://ui/composants/compteur_ressource.tscn")
const CADRE_NIVEAU := preload("res://assets/visual/interface/menu/niveau_braise.svg")
const MEDAILLON_NIVEAU := preload("res://assets/visual/interface/menu/medaillon_niveau.svg")
const XP_FOND := preload("res://assets/visual/interface/menu/xp_fond_braise.svg")
const XP_PLEIN := preload("res://assets/visual/interface/menu/xp_plein_braise.svg")

var _profil_fond: Panel
var _profil: Button
var _reglages: Button
var _niveau: Label
var _titre_niveau: Label
var _medaillon: TextureRect
var _experience: ProgressBar
var _experience_libelle: Label
var _gouttes: CompteurRessource
var _pierres: CompteurRessource

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_profil_fond = Panel.new()
	_profil_fond.name = "CadreNiveau"
	_profil_fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cadre := StyleBoxTexture.new()
	cadre.texture = CADRE_NIVEAU
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		cadre.set_texture_margin(cote, 40)
	_profil_fond.add_theme_stylebox_override("panel", cadre)
	add_child(_profil_fond)
	_profil = StyleInterface.zone_tactile(func(): profil_demande.emit())
	_profil.name = "Profil"
	_profil.tooltip_text = "Voir le héros"
	add_child(_profil)
	_medaillon = TextureRect.new()
	_medaillon.name = "MedaillonNiveau"
	_medaillon.texture = MEDAILLON_NIVEAU
	_medaillon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_medaillon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_medaillon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_medaillon)
	_niveau = StyleAzur.texte("", 48, Color("ffe8b0"))
	_niveau.add_theme_font_override("font", Polices.CHIFFRES)
	_niveau.add_theme_font_size_override("font_size", 46)
	_niveau.name = "Niveau"
	_niveau.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_niveau.autowrap_mode = TextServer.AUTOWRAP_OFF
	_niveau.clip_text = true
	add_child(_niveau)
	_titre_niveau = StyleAzur.texte("NIVEAU", 27, Color("f7d6a0"))
	_titre_niveau.name = "TitreNiveau"
	_titre_niveau.add_theme_font_override("font", Polices.GRIMOIRE)
	_titre_niveau.add_theme_font_size_override("font_size", 28)
	_titre_niveau.autowrap_mode = TextServer.AUTOWRAP_OFF
	add_child(_titre_niveau)
	_experience_libelle = StyleAzur.texte("", 21, Color("b9edf2"))
	_experience_libelle.name = "ExperienceTexte"
	_experience_libelle.autowrap_mode = TextServer.AUTOWRAP_OFF
	_experience_libelle.clip_text = true
	add_child(_experience_libelle)
	_experience = ProgressBar.new()
	_experience.show_percentage = false
	_experience.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fond_xp := StyleBoxTexture.new()
	fond_xp.texture = XP_FOND
	var plein_xp := StyleBoxTexture.new()
	plein_xp.texture = XP_PLEIN
	for cote in [SIDE_LEFT, SIDE_RIGHT]:
		fond_xp.set_texture_margin(cote, 14)
		plein_xp.set_texture_margin(cote, 14)
	for cote in [SIDE_TOP, SIDE_BOTTOM]:
		fond_xp.set_texture_margin(cote, 8)
		plein_xp.set_texture_margin(cote, 8)
	_experience.add_theme_stylebox_override("background", fond_xp)
	_experience.add_theme_stylebox_override("fill", plein_xp)
	add_child(_experience)
	_gouttes = COMPTEUR.instantiate() as CompteurRessource
	_gouttes.name = "Gouttes"
	add_child(_gouttes)
	_gouttes.configurer("gouttes", "Gouttes")
	_pierres = COMPTEUR.instantiate() as CompteurRessource
	_pierres.name = "Pierres"
	add_child(_pierres)
	_pierres.configurer("pierres", "Pierres")
	_reglages = StyleAzur.bouton_rond("", func(): reglages_demandes.emit(), 112.0)
	_reglages.name = "Reglages"
	_reglages.tooltip_text = "Paramètres"
	_reglages.icon = StyleAzur.texture_interface("parametres")
	_reglages.expand_icon = true
	_reglages.add_theme_constant_override("icon_max_width", 54)
	add_child(_reglages)
	resized.connect(_replacer)
	_replacer()

func afficher(niveau: int, experience: float, experience_requise: float, gouttes: String, pierres: String) -> void:
	_niveau.text = str(niveau)
	_profil.accessibility_name = "Niveau %d. Expérience %d sur %d. Voir le héros." % [niveau, int(experience), int(experience_requise)]
	_experience.max_value = experience_requise
	_experience.value = experience
	_experience_libelle.text = "XP %d / %d" % [int(experience), int(experience_requise)]
	_gouttes.afficher(gouttes)
	_pierres.afficher(pierres)
	_replacer()

func _replacer() -> void:
	if _profil == null or size.x <= 0.0:
		return
	var largeur_profil := minf(400.0, size.x * 0.4)
	var hauteur_profil := 136.0
	_profil_fond.position = Vector2(0, 8)
	_profil_fond.size = Vector2(largeur_profil, hauteur_profil)
	_profil.position = _profil_fond.position
	_profil.size = _profil_fond.size
	_medaillon.position = Vector2(8, 14)
	_medaillon.size = Vector2(108, 108)
	_niveau.position = Vector2(22, 38)
	_niveau.size = Vector2(80, 60)
	_titre_niveau.position = Vector2(132, 22)
	_titre_niveau.size = Vector2(largeur_profil - 148, 38)
	_experience.position = Vector2(132, 72)
	_experience.size = Vector2(largeur_profil - 158, 18)
	_experience_libelle.position = Vector2(134, 96)
	_experience_libelle.size = Vector2(largeur_profil - 158, 29)
	if size.x >= 880.0:
		custom_minimum_size.y = 142.0
		_reglages.position = Vector2(size.x - 112, 12)
		_reglages.size = Vector2(112, 112)
		_pierres.position = Vector2(size.x - 112 - 14 - 200, 17)
		_pierres.size = Vector2(200, 100)
		_gouttes.position = Vector2(size.x - 112 - 14 - 200 - 14 - 200, 17)
		_gouttes.size = Vector2(200, 100)
	else:
		custom_minimum_size.y = 248.0
		_profil_fond.size.x = size.x - 126.0
		_profil.size.x = _profil_fond.size.x
		_titre_niveau.size.x = _profil.size.x - 148.0
		_experience_libelle.size.x = _profil.size.x - 158.0
		_experience.size.x = _profil.size.x - 158.0
		_reglages.position = Vector2(size.x - 112, 12)
		_reglages.size = Vector2(112, 112)
		var largeur_compteur := (size.x - 14.0) * 0.5
		_gouttes.position = Vector2(0, 151)
		_gouttes.size = Vector2(largeur_compteur, 90)
		_pierres.position = Vector2(largeur_compteur + 14.0, 151)
		_pierres.size = Vector2(largeur_compteur, 90)
