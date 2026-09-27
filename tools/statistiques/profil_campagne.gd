extends RefCounted

# Cas reproductible, pas optimum d'achats. Les derniers modeles sont accordes
# et les anciennes forges ignorees : cette hypothese favorise la campagne seule.
const ATTRIBUTS := {"force": 25, "vitalite": 35, "agilite": 15, "intelligence": 20}
const MAITRISES := {
	"force": 10, "cadence": 5, "precision": 1, "puissance": 8, "rythme": 3,
	"catalyse": 1, "trajectoire": 3, "tempete": 1, "domination": 1, "grand_oeuvre": 1,
	"constitution": 10, "armure": 7, "vitalite": 1, "rempart": 8, "robustesse": 3,
	"carapace": 1, "endurance": 4, "bastion": 1, "colosse": 1, "immortel": 2,
	"celerite": 2, "collecte": 3, "distillation": 1, "fortune": 1, "sagesse": 3,
	"abondance": 1, "savoir": 1, "elan": 3,
}
const FORGES := {"arme": 10, "anneau": 8, "bracelet": 8, "collier": 5, "familier": 1}

static func construire() -> Dictionary:
	var ressources := budget()
	var bijoux := {}
	var forge_bijoux := {}
	for id: String in CatalogueObjets.IDS_PAR_MONDE[Chapitres.MONDES.size() - 1]:
		var objet: Dictionary = CatalogueObjets.OBJETS[id]
		var slot := str(objet["slot"])
		bijoux[slot] = id
		forge_bijoux[id] = int(FORGES[slot])
	return {"arme": "royal", "forge_arme": int(FORGES["arme"]),
		"familier": "golem", "forge_familier": int(FORGES["familier"]),
		"bijoux": bijoux, "forge_bijoux": forge_bijoux,
		"niveau": int(ressources["niveau"]), "attributs": ATTRIBUTS.duplicate(),
		"maitrises": MAITRISES.duplicate(), "passifs": {}, "coeurs": 0, "conditions": false}

static func budget() -> Dictionary:
	var gouttes_min := 0
	var gouttes_max := 0
	var pierres := 0
	var xp := 0
	var victoires := maxi(0, Chapitres.nombre() - 1)
	# Le butin de base suffit a payer ces achats : aucun bonus economique,
	# elite, echec ou repetition ne finance artificiellement la comparaison.
	for chapitre in victoires:
		var donnees: Dictionary = Chapitres.par_index(chapitre)
		var boss: Array = donnees["bosses"]
		var offre := ButinsRun.offre("grimoire", chapitre, Chapitres.salles(chapitre),
			boss.size(), true, 1, {}, [], 0)
		gouttes_min += int(offre["gouttes_min"])
		gouttes_max += int(offre["gouttes_max"])
		pierres += int(offre["pierres"])
		xp += int(offre["xp"])
	var niveau := 1
	var xp_restante := xp
	while niveau < Personnage.NIVEAU_MAX:
		var requis := Reglages.experience_compte_requise(niveau)
		if xp_restante < requis:
			break
		xp_restante -= requis
		niveau += 1
	if niveau >= Personnage.NIVEAU_MAX:
		xp_restante = 0
	var cout_maitrises := 0
	for id: String in MAITRISES:
		for rang in int(MAITRISES[id]):
			cout_maitrises += ArbreCompetences.cout(id, rang)
	var cout_forge := 0
	for slot: String in FORGES:
		for rang in int(FORGES[slot]):
			cout_forge += Reglages.cout_forge(rang)
	return {"chapitres_vaincus": victoires, "gouttes_min": gouttes_min,
		"gouttes_max": gouttes_max, "pierres": pierres, "xp": xp,
		"niveau": niveau, "xp_restante": xp_restante,
		"points_attributs": Personnage.points_totaux(niveau),
		"cout_maitrises": cout_maitrises, "cout_forge": cout_forge}
