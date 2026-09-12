extends RefCounted

func test_chaque_augmentation_a_des_recettes(v: Verif) -> void:
	for augment in CatalogueReactifs.ids():
		var recettes := CatalogueRecettes.compatibles(augment)
		v.vrai(recettes.size() >= 2,"deux directions minimum pour " + augment)
		for recette in recettes:
			var id := CatalogueRecettes.id_fusion(recette,augment)
			v.vrai(CatalogueRecettes.creer(id) != null,"recette valide " + id)
			v.egal(CatalogueRecettes.augment_de(id),augment,"origine conservee")
			v.vrai(not CatalogueRecettes.creer(id).description.is_empty(),"effet explique")

func test_choix_varies_et_sans_fusion_double(v: Verif) -> void:
	for graine in 100:
		var rng := RandomNumberGenerator.new()
		rng.seed = graine
		var inventaire: Array = ["ricochet","egide","meteores","sceau_furie",CatalogueRecettes.id_fusion("braises","ricochet")]
		var choix := CatalogueRecettes.proposer(inventaire,rng)
		v.egal(choix.size(),3,"trois propositions")
		v.egal(CatalogueRecettes.TOUS[CatalogueRecettes.recette_de(choix[0])]["element"],"eau","une piste de reaction proposee quand elle est disponible")
		var vus: Array[String] = []
		for id in choix:
			v.vrai(CatalogueRecettes.augment_de(id) != "ricochet","pas de seconde fusion sur le meme support")
			v.vrai(CatalogueRecettes.recette_de(id) not in vus,"recettes distinctes")
			vus.append(CatalogueRecettes.recette_de(id))
		v.vrai("braises" not in vus,"une recette ne se cumule pas")
		var draft := DraftLogique.proposer([],rng)
		var familles: Array[String] = []
		for id in draft:
			v.vrai(CatalogueReactifs.par_id(id).famille not in familles,"trois familles au choix de niveau")
			familles.append(CatalogueReactifs.par_id(id).famille)

func test_epuisement_et_entrees_invalides(v: Verif) -> void:
	var rng := RandomNumberGenerator.new()
	v.egal(CatalogueRecettes.proposer([],rng),[],"sans support aucun choix")
	v.egal(CatalogueRecettes.creer("recette__inconnue__egide"),null,"recette inconnue refusee")
	v.egal(CatalogueRecettes.creer("recette__braises__egide"),null,"famille incompatible refusee")
	v.egal(CatalogueRecettes.proposer(["egide",CatalogueElements.id_fusion("feu","egide")],rng),[],"ancienne fusion respectee")
