extends RefCounted

func _base() -> Tir:
	return Tir.de_base(Stats.depuis_reglages())

func test_sans_mods_rien_ne_change(v: Verif) -> void:
	var t := Mods.appliquer(_base(), [])
	v.egal(t.nb_projectiles, 1, "aucun mod, un projectile")
	v.presque(t.degats, Reglages.TIR_DEGATS, "aucun mod, degats de base")

func test_addition(v: Verif) -> void:
	var t := Mods.appliquer(_base(), [{"nb_projectiles_add": 1}, {"nb_projectiles_add": 1}])
	v.egal(t.nb_projectiles, 3, "deux ajouts sur une base de 1")

func test_multiplicateurs_additifs(v: Verif) -> void:
	# +100 % et +50 % font +150 %, pas +200 % : en produit, empiler quatre
	# reactifs de degats fabriquait une main six fois au-dessus de la moyenne.
	var t := Mods.appliquer(_base(), [{"degats_mult": 2.0}, {"degats_mult": 1.5}])
	v.presque(t.degats, Reglages.TIR_DEGATS * 2.5, "les multiplicateurs s'additionnent")

func test_malus_ne_peut_pas_annuler_le_tir(v: Verif) -> void:
	var t := Mods.appliquer(_base(), [{"degats_mult": 0.5}, {"degats_mult": 0.5}, {"degats_mult": 0.5}])
	v.vrai(t.degats > 0.0, "un empilement de malus laisse toujours un tir")

func test_effets_reunis_sans_doublon(v: Verif) -> void:
	var t := Mods.appliquer(_base(), [{"effets": ["braise"]}, {"effets": ["braise", "givre"]}])
	v.egal(t.effets.size(), 2, "braise n'est comptee qu'une fois")
	v.vrai("givre" in t.effets, "givre est present")

func test_ordre_sans_importance(v: Verif) -> void:
	var a := Mods.appliquer(_base(), [{"degats_mult": 2.0}, {"nb_projectiles_add": 1}])
	var b := Mods.appliquer(_base(), [{"nb_projectiles_add": 1}, {"degats_mult": 2.0}])
	v.presque(a.degats, b.degats, "l'ordre ne change pas les degats")
	v.egal(a.nb_projectiles, b.nb_projectiles, "l'ordre ne change pas le nombre")

func test_base_non_modifiee(v: Verif) -> void:
	var base := _base()
	Mods.appliquer(base, [{"degats_mult": 5.0}, {"effets": ["braise"]}])
	v.presque(base.degats, Reglages.TIR_DEGATS, "le Tir de base n'est jamais mute")
	v.egal(base.effets.size(), 0, "les effets du Tir de base non plus")

func test_drapeaux(v: Verif) -> void:
	var t := Mods.appliquer(_base(), [{"drapeaux": ["homing"]}])
	v.vrai("homing" in t.drapeaux, "le drapeau est transmis")

func test_bonus_et_couts_separes(v: Verif) -> void:
	var mods := [{"degats_mult": 0.5}, {"degats_mult": 0.5}, {"degats_mult": 1.5}]
	var t := Mods.appliquer(_base(), mods)
	v.presque(t.degats, Reglages.TIR_DEGATS * 0.25 * 1.5, "les couts ne s'annulent pas et le bonus ne les efface pas")
	mods.reverse()
	v.presque(Mods.appliquer(_base(), mods).degats, t.degats, "ordre des couts et bonus indifferent")

func test_catalogue_complet_et_fusions(v: Verif) -> void:
	for id in CatalogueReactifs.ids():
		for autre in CatalogueReactifs.ids():
			var ids := [id, autre]
			var t := Mods.appliquer(_base(), Mods.depuis_l_inventaire(ids))
			ids.reverse()
			var inverse := Mods.appliquer(_base(), Mods.depuis_l_inventaire(ids))
			v.vrai(t.degats > 0.0 and t.cadence > 0.0 and t.portee > 0.0, "%s + %s reste jouable" % [id, autre])
			v.presque(t.degats, inverse.degats, "paire commutative")
		for element in CatalogueElements.ids():
			var t := Mods.appliquer(_base(), Mods.depuis_l_inventaire([id, CatalogueElements.id_fusion(element, id)]))
			v.vrai(t.degats > 0.0 and t.cadence > 0.0, "fusion %s/%s valide" % [id,element])

func test_tirs_combines_ne_perdent_pas_de_puissance_totale(v: Verif) -> void:
	var inventaire: Array = ["spirale"]
	var avant := Mods.appliquer(_base(), Mods.depuis_l_inventaire(inventaire))
	inventaire.append("tir_multiple")
	var apres := Mods.appliquer(_base(), Mods.depuis_l_inventaire(inventaire))
	v.vrai(apres.degats * apres.nb_projectiles >= avant.degats * avant.nb_projectiles, "Tir multiple ne penalise plus un eventail complet")
	inventaire.append("salve")
	var salve := Mods.appliquer(_base(), Mods.depuis_l_inventaire(inventaire))
	v.vrai(salve.degats * salve.nb_projectiles * Reglages.RAFALE_NOMBRE > apres.degats * apres.nb_projectiles, "Salve renforce les tirs combines")
