extends RefCounted

func test_pool_d_augments_sans_elements(v: Verif) -> void:
	v.egal(CatalogueReactifs.ids().size(), 30, "le pool actuel compte exactement trente Améliorations")
	for element_legacy in ["braise", "givre", "foudre", "acide"]:
		v.vrai(element_legacy not in CatalogueReactifs.ids(), "%s ne tombe jamais au draft" % element_legacy)

func test_chaque_reactif_a_un_effet(v: Verif) -> void:
	for id in CatalogueReactifs.ids():
		var r := CatalogueReactifs.par_id(id)
		v.vrai(not r.mods.is_empty(), "le reactif %s doit modifier quelque chose" % id)
		v.vrai(r.nom != "", "le reactif %s doit avoir un nom affichable" % id)
		v.vrai(r.description != "", "le reactif %s doit avoir une description" % id)

func test_ids_uniques(v: Verif) -> void:
	var vus: Array[String] = []
	for id in CatalogueReactifs.ids():
		v.vrai(not id in vus, "l'id %s ne doit apparaitre qu'une fois" % id)
		vus.append(id)

func test_id_coherent_avec_la_cle(v: Verif) -> void:
	for id in CatalogueReactifs.ids():
		v.egal(CatalogueReactifs.par_id(id).id, id, "la cle du catalogue est l'id du reactif")

func test_aucun_augment_n_est_une_transformation(v: Verif) -> void:
	for id in CatalogueReactifs.ids():
		v.vrai(not CatalogueReactifs.par_id(id).est_transformation, "%s est un Amélioration de base" % id)

func test_tir_multiple_ajoute_un_projectile(v: Verif) -> void:
	var r := CatalogueReactifs.par_id("tir_multiple")
	var t := Mods.appliquer(Tir.de_base(Stats.depuis_reglages()), [r.mods])
	v.egal(t.nb_projectiles, 2, "Tir multiple porte le tir a deux projectiles")
	v.vrai(t.ecart_lateral > 0.0, "deux projectiles partent sur deux lignes lisibles")

func test_salve_tire_exactement_deux_fois(v: Verif) -> void:
	v.vrai("rafale" in CatalogueReactifs.par_id("salve").mods["drapeaux"],
		"Salve active le comportement de rafale")
	v.egal(Reglages.RAFALE_NOMBRE, 2, "Salve produit exactement deux tirs")

func test_repartition_exacte_des_familles(v: Verif) -> void:
	v.egal(CatalogueReactifs.ids_de_famille(CatalogueReactifs.PROJECTILE).size(), 10,
		"dix Améliorations modifient les projectiles")
	v.egal(CatalogueReactifs.ids_de_famille(CatalogueReactifs.HEROS).size(), 8,
		"huit Améliorations transforment le Heros")
	v.egal(CatalogueReactifs.ids_de_famille(CatalogueReactifs.PHENOMENE).size(), 7,
		"sept Améliorations creent des phenomenes")
	v.egal(CatalogueReactifs.ids_de_famille(CatalogueReactifs.SCEAU).size(), 5,
		"cinq Sceaux gravent une regle permanente")
	# La famille decide de ce que l'Element produit a la fusion : une famille
	# vide de contenu rendrait une part des Elements sans effet.
	var total := 0
	for famille in [CatalogueReactifs.PROJECTILE, CatalogueReactifs.HEROS,
			CatalogueReactifs.PHENOMENE, CatalogueReactifs.SCEAU]:
		var compte := CatalogueReactifs.ids_de_famille(famille).size()
		v.vrai(compte >= 5, "la famille %s reste assez fournie pour porter les Elements" % famille)
		total += compte
	v.egal(total, CatalogueReactifs.ids().size(), "aucune Amélioration n'est hors famille")

# La famille decide de ce qu'un Element produit a la fusion. Les Sceaux sont le
# quatrieme axe : leur Element controle au lieu de frapper.
func test_les_sceaux_ont_leur_propre_interaction_elementaire(v: Verif) -> void:
	for id in CatalogueReactifs.ids_de_famille(CatalogueReactifs.SCEAU):
		for element in CatalogueElements.ids():
			var fusion := CatalogueElements.creer_fusion(element, id)
			v.vrai(fusion != null, "%s doit fusionner avec %s" % [id, element])
			var drapeaux: Array = fusion.mods.get("drapeaux", [])
			v.vrai("sceau_element_%s" % element in drapeaux,
				"la fusion %s · %s scelle son Element dans la salle" % [id, element])
			v.vrai(fusion.description.length() > 20,
				"la fusion %s · %s explique ce qu'elle change" % [id, element])

