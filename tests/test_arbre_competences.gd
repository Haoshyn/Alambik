extends RefCounted

func test_une_maitrise_se_pousse_sur_plusieurs_rangs(v: Verif) -> void:
	v.egal(ArbreCompetences.MAX_RANG, Reglages.MAITRISE_RANG_MAX,
		"le plafond de rang vit dans l'equilibrage")
	v.vrai(ArbreCompetences.MAX_RANG > 1, "le farm peut pousser une Maitrise au-dela du premier rang")
	v.egal(ArbreCompetences.rangs("force"), Reglages.MAITRISE_RANG_MAX,
		"une Maitrise chiffree se rachete jusqu'au plafond")
	# Un deblocage ne s'empile pas : un second Passif obtenu cinq fois ne veut
	# rien dire, et cinq nouveaux tirages rendraient le draft entierement choisi.
	v.egal(ArbreCompetences.rangs("savoir"), 1, "un deblocage unique reste unique")
	v.egal(ArbreCompetences.rangs("distillation"), 2, "les nouveaux tirages restent bornes")
	v.egal(ArbreCompetences.nombre_rerolls({"distillation": 2, "prescience": 2}), 4,
		"les rangs de tirage s'additionnent")

func test_le_cout_d_un_rang_monte_avec_le_rang(v: Verif) -> void:
	var base := ArbreCompetences.cout("force", 0)
	v.egal(base, Reglages.MAITRISE_COUTS[0], "le premier rang garde le cout du palier")
	for rang in range(1, ArbreCompetences.rangs("force")):
		v.vrai(ArbreCompetences.cout("force", rang) > ArbreCompetences.cout("force", rang - 1),
			"le rang %d coute plus que le precedent" % (rang + 1))
	v.vrai(ArbreCompetences.cout_total("force") > base * ArbreCompetences.rangs("force"),
		"maitriser entierement un noeud coute plus que cinq fois son premier rang")

func test_un_rang_supplementaire_ajoute_sa_part(v: Verif) -> void:
	v.presque(ArbreCompetences.multiplicateur_degats({"force": 1}), 1.012,
		"un rang de Force vaut sa valeur unitaire")
	v.presque(ArbreCompetences.multiplicateur_degats({"force": 3}), 1.036,
		"trois rangs valent trois fois la valeur unitaire")
	v.presque(ArbreCompetences.multiplicateur_degats({"force": 99}), 1.060,
		"un rang sauvegarde au-dela du plafond ne donne rien de plus")

func test_les_trois_branches_restent_independantes(v: Verif) -> void:
	v.egal(ArbreCompetences.BRANCHES.size(), 3, "offensif, defensif et utilitaire sont separes")
	for branche in ArbreCompetences.BRANCHES:
		var ids: Array = ArbreCompetences.BRANCHES[branche]
		v.vrai(ids.size() >= 2, "%s contient un chemin jouable" % branche)
		for index in range(1, ids.size()):
			v.egal(ArbreCompetences.NOEUDS[ids[index]]["requis"], ids[index - 1],
				"chaque avancee de %s demande le noeud precedent" % branche)

func test_l_arbre_accompagne_les_dix_mondes(v: Verif) -> void:
	v.egal(ArbreCompetences.NOEUDS.size(), 30, "trois branches de dix paliers sont disponibles")
	for branche in ArbreCompetences.BRANCHES:
		v.egal(ArbreCompetences.BRANCHES[branche].size(), 10, "%s accompagne les dix mondes" % branche)
	v.vrai(not ArbreCompetences.prerequis_atteint("cadence", {}), "Cadence commence verrouillee")
	v.vrai(ArbreCompetences.prerequis_atteint("cadence", {"force": 1}), "Force ouvre Cadence")

func _branche_au_rang(branche: String, rang: int) -> Dictionary:
	var rangs := {}
	for id in ArbreCompetences.BRANCHES[branche]:
		rangs[id] = mini(rang, ArbreCompetences.rangs(str(id)))
	return rangs

func test_la_puissance_va_du_petit_bonus_au_gros_scaling(v: Verif) -> void:
	v.presque(ArbreCompetences.multiplicateur_pv({"constitution": 1}), 1.016,
		"Constitution applique son premier bonus")
	v.presque(ArbreCompetences.multiplicateur_degats({"force": 1}), 1.012,
		"Force applique son premier bonus")
	v.presque(ArbreCompetences.reduction_degats({"armure": 1}), 0.002,
		"Armure applique sa reduction")
	var offensive_premier := _branche_au_rang("Offensif", 1)
	var dps_premier := ArbreCompetences.multiplicateur_degats(offensive_premier) \
		* ArbreCompetences.multiplicateur_cadence(offensive_premier)
	v.vrai(dps_premier >= 1.20 and dps_premier <= 1.30,
		"les dix premiers rangs donnent un vrai gain sans devenir la campagne a eux seuls")

