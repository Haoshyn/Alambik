extends Control
signal ferme
var obligatoire := false
var premiers_pas := false
var _index := 0
var _nom: Label
var _position: Label
var _atout: Label
var _description: Label
var _conseil: Label
var _embleme: TextureRect
var _choix: Button
var _classes: Array = Personnage.SPECIALISATIONS.keys()

func _ready() -> void:
	if not ReglagesJoueur.specialisation_effective().is_empty():
		_index = _classes.find(ReglagesJoueur.specialisation_effective())
	var col := StyleAzur.page(self, "Votre voie", true)
	var contenu := StyleAzur.defilement(col)
	var titre := StyleAzur.texte("5/5 · Choisissez votre voie" if premiers_pas else "Choisissez votre classe", 42)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenu.add_child(titre)
	var message := "Vous avez traversé votre première salle. Choisissez maintenant votre façon de combattre. Le changement reste gratuit depuis Héros." \
		if premiers_pas else "Chaque classe favorise une façon de jouer. Le changement est gratuit depuis Héros."
	var aide := StyleAzur.texte(message, 26, StyleAzur.ATTENUE)
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
	_position = StyleAzur.texte("", 24, StyleAzur.CUIVRE)
	_position.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenu.add_child(_position)
	var fiche := StyleAzur.plaque(contenu)
	_atout = StyleAzur.texte("", 31, StyleAzur.MENTHE)
	_atout.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fiche.add_child(_atout)
	_description = StyleAzur.texte("", 30)
	_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fiche.add_child(_description)
	_conseil = StyleAzur.texte("", 25, StyleAzur.ATTENUE)
	_conseil.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fiche.add_child(_conseil)
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
	_position.text = "%d / %d" % [_index + 1, _classes.size()]
	_atout.text = str(donnees["atout"])
	_description.text = str(donnees["description"])
	_conseil.text = str(donnees["conseil"])
	_embleme.texture = StyleAzur.texture_interface(["heros", "grimoire", "astrolabe"][_index])
	_choix.text = "Choisir · " + str(donnees["nom"])

func _confirmer() -> void:
	ReglagesJoueur.choisir_specialisation(str(_classes[_index]))
	Sons.jouer("fusion", -12)
	ferme.emit()
