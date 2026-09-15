extends RefCounted

func test_un_palier_et_aucune_cadence(v: Verif) -> void:
	for id in CatalogueObjets.OBJETS:
		var parcours: Array = CatalogueObjets.OBJETS[id]["effets"]
		v.egal(parcours.size(),1,"un effet par bijou")
		for niveau in range(101):
			var actifs := CatalogueObjets.effets_objet(id,niveau)
			v.egal(actifs.size(),1 if niveau >= 10 else 0,"un pouvoir au niveau 10 uniquement")
			var bonus := CatalogueObjets.bonus_objet(id,niveau)
			v.vrai(float(bonus["degats"])>0.0 and float(bonus["pv"])>0.0,"degats et PV sur chaque objet")
			v.vrai(not bonus.has("cadence") and not bonus.has("collecte"),"uniquement degats et PV")
			var tir := Mods.appliquer(Tir.de_base(Stats.depuis_reglages()),Mods.depuis_l_inventaire(actifs))
			v.presque(tir.cadence,Reglages.HEROS_CADENCE,"les effets ne changent pas la cadence")
		for effet in parcours:
			v.vrai(CatalogueReactifs.par_id(effet)!=null,"effet branche au catalogue de combat")
		v.vrai(CatalogueObjets.description_effets(id,10).contains("Débloqué"),"effet acquis visible")
		v.vrai(CatalogueObjets.description_effets(id,9).contains("Verrouillé"),"effets futurs visibles")

func test_effets_portes_sans_polluer_le_draft(v: Verif) -> void:
	var id := "plume_encres"
	var inventaire := ["ricochet"]
	var actifs := CatalogueObjets.avec_effets(inventaire,{"anneau_gauche":id},{id:30})
	v.egal(actifs.count("ricochet"),1,"pas de pouvoir identique en double")
	v.vrai("familier_tireur" in actifs and "fragmentation" not in actifs,"seul le pouvoir unique est accorde")
	v.egal(inventaire,["ricochet"],"inventaire de run non modifie")
	for effet in actifs: v.vrai(effet not in DraftLogique.candidats(actifs),"pas de choix de draft inutile")
	v.egal(CatalogueObjets.effets_equipes({}, {id:30}),[],"un objet non porte n'accorde aucun effet")
	v.egal(CatalogueObjets.effets_equipes({"collier":id}, {id:30}),[],"un slot incompatible n'accorde rien")

func test_migration_preserve_les_investissements(v: Verif) -> void:
	var r: Node = load("res://autoload/reglages_joueur.gd").new()
	r.sauvegarde_active = false
	for ancien in range(61):
		r.version_forge = 1
		r.forge_niveaux = {"plume_encres":ancien}
		r._migrer_niveaux_forge()
		var niveau: int = r.forge_niveaux["plume_encres"]
		v.egal(niveau,ceili(float(ancien)/2),"deux anciens niveaux regroupes")
		var bonus := CatalogueObjets.bonus_objet("plume_encres",niveau,0)
		v.vrai(float(bonus["degats"])+0.00001 >= .50*pow(1.04,ancien),"aucune puissance investie perdue")
		r._migrer_niveaux_forge()
		v.egal(int(r.forge_niveaux["plume_encres"]),niveau,"migration appliquee une seule fois")
	r.free()