# Chaque Amélioration doit pouvoir fusionner avec les six Elements : une fusion
# qui ne produit rien serait un Alambic perdu.
func test_chaque_amelioration_fusionne_avec_les_six_elements(v: Verif) -> void:
	for id in CatalogueReactifs.ids():
		for element in CatalogueElements.ids():
			var fusion := CatalogueElements.creer_fusion(element, id)
			v.vrai(fusion != null, "%s doit pouvoir fusionner avec %s" % [id, element])
			v.vrai(fusion.description != "", "la fusion %s · %s doit s'expliquer" % [id, element])

func _rendement_projectile(ids: Array[String]) -> float:
	var base := Tir.de_base(Stats.depuis_reglages())
	var mods: Array = []
	for id in ids:
		mods.append(CatalogueReactifs.par_id(id).mods)
	var tir := Mods.appliquer(base, mods)
	var salves := Reglages.RAFALE_NOMBRE if "rafale" in tir.drapeaux else 1
	return tir.degats / base.degats * tir.cadence / base.cadence \
		* float(tir.nb_projectiles) * float(salves)

# Une carte de projectile ne doit plus etre soit autowin, soit presque morte.
# Le proxy ci-dessous mesure le DPS brut sur une cible assez large pour prendre
# les projectiles ; les cartes de trajectoire ont en plus leur vraie utilite en jeu.
func test_les_projectiles_restent_dans_un_budget_resserre(v: Verif) -> void:
	var minimum := INF
	var maximum := 0.0
	for id in CatalogueReactifs.ids_de_famille(CatalogueReactifs.PROJECTILE):
		var rendement := _rendement_projectile([id])
		minimum = minf(minimum, rendement)
		maximum = maxf(maximum, rendement)
	v.vrai(minimum >= 0.94, "aucune Amélioration projectile n'est presque strictement pire que le tir de base")
	v.vrai(maximum <= 1.80, "aucune Amélioration projectile seule ne double gratuitement le DPS")

func test_le_trio_multi_salve_cadence_reste_fort_sans_exploser(v: Verif) -> void:
	var rendement := _rendement_projectile(["tir_multiple", "salve", "cadence_febrile"])
	v.vrai(rendement >= 1.70 and rendement <= 2.05,
		"multi + salve + cadence reste un power spike, pas un multiplicateur hors echelle")
	var moyenne_tenebres := 1.0 + Reglages.TENEBRES_CHANCE_SURCHARGE * (Reglages.TENEBRES_SURCHARGE_MULT - 1.0)
	v.vrai(moyenne_tenebres <= 1.30,
		"Tenebres ne rajoute plus pres de cinquante pour cent de DPS moyen a chaque impact")

func test_les_nouvelles_ameliorations_ont_un_vrai_arbitrage(v: Verif) -> void:
	# Une Amélioration qui ne fait que gagner n'est pas un choix. Les trois
	# nouvelles Améliorations de projectile echangent explicitement une
	# statistique contre une autre.
	for id in ["frappe_lourde", "cadence_febrile", "trait_transpercant"]:
		var mods: Dictionary = CatalogueReactifs.par_id(id).mods
		var gagne := false
		var perd := false
		for cle in ["degats_mult", "cadence_mult", "vitesse_mult", "portee_mult"]:
			if mods.has(cle):
				gagne = gagne or float(mods[cle]) > 1.0
				perd = perd or float(mods[cle]) < 1.0
		v.vrai(perd, "%s paie son gain par une statistique en baisse" % id)
		v.vrai(gagne or mods.has("drapeaux"), "%s apporte bien quelque chose" % id)

func test_le_feu_est_borne_sur_les_cibles_longues(v: Verif) -> void:
	v.vrai(Reglages.FEU_DOT_CUMUL_MAX >= 3 and Reglages.FEU_DOT_CUMUL_MAX <= 5,
		"Feu garde plusieurs cumuls sans pouvoir croitre pendant tout un boss")
	var donnees := {"pv": 10000.0, "couleur": Color.WHITE}
	for chemin in ["res://scripts/ennemi.gd", "res://scripts/boss.gd"]:
		var acteur: Node = load(chemin).new()
		acteur.configurer(donnees)
		for impact in 12:
			acteur.recevoir_degats(10.0, ["feu"])
		v.egal(int(acteur.get("_feu_cumuls")), Reglages.FEU_DOT_CUMUL_MAX,
			"la cible plafonne le nombre de brulures")
		v.presque(float(acteur.get("_feu_dps")),
			10.0 * Reglages.FEU_DOT_PART_PAR_SECONDE * float(Reglages.FEU_DOT_CUMUL_MAX),
			"les impacts au-dela du plafond n'ajoutent plus de DPS")
		acteur.free()
