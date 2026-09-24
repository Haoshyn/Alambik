class_name BandeauAccueil
extends Control

signal profil_demande
signal reglages_demandes

const COMPTEUR := preload("res://ui/composants/compteur_ressource.tscn")

var _profil_fond: Panel
var _profil: Button
var _reglages: Button
var _niveau: Label
var _experience: ProgressBar
var _experience_libelle: Label
var _gouttes: CompteurRessource
var _pierres: CompteurRessource

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_profil_fond = Panel.new()
	_profil_fond.name = "CadreNiveau"
	_profil_fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_profil_fond.add_theme_stylebox_override("panel", StyleAzur.texture_etirable("bandeau", 40, 0, 0))
	add_child(_profil_fond)
	_profil = StyleInterface.zone_tactile(func(): profil_demande.emit())
	_profil.name = "Profil"
	_profil.tooltip_text = "Voir le héros"
	add_child(_profil)
	_niveau = StyleAzur.texte("", 37, StyleAzur.IVOIRE)
	_niveau.name = "Niveau"
	_niveau.autowrap_mode = TextServer.AUTOWRAP_OFF
	_niveau.clip_text = true
	add_child(_niveau)
	_experience_libelle = StyleAzur.texte("", 24, StyleAzur.ATTENUE)
	_experience_libelle.name = "ExperienceTexte"
	_experience_libelle.autowrap_mode = TextServer.AUTOWRAP_OFF
	_experience_libelle.clip_text = true
	add_child(_experience_libelle)
	_experience = ProgressBar.new()
	_experience.show_percentage = false
	_experience.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_experience.add_theme_stylebox_override("background", StyleAzur.jauge(false))
	_experience.add_theme_stylebox_override("fill", StyleAzur.jauge(true, StyleAzur.MAGIE))
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
	_niveau.text = "Niv. %d" % niveau
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
	var largeur_profil := minf(370.0, size.x * 0.37)
	var hauteur_profil := 136.0
	_profil_fond.position = Vector2.ZERO
	_profil_fond.size = Vector2(largeur_profil, hauteur_profil)
	_profil.position = Vector2.ZERO
	_profil.size = _profil_fond.size
	_niveau.position = Vector2(26, 14)
	_niveau.size = Vector2(largeur_profil - 52, 54)
	_experience_libelle.position = Vector2(27, 68)
	_experience_libelle.size = Vector2(largeur_profil - 54, 30)
	_experience.position = Vector2(26, 100)
	_experience.size = Vector2(largeur_profil - 52, 18)
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
		_niveau.size.x = _profil.size.x - 52.0
		_experience_libelle.size.x = _profil.size.x - 54.0
		_experience.size.x = _profil.size.x - 52.0
		_reglages.position = Vector2(size.x - 112, 12)
		_reglages.size = Vector2(112, 112)
		var largeur_compteur := (size.x - 14.0) * 0.5
		_gouttes.position = Vector2(0, 151)
		_gouttes.size = Vector2(largeur_compteur, 90)
		_pierres.position = Vector2(largeur_compteur + 14.0, 151)
		_pierres.size = Vector2(largeur_compteur, 90)
