extends Control
signal termine

var campagne := false
var etage_recompense := 1
var soin_choisi := 0.0
var rarete_imposee := ""
var palier_epique := 0
var _contexte: Dictionary = {}
var _choisi := false
var _rarete := ""
var _propositions: Array[String] = []
var _cartes: VBoxContainer
var _bouton_reroll: Button

func _ready() -> void:
	var arme: Dictionary = CatalogueProjectiles.TYPES.get(ReglagesJoueur.projectile_equipe_effectif(), {})
	_contexte = {
		"drapeaux_arme": arme.get("drapeaux", []),
		"avec_sorts": Sorts.ACTIFS.has(ReglagesJoueur.sort_actif_effectif()) or Sorts.ULTIMES.has(ReglagesJoueur.ultime_effectif()),
		"bouclier_initial": Sorts.donne_bouclier(ReglagesJoueur.passifs_equipes_effectifs()) or ArbreCompetences.donne_bouclier(ReglagesJoueur.rangs_competences_effectifs()),
	}
	_rarete = rarete_imposee
	if campagne and _rarete.is_empty():
		_rarete = ProgressionAugments.rarete_niveau(etage_recompense, Jeu.niveaux_rares)
	var titre := "Choisissez une augmentation"
	var sous_titre := "Une nouvelle magie pour cette aventure"
	if palier_epique > 0:
		titre = "Étage %d · Augmentation épique" % palier_epique
		sous_titre = "Choisissez un pouvoir · Soin garanti : %d %% des PV max" % roundi(ProgressionAugments.SOIN_EPIQUE * 100.0)
	elif campagne:
		titre = "Niveau %d / %d · %s" % [etage_recompense, ProgressionAugments.niveau_max(),
			"Rare" if _rarete == Reactif.RARE else "Commun"]
		sous_titre = "Quatre rares garantis entre les niveaux 1 et 10" if _rarete == Reactif.RARE else "Soin, attaque ou PV maximum · Bonus cumulables sans diminution"
	var col := StyleAzur.page(self, titre)
	col.add_child(StyleAzur.texte(sous_titre, 28, StyleAzur.IVOIRE))
	_cartes = StyleAzur.defilement(col)
	_bouton_reroll = StyleAzur.bouton("", _sur_reroll)
	col.add_child(_bouton_reroll)
	_nouveau_tirage()
	Capture.programmer(self)
	if Jeu.mode_auto:
		_choisir_automatiquement()

func _nouveau_tirage() -> void:
	var anciennes := _propositions.duplicate()
	_propositions = DraftLogique.proposer(Jeu.ameliorations_effectives(), Jeu.rng,
		ProgressionAugments.NOMBRE_CHOIX, _rarete, etage_recompense if campagne else 0, anciennes, _contexte)
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	if _propositions.is_empty():
		_fermer_sans_choix()
		return
	for id in _propositions:
		var reactif := CatalogueReactifs.par_id(id)
		var b := StyleAzur.bouton("", func(): _sur_choix(id))
		var index := _cartes.get_child_count() % 3
		var teinte: Color = [Color("583248"), Color("354f49"), Color("53425f")][index]
		var accent := reactif.couleur_rarete()
		b.add_theme_stylebox_override("normal", StyleAzur.cadre(teinte, accent))
		b.custom_minimum_size.y = 310
		_cartes.add_child(b)
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for cote in ["left", "right", "top", "bottom"]:
			marge.add_theme_constant_override("margin_" + cote, 24)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(marge)
		var ligne := HBoxContainer.new()
		ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne.add_theme_constant_override("separation", 28)
		marge.add_child(ligne)
		ligne.add_child(StyleAzur.vignette(id, 160))
		var texte := VBoxContainer.new()
		texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texte.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne.add_child(texte)
		var deja := Jeu.copies(id)
		var etiquette := reactif.nom_rarete().to_upper()
		if reactif.copies_permises() > 1 and not reactif.mods.has("soin_part"):
			etiquette += " · Rang %d/%d" % [deja + 1, reactif.copies_permises()]
		texte.add_child(StyleAzur.texte(etiquette, 22, accent))
		texte.add_child(StyleAzur.texte(reactif.nom, 35))
		texte.add_child(StyleAzur.texte(reactif.description, 27, StyleAzur.ATTENUE))
		if reactif.rarete != Reactif.COMMUN:
			texte.add_child(StyleAzur.texte(DetailsReactif.texte_gain(reactif, deja), 25, accent))
		marge.minimum_size_changed.connect(func(): b.custom_minimum_size.y = maxf(310.0, marge.get_combined_minimum_size().y))
	var disponibles := DraftLogique.candidats(Jeu.ameliorations_effectives(),
		_rarete, etage_recompense if campagne else 0, _contexte)
	var peut_changer := false
	for id in disponibles:
		if id not in _propositions:
			peut_changer = true
	_bouton_reroll.text = "Nouveau tirage · %d restant(s)" % Jeu.rerolls_restants
	_bouton_reroll.disabled = _rarete == Reactif.COMMUN or Jeu.rerolls_restants <= 0 or not peut_changer

func _sur_reroll() -> void:
	if _choisi or _bouton_reroll.disabled or Jeu.rerolls_restants <= 0:
		return
	Jeu.rerolls_restants -= 1
	# La rarete est fixee a l'ouverture du niveau, jamais relancee.
	_nouveau_tirage()

func _sur_choix(id: String) -> void:
	if _choisi or id not in _propositions:
		return
	_choisi = true
	var reactif := CatalogueReactifs.par_id(id)
	soin_choisi = float(reactif.mods.get("soin_part", 0.0))
	if reactif.rarete == Reactif.EPIQUE:
		soin_choisi += ProgressionAugments.SOIN_EPIQUE
	if not reactif.mods.has("soin_part"):
		Jeu.ajouter_reactif(id)
	Sons.jouer("choix", -10.0)
	StyleInterface.sortir_puis(self, func() -> void: termine.emit())

func _fermer_sans_choix() -> void:
	if _choisi:
		return
	_choisi = true
	StyleInterface.sortir_puis(self, func() -> void: termine.emit())

func _choisir_automatiquement() -> void:
	await get_tree().create_timer(0.12).timeout
	if not _choisi and not _propositions.is_empty():
		_sur_choix(_propositions[0])
