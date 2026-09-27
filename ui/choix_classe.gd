extends Control
signal ferme

var obligatoire := false
var _index := 0
var _nom: Label
var _position: Label
var _bonus: VBoxContainer
var _fiche: PanelContainer
var _embleme: TextureRect
var _choix: Button
var _classes: Array = Personnage.SPECIALISATIONS.keys()

func _ready() -> void:
	var actuelle := ReglagesJoueur.specialisation_effective()
	if actuelle in _classes:
		_index = _classes.find(actuelle)
	var col := StyleAzur.page(self, "Choisissez votre classe", true)
	var contenu := StyleAzur.defilement(col)
	_fiche = PanelContainer.new()
	_fiche.set_meta("surface_lecture", false)
	contenu.add_child(_fiche)
	var presentation := VBoxContainer.new()
	presentation.add_theme_constant_override("separation", 20)
	_fiche.add_child(presentation)
	_position = StyleAzur.texte("", 30, StyleAzur.IVOIRE)
	_position.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	presentation.add_child(_position)
	var ligne := HBoxContainer.new()
	ligne.alignment = BoxContainer.ALIGNMENT_CENTER
	ligne.add_theme_constant_override("separation", 24)
	presentation.add_child(ligne)
	var precedent := StyleAzur.bouton_rond("‹", func(): _tourner(-1), 96)
	precedent.tooltip_text = "Classe précédente"
	ligne.add_child(precedent)
	_embleme = TextureRect.new()
	_embleme.custom_minimum_size = Vector2(240, 240)
	_embleme.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_embleme.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_embleme.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	ligne.add_child(_embleme)
	var suivant := StyleAzur.bouton_rond("›", func(): _tourner(1), 96)
	suivant.tooltip_text = "Classe suivante"
	ligne.add_child(suivant)
	_nom = StyleAzur.calligraphie("", 64, StyleAzur.IVOIRE)
	_nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	presentation.add_child(_nom)
	_bonus = VBoxContainer.new()
	_bonus.add_theme_constant_override("separation", 16)
	presentation.add_child(_bonus)
	_choix = StyleAzur.bouton("", _confirmer, true)
	col.add_child(_choix)
	if not obligatoire:
		col.add_child(StyleAzur.bouton("Retour au héros", func(): ferme.emit()))
	_rafraichir()

func _tourner(sens: int) -> void:
	_index = wrapi(_index + sens, 0, _classes.size())
	_rafraichir()
	StyleInterface.animer_entree(_embleme, 10)

func _rafraichir() -> void:
	var id := str(_classes[_index])
	var donnees: Dictionary = Personnage.SPECIALISATIONS[id]
	var accent: Color = donnees["couleur"]
	_nom.text = str(donnees["nom"])
	_nom.add_theme_color_override("font_color", accent)
	_position.text = "%d / %d%s" % [_index + 1, _classes.size(), " · Équipée" if id == ReglagesJoueur.specialisation_effective() else ""]
	_fiche.add_theme_stylebox_override("panel", StyleAzur.cadre_grimoire(accent))
	_embleme.texture = load("res://assets/visual/interface/classes/%s.png" % id) as Texture2D
	for enfant in _bonus.get_children():
		_bonus.remove_child(enfant)
		enfant.queue_free()
	for bonus: Dictionary in Personnage.bonus_classe(id):
		var ligne := StyleAzur.cartouche_infos(_bonus, accent)
		var valeur := float(bonus["valeur"]) * 100.0
		var chiffre := StyleAzur.texte("%s%d %%" % ["+" if valeur >= 0.0 else "−", absi(roundi(valeur))], 48, accent)
		chiffre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ligne.add_child(chiffre)
		var libelle := StyleAzur.texte(str(bonus["nom"]), 34, StyleAzur.IVOIRE)
		libelle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ligne.add_child(libelle)
	_choix.text = "Choisir · " + str(donnees["nom"])
	StyleAzur.bouton_enlumine(_choix, accent, 40)

func _confirmer() -> void:
	ReglagesJoueur.choisir_specialisation(str(_classes[_index]))
	Sons.jouer("fusion", -12)
	ferme.emit()
