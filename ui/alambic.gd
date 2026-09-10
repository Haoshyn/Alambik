extends Control



# L'Alambic genere un Element et l'attache a un Amélioration existant. La fusion
# ajoute une transformation : elle ne retire ni ne remplace jamais l'original.

signal termine

var _liste: VBoxContainer
var _cartes: Array[CarteReactif] = []
var _selection := ""
var _element := ""
var _bouton_fusionner: Button
var _apercu: Label
var _anim := 0.0
var _fusion_en_cours := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_element = Jeu.tirer_element_alambic()
	_construire()
	StyleInterface.animer_entree(self)
	if Jeu.mode_auto:
		_jouer_automatiquement()

func _process(delta: float) -> void:
	_anim += delta
	queue_redraw()

func _construire() -> void:
	var col := StyleAzur.page(self,"Infusion élémentaire")
	var element := CatalogueElements.par_id(_element)
	col.add_child(StyleAzur.image(14,180))
	col.add_child(StyleAzur.texte(str(element.get("nom","Alambic")),36,StyleAzur.MAGIE))
	_liste = StyleAzur.defilement(col)
	_apercu = StyleAzur.texte("",28)
	col.add_child(_apercu)
	_bouton_fusionner = StyleAzur.bouton("Infuser l’amélioration",_sur_fusionner,true)
	col.add_child(_bouton_fusionner)
	_construire_cartes()
	if _cartes.is_empty() or _element.is_empty():
		col.add_child(StyleAzur.bouton("Continuer",func(): StyleInterface.sortir_puis(self,func(): termine.emit())))

func _construire_cartes() -> void:
	var deja_vus: Array[String] = []
	for id in Jeu.inventaire:
		if id in deja_vus or id not in CatalogueReactifs.ids() or Jeu.augment_deja_fusionne(id):
			continue
		deja_vus.append(id)
		var reactif := CatalogueReactifs.par_id(id)
		var carte := CarteReactif.new()
		carte.configurer(reactif)
		carte.custom_minimum_size = Vector2(0, 150)
		carte.selectionnee = id == _selection
		carte.choisie.connect(_sur_choix)
		_liste.add_child(carte)
		_cartes.append(carte)
	_rafraichir()
	call_deferred("_animer_cartes")

func _animer_cartes() -> void:
	if is_instance_valid(_liste):
		StyleInterface.animer_liste(_liste, 0.045)

func _sur_choix(id: String) -> void:
	if _fusion_en_cours:
		return
	_selection = "" if _selection == id else id
	_rafraichir()

func _rafraichir() -> void:
	for carte in _cartes:
		if is_instance_valid(carte):
			carte.selectionnee = carte.reactif.id == _selection
			carte.queue_redraw()
	_bouton_fusionner.disabled = _selection.is_empty() or _element.is_empty()
	var donnees := CatalogueElements.par_id(_element)
	if donnees.is_empty():
		_apercu.text = "L'Alambic reste silencieux."
	elif _cartes.is_empty():
		_apercu.text = "%s\n\nAucune Amélioration non fusionnée n'est disponible." % donnees["nom"]
	elif _selection.is_empty():
		_apercu.text = "%s\n\nChoisissez l'Amélioration à transformer." % donnees["nom"]
	else:
		var augment := CatalogueReactifs.par_id(_selection)
		var fusion := CatalogueElements.creer_fusion(_element, _selection)
		_apercu.text = "%s + %s\n%s" % [augment.nom, donnees["nom"], fusion.description]
	_apercu.add_theme_color_override("font_color", _teinte_element())

func _sur_fusionner() -> void:
	if _fusion_en_cours or _selection.is_empty():
		return
	_fusion_en_cours = true
	if not Jeu.ajouter_fusion_elementaire(_element, _selection):
		_fusion_en_cours = false
		return
	Sons.jouer("fusion", -8.0)
	var fusion := CatalogueElements.creer_fusion(_element, _selection)
	_apercu.text = "%s !\n%s" % [fusion.nom, fusion.description]
	await get_tree().create_timer(0.85).timeout
	StyleInterface.sortir_puis(self, func() -> void: termine.emit())

func _jouer_automatiquement() -> void:
	await get_tree().create_timer(0.2).timeout
	if _cartes.is_empty():
		StyleInterface.sortir_puis(self, func() -> void: termine.emit())
		return
	_selection = _cartes[0].reactif.id
	_rafraichir()
	_sur_fusionner()

func _teinte_element() -> Color:
	var donnees := CatalogueElements.par_id(_element)
	return donnees.get("teinte", Palette.ESSENCE)
