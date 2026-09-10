extends RefCounted

func test_valeurs_de_depart(v: Verif) -> void:
	var s := Stats.depuis_reglages()
	v.presque(s.pv, Reglages.HEROS_PV, "le heros commence a ses PV max")
	v.presque(s.pv_max, Reglages.HEROS_PV, "PV max lus dans les reglages")

# Le niveau de compte mesure l'avancement mais n'ajoute pas une couche de stats :
# Maitrises, objets et Passifs restent les trois sources permanentes lisibles.
func test_le_niveau_ne_donne_pas_de_statistiques_de_base(v: Verif) -> void:
	for niveau in [1, 2, 10, Reglages.NIVEAU_REFERENCE_FIN]:
		v.presque(Stats.base_degats(niveau), Reglages.TIR_DEGATS,
			"le niveau %d ne modifie pas les degats" % niveau)
		v.presque(Stats.base_pv(niveau), Reglages.HEROS_PV,
			"le niveau %d ne modifie pas les PV" % niveau)
		v.presque(Stats.base_cadence(niveau), Reglages.HEROS_CADENCE,
			"le niveau %d ne modifie pas la cadence" % niveau)

func test_les_bonus_permanents_restent_independants_du_niveau(v: Verif) -> void:
	var rangs := {"force": ArbreCompetences.rangs("force")}
	var bas := Stats.depuis_reglages(rangs, {}, {}, 1)
	var haut := Stats.depuis_reglages(rangs, {}, {}, Reglages.NIVEAU_REFERENCE_FIN)
	v.presque(haut.degats, bas.degats,
		"le meme investissement de Maitrise vaut pareil quel que soit le niveau de compte")

func test_blesser_retire_des_pv(v: Verif) -> void:
	var s := Stats.depuis_reglages()
	s.blesser(10.0)
	v.presque(s.pv, Reglages.HEROS_PV - 10.0, "la blessure retire des PV")

func test_pv_ne_descendent_pas_sous_zero(v: Verif) -> void:
	var s := Stats.depuis_reglages()
	s.blesser(Reglages.HEROS_PV * 10.0)
	v.presque(s.pv, 0.0, "les PV plafonnent a zero")
	v.vrai(s.est_mort(), "a zero PV le heros est mort")

func test_soigner_ne_depasse_pas_le_max(v: Verif) -> void:
	var s := Stats.depuis_reglages()
	s.blesser(5.0)
	s.soigner(50.0)
	v.presque(s.pv, s.pv_max, "le soin plafonne aux PV max")

func test_un_objet_apporte_son_profil_multiplie_par_la_forge(v: Verif) -> void:
	# Anneau I du premier Monde : son facteur de Monde vaut un, donc le bonus
	# lisible est exactement son profil multiplie par la Forge.
	var id := CatalogueObjets.objet_du_chapitre(0)
	var profil: Dictionary = CatalogueObjets.OBJETS[id]["profil"]
	var forge := 1.0 + 2.0 * Reglages.FORGE_BONUS_PAR_NIVEAU
	var bonus := CatalogueObjets.bonus_effectifs({"anneau_gauche": id}, {id: 2})
	v.presque(float(bonus["degats"]), float(profil["degats"]) * forge,
		"l'objet apporte son profil, la Forge le multiplie")
	var s := Stats.depuis_reglages({}, {}, bonus)
	v.presque(s.degats, Reglages.TIR_DEGATS * (1.0 + float(profil["degats"]) * forge),
		"le bonus d'objet est applique en combat")

func test_un_objet_non_forge_vaut_deja_quelque_chose(v: Verif) -> void:
	var id := CatalogueObjets.objet_du_chapitre(0)
	var bonus := CatalogueObjets.bonus_effectifs({"anneau_gauche": id}, {})
	v.vrai(float(bonus["degats"]) > 0.0,
		"trouver un objet apporte un gain immediat, avant toute Pierre de forge")

func test_le_collier_defend_et_l_anneau_attaque(v: Verif) -> void:
	var collier := CatalogueObjets.objet_du_chapitre(2)
	var bonus := CatalogueObjets.bonus_effectifs({"collier": collier}, {})
	v.vrai(float(bonus["pv"]) > float(bonus["degats"]),
		"le Collier est d'abord un objet defensif")
	var anneau := CatalogueObjets.objet_du_chapitre(0)
	var offensif := CatalogueObjets.bonus_effectifs({"anneau_gauche": anneau}, {})
	v.presque(float(offensif["pv"]), 0.0, "l'Anneau I ne donne pas de PV")

# Le palier du compte rattrape les vieux objets : le choix final pourra donc se
# faire sur leur effet propre sans qu'un drop tardif invalide automatiquement le
# meme slot du premier Monde.
func test_un_objet_ancien_rattrape_le_palier_du_compte(v: Verif) -> void:
	var premier := CatalogueObjets.objet_du_chapitre(0)
	var dernier := CatalogueObjets.objet_du_chapitre((Chapitres.MONDES.size() - 1) * 3)
	var monde_final := Chapitres.MONDES.size() - 1
	var ancien := CatalogueObjets.bonus_objet(premier, 0, monde_final)
	var tardif := CatalogueObjets.bonus_objet(dernier, 0, monde_final)
	v.presque(float(ancien["degats"]), float(tardif["degats"]),
		"deux Anneaux du meme profil ont la meme base une fois le Monde rattrape")
