extends Control

signal ferme
const PROFIL := preload("res://dev_temporaire/profil.gd")
const SESSION := preload("res://dev_temporaire/session.gd")
var _monde := 1
var _choix: OptionButton
var _resume: Label
var _etat: Label
var _appliquer: Button
var _restaurer: Button

func _ready() -> void:
	name = "ProfilDevTemporaire"
	var colonne := StyleAzur.page(self, "Mode dev temporaire")
	var contenu := StyleAzur.defilement(colonne)
	contenu.add_child(StyleAzur.texte("Un compte après la fin du monde choisi, avec un peu de farm.", 30))
	contenu.add_child(StyleAzur.texte("Campagne, reprises, Mine et Épreuves. Attributs répartis, maîtrises et forge achetées, passifs équipés et réserve de ressources.", 27))
	_choix = OptionButton.new()
	_choix.name = "MondeDev"
	_choix.custom_minimum_size.y = Ecran.CIBLE_TACTILE
	_choix.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_choix.fit_to_longest_item = false
	StyleInterface.styliser_selecteur(_choix, StyleAzur.MAGIE)
	_choix.add_theme_font_size_override("font_size", 29)
	_choix.get_popup().add_theme_font_size_override("font_size", 29)
	_choix.get_popup().add_theme_constant_override("v_separation", 36)
	for index in Chapitres.MONDES.size():
		var monde: Dictionary = Chapitres.MONDES[index]
		_choix.add_item("Monde %d · %s terminé" % [index + 1, str(monde["nom"])])
		var dernier := (index + 1) * Chapitres.CHAPITRES_PAR_MONDE - 1
		if ReglagesJoueur.meilleure_du_chapitre(dernier) >= Chapitres.salles(dernier):
			_monde = index + 1
	_choix.selected = _monde - 1
	_choix.item_selected.connect(_selectionner)
	contenu.add_child(_choix)
	_resume = StyleAzur.texte("", 29)
	_resume.name = "ApercuProfilDev"
	contenu.add_child(_resume)
	contenu.add_child(StyleAzur.texte("Choisir un monde plus bas remplace aussi les gains des mondes supérieurs. Réappliquer un profil remet son état initial.", 26, StyleAzur.CUIVRE))
	_etat = StyleAzur.texte("", 27, StyleAzur.MAGIE)
	contenu.add_child(_etat)
	_appliquer = StyleAzur.bouton("", _sur_appliquer, true)
	_appliquer.name = "AppliquerProfilDev"
	colonne.add_child(_appliquer)
	_restaurer = StyleAzur.bouton("Désactiver et restaurer mon compte", _sur_restaurer)
	_restaurer.name = "RestaurerCompteDev"
	colonne.add_child(_restaurer)
	colonne.add_child(StyleAzur.bouton("Retour au menu", func() -> void: ferme.emit()))
	_selectionner(_monde - 1)
	_rafraichir_etat()

func _selectionner(index: int) -> void:
	_monde = index + 1
	var compte := PROFIL.construire(_monde, ReglagesJoueur.specialisation)
	var stats := Stats.depuis_reglages(compte.rangs_competences, compte.passifs_equipes_effectifs(),
		compte.bonus_objets_effectifs(), compte.niveau_compte, compte.attributs, compte.specialisation)
	var rangs := 0
	for rang: int in compte.rangs_competences.values():
		rangs += rang
	var suite := "Campagne entièrement terminée." if _monde == Chapitres.MONDES.size() \
		else "Monde %d ouvert." % (_monde + 1)
	_resume.text = "Niveau %d · ATK %.0f · PV %.0f · Défense %.0f\n%d gouttes · %d pierres\n%d bijoux · %d passifs possédés · %d équipés\n%d cœurs de mana · %d rangs de maîtrises\n%s" % [
		compte.niveau_compte, stats.degats, stats.pv_max, stats.defense,
		compte.gouttes, compte.pierres_forge, compte.objets.size(), compte.nombre_passifs_debloques(),
		compte.passifs_equipes.size(), compte.nombre_coeurs_mana(), rangs, suite]
	compte.free()

func _rafraichir_etat() -> void:
	var actif := SESSION.active()
	_appliquer.text = "Appliquer ce profil" if actif else "Activer avec ce profil"
	_restaurer.visible = actif
	_etat.text = "Compte test actif. Votre compte d’origine est conservé à part, même après fermeture du jeu." if actif \
		else "Votre compte actuel sera conservé. Vous pourrez le restaurer en désactivant ce mode."

func _sur_appliquer() -> void:
	var erreur := SESSION.appliquer(_monde)
	_rafraichir_etat()
	_etat.text = "Monde %d terminé : profil appliqué. Vous pouvez jouer." % _monde if erreur.is_empty() else erreur

func _sur_restaurer() -> void:
	var erreur := SESSION.restaurer()
	_rafraichir_etat()
	_etat.text = "Compte d’origine restauré. Mode dev désactivé." if erreur.is_empty() else erreur
