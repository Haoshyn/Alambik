extends Control

var _bilan: VBoxContainer

# Le bilan presente les gains deja attribues, sans nouveau tirage au rendu.

signal termine

var _victoire := false
var _salle := 0
var _anim := 0.0
var _duree := 0.0
var _coffre_gouttes := 0
var _objet_obtenu := ""
var _xp_gagnee := 0
var _coffre: Dictionary = {}
var _salles_vaincues := 0
var _pierres_gagnees := 0
var _son_coffre_joue := false

const COFFRE_DEBUT_OUVERTURE := 1.05
const COFFRE_FIN_OUVERTURE := 1.62
const COFFRE_REVELATION := 1.48
const COFFRE_DUREE_ECRAN := 4.8

func _ready() -> void:
	var col := StyleAzur.page(self,"Bilan de l’aventure")
	_bilan = StyleAzur.defilement(col)
	StyleInterface.animer_entree(self)

func afficher(victoire: bool, salle_atteinte: int) -> void:
	_victoire = victoire
	_salle = salle_atteinte
	_duree = Jeu.duree_run()
	_salles_vaincues = salle_atteinte if victoire else maxi(0, salle_atteinte - 1)
	_coffre = Recompenses.coffre_pour(_salles_vaincues)
	if Jeu.mode_run == "grimoire" and int(_coffre["palier"]) > 0:
		_coffre_gouttes = roundi(float(Recompenses.tirer_gouttes_coffre(_coffre, Jeu.chapitre, Jeu.rng)) \
			* ArbreCompetences.multiplicateur_coffre(ReglagesJoueur.rangs_competences_effectifs()) \
			* (Reglages.AVIDITE_GOUTTES_MULT if "avidite" in Jeu.inventaire else 1.0))
		ReglagesJoueur.ajouter_gouttes(_coffre_gouttes)
		var manquants := CatalogueObjets.manquants(Jeu.chapitre, ReglagesJoueur.objets)
		if not manquants.is_empty() and Recompenses.donne_objet(_coffre,
				ReglagesJoueur.grands_coffres_rates(Jeu.chapitre), Jeu.rng):
			_objet_obtenu = CatalogueObjets.tirer_manquant(Jeu.chapitre, ReglagesJoueur.objets, Jeu.rng)
			ReglagesJoueur.ajouter_objet(_objet_obtenu)
		if int(_coffre["palier"]) >= Reglages.SALLES_PAR_RUN:
			ReglagesJoueur.enregistrer_grand_coffre(Jeu.chapitre, not _objet_obtenu.is_empty())
	elif Jeu.mode_run == "mine" and victoire:
		_pierres_gagnees = ReglagesJoueur.ajouter_pierres_forge(ReglagesJoueur.pierres_mine())
	_xp_gagnee = 0 if Jeu.est_retro() else \
		_salle * (2 if Jeu.mode_run == "grimoire" else 1) + (20 if victoire and Jeu.mode_run == "grimoire" else 0)
	if _xp_gagnee > 0:
		ReglagesJoueur.ajouter_experience_compte(_xp_gagnee)
	if Jeu.mode_run == "grimoire":
		ReglagesJoueur.enregistrer_resultat(salle_atteinte, victoire, Jeu.chapitre)
	elif not Jeu.est_retro():
		ReglagesJoueur.enregistrer_resultat_annexe(victoire)

	_construire_bilan()
	_retour_automatique()

func _retour_automatique() -> void:
	var attente := COFFRE_DUREE_ECRAN if _a_un_coffre() else 2.6
	await get_tree().create_timer(attente, true).timeout
	get_tree().paused = false
	if Jeu.mode_auto:
		get_tree().quit()
	else:
		StyleInterface.sortir_puis(self, func() -> void:
			get_tree().change_scene_to_file("res://scenes/menu.tscn"))

func _process(delta: float) -> void:
	_anim += delta
	if _a_un_coffre() and not _son_coffre_joue and _anim >= COFFRE_REVELATION:
		_son_coffre_joue = true
		Sons.jouer("coffre", -5.0)
	queue_redraw()

func _a_un_coffre() -> bool:
	return Jeu.mode_run == "grimoire" and int(_coffre.get("palier", 0)) > 0

static func progression_ouverture(temps: float) -> float:
	var brut := clampf((temps - COFFRE_DEBUT_OUVERTURE) /
		(COFFRE_FIN_OUVERTURE - COFFRE_DEBUT_OUVERTURE), 0.0, 1.0)
	return brut * brut * (3.0 - 2.0 * brut)

static func progression_revelation(temps: float) -> float:
	return clampf((temps - COFFRE_REVELATION) / 0.55, 0.0, 1.0)

func _construire_bilan() -> void:
	_bilan.add_child(StyleAzur.image(StyleAzur.icone_objet(_objet_obtenu) if not _objet_obtenu.is_empty() else 10,320))
	_bilan.add_child(StyleAzur.texte("Victoire" if _victoire else "Le voyage continue…",46))
	_bilan.add_child(StyleAzur.texte("%s · Salle %d / %d" % [Jeu.nom_run(),_salle,Jeu.salles_du_chapitre()],32))
	_bilan.add_child(StyleAzur.texte("%d créatures vaincues · %d min %02d s" % [Jeu.ennemis_abattus,int(_duree/60),int(_duree)%60],28,StyleAzur.ATTENUE))
	var recompenses := StyleAzur.plaque(_bilan,true)
	recompenses.add_child(StyleAzur.texte("+%d XP de compte" % _xp_gagnee,34,StyleAzur.ENCRE))
	if _coffre_gouttes > 0: recompenses.add_child(StyleAzur.texte("+%d gouttes" % _coffre_gouttes,32,StyleAzur.ENCRE))
	if _pierres_gagnees > 0: recompenses.add_child(StyleAzur.texte("+%d pierres de forge" % _pierres_gagnees,32,StyleAzur.ENCRE))
	if not _objet_obtenu.is_empty(): recompenses.add_child(StyleAzur.texte(str(CatalogueObjets.OBJETS[_objet_obtenu]["nom"]),32,StyleAzur.ENCRE))
	_bilan.add_child(StyleAzur.texte("Retour à l’accueil…",27,StyleAzur.ATTENUE))
