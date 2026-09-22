extends Control
signal ferme
var obligatoire := false
var _index := 0
var _nom: Label
var _description: Label
var _embleme: TextureRect
var _choix: Button
var _classes: Array = Personnage.SPECIALISATIONS.keys()

func _ready() -> void:
	if not ReglagesJoueur.specialisation_effective().is_empty():
		_index = _classes.find(ReglagesJoueur.specialisation_effective())
	var col := StyleAzur.page(self, "Votre voie", true)
	var contenu := StyleAzur.defilement(col)
	var titre := StyleAzur.texte("Choisissez votre classe", 42)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenu.add_child(titre)
	var aide := StyleAzur.texte("Ce choix est nécessaire pour commencer. Vous pourrez changer gratuitement depuis Héros.", 26, StyleAzur.ATTENUE)
	aide.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenu.add_child(aide)
	var ligne := HBoxContainer.new()
	ligne.alignment = BoxContainer.ALIGNMENT_CENTER
	ligne.add_theme_constant_override("separation", 24)
	contenu.add_child(ligne)
	ligne.add_child(StyleAzur.bouton_rond("‹", func(): _tourner(-1)))
	var sceau := PanelContainer.new()
	sceau.add_theme_stylebox_override("panel", StyleAzur.cercle(true))
	sceau.custom_minimum_size = Vector2(260, 260)
	ligne.add_child(sceau)
	_embleme = StyleAzur.illustration("heros", 224)
	sceau.add_child(_embleme)
	ligne.add_child(StyleAzur.bouton_rond("›", func(): _tourner(1)))
	_nom = StyleAzur.texte("", 48)
	_nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenu.add_child(_nom)
	var fiche := StyleAzur.plaque(contenu)
	_description = StyleAzur.texte("", 30)
	_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fiche.add_child(_description)
	_choix = StyleAzur.bouton("", _confirmer, true)
	contenu.add_child(_choix)
	if not obligatoire:
		contenu.add_child(StyleAzur.bouton("Retour au héros", func(): ferme.emit()))
	_rafraichir()

func _tourner(sens: int) -> void:
	_index = wrapi(_index + sens, 0, _classes.size())
	_rafraichir()
	StyleInterface.animer_entree(_embleme, 10)

func _rafraichir() -> void:
	var id := str(_classes[_index])
	var donnees: Dictionary = Personnage.SPECIALISATIONS[id]
	_nom.text = str(donnees["nom"])
	_description.text = str(donnees["description"])
	_embleme.texture = StyleAzur.texture_interface(["heros", "grimoire", "astrolabe"][_index])
	_choix.text = "Choisir · " + str(donnees["nom"])

func _confirmer() -> void:
	ReglagesJoueur.choisir_specialisation(str(_classes[_index]))
	Sons.jouer("fusion", -12)
	ferme.emit()
