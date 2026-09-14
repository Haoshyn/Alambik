extends Control

signal termine
const COFFRE_DEBUT_OUVERTURE := 1.05
const COFFRE_FIN_OUVERTURE := 1.62
const COFFRE_REVELATION := 1.48
const COFFRE_DUREE_ECRAN := 4.8
var _bilan: VBoxContainer
var _coffre: Button
var _recompenses: VBoxContainer
var _indication: Label
var _retour: Button
var _anim := 0.0
var _ouvert := false
var _revele := false
var _affiche := false
var _sortie := false

func _ready() -> void:
	_bilan = StyleAzur.defilement(StyleAzur.page(self, "Le coffre de l’aventure"))
	StyleInterface.animer_entree(self)

func afficher(victoire: bool, salle_atteinte: int) -> void:
	if _affiche: return
	_affiche = true
	var gains := BilanRun.finaliser(victoire, salle_atteinte)
	_bilan.add_child(StyleAzur.texte("Victoire !" if victoire else "Fin de l’aventure", 46))
	_bilan.add_child(StyleAzur.texte(Jeu.nom_run(), 32))
	_bilan.add_child(StyleAzur.texte("%d salles terminées · %d boss vaincus" % [Jeu.salles_terminees.size(), Jeu.boss_vaincus.size()], 28, StyleAzur.ATTENUE))
	_bilan.add_child(StyleAzur.texte(str(gains["nom"]), 36, StyleAzur.CUIVRE))
	_coffre = preload("res://ui/coffre_anime.gd").new()
	_coffre.rang = int(gains["rang"])
	_coffre.pressed.connect(_ouvrir)
	_bilan.add_child(_coffre)
	_indication = StyleAzur.texte("Touchez le coffre pour l’ouvrir", 30)
	_bilan.add_child(_indication)
	_recompenses = StyleAzur.plaque(_bilan, true)
	_recompenses.visible = false
	for cle in ["gouttes", "xp", "pierres"]:
		var nombre := int(gains[cle])
		if nombre > 0:
			_recompenses.add_child(StyleAzur.texte("+%d %s" % [nombre, {"gouttes": "gouttes", "xp": "XP de compte", "pierres": "pierres de forge"}[cle]], 32, StyleAzur.ENCRE))
	var objet := str(gains["objet"])
	if not objet.is_empty(): _recompenses.add_child(StyleAzur.texte(str(CatalogueObjets.OBJETS[objet]["nom"]), 32, StyleAzur.ENCRE))
	var sort_ := str(gains["sort"])
	for cadeau in gains["cadeaux"]:
		_recompenses.add_child(StyleAzur.texte("Cadeau de campagne · %s" % Sorts.donnees(str(cadeau))["nom"], 30, StyleAzur.ENCRE))
	if not sort_.is_empty():
		_recompenses.add_child(StyleAzur.vignette(sort_, 110))
		_recompenses.add_child(StyleAzur.texte("%s · rang %d" % [Sorts.donnees(sort_)["nom"], ReglagesJoueur.rang_sort(sort_)], 32, StyleAzur.ENCRE))
	if _recompenses.get_child_count() == 0:
		_recompenses.add_child(StyleAzur.texte("Le coffre est vide.\nTerminez une salle pour commencer à le remplir.", 30, StyleAzur.ENCRE))
	_retour = StyleAzur.bouton("Retour à l’accueil", _retourner, true)
	_retour.visible = false
	_bilan.add_child(_retour)
	if Jeu.mode_auto: _ouvrir()

func _ouvrir() -> void:
	if _ouvert: return
	_ouvert = true
	_anim = COFFRE_DEBUT_OUVERTURE
	_coffre.disabled = true
	_indication.text = "Ouverture…"

func _process(delta: float) -> void:
	if not _ouvert: return
	_anim += delta
	_coffre.ouverture = progression_ouverture(_anim)
	if not _revele and _anim >= COFFRE_FIN_OUVERTURE:
		_revele = true
		Sons.jouer("coffre", -5.0)
		_indication.text = "Récompenses obtenues"
		_recompenses.show()
		_retour.show()
	if Jeu.mode_auto and _anim >= COFFRE_DUREE_ECRAN: _retourner()

func _retourner() -> void:
	if _sortie or not _revele: return
	_sortie = true
	get_tree().paused = false
	if Jeu.mode_auto: get_tree().quit()
	else: get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _notification(quoi: int) -> void:
	if quoi == NOTIFICATION_WM_GO_BACK_REQUEST and _affiche:
		if _revele: _retourner()
		else: _ouvrir()

static func progression_ouverture(temps: float) -> float:
	var brut := clampf((temps - COFFRE_DEBUT_OUVERTURE) / (COFFRE_FIN_OUVERTURE - COFFRE_DEBUT_OUVERTURE), 0.0, 1.0)
	return brut * brut * (3.0 - 2.0 * brut)

static func progression_revelation(temps: float) -> float:
	return clampf((temps - COFFRE_REVELATION) / 0.55, 0.0, 1.0)
