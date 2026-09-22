class_name AccueilClairiere
extends Control

signal campagne
signal mine
signal epreuve
signal reglages
signal jouer
signal page_demandee(index: int)

@onready var _marges: MarginContainer = $ZoneSure
@onready var _bandeau: BandeauAccueil = $ZoneSure/Defilement/Composition/Bandeau
@onready var _scene: SceneAccueil = $ZoneSure/Defilement/Composition/Scene
@onready var _depart: CommandeDepart = $ZoneSure/Defilement/Composition/CentrageDepart/Depart
@onready var _defilement: ScrollContainer = $ZoneSure/Defilement
@onready var _composition: VBoxContainer = $ZoneSure/Defilement/Composition
@onready var _titre: Label = $ZoneSure/Defilement/Composition/Titre

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	theme = StyleAzur.theme_interface()
	_titre.add_theme_font_override("font", Polices.TITRE)
	_titre.add_theme_color_override("font_color", Color("fff0bf"))
	_titre.add_theme_constant_override("outline_size", 3)
	_titre.add_theme_color_override("font_outline_color", StyleAzur.FOND)
	_titre.add_theme_constant_override("shadow_offset_y", 5)
	_titre.add_theme_color_override("font_shadow_color", Color(StyleAzur.FOND, 0.6))
	_bandeau.profil_demande.connect(func(): page_demandee.emit(0))
	_bandeau.reglages_demandes.connect(func(): reglages.emit())
	_scene.mine_demandee.connect(func(): mine.emit())
	_scene.epreuve_demandee.connect(func(): epreuve.emit())
	_depart.destination_demandee.connect(func(): campagne.emit())
	_depart.depart_demande.connect(func(): jouer.emit())
	ReglagesJoueur.maitrise_changee.connect(rafraichir)
	resized.connect(_cadrer)
	_defilement.resized.connect(_adapter_hauteur)
	_cadrer()
	_adapter_hauteur.call_deferred()
	rafraichir()

func _cadrer() -> void:
	if _marges == null: return
	var lateral := maxi(28, int((size.x - 1080.0) * 0.5))
	_marges.add_theme_constant_override("margin_left", maxi(lateral, int(Ecran.marge_gauche())))
	_marges.add_theme_constant_override("margin_right", maxi(lateral, int(Ecran.marge_droite())))
	_marges.add_theme_constant_override("margin_top", int(Ecran.marge_haute()))
	_marges.add_theme_constant_override("margin_bottom", int(Ecran.marge_basse() + StyleAzur.HAUTEUR_NAVIGATION + 20))
	var largeur := maxf(0.0, size.x - maxf(lateral, Ecran.marge_gauche()) - maxf(lateral, Ecran.marge_droite()))
	_depart.custom_minimum_size.x = minf(850.0, largeur)
	_titre.add_theme_font_size_override("font_size", int(clampf(largeur * 0.082, 48.0, 84.0)))

func rafraichir() -> void:
	_bandeau.afficher(ReglagesJoueur.niveau_compte_effectif(), ReglagesJoueur.experience_compte,
		ReglagesJoueur.experience_compte_requise(), ReglagesJoueur.gouttes_affichees(), str(ReglagesJoueur.pierres_forge))
	_scene.definir_acces(ReglagesJoueur.mode_debloque("mine"), Reglages.MINE_NIVEAU_DEBLOCAGE,
		ReglagesJoueur.mode_debloque("epreuve_sorts"), Reglages.EPREUVE_NIVEAU_DEBLOCAGE)
	var mode := ReglagesJoueur.mode_run_choisi
	var chapitre: Dictionary = Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
	var monde: Dictionary = Chapitres.MONDES[int(chapitre["monde"])]
	var destination := "%s · Chapitre %d" % [str(monde["nom"]), int(chapitre["chapitre_monde"])]
	if mode == "mine": destination = "La Mine"
	elif mode != "grimoire": destination = "Épreuve · niveau %d" % ReglagesJoueur.niveau_epreuve_choisi
	_depart.afficher(destination, mode)

func _adapter_hauteur() -> void:
	_composition.custom_minimum_size.y = _defilement.size.y
