extends Control
signal termine

var _propositions: Array[String] = []
var _selection := ""
var _boutons: Array[Button] = []
var _bouton_fusionner: Button
var _apercu: Label
var _fusion_en_cours := false

func _ready() -> void:
	_propositions = CatalogueRecettes.proposer(Jeu.inventaire,Jeu.rng)
	var col := StyleAzur.page(self,"L’Alambic des possibles")
	col.add_child(StyleAzur.texte("Une fusion pour orienter cette aventure",28,StyleAzur.ATTENUE))
	var liste := StyleAzur.defilement(col)
	for id in _propositions:
		var recette := CatalogueRecettes.creer(id)
		var base := CatalogueReactifs.par_id(CatalogueRecettes.augment_de(id))
		var element := CatalogueElements.par_id(CatalogueRecettes.TOUS[CatalogueRecettes.recette_de(id)]["element"])
		var bouton := StyleAzur.bouton("%s\n%s + %s\n\n%s" % [recette.nom,base.nom,element["nom"],recette.description],func(): _sur_choix(id))
		bouton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bouton.custom_minimum_size.y = 300
		bouton.add_theme_font_size_override("font_size",28)
		liste.add_child(bouton)
		_boutons.append(bouton)
	_apercu = StyleAzur.texte("L’amélioration de départ reste active. Les réactions peuvent combiner plusieurs fusions.",25,StyleAzur.ATTENUE)
	col.add_child(_apercu)
	_bouton_fusionner = StyleAzur.bouton("Choisir une recette",_sur_fusionner,true)
	_bouton_fusionner.disabled = true
	col.add_child(_bouton_fusionner)
	if _propositions.is_empty():
		_apercu.text = "Toutes vos améliorations sont déjà transformées. Le soin de l’Alambic est conservé."
		col.add_child(StyleAzur.bouton("Continuer",_fermer))
	StyleInterface.animer_entree(self)
	Capture.programmer(self)
	if Jeu.mode_auto: _jouer_automatiquement()

func _sur_choix(id: String) -> void:
	if _fusion_en_cours: return
	_selection = id
	for i in _boutons.size():
		_boutons[i].modulate = Color.WHITE if _propositions[i] == id else Color(0.72,0.78,0.85)
	_bouton_fusionner.disabled = false
	_bouton_fusionner.text = "Créer · " + CatalogueRecettes.creer(id).nom

func _sur_fusionner() -> void:
	if _fusion_en_cours or _selection.is_empty(): return
	if not Jeu.ajouter_recette(_selection): return
	_fusion_en_cours = true
	_bouton_fusionner.disabled = true
	for bouton in _boutons: bouton.disabled = true
	Sons.jouer("fusion",-8.0)
	_apercu.text = CatalogueRecettes.creer(_selection).nom + " créée !"
	await get_tree().create_timer(0.65).timeout
	_fermer()

func _fermer() -> void:
	StyleInterface.sortir_puis(self,func(): termine.emit())

func _jouer_automatiquement() -> void:
	await get_tree().create_timer(0.2).timeout
	if _propositions.is_empty():
		_fermer()
		return
	_sur_choix(_propositions[Jeu.rng.randi_range(0,_propositions.size()-1)])
	_sur_fusionner()
