extends Control
signal termine
var _choisi := false

func _ready() -> void:
	var col := StyleAzur.page(self, "La halte")
	col.add_child(StyleAzur.texte("+50 % de vos PV maximum\nChoisissez une nouvelle augmentation", 30, StyleAzur.ATTENUE))
	var liste := StyleAzur.defilement(col)
	var propositions := DraftLogique.proposer_halte(Jeu.inventaire, Jeu.rng)
	for id in propositions:
		var reactif := CatalogueReactifs.par_id(id)
		var bouton := StyleAzur.bouton(reactif.nom + "\n\n" + reactif.description, func(): _choisir(id))
		bouton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bouton.custom_minimum_size.y = 260
		liste.add_child(bouton)
	if propositions.is_empty():
		liste.add_child(StyleAzur.bouton("Reprendre la route", func(): _choisir("")))
	StyleInterface.animer_entree(self)
	if Jeu.mode_auto:
		await get_tree().create_timer(0.2).timeout
		_choisir(propositions[0] if not propositions.is_empty() else "")

func _choisir(id: String) -> void:
	if _choisi: return
	_choisi = true
	if not id.is_empty(): Jeu.ajouter_reactif(id)
	Sons.jouer("choix", -8.0)
	StyleInterface.sortir_puis(self, func(): termine.emit())
