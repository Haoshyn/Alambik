class_name CatalogueReactifs
extends RefCounted

# Les pouvoirs uniques se repartissent en 15 rares, 10 epiques et 5 legendaires.
const PROJECTILE := "projectile"
const HEROS := "heros"
const PHENOMENE := "phenomene"
const SCEAU := "sceau"
const AUGMENTS_SORTS := ["puissance_arcanique", "cycle_arcanique", "apotheose"]

# Reutiliser les illustrations du jeu pour les dosages simples.
const ICONES_COMMUNES := {
	"soin": "regeneration",
	"poudre_vive": "sceau_furie",
	"reserve_vitale": "regeneration",
	"puissance_arcanique": "sceau_furie",
	"cycle_arcanique": "sceau_celerite",
	"apotheose": "meteores",
}

static var TOUS := {
	"tir_multiple": Reactif.creer("tir_multiple", "Tir multiple",
		"Ajoute un projectile simultané à pleine puissance, sans affaiblir les autres tirs.",
		{"nb_projectiles_add": 1, "ecart_lateral_add": 30.0},
		Color(0.98, 0.82, 0.42), "eventail", 1, PROJECTILE, Reactif.EPIQUE),
	"salve": Reactif.creer("salve", "Salve souveraine",
		"Chaque attaque devient une rafale de trois tirs à pleine puissance.",
		{"drapeaux": ["rafale"]},
		Color(1.00, 0.72, 0.34), "triple_barre", 1, PROJECTILE, Reactif.LEGENDAIRE),
	"ricochet": Reactif.creer("ricochet", "Ricochet",
		"Attaque +75 %. Chaque projectile rebondit vers quatre autres ennemis, avec une perte de puissance à chaque rebond.",
		{"rebonds_add": 4, "attaque_mult": 1.75}, Color(0.62, 0.86, 0.96), "zigzag", 1, PROJECTILE, Reactif.EPIQUE),
	"perforation": Reactif.creer("perforation", "Perforation",
		"Attaque +80 %. Traverse trois ennemis supplémentaires ; chaque traversée réduit les dégâts suivants.",
		{"perforations_add": 3, "attaque_mult": 1.80}, Color(0.86, 0.90, 0.98), "lance", 1, PROJECTILE, Reactif.EPIQUE),
	"fragmentation": Reactif.creer("fragmentation", "Fragmentation",
		"Attaque +80 %. L’impact final libère quatre éclats vers les autres ennemis.",
		{"fragments_add": 4, "attaque_mult": 1.80}, Color(0.80, 0.96, 0.94), "eclats", 1, PROJECTILE, Reactif.EPIQUE),
	"homing": Reactif.creer("homing", "Traque alchimique",
		"Les projectiles recherchent leur cible. Attaque et portée +25 %, vitesse des projectiles +20 %.",
		{"drapeaux": ["homing"], "attaque_mult": 1.25, "portee_mult": 1.25, "vitesse_mult": 1.20},
		Color(0.72, 0.88, 1.00), "oeil", 1, PROJECTILE, Reactif.RARE),
	"frappe_lourde": Reactif.creer("frappe_lourde", "Frappe cataclysmique",
		"Attaque +250 %, cadence −15 %. Chaque trait traverse deux ennemis supplémentaires puis libère quatre éclats.",
		{"attaque_mult": 3.50, "cadence_mult": 0.85, "perforations_add": 2, "fragments_add": 4},
		Color(0.92, 0.60, 0.32), "masse", 1, PROJECTILE, Reactif.LEGENDAIRE),
	"cadence_febrile": Reactif.creer("cadence_febrile", "Cadence fébrile",
		"Cadence +50 %, au prix de 10 % de portée.",
		{"cadence_mult": 1.50, "portee_mult": 0.90},
		Color(1.00, 0.88, 0.52), "triple_barre", 1, PROJECTILE, Reactif.RARE),
	"spirale": Reactif.creer("spirale", "Spirale",
		"Ajoute deux projectiles latéraux guidés à pleine puissance pour concentrer l’éventail sur les ennemis.",
		{"nb_projectiles_add": 2, "projectiles_lateraux_add": 2, "angle_eventail_add": 0.55, "drapeaux": ["homing"]},
		Color(0.94, 0.78, 1.00), "eventail", 1, PROJECTILE, Reactif.EPIQUE),
	"trait_transpercant": Reactif.creer("trait_transpercant", "Trait transperçant",
		"Attaque +70 %, vitesse des projectiles +40 %. Traverse tous les ennemis, avec une perte de puissance à chaque traversée.",
		{"drapeaux": ["perfore_tout"], "attaque_mult": 1.70, "vitesse_mult": 1.40},
		Color(0.78, 0.94, 0.90), "lance", 1, PROJECTILE, Reactif.EPIQUE),

	"egide": Reactif.creer("egide", "Égide souveraine",
		"PV maximum +100 %. Annule la première attaque de chaque salle, réduit les dégâts subis et régénère les PV entre les salles.",
		{"pv_max_mult": 2.0, "drapeaux": ["egide", "sceau_garde", "regeneration"]},
		Color(0.88, 0.92, 1.00), "hexagone", 1, HEROS, Reactif.LEGENDAIRE),
	"regeneration": Reactif.creer("regeneration", "Régénération",
		"PV maximum +20 %. Récupère des PV entre les salles, dans le budget partagé des soins de combat.",
		{"drapeaux": ["regeneration"], "pv_max_mult": 1.20}, Color(0.54, 0.92, 0.62), "goutte", 1, HEROS, Reactif.RARE),
	"avidite": Reactif.creer("avidite", "Avidité",
		"Attaque +10 %. Augmente l’XP de run et les Gouttes obtenues pendant cette tentative.",
		{"drapeaux": ["avidite"], "attaque_mult": 1.10}, Color(1.00, 0.78, 0.30), "fiole", 1, HEROS, Reactif.RARE),
	"courageux": Reactif.creer("courageux", "Courage indomptable",
		"Attaque +75 %, cadence +30 %. Un bonus d’attaque supplémentaire grandit à mesure que les PV diminuent.",
		{"drapeaux": ["courageux"], "attaque_mult": 1.75, "cadence_mult": 1.30},
		Color(0.98, 0.42, 0.40), "flamme", 1, HEROS, Reactif.LEGENDAIRE),
	"mannequin": Reactif.creer("mannequin", "Mannequin",
		"Rester immobile assez longtemps augmente l’attaque et la cadence.",
		{"drapeaux": ["mannequin"]}, Color(0.82, 0.72, 0.54), "masse", 1, HEROS, Reactif.RARE),
	"peau_de_pierre": Reactif.creer("peau_de_pierre", "Peau de pierre",
		"PV maximum +40 %. Réduit fortement tous les dégâts subis, sans ralentir les attaques.",
		{"drapeaux": ["peau_de_pierre"], "pv_max_mult": 1.40},
		Color(0.68, 0.66, 0.60), "hexagone", 1, HEROS, Reactif.EPIQUE),
	"elan_vital": Reactif.creer("elan_vital", "Élan vital",
		"Cadence +15 %. Se déplacer augmente fortement l’attaque pendant deux secondes.",
		{"drapeaux": ["elan_vital"], "cadence_mult": 1.15}, Color(0.56, 0.98, 0.86), "sillage", 1, HEROS, Reactif.EPIQUE),
	"soif_de_sang": Reactif.creer("soif_de_sang", "Soif de sang",
		"PV maximum +20 %. Chaque élimination rend des PV, dans le budget partagé des soins de combat.",
		{"drapeaux": ["soif_de_sang"], "pv_max_mult": 1.20}, Color(0.94, 0.34, 0.44), "goutte", 1, HEROS, Reactif.RARE),

	"familier_tireur": Reactif.creer("familier_tireur", "Familier tireur",
		"Un familier à distance attaque automatiquement les ennemis.",
		{"drapeaux": ["familier_tireur"]}, Color(0.66, 0.86, 1.00), "oeil", 1, PHENOMENE, Reactif.RARE),
	"meteores": Reactif.creer("meteores", "Météores",
		"Attaque +25 %. Des impacts dévastateurs tombent régulièrement sur les ennemis et frappent une large zone.",
		{"drapeaux": ["meteores"], "attaque_mult": 1.25}, Color(1.00, 0.52, 0.28), "etoile", 1, PHENOMENE, Reactif.EPIQUE),
	"zone_heros": Reactif.creer("zone_heros", "Zone alchimique",
		"Une zone offensive entoure le héros et récompense le jeu à courte portée.",
		{"drapeaux": ["zone_heros"]}, Color(0.68, 0.94, 0.66), "hexagone", 1, PHENOMENE, Reactif.RARE),
	"familier_gardien": Reactif.creer("familier_gardien", "Familier gardien",
		"Un gardien de mêlée attaque, intercepte les menaces et revient après sa mort.",
		{"drapeaux": ["familier_gardien"]}, Color(0.78, 0.72, 0.94), "patte", 1, PHENOMENE, Reactif.RARE),
	"orbes_chargees": Reactif.creer("orbes_chargees", "Orbes chargées",
		"Des orbes s’accumulent puis partent avec la prochaine attaque.",
		{"drapeaux": ["orbes_chargees"]}, Color(0.94, 0.72, 1.00), "cristal", 1, PHENOMENE, Reactif.RARE),
	"chaine_alchimique": Reactif.creer("chaine_alchimique", "Chaîne alchimique",
		"Attaque +20 %. Un arc surpuissant frappe régulièrement jusqu’à cinq ennemis de proche en proche.",
		{"drapeaux": ["chaine_alchimique"], "attaque_mult": 1.20}, Color(0.60, 0.90, 1.00), "zigzag", 1, PHENOMENE, Reactif.EPIQUE),
	"onde_de_choc": Reactif.creer("onde_de_choc", "Onde de choc",
		"Une déflagration régulière frappe et repousse tout ce qui vous entoure.",
		{"drapeaux": ["onde_de_choc"]}, Color(0.86, 0.94, 1.00), "hexagone", 1, PHENOMENE, Reactif.RARE),

	"sceau_garde": Reactif.creer("sceau_garde", "Sceau de garde",
		"Grave une protection permanente contre les dégâts subis.",
		{"drapeaux": ["sceau_garde"]}, Color(0.62, 0.82, 1.00), "hexagone", 1, SCEAU, Reactif.RARE),
	"sceau_ruine": Reactif.creer("sceau_ruine", "Sceau de ruine",
		"Attaque +60 %, mais les dégâts subis augmentent.",
		{"attaque_mult": 1.60, "drapeaux": ["sceau_ruine"]},
		Color(0.80, 0.34, 0.86), "cristal", 1, SCEAU, Reactif.RARE),

	"puissance_arcanique": Reactif.creer("puissance_arcanique", "Puissance arcanique",
		"Attaque des sorts actifs et ultimes +50 %.", {"attaque_sorts_mult": 1.50},
		Color("8dc8eb"), "etoile", 1, PHENOMENE, Reactif.RARE),
	"cycle_arcanique": Reactif.creer("cycle_arcanique", "Cycle arcanique",
		"Sort actif et ultime : récupération réduite de 25 %.", {"recharge_sorts_mult": 0.75},
		Color("8dc8eb"), "sillage", 1, PHENOMENE, Reactif.RARE),
	"apotheose": Reactif.creer("apotheose", "Apothéose",
		"Sort actif et ultime : attaque +150 %, récupération −40 %. Rayon du sort actif +50 %.",
		{"attaque_sorts_mult": 2.50, "recharge_sorts_mult": 0.60, "rayon_sorts_mult": 1.50},
		Color("ffcb70"), "etoile", 1, PHENOMENE, Reactif.LEGENDAIRE),

	"soin": Reactif.creer("soin", "Soin immédiat",
		"Récupère 30 % des PV maximum.", {"soin_part": ProgressionAugments.SOIN_CHOIX},
		Color("71d9b4"), "goutte", ProgressionAugments.niveau_max(), HEROS, Reactif.COMMUN),
	"poudre_vive": Reactif.creer("poudre_vive", "Poudre vive",
		"Attaque +10 % pour cette aventure. Chaque choix donne le même bonus.",
		{"attaque_mult": 1.0 + ProgressionAugments.BONUS_COMMUN},
		Color(0.90, 0.64, 0.48), "flamme", ProgressionAugments.niveau_max(), PROJECTILE, Reactif.COMMUN),
	"reserve_vitale": Reactif.creer("reserve_vitale", "Réserve vitale",
		"PV maximum +10 % pour cette aventure, sans soin immédiat.",
		{"pv_max_mult": 1.0 + ProgressionAugments.BONUS_COMMUN},
		Color(0.55, 0.82, 0.64), "goutte", ProgressionAugments.niveau_max(), HEROS, Reactif.COMMUN),
}

