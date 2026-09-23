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
@onready var _depart: CommandeDepart = $ZoneSure/Defilement/Composition/Depart
@onready var _defilement: ScrollContainer = $ZoneSure/Defilement
@onready var _composition: VBoxContainer = $ZoneSure/Defilement/Composition

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	theme = StyleAzur.theme_interface()
	_bandeau.profil_demande.connect(func(): page_demandee.emit(0))
	_bandeau.reglages_demandes.connect(func(): reglages.emit())
	_scene.campagne_demandee.connect(func(): campagne.emit())
	_depart.mine_demandee.connect(func(): mine.emit())
	_depart.epreuve_demandee.connect(func(): epreuve.emit())
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

func rafraichir() -> void:
	_bandeau.afficher(ReglagesJoueur.niveau_compte_effectif(), ReglagesJoueur.experience_compte,
		ReglagesJoueur.experience_compte_requise(), ReglagesJoueur.gouttes_affichees(), str(ReglagesJoueur.pierres_forge))
	_depart.definir_acces(ReglagesJoueur.mode_debloque("mine"), Reglages.MINE_NIVEAU_DEBLOCAGE,
		ReglagesJoueur.mode_debloque("epreuve_sorts"), Reglages.EPREUVE_NIVEAU_DEBLOCAGE)
	var chapitre: Dictionary = Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
	var monde: Dictionary = Chapitres.MONDES[int(chapitre["monde"])]
	_scene.afficher_campagne(int(chapitre["monde"]), int(chapitre["chapitre_monde"]), str(monde["nom"]))

func _adapter_hauteur() -> void:
	_composition.custom_minimum_size.y = _defilement.size.y