func test_l_arbre_entierement_pousse_reste_dans_son_budget(v: Verif) -> void:
	var offensive := _branche_au_rang("Offensif", ArbreCompetences.MAX_RANG)
	var dps := ArbreCompetences.multiplicateur_degats(offensive) \
		* ArbreCompetences.multiplicateur_cadence(offensive)
	v.vrai(dps >= 2.25 and dps <= 2.45,
		"la branche offensive maxee reste autour de x2,35")
	var defensive := _branche_au_rang("Défensif", ArbreCompetences.MAX_RANG)
	var survie := ArbreCompetences.multiplicateur_pv(defensive) \
		/ (1.0 - ArbreCompetences.reduction_degats(defensive))
	v.vrai(survie >= 2.05 and survie <= 2.30,
		"la branche defensive maxee garde un budget comparable")
	v.vrai(ArbreCompetences.reduction_degats(defensive) < 0.15,
		"la Maitrise defensive seule ne s'approche jamais de l'invulnerabilite")

# Le dernier chapitre appartient encore a la campagne : un compte totalement
# farme doit etre au-dessus de sa courbe, pas juste atteindre le minimum requis.
func test_le_maximum_permanent_est_overkill_sur_la_campagne(v: Verif) -> void:
	var offensive := _branche_au_rang("Offensif", ArbreCompetences.MAX_RANG)
	var equipements := {"anneau_gauche": "alambic_royal", "anneau_droit": "robe_grand_oeuvre",
		"collier": "pierre_philosophale"}
	var forge := {}
	for id in equipements.values():
		forge[id] = Reglages.FORGE_NIVEAU_MAX
	var bonus := CatalogueObjets.bonus_effectifs(equipements, forge, Chapitres.MONDES.size() - 1)
	var permanent := ArbreCompetences.multiplicateur_degats(offensive) \
		* ArbreCompetences.multiplicateur_cadence(offensive) \
		* (1.0 + float(bonus["degats"])) * (1.0 + float(bonus["cadence"]))
	var dernier := Chapitres.nombre() - 1
	v.vrai(permanent >= Chapitres.facteur_pv(dernier, 1) * 1.35,
		"le compte maxe commence le dernier chapitre nettement au-dessus de la courbe")
	# Deux choix simples de run suffisent deja a depasser le mur statistique de
	# la salle 20 : le reste du build devient du confort et de l'overkill.
	var base := Tir.de_base(Stats.depuis_reglages())
	var tire := Mods.appliquer(base, Mods.depuis_l_inventaire(["sceau_furie", "sceau_celerite"]))
	var facteur_run := (tire.degats / base.degats) * (tire.cadence / base.cadence)
	v.vrai(permanent * facteur_run > Chapitres.facteur_pv(dernier, Reglages.SALLES_PAR_RUN) * 1.15,
		"un compte maxe n'a pas besoin d'un build parfait pour ecraser la campagne")

func test_une_progression_incomplete_peut_finir_avec_un_bon_build(v: Verif) -> void:
	var offensive := _branche_au_rang("Offensif", 1)
	var anciens := CatalogueObjets.IDS_PAR_MONDE[0]
	var equipements := {"anneau_gauche": str(anciens[0]), "anneau_droit": str(anciens[1]),
		"collier": str(anciens[2])}
	var forge := {}
	for id in anciens:
		forge[str(id)] = 20
	var bonus := CatalogueObjets.bonus_effectifs(equipements, forge, Chapitres.MONDES.size() - 1)
	var permanent := ArbreCompetences.multiplicateur_degats(offensive) \
		* ArbreCompetences.multiplicateur_cadence(offensive) \
		* (1.0 + float(bonus["degats"])) * (1.0 + float(bonus["cadence"]))
	var base := Tir.de_base(Stats.depuis_reglages())
	var build := ["sceau_furie", "sceau_celerite", "frappe_lourde", "cadence_febrile", "salve"]
	var tire := Mods.appliquer(base, Mods.depuis_l_inventaire(build))
	var facteur_run := (tire.degats / base.degats) * (tire.cadence / base.cadence)
	if "rafale" in tire.drapeaux:
		facteur_run *= float(Reglages.RAFALE_NOMBRE)
	var dernier := Chapitres.nombre() - 1
	v.vrai(permanent * facteur_run > Chapitres.facteur_pv(dernier, Reglages.SALLES_PAR_RUN),
		"deux branches rang 1 et une Forge 20 peuvent finir la campagne avec un bon build")

