extends Control
signal termine
var _choisi := false
var _propositions: Array[String] = []
var _cartes: VBoxContainer
var _bouton_reroll: Button
var etage_recompense := 1

func _ready() -> void:
	var col := StyleAzur.page(self,"Choisissez une amélioration")
	col.add_child(StyleAzur.texte("Une nouvelle magie pour cette aventure",30,StyleAzur.ATTENUE))
	_cartes = StyleAzur.defilement(col)
	_bouton_reroll = StyleAzur.bouton("",_sur_reroll)
	col.add_child(_bouton_reroll)
	_nouveau_tirage()
	Capture.programmer(self)
	if Jeu.mode_auto: _choisir_automatiquement()

func _nouveau_tirage() -> void:
	_propositions = DraftLogique.proposer(Jeu.inventaire,Jeu.rng)
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	if _propositions.is_empty():
		_fermer_sans_choix()
		return
	for id in _propositions:
		var reactif := CatalogueReactifs.par_id(id)
		var b := StyleAzur.bouton("",func(): _sur_choix(id))
		b.custom_minimum_size.y = 310
		_cartes.add_child(b)
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for cote in ["left","right","top","bottom"]: marge.add_theme_constant_override("margin_"+cote,24)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(marge)
		var ligne := HBoxContainer.new()
		ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne.add_theme_constant_override("separation",28)
		marge.add_child(ligne)
		ligne.add_child(StyleAzur.vignette(id,160))
		var texte := VBoxContainer.new()
		texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texte.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne.add_child(texte)
		texte.add_child(StyleAzur.texte(reactif.nom,35))
		texte.add_child(StyleAzur.texte(reactif.description,29,StyleAzur.ATTENUE))
	_bouton_reroll.text = "Nouveau tirage · %d restant(s)" % Jeu.rerolls_restants
	_bouton_reroll.disabled = Jeu.rerolls_restants <= 0

func _sur_reroll() -> void:
	if _choisi or Jeu.rerolls_restants <= 0: return
	Jeu.rerolls_restants -= 1
	_nouveau_tirage()

func _sur_choix(id: String) -> void:
	if _choisi:
		return
	_choisi = true
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