# Ces anciens identifiants restent lisibles sans agrandir les offres de run.
static var HISTORIQUES := {
	"sceau_furie": Reactif.creer("sceau_furie", "Sceau de furie",
		"Attaque +20 % pour cette aventure.",
		{"attaque_mult": 1.20}, Color(1.00, 0.46, 0.36), "flamme", 1, SCEAU, Reactif.RARE),
	"sceau_celerite": Reactif.creer("sceau_celerite", "Sceau de célérité",
		"Accélère durablement les attaques de cette aventure.",
		{"cadence_mult": 1.15}, Color(0.98, 0.92, 0.48), "sillage", 1, SCEAU, Reactif.RARE),
	"sceau_portee": Reactif.creer("sceau_portee", "Sceau d’envergure",
		"Les tirs vont plus loin et plus vite.",
		{"portee_mult": 1.25, "vitesse_mult": 1.25}, Color(0.74, 0.90, 0.98), "lance", 1, SCEAU, Reactif.RARE),
}

static func par_id(id: String) -> Reactif:
	return TOUS.get(id, HISTORIQUES.get(id))

static func ids() -> Array[String]:
	var liste: Array[String] = []
	for id in TOUS:
		liste.append(id)
	liste.sort()
	return liste

static func ids_de_famille(famille: String) -> Array[String]:
	var liste: Array[String] = []
	for id in ids():
		if par_id(id).famille == famille:
			liste.append(id)
	return liste
