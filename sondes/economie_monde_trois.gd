extends RefCounted

# Un achat peut inclure ses prerequis : les petits noeuds de cadence ne bloquent
# pas artificiellement l'acces a un pouvoir majeur pourtant rentable.
static func _lot(id: String, rangs: Dictionary) -> Array[String]:
	var resultat: Array[String] = []
	var requis := str(ArbreCompetences.NOEUDS[id].get("requis",""))
	if not requis.is_empty() and int(rangs.get(requis,0)) == 0:
		resultat.append_array(_lot(requis,rangs))
	resultat.append(id)
	return resultat

static func _puissance(rangs: Dictionary, poids_defense: float) -> float:
	var attaque := ArbreCompetences.multiplicateur_degats(rangs)*ArbreCompetences.multiplicateur_cadence(rangs)
	var defense := ArbreCompetences.multiplicateur_pv(rangs)/(1.0-ArbreCompetences.reduction_degats(rangs))
	return log(attaque)+poids_defense*log(defense)

static func acheter(rangs: Dictionary, solde: int, poids_defense: float) -> int:
	# Trois rangs de recolte representent un petit investissement economique explicite.
	while int(rangs.get("celerite",0)) < 3:
		var cout := ArbreCompetences.cout("celerite",int(rangs.get("celerite",0)))
		if solde < cout: return solde
		solde -= cout
		rangs["celerite"] = int(rangs.get("celerite",0))+1
	while true:
		var meilleur: Array[String] = []
		var meilleur_gain := 0.0
		var meilleur_cout := 0
		for id: String in ArbreCompetences.NOEUDS:
			if ArbreCompetences.NOEUDS[id]["categorie"] == "Utilitaire": continue
			if int(rangs.get(id,0)) >= ArbreCompetences.rangs(id): continue
			var lot := _lot(id,rangs)
			var essai := rangs.duplicate()
			var cout := 0
			for achat in lot:
				cout += ArbreCompetences.cout(achat,int(essai.get(achat,0)))
				essai[achat] = int(essai.get(achat,0))+1
			if cout > solde: continue
			var gain := (_puissance(essai,poids_defense)-_puissance(rangs,poids_defense))/float(cout)
			if gain > meilleur_gain:
				meilleur = lot
				meilleur_gain = gain
				meilleur_cout = cout
		if meilleur.is_empty(): break
		solde -= meilleur_cout
		for id in meilleur: rangs[id] = int(rangs.get(id,0))+1
	return solde

static func simuler(repetitions: int, graine: int, poids_defense := 1.0, chapitres := 6) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var objets: Array[String] = []
	var rangs := {}
	var sorts := {}
	var solde := 0
	var revenus := 0
	for chapitre in chapitres:
		var echecs := 0
		for passage in repetitions:
			var offre := ButinsRun.offre("grimoire",chapitre,20,4,true,1,sorts,objets,echecs)
			var butin := ButinsRun.tirer(offre,rng)
			var gain := roundi(float(butin["gouttes"])*ArbreCompetences.multiplicateur_coffre(rangs))
			gain = roundi(float(gain)*ArbreCompetences.multiplicateur_collecte(rangs))
			revenus += gain
			solde += gain
			var objet := str(butin["objet"])
			if not objet.is_empty():
				objets.append(objet)
				echecs = 0
			elif not (offre["objets"] as Array).is_empty(): echecs += 1
			for cadeau in butin["cadeaux"]: sorts[str(cadeau)] = 1
			solde = acheter(rangs,solde,poids_defense)
	var meilleur := -INF
	var equipe := {}
	# Au plus neuf objets : enumerer les slots evite de supposer le set toujours complet.
	var candidats := objets.duplicate()
	candidats.append("")
	for gauche in candidats:
		if not gauche.is_empty() and not CatalogueObjets.compatible("anneau_gauche",gauche): continue
		for droit in candidats:
			if not droit.is_empty() and (droit == gauche or not CatalogueObjets.compatible("anneau_droit",droit)): continue
			for collier in candidats:
				if not collier.is_empty() and not CatalogueObjets.compatible("collier",collier): continue
				var proposition := {"anneau_gauche":gauche,"anneau_droit":droit,"collier":collier}
				var bonus := CatalogueObjets.bonus_effectifs(proposition,{})
				var score := log(1.0+float(bonus["degats"]))+poids_defense*log(1.0+float(bonus["pv"]))
				if score > meilleur:
					meilleur = score
					equipe = proposition
	var stats := Stats.depuis_reglages(rangs,{},CatalogueObjets.bonus_effectifs(equipe,{}))
	var arme: String = CatalogueProjectiles.disponibles(chapitres+1).back()
	var tir := CatalogueProjectiles.appliquer(arme,Tir.de_base(stats))
	return {"revenus":revenus,"solde":solde,"depenses":revenus-solde,"rangs":rangs,"objets":objets,
		"equipements":equipe,"sorts":sorts,"forge":{},"arme":arme,"pv":stats.pv_max,
		"resistance":stats.pv_max/(1.0-ArbreCompetences.reduction_degats(rangs)),
		"degats":tir.degats,"dps":tir.degats*tir.cadence*tir.nb_projectiles,"cadence":tir.cadence}
