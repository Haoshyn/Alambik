extends Control

signal ferme
signal progression_appliquee

var _monde: OptionButton
var _chapitre: OptionButton
var _resume: Label
var _appliquer: Button
var _apercu: Dictionary = {}

func _ready() -> void:
	if not ReglagesJoueur.outils_developpement_disponibles():
		queue_free()
		return
	var col := StyleAzur.page(self, "Avancer à")
	var contenu := StyleAzur.defilement(col)
	StyleAzur.banniere(contenu, "Un compte prêt pour ce chapitre", "Outils de développement", "grimoire")
	contenu.add_child(StyleAzur.texte("Recrée une progression depuis zéro : cinq victoires par chapitre précédent, par palier de Mine jusqu’à la destination et par Épreuve de difficulté correspondante. Le chapitre choisi reste à faire.", 27))
	_monde = _selecteur(contenu, "Monde")
	for index in Chapitres.MONDES.size():
		var monde: Dictionary = Chapitres.MONDES[index]
		_monde.add_item("Monde %d · %s" % [index + 1, monde["nom"]])
	_chapitre = _selecteur(contenu, "Chapitre")
	for index in Chapitres.CHAPITRES_PAR_MONDE:
		_chapitre.add_item("Chapitre %d" % [index + 1])
	_monde.selected = int(Chapitres.par_index(ReglagesJoueur.chapitre_choisi)["monde"])
	_chapitre.selected = int(Chapitres.par_index(ReglagesJoueur.chapitre_choisi)["chapitre_monde"]) - 1
	_monde.item_selected.connect(_invalider)
	_chapitre.item_selected.connect(_invalider)
	contenu.add_child(StyleAzur.bouton("Calculer la progression", _calculer, true))
	_resume = StyleAzur.texte("Choisissez la destination, puis calculez son aperçu.", 27)
	StyleAzur.plaque(contenu).add_child(_resume)
	contenu.add_child(StyleAzur.texte("Les vrais coffres, leurs garanties et les déblocages sont appliqués avec des tirages fixes. Les vagues sont supposées entièrement vaincues, sans bonus d’augmentation ni achat : gouttes, pierres et points restent à dépenser. Le tutoriel est considéré terminé avec son cadeau.", 24, StyleAzur.ATTENUE))
	_appliquer = StyleAzur.bouton("Remplacer ma progression et avancer", _remplacer)
	_appliquer.disabled = true
	col.add_child(_appliquer)
	col.add_child(StyleAzur.bouton("Annuler", func(): ferme.emit()))

func _selecteur(parent: Node, titre: String) -> OptionButton:
	parent.add_child(StyleAzur.texte(titre, 28, StyleAzur.CUIVRE))
	var bouton := OptionButton.new()
	bouton.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	bouton.fit_to_longest_item = false
	bouton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	StyleInterface.styliser_selecteur(bouton, StyleAzur.MAGIE)
	bouton.add_theme_font_override("font", Polices.CORPS)
	bouton.add_theme_font_size_override("font_size", 29)
	parent.add_child(bouton)
	return bouton

func _invalider(_index: int) -> void:
	_apercu.clear()
	_appliquer.disabled = true
	_resume.text = "Destination modifiée : recalculez l’aperçu avant de l’appliquer."

func _calculer() -> void:
	var destination := _monde.selected * Chapitres.CHAPITRES_PAR_MONDE + _chapitre.selected
	_apercu = ProgressionDeveloppement.preparer(destination)
	_appliquer.disabled = _apercu.is_empty()
	if _apercu.is_empty():
		_resume.text = "Cette destination n’est pas disponible."
		return
	var progression: Dictionary = _apercu["progression"]
	var sorts: Dictionary = progression["rangs_sorts"]
	var objets: Array = progression["objets"]
	var coeurs: Dictionary = progression["coeurs_mana"]
	_resume.text = "%s\n\n%d victoires en campagne · %d en Mine · %d en Épreuves\n\n%d gouttes · %d pierres de forge\nCompte niveau %d · %d XP vers le suivant\n%d bijoux · %d capacités · %d Cœurs de mana\nÉpreuves ouvertes jusqu’au niveau %d\n\nVotre progression actuelle sera remplacée et vous reviendrez à l’accueil. Le mode développeur sera désactivé." % [
		Chapitres.par_index(destination)["nom"], _apercu["campagnes"], _apercu["mines"], _apercu["epreuves"],
		progression["gouttes"], progression["pierres_forge"], progression["niveau_compte"],
		progression["experience_compte"], objets.size(), sorts.size(), coeurs.size(),
		progression["niveau_epreuve_debloque"]]

func _remplacer() -> void:
	if _apercu.is_empty():
		return
	if ReglagesJoueur.appliquer_progression(_apercu["progression"]):
		_appliquer.disabled = true
		progression_appliquee.emit()
