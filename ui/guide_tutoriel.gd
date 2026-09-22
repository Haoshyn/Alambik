class_name GuideTutoriel
extends CanvasLayer

signal action_demandee(action: String)
signal passe
signal ouverture

var en_combat := false
var _racine: Control
var _passer: Button
var _panneau: Control
var _pause_avant := false
var _confirmation := false
var _titre := ""
var _detail := ""
var _actions: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_racine = Control.new()
	_racine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_racine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_racine)
	_passer = StyleAzur.bouton("Passer le tutoriel", _confirmer_passage)
	_passer.add_theme_font_size_override("font_size", 24)
	_racine.add_child(_passer)
	_passer.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_passer.offset_left = -330
	_passer.offset_right = -24
	_passer.offset_top = Ecran.marge_haute() + (274 if en_combat else 142)
	_passer.offset_bottom = _passer.offset_top + Ecran.CIBLE_TACTILE
	actualiser()

func actualiser() -> void:
	_passer.visible = ParcoursTutoriel.actif() and _panneau == null

func est_ouvert() -> bool:
	return is_instance_valid(_panneau)

func afficher(titre: String, detail: String, actions: Array) -> void:
	if not ParcoursTutoriel.actif():
		return
	_titre = titre
	_detail = detail
	_actions = actions
	if _panneau == null:
		ouverture.emit()
		_pause_avant = get_tree().paused
		get_tree().paused = true
	_construire(titre, detail, actions)

func _construire(titre: String, detail: String, actions: Array) -> void:
	if is_instance_valid(_panneau):
		_panneau.hide()
		_panneau.queue_free()
	_panneau = Control.new()
	_racine.add_child(_panneau)
	var col := StyleAzur.page(_panneau, "Tutoriel")
	var entete := HBoxContainer.new()
	entete.alignment = BoxContainer.ALIGNMENT_END
	col.add_child(entete)
	col.move_child(entete, 0)
	if not _confirmation:
		var passer := StyleAzur.bouton("Passer le tutoriel", _confirmer_passage)
		passer.size_flags_horizontal = Control.SIZE_SHRINK_END
		passer.custom_minimum_size.x = 340
		entete.add_child(passer)
	var contenu := StyleAzur.defilement(col)
	StyleAzur.banniere(contenu, titre, "À votre rythme", "grimoire")
	var plaque := StyleAzur.plaque(contenu)
	plaque.add_child(StyleAzur.texte(detail, 30))
	for action: Array in actions:
		var id := str(action[0])
		col.add_child(StyleAzur.bouton(str(action[1]), _agir.bind(id), id != "plus_tard"))
	_passer.hide()

func _confirmer_passage() -> void:
	if _confirmation or not ParcoursTutoriel.actif():
		return
	if _panneau == null:
		_titre = ""
		ouverture.emit()
		_pause_avant = get_tree().paused
		get_tree().paused = true
	_confirmation = true
	_construire("Passer tout le tutoriel ?",
		"Vous risquez de manquer des éléments importants : récompenses de chaque mode, maîtrises, utilisation des sorts et réglages de lancement.\n\nToutes les explications suivantes seront désactivées. L’arme de départ et les modes restent accessibles ; la récompense d’initiation n’est accordée qu’en terminant ses cinq étages.",
		[["annuler", "Continuer le tutoriel"], ["confirmer_passage", "Passer quand même"]])

func _agir(action: String) -> void:
	if not is_instance_valid(_panneau):
		return
	if action == "annuler":
		_annuler_passage()
		return
	if action == "confirmer_passage":
		_fermer()
		ParcoursTutoriel.passer()
		actualiser()
		passe.emit()
		return
	_fermer()
	action_demandee.emit(action)

func _annuler_passage() -> void:
	_confirmation = false
	if _titre.is_empty():
		_fermer()
	else:
		_construire(_titre, _detail, _actions)

func _fermer() -> void:
	if is_instance_valid(_panneau):
		_panneau.hide()
		_panneau.queue_free()
	_panneau = null
	_confirmation = false
	get_tree().paused = _pause_avant
	actualiser()

func _notification(quoi: int) -> void:
	if quoi == NOTIFICATION_WM_GO_BACK_REQUEST and _confirmation:
		_annuler_passage()
