extends Control

signal ferme
signal lancement_demande

const NIVEAUX_PAR_PAGE := 8

var mode := "mine"

var _niveau := 1
var _page := 0
var _etapes: Array[EtapeNiveau] = []
var _progression: Label
var _plage: Label
var _selection_titre: Label
var _details: Label
var _symboles: HBoxContainer
var _precedent: Button
var _suivant: Button
var _demarrer: Button
var _apercu: Control

func _ready() -> void:
	_niveau = ReglagesJoueur.niveau_mine_choisi if mode == "mine" else ReglagesJoueur.niveau_epreuve_choisi
	_niveau = clampi(_niveau, 1, _nombre())
	_page = (_niveau - 1) / NIVEAUX_PAR_PAGE
	var titre := "La Mine" if mode == "mine" else "Épreuves"
	var col := StyleAzur.page(self, titre)
	var contenu := StyleAzur.defilement(col)
	var presentation := BoxContainer.new()
	StyleAzur.adapter_ligne(presentation, 650.0)
	presentation.add_theme_constant_override("separation", 24)
	contenu.add_child(presentation)
	var illustration := StyleAzur.illustration("mine" if mode == "mine" else "epreuves", 200)
	presentation.add_child(illustration)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	textes.add_theme_constant_override("separation", 8)
	presentation.add_child(textes)
	textes.add_child(StyleAzur.texte("EXPÉDITION ANNEXE" if mode == "mine" else "RITUELS DE MAGIE", 25, StyleAzur.CUIVRE))
	textes.add_child(StyleAzur.texte("Choisissez votre veine" if mode == "mine" else "Choisissez votre épreuve", 43))
	textes.add_child(StyleAzur.texte(
		"Survivez cinq minutes, affrontez le gardien et rapportez des pierres de forge." if mode == "mine"
		else "Affrontez cinq boss. Chaque niveau cache ses sorts et un Cœur de mana unique.",
		27, StyleAzur.ATTENUE))
	_progression = StyleAzur.texte("", 25, StyleAzur.MAGIE)
	textes.add_child(_progression)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 14)
	contenu.add_child(navigation)
	_precedent = StyleAzur.bouton_rond("‹", func(): _changer_page(-1), 96.0)
	_precedent.tooltip_text = "Niveaux précédents"
	navigation.add_child(_precedent)
	_plage = StyleAzur.texte("", 25, StyleAzur.CUIVRE)
	_plage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_plage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation.add_child(_plage)
	_suivant = StyleAzur.bouton_rond("›", func(): _changer_page(1), 96.0)
	_suivant.tooltip_text = "Niveaux suivants"
	navigation.add_child(_suivant)
	StyleAzur.separateur(contenu)
	var carte := CarteAnnexe.new()
	carte.mode = mode
	carte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_child(carte)
	for i in NIVEAUX_PAR_PAGE:
		var etape := EtapeNiveau.new()
		carte.ajouter_etape(etape)
		etape.activee.connect(_choisir_niveau)
		_etapes.append(etape)
	var fiche := StyleAzur.plaque(contenu)
	_selection_titre = StyleAzur.texte("", 23, StyleAzur.MAGIE)
	fiche.add_child(_selection_titre)
	if mode == "epreuve_sorts":
		_symboles = HBoxContainer.new()
		_symboles.add_theme_constant_override("separation", 12)
		fiche.add_child(_symboles)
	_details = StyleAzur.texte("", 29)
	fiche.add_child(_details)
	var actions := BoxContainer.new()
	StyleAzur.adapter_ligne(actions)
	actions.add_theme_constant_override("separation", 14)
	fiche.add_child(actions)
	_demarrer = StyleAzur.bouton("Entrer dans la Mine" if mode == "mine" else "Lancer cette épreuve",
		_lancer, true)
	actions.add_child(_demarrer)
	var butin := StyleAzur.bouton("Butin", _voir_loots)
	butin.size_flags_horizontal = Control.SIZE_FILL
	butin.custom_minimum_size.x = 190
	actions.add_child(butin)
	_rafraichir()
	Capture.programmer(self)

