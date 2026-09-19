class_name CatalogueReactifs
extends RefCounted

# Les Elements et les anciennes fusions restent separes du tirage de run.
# Commun : soutien cumulable. Rare : specialisation. Legendaire : regle de jeu.
const PROJECTILE := "projectile"
const HEROS := "heros"
const PHENOMENE := "phenomene"
const SCEAU := "sceau"

# Reutiliser les illustrations du jeu pour les dosages simples.
const ICONES_COMMUNES := {
	"poudre_vive": "sceau_furie",
	"catalyse_fine": "sceau_celerite",
	"reserve_vitale": "regeneration",
	"pas_leger": "elan_vital",
	"verre_longue_vue": "sceau_portee",
	"flux_stable": "homing",
	"dosage_equilibre": "avidite",
	"fiole_tonique": "soif_de_sang",
}

static var TOUS := {
	"tir_multiple": Reactif.creer("tir_multiple", "Tir multiple",
		"Ajoute un projectile simultané. Chaque trait conserve 70 % de ses dégâts.",
		{"nb_projectiles_add": 1, "ecart_lateral_add": 30.0, "degats_mult": 0.70},
		false, Color(0.98, 0.82, 0.42), "eventail", 1, PROJECTILE),
	"salve": Reactif.creer("salve", "Salve",
		"Chaque attaque devient deux tirs rapides à 68 % de leurs dégâts chacun.",
		{"drapeaux": ["rafale"], "degats_mult": 0.68},
		false, Color(1.00, 0.72, 0.34), "triple_barre", 1, PROJECTILE),
	"ricochet": Reactif.creer("ricochet", "Ricochet",
		"Chaque projectile peut rebondir vers deux autres ennemis, avec une perte de puissance à chaque rebond.",
		{"rebonds_add": 2}, false, Color(0.62, 0.86, 0.96), "zigzag", 1, PROJECTILE),
	"perforation": Reactif.creer("perforation", "Perforation",
		"Traverse jusqu’à trois ennemis supplémentaires et renforce l’impact initial.",
		{"perforations_add": 3, "degats_mult": 1.12}, false, Color(0.86, 0.90, 0.98), "lance", 1, PROJECTILE),
	"fragmentation": Reactif.creer("fragmentation", "Fragmentation",
		"L’impact final libère trois éclats vers les autres ennemis, sans affaiblir le tir principal.",
		{"fragments_add": 3}, false, Color(0.80, 0.96, 0.94), "eclats", 1, PROJECTILE),
	"homing": Reactif.creer("homing", "Homing",
		"Les projectiles recherchent leur cible et gagnent un peu de puissance.",
		{"drapeaux": ["homing"], "degats_mult": 1.10}, false, Color(0.72, 0.88, 1.00), "oeil", 1, PROJECTILE, Reactif.RARE),
	"frappe_lourde": Reactif.creer("frappe_lourde", "Frappe lourde",
		"Double les dégâts de chaque impact, au prix de 30 % de cadence.",
		{"degats_mult": 2.0, "cadence_mult": 0.70},
		false, Color(0.92, 0.60, 0.32), "masse", 1, PROJECTILE),
	"cadence_febrile": Reactif.creer("cadence_febrile", "Cadence fébrile",
		"Les attaques s’enchaînent plus vite, au prix d’une portée réduite.",
		{"cadence_mult": 1.38, "portee_mult": 0.82},
		false, Color(1.00, 0.88, 0.52), "triple_barre", 1, PROJECTILE),
	"spirale": Reactif.creer("spirale", "Spirale",
		"Les attaques s’ouvrent en large éventail de trois projectiles plus légers.",
		{"nb_projectiles_add": 2, "projectiles_lateraux_add": 2, "angle_eventail_add": 0.55, "degats_mult": 0.58},
		false, Color(0.94, 0.78, 1.00), "eventail", 1, PROJECTILE),
	"trait_transpercant": Reactif.creer("trait_transpercant", "Trait transperçant",
		"Traverse tous les ennemis et accélère les projectiles ; les impacts successifs perdent de la puissance.",
		{"drapeaux": ["perfore_tout"], "vitesse_mult": 1.05},
		false, Color(0.78, 0.94, 0.90), "lance", 1, PROJECTILE),

	"egide": Reactif.creer("egide", "Égide",
		"Annule la première attaque subie dans chaque salle.",
		{"drapeaux": ["egide"]}, false, Color(0.88, 0.92, 1.00), "hexagone", 1, HEROS),
	"regeneration": Reactif.creer("regeneration", "Régénération",
		"Récupère 2 % des PV entre les salles, dans le budget partagé des soins de combat.",
		{"drapeaux": ["regeneration"]}, false, Color(0.54, 0.92, 0.62), "goutte", 1, HEROS, Reactif.RARE),
	"avidite": Reactif.creer("avidite", "Avidité",
		"Augmente l’XP de run et les Gouttes obtenues pendant cette tentative.",
		{"drapeaux": ["avidite"]}, false, Color(1.00, 0.78, 0.30), "fiole", 1, HEROS, Reactif.RARE),
	"courageux": Reactif.creer("courageux", "Courageux",
		"Les dégâts augmentent progressivement à mesure que les PV diminuent.",
		{"drapeaux": ["courageux"]}, false, Color(0.98, 0.42, 0.40), "flamme", 1, HEROS),
	"mannequin": Reactif.creer("mannequin", "Mannequin",
		"Rester immobile assez longtemps augmente la puissance et la cadence.",
		{"drapeaux": ["mannequin"]}, false, Color(0.82, 0.72, 0.54), "masse", 1, HEROS),
	"peau_de_pierre": Reactif.creer("peau_de_pierre", "Peau de pierre",
		"Réduit fortement les dégâts subis, au prix d’un peu de cadence.",
		{"drapeaux": ["peau_de_pierre"], "cadence_mult": 0.92},
		false, Color(0.68, 0.66, 0.60), "hexagone", 1, HEROS),
	"elan_vital": Reactif.creer("elan_vital", "Élan vital",
		"Se déplacer augmente fortement la puissance des attaques suivantes.",
		{"drapeaux": ["elan_vital"]}, false, Color(0.56, 0.98, 0.86), "sillage", 1, HEROS),
	"soif_de_sang": Reactif.creer("soif_de_sang", "Soif de sang",
		"Chaque élimination rend des PV, dans le budget partagé des soins de combat.",
		{"drapeaux": ["soif_de_sang"]}, false, Color(0.94, 0.34, 0.44), "goutte", 1, HEROS, Reactif.RARE),

	"familier_tireur": Reactif.creer("familier_tireur", "Familier tireur",
		"Un familier à distance attaque automatiquement les ennemis.",
		{"drapeaux": ["familier_tireur"]}, false, Color(0.66, 0.86, 1.00), "oeil", 1, PHENOMENE),
	"meteores": Reactif.creer("meteores", "Météores",
		"Un impact de zone puissant tombe périodiquement sur un ennemi.",
		{"drapeaux": ["meteores"]}, false, Color(1.00, 0.52, 0.28), "etoile", 1, PHENOMENE),
	"zone_heros": Reactif.creer("zone_heros", "Zone alchimique",
		"Une zone offensive entoure le héros et récompense le jeu à courte portée.",
		{"drapeaux": ["zone_heros"]}, false, Color(0.68, 0.94, 0.66), "hexagone", 1, PHENOMENE),
	"familier_gardien": Reactif.creer("familier_gardien", "Familier gardien",
		"Un gardien de mêlée attaque, intercepte les menaces et revient après sa mort.",
		{"drapeaux": ["familier_gardien"]}, false, Color(0.78, 0.72, 0.94), "patte", 1, PHENOMENE),
	"orbes_chargees": Reactif.creer("orbes_chargees", "Orbes chargées",
		"Des orbes s’accumulent pendant le mouvement puis partent avec la prochaine attaque.",
		{"drapeaux": ["orbes_chargees"]}, false, Color(0.94, 0.72, 1.00), "cristal", 1, PHENOMENE),
	"chaine_alchimique": Reactif.creer("chaine_alchimique", "Chaîne alchimique",
		"Un arc frappe régulièrement plusieurs ennemis de proche en proche.",
		{"drapeaux": ["chaine_alchimique"]}, false, Color(0.60, 0.90, 1.00), "zigzag", 1, PHENOMENE),
	"onde_de_choc": Reactif.creer("onde_de_choc", "Onde de choc",
		"Une déflagration régulière frappe et repousse tout ce qui vous entoure.",
		{"drapeaux": ["onde_de_choc"]}, false, Color(0.86, 0.94, 1.00), "hexagone", 1, PHENOMENE),

	"sceau_furie": Reactif.creer("sceau_furie", "Sceau de furie",
		"Renforce durablement les dégâts de cette aventure.",
		{"degats_mult": 1.20}, false, Color(1.00, 0.46, 0.36), "flamme", 1, SCEAU, Reactif.RARE),
	"sceau_celerite": Reactif.creer("sceau_celerite", "Sceau de célérité",
		"Accélère durablement les attaques de cette aventure.",
		{"cadence_mult": 1.18}, false, Color(0.98, 0.92, 0.48), "sillage", 1, SCEAU, Reactif.RARE),
	"sceau_garde": Reactif.creer("sceau_garde", "Sceau de garde",
		"Grave une protection permanente contre les dégâts subis.",
		{"drapeaux": ["sceau_garde"]}, false, Color(0.62, 0.82, 1.00), "hexagone", 1, SCEAU, Reactif.RARE),
	"sceau_portee": Reactif.creer("sceau_portee", "Sceau d’envergure",
		"Les tirs vont plus loin et plus vite.",
		{"portee_mult": 1.35, "vitesse_mult": 1.20}, false, Color(0.74, 0.90, 0.98), "lance", 1, SCEAU, Reactif.RARE),
	"sceau_ruine": Reactif.creer("sceau_ruine", "Sceau de ruine",
		"Beaucoup de puissance, mais les dégâts subis augmentent.",
		{"degats_mult": 1.40, "drapeaux": ["sceau_ruine"]},
		false, Color(0.80, 0.34, 0.86), "cristal", 1, SCEAU, Reactif.RARE),

	"poudre_vive": Reactif.creer("poudre_vive", "Poudre vive",
		"Renforce légèrement chaque impact.", {"degats_mult": 1.08},
		false, Color(0.90, 0.64, 0.48), "flamme", 5, PROJECTILE, Reactif.COMMUN),
	"catalyse_fine": Reactif.creer("catalyse_fine", "Catalyse fine",
		"Accélère légèrement les attaques.", {"cadence_mult": 1.06},
		false, Color(0.88, 0.82, 0.52), "triple_barre", 5, PROJECTILE, Reactif.COMMUN),
	"reserve_vitale": Reactif.creer("reserve_vitale", "Réserve vitale",
		"Augmente les PV maximum, sans soin supplémentaire immédiat.", {"pv_max_mult": 1.06},
		false, Color(0.55, 0.82, 0.64), "goutte", 5, HEROS, Reactif.COMMUN),
	"pas_leger": Reactif.creer("pas_leger", "Pas léger",
		"Facilite les déplacements et les esquives.", {"deplacement_mult": 1.04},
		false, Color(0.63, 0.82, 0.79), "sillage", 5, HEROS, Reactif.COMMUN),
	"verre_longue_vue": Reactif.creer("verre_longue_vue", "Verre de longue-vue",
		"Allonge la portée des projectiles.", {"portee_mult": 1.12},
		false, Color(0.63, 0.78, 0.88), "lance", 5, PROJECTILE, Reactif.COMMUN),
	"flux_stable": Reactif.creer("flux_stable", "Flux stable",
		"Accélère les projectiles pour mieux atteindre les cibles mobiles.", {"vitesse_mult": 1.12},
		false, Color(0.64, 0.80, 0.85), "oeil", 5, PROJECTILE, Reactif.COMMUN),
	"dosage_equilibre": Reactif.creer("dosage_equilibre", "Dosage équilibré",
		"Un peu de puissance et de cadence à la fois.", {"degats_mult": 1.04, "cadence_mult": 1.03},
		false, Color(0.82, 0.72, 0.58), "fiole", 5, SCEAU, Reactif.COMMUN),
	"fiole_tonique": Reactif.creer("fiole_tonique", "Fiole tonique",
		"Un peu de réserve vitale et de mobilité, sans soin supplémentaire immédiat.",
		{"pv_max_mult": 1.03, "deplacement_mult": 1.02},
		false, Color(0.57, 0.84, 0.73), "goutte", 5, HEROS, Reactif.COMMUN),
}

static func par_id(id: String) -> Reactif:
	return TOUS.get(id)

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