func test_maitrises_et_capacites_sont_separees(v: Verif) -> void:
	for catalogue in [Sorts.ACTIFS, Sorts.PASSIFS, Sorts.ULTIMES]:
		for id in catalogue:
			v.vrai(not catalogue[id].has("requis"), "%s n'a aucune Maitrise prerequise" % id)
			v.vrai(not catalogue[id].has("niveau"), "%s ne depend pas du niveau de compte" % id)

func test_les_capacites_changent_les_regles_du_build(v: Verif) -> void:
	v.vrai(Sorts.donne_bouclier({"rempart_initial": 1}), "un Passif donne un bouclier au depart")
	v.presque(Sorts.multiplicateur_degats_conditionnel({"audace": 1}, 0.4),
		1.0 + Reglages.AUDACE_BONUS, "Audace ne renforce que le heros blesse")
	v.presque(Sorts.multiplicateur_degats_conditionnel({"audace": 1}, 0.8), 1.0,
		"Audace ne donne rien quand le heros va bien")

func test_l_epreuve_active_un_sort(v: Verif) -> void:
	var r: Node = load("res://autoload/reglages_joueur.gd").new()
	r.sauvegarde_active = false
	r.rangs_sorts = {"onde_alchimique": 0}
	v.vrai(not r.sort_decouvert("onde_alchimique"), "le premier sort reste cache au niveau un")
	r.meilleures_par_chapitre = {"0": Reglages.SALLES_PAR_RUN}
	v.vrai(r.sort_decouvert("onde_alchimique"), "le sort entre dans la pool au niveau deux")
	v.vrai(not r.sort_debloque("onde_alchimique"), "au rang zero il reste inutilisable")
	v.vrai(r.debloquer_sort("onde_alchimique"), "le premier loot active le sort")
	v.egal(r.rang_sort("onde_alchimique"), 1, "le premier exemplaire donne le rang un")
	for i in Reglages.CAPACITE_RANG_MAX - 1:
		v.vrai(r.debloquer_sort("onde_alchimique"), "un doublon ameliore encore le sort")
	v.egal(r.rang_sort("onde_alchimique"), Reglages.CAPACITE_RANG_MAX, "le sort respecte le rang maximal")
	v.presque(r.efficacite_sort("onde_alchimique"),
		1.0 + float(Reglages.CAPACITE_RANG_MAX - 1) * Reglages.CAPACITE_BONUS_PAR_RANG,
		"les doublons ameliorent la capacite sans multiplier sa puissance par cinq")
	v.vrai(not r.debloquer_sort("onde_alchimique"), "un exemplaire au-dela du rang maximal ne sert pas")
	r.free()

func test_les_deblocages_utilitaires_changent_les_regles(v: Verif) -> void:
	v.egal(ArbreCompetences.nombre_rerolls({"distillation": 1}), 1,
		"la Maitrise donne un nouveau tirage")
	v.vrai(ArbreCompetences.donne_second_passif({"savoir": 1}),
		"la Maitrise ouvre le second slot Passif")

func test_un_sort_actif_et_un_ultime_peuvent_etre_retires(v: Verif) -> void:
	var r: Node = load("res://autoload/reglages_joueur.gd").new()
	r.sauvegarde_active = false
	r.rangs_sorts = {"onde_alchimique": 1, "grand_oeuvre": 1}
	r.equiper_sort("onde_alchimique", "actif")
	r.equiper_sort("grand_oeuvre", "ultime")
	v.egal(r.sort_actif_effectif(), "onde_alchimique", "le Sort actif est equipe")
	v.egal(r.ultime_effectif(), "grand_oeuvre", "l'Ultime est equipe")
	v.vrai(r.retirer_sort("actif"), "le Sort actif peut etre retire")
	v.vrai(r.retirer_sort("ultime"), "l'Ultime peut etre retire")
	v.egal(r.sort_actif_effectif(), "", "le slot actif peut rester vide")
	v.egal(r.ultime_effectif(), "", "le slot Ultime peut rester vide")
	v.vrai(not r.retirer_sort("actif"), "retirer un slot deja vide ne fait rien")
	r.free()
