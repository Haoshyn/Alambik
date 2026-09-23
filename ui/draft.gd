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
var _espace_haut: Control
var _consigne: Label
var _bouton_reroll: Button

func _ready() -> void:
	var arme: Dictionary = CatalogueProjectiles.TYPES.get(ReglagesJoueur.projectile_equipe_effectif(), {})
	_contexte = {
		"drapeaux_arme": arme.get("drapeaux", []),
		"avec_sorts": Sorts.ACTIFS.has(ReglagesJoueur.sort_actif_effectif()) or Sorts.ULTIMES.has(ReglagesJoueur.ultime_effectif()),
	}
	_rarete = rarete_imposee
	if campagne and _rarete.is_empty():
		_rarete = ProgressionAugments.rarete_niveau(etage_recompense, Jeu.niveaux_rares)
	var titre := "Choisissez une augmentation"
	var sous_titre := "Une nouvelle magie pour cette aventure"
	if palier_epique > 0:
		titre = "Étage %d · Augmentation %s" % [palier_epique,
			"légendaire" if _rarete == Reactif.LEGENDAIRE else "épique"]
		sous_titre = "Choisissez un pouvoir · Soin garanti : %d %% des PV max" % roundi(ProgressionAugments.SOIN_EPIQUE * 100.0)
		if _rarete == Reactif.LEGENDAIRE:
			sous_titre += "\nUnique dans cette aventure · Aucune relance"
	elif campagne:
		titre = "Niveau %d / %d · %s" % [etage_recompense, ProgressionAugments.niveau_max(),
			"Rare" if _rarete == Reactif.RARE else "Commun"]
		sous_titre = "Quatre rares garantis entre les niveaux 1 et 10" if _rarete == Reactif.RARE else "Soin, attaque ou PV maximum · Bonus cumulables sans diminution"
	var col := StyleAzur.page(self, "Augmentations")
	StyleAzur.banniere(col, titre, sous_titre, "fiole")
	_cartes = StyleAzur.defilement(col)
	_cartes.add_theme_constant_override("separation", 28)
	_espace_haut = Control.new()
	_cartes.add_child(_espace_haut)
	_consigne = StyleAzur.texte("Touchez le pouvoir à emporter", 26, StyleAzur.MENTHE)
	_consigne.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cartes.add_child(_consigne)
	_cartes.get_parent().resized.connect(_recentrer_cartes)
	_bouton_reroll = StyleAzur.bouton("", _sur_reroll)
	col.add_child(_bouton_reroll)
	_nouveau_tirage()
	if not _choisi:
		StyleInterface.animer_entree(self)
	Capture.programmer(self)
	if Jeu.mode_auto:
		_choisir_automatiquement()

func _nouveau_tirage() -> void:
	if _rarete == Reactif.LEGENDAIRE and not _propositions.is_empty():
		return
	var anciennes := _propositions.duplicate()
	_propositions = DraftLogique.proposer(Jeu.ameliorations_effectives(), Jeu.rng,
		ProgressionAugments.NOMBRE_CHOIX, _rarete, etage_recompense if campagne else 0, anciennes, _contexte)
	for enfant in _cartes.get_children():
		if enfant == _espace_haut or enfant == _consigne:
			continue
		_cartes.remove_child(enfant)
		enfant.queue_free()
	if _propositions.is_empty():
		_fermer_sans_choix()
		return
	for id in _propositions:
		var reactif := CatalogueReactifs.par_id(id)
		var carte := CarteReactif.new()
		carte.pour_choix = true
		carte.configurer(reactif)
		carte.choisie.connect(_sur_choix)
		_cartes.add_child(carte)
	_recentrer_cartes.call_deferred()
	var disponibles := DraftLogique.candidats(Jeu.ameliorations_effectives(),
		_rarete, etage_recompense if campagne else 0, _contexte)
	var peut_changer := false
	for id in disponibles:
		if id not in _propositions:
			peut_changer = true
	_bouton_reroll.text = "Renouveler les cartes · %d relance%s" % [Jeu.rerolls_restants,
		"s" if Jeu.rerolls_restants > 1 else ""]
	_bouton_reroll.visible = ProgressionAugments.relance_autorisee(_rarete) and Jeu.rerolls_restants > 0 and peut_changer
	_bouton_reroll.disabled = not _bouton_reroll.visible

func _recentrer_cartes() -> void:
	if not is_instance_valid(_cartes) or not is_instance_valid(_espace_haut):
		return
	var hauteur := _consigne.get_combined_minimum_size().y
	var nombre := 0
	for enfant in _cartes.get_children():
		if enfant is CarteReactif:
			hauteur += (enfant as Control).get_combined_minimum_size().y
			nombre += 1
	hauteur += float(nombre) * float(_cartes.get_theme_constant("separation"))
	var defilement := _cartes.get_parent() as ScrollContainer
	_espace_haut.custom_minimum_size.y = clampf((defilement.size.y - hauteur) * 0.42, 0.0, 300.0)

func _sur_reroll() -> void:
	if _choisi or _bouton_reroll.disabled:
		return
	if not Jeu.consommer_relance(_rarete):
		return
	# La rarete est fixee a l'ouverture du niveau, jamais relancee.
	_nouveau_tirage()

func _sur_choix(id: String) -> void:
	if _choisi or id not in _propositions:
		return
	_choisi = true
	for carte in _cartes.get_children():
		if carte is CarteReactif:
			carte.selectionnee = carte.reactif.id == id
			carte.disabled = true
	var reactif := CatalogueReactifs.par_id(id)
	soin_choisi = float(reactif.mods.get("soin_part", 0.0))
	if reactif.rarete in [Reactif.EPIQUE, Reactif.LEGENDAIRE]:
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