func _nombre() -> int:
	return Mine.nombre() if mode == "mine" else Epreuves.nombre()

func _nombre_debloque() -> int:
	return ReglagesJoueur.niveau_mine_debloque() if mode == "mine" else (
		Epreuves.nombre() if ReglagesJoueur.mode_dev else ReglagesJoueur.niveau_epreuve_debloque)

func _rafraichir() -> void:
	var total := _nombre()
	var debloque := _nombre_debloque()
	_progression.text = "%d / %d niveaux accessibles" % [debloque, total]
	var debut := _page * NIVEAUX_PAR_PAGE + 1
	var fin := mini(total, debut + NIVEAUX_PAR_PAGE - 1)
	_plage.text = "NIVEAUX %d–%d" % [debut, fin]
	_precedent.disabled = _page == 0
	_suivant.disabled = fin >= total
	for i in NIVEAUX_PAR_PAGE:
		var niveau := debut + i
		var etape := _etapes[i]
		etape.visible = niveau <= total
		if niveau > total:
			continue
		var accessible := niveau <= debloque
		var statut := "Verrouillé" if not accessible else "Sélectionné" if niveau == _niveau else "Disponible"
		if mode == "epreuve_sorts" and accessible and ReglagesJoueur.coeur_mana_obtenu(niveau) and niveau != _niveau:
			statut = "Cœur trouvé"
		etape.afficher(niveau, niveau == _niveau, accessible, statut, false, "mine" if mode == "mine" else "epreuves")
	_selection_titre.text = "NIVEAU %02d · %s" % [_niveau, "LA MINE" if mode == "mine" else "ÉPREUVE DE MAGIE"]
	if mode == "mine":
		var pierres := Reglages.pierres_mine(Mine.palier(_niveau))
		_details.text = "Niveau de campagne %d requis · %d min de survie\n%d pierres de forge à la victoire, avant vos bonus." % [
			Mine.campagne_requise(_niveau), roundi(Reglages.MINE_DUREE / 60.0), pierres]
	else:
		var noms: Array[String] = []
		for enfant in _symboles.get_children():
			enfant.queue_free()
		for id in Epreuves.sorts(_niveau):
			var donnees: Dictionary = Sorts.donnees(str(id))
			noms.append(str(donnees["nom"]))
			_symboles.add_child(StyleAzur.vignette(str(id), 76))
		_details.text = "Sorts possibles : %s\nCœur de mana : %s" % [
			" · ".join(noms), "obtenu" if ReglagesJoueur.coeur_mana_obtenu(_niveau) else "à trouver"]
	if _niveau > debloque:
		_details.text += "\n%s" % (
			"Terminez le chapitre de campagne requis." if mode == "mine"
			else "Terminez l’épreuve précédente pour ouvrir ce niveau.")
	_demarrer.disabled = _niveau > debloque

func _changer_page(direction: int) -> void:
	var derniere := (_nombre() - 1) / NIVEAUX_PAR_PAGE
	var nouvelle := clampi(_page + direction, 0, derniere)
	if nouvelle == _page:
		return
	_page = nouvelle
	_niveau = _page * NIVEAUX_PAR_PAGE + 1
	Sons.jouer("choix", -16.0)
	_rafraichir()

func _choisir_niveau(numero: int) -> void:
	_niveau = clampi(numero, 1, _nombre())
	Sons.jouer("choix", -16.0)
	_rafraichir()

func _lancer() -> void:
	var choisi := ReglagesJoueur.choisir_mine(_niveau) if mode == "mine" else ReglagesJoueur.choisir_epreuve(_niveau)
	if choisi:
		lancement_demande.emit()

func _voir_loots() -> void:
	if is_instance_valid(_apercu):
		return
	_apercu = preload("res://ui/apercu_butin.gd").new()
	_apercu.mode = mode
	_apercu.niveau_mine = _niveau
	_apercu.niveau_epreuve = _niveau
	add_child(_apercu)
	_apercu.ferme.connect(func():
		_apercu.queue_free()
		_apercu = null)
