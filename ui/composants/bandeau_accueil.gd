class_name BandeauAccueil
extends HFlowContainer

signal profil_demande
signal reglages_demandes

const COMPTEUR := preload("res://ui/composants/compteur_ressource.tscn")
var _niveau: Label
var _experience: ProgressBar
var _gouttes: CompteurRessource
var _pierres: CompteurRessource

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("h_separation", 12)
	add_theme_constant_override("v_separation", 10)
	var profil := StyleAzur.bouton("", func(): profil_demande.emit())
	profil.name = "Profil"
	StyleInterface.rendre_invisible(profil)
	profil.custom_minimum_size = Vector2(330, 112)
	profil.tooltip_text = "Voir le héros"
	add_child(profil)
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for cote in ["left", "right"]: marge.add_theme_constant_override("margin_" + cote, 20)
	for cote in ["top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 14)
	profil.add_child(marge)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 12)
	marge.add_child(ligne)
	ligne.add_child(StyleAzur.illustration("heros", 64))
	var identite := VBoxContainer.new()
	identite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ligne.add_child(identite)
	_niveau = StyleAzur.texte("", 28)
	identite.add_child(_niveau)
	_experience = ProgressBar.new()
	_experience.custom_minimum_size.y = 12
	_experience.show_percentage = false
	_experience.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_experience.add_theme_stylebox_override("background", StyleAzur.jauge(false))
	_experience.add_theme_stylebox_override("fill", StyleAzur.jauge(true, StyleAzur.MAGIE))
	identite.add_child(_experience)
	_gouttes = COMPTEUR.instantiate() as CompteurRessource
	_gouttes.name = "Gouttes"
	add_child(_gouttes)
	_gouttes.configurer("gouttes", "Gouttes")
	_pierres = COMPTEUR.instantiate() as CompteurRessource
	_pierres.name = "Pierres"
	add_child(_pierres)
	_pierres.configurer("pierres", "Pierres")
	var reglages := StyleAzur.bouton("", func(): reglages_demandes.emit())
	reglages.name = "Reglages"
	reglages.custom_minimum_size = Vector2.ONE * Ecran.CIBLE_TACTILE
	reglages.size_flags_horizontal = Control.SIZE_SHRINK_END
	reglages.tooltip_text = "Paramètres"
	reglages.icon = StyleAzur.texture_interface("parametres")
	reglages.expand_icon = true
	reglages.add_theme_constant_override("icon_max_width", 74)
	for etat in ["normal", "hover", "pressed", "disabled"]:
		reglages.add_theme_stylebox_override(etat, StyleAzur.cercle())
	add_child(reglages)

func afficher(niveau: int, experience: float, experience_requise: float, gouttes: String, pierres: String) -> void:
	_niveau.text = "Alchimiste · niv. %d" % niveau
	_experience.max_value = experience_requise
	_experience.value = experience
	_gouttes.afficher(gouttes)
	_pierres.afficher(pierres)
