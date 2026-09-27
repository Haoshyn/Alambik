class_name CatalogueReactifs
extends RefCounted

# Chaque choix renforce les statistiques ou les tirs ordinaires du heros.
const PROJECTILE := "projectile"
const HEROS := "heros"
const SCEAU := "sceau"

const ICONES_COMMUNES := {
	"battement_triple": "salve",
	"couronne_incisive": "domination",
	"garde_remanente": "egide",
	"encre_mordante": "sceau_ruine",
	"noyau_pesant": "frappe_lourde",
	"pointe_lucide": "cadence",
	"peau_cuivre": "armure",
	"pas_brume": "elan_vital",
	"encrage_vif": "sceau_portee",
	"baume_profond": "regeneration",
}

static var TOUS := {
	"salve": Reactif.creer("salve", "Salve",
		"Une seconde salve, avec des projectiles moins puissants.",
		{"salves_add": 1, "degats_salve_mult": ReglagesAugments.MALUS_TIRS_MULT},
		Color(0.62, 0.86, 0.96), "triple_barre", 1, PROJECTILE, Reactif.RARE),
	"tir_multiple": Reactif.creer("tir_multiple", "Tir double",
		"Un projectile frontal parallèle supplémentaire. Chaque copie réduit les dégâts de tous les projectiles.",
		{"nb_projectiles_add": 1, "ecart_lateral_min": ReglagesAugments.TIR_DOUBLE_ECART,
			"degats_finaux_projectile_mult": ReglagesAugments.MALUS_TIRS_MULT},
		Color(0.98, 0.82, 0.42), "eventail", ReglagesAugments.COPIES_MAX, PROJECTILE, Reactif.RARE),
	"homing": Reactif.creer("homing", "Traque alchimique",
		"Les projectiles s'orientent vers les ennemis.",
		{"drapeaux": ["homing"]},
		Color(0.72, 0.88, 1.00), "oeil", 1, PROJECTILE, Reactif.RARE),
	"cadence_febrile": Reactif.creer("cadence_febrile", "Cadence fébrile",
		"Des attaques plus fréquentes.", {"cadence_mult": 1.20},
		Color(1.00, 0.88, 0.52), "triple_barre", ReglagesAugments.COPIES_MAX, PROJECTILE, Reactif.RARE),
	"avidite": Reactif.creer("avidite", "Avidité",
		"Davantage d'XP de la partie et de Gouttes.",
		{"experience_mult": 1.20, "gouttes_mult": 1.20},
		Color(1.00, 0.78, 0.30), "fiole", 1, HEROS, Reactif.RARE),
	"sceau_garde": Reactif.creer("sceau_garde", "Sceau de garde",
		"Réduit tous les dégâts reçus.",
		{"degats_subis_mult": 0.85},
		Color(0.62, 0.82, 1.00), "hexagone", 1, SCEAU, Reactif.RARE),
	"sceau_ruine": Reactif.creer("sceau_ruine", "Sceau de ruine",
		"Une attaque renforcée.",
		{"attaque_mult": 1.20},
		Color(0.80, 0.34, 0.86), "cristal", 1, SCEAU, Reactif.RARE),
	"pointe_lucide": Reactif.creer("pointe_lucide", "Pointe lucide",
		"Des critiques plus fréquents et plus puissants.",
		{"critique_add": 0.10, "degats_critiques_add": 0.15},
		Color("9edcea"), "oeil", ReglagesAugments.COPIES_MAX, HEROS, Reactif.RARE),
	"peau_cuivre": Reactif.creer("peau_cuivre", "Peau de cuivre",
		"Plus de défense et de vitalité.",
		{"defense_mult": 1.15, "pv_max_mult": 1.20},
		Color("d7b193"), "hexagone", ReglagesAugments.COPIES_MAX, HEROS, Reactif.RARE),
	"pas_brume": Reactif.creer("pas_brume", "Pas de brume",
		"Plus de mobilité et de répit après chaque coup reçu.",
		{"deplacement_mult": 1.20, "invulnerabilite_add": 0.20},
		Color("a3daca"), "sillage", ReglagesAugments.COPIES_MAX, HEROS, Reactif.RARE),
	"encrage_vif": Reactif.creer("encrage_vif", "Encrage vif",
		"Des projectiles plus rapides et une attaque renforcée.",
		{"attaque_mult": 1.10, "vitesse_mult": 1.20},
		Color("a6bff2"), "lance", ReglagesAugments.COPIES_MAX, PROJECTILE, Reactif.RARE),
	"baume_profond": Reactif.creer("baume_profond", "Baume profond",
		"Les soins rendent davantage de PV. La réserve de vie augmente sans soin immédiat.",
		{"soin_mult": 1.20, "pv_max_mult": 1.10},
		Color("a9dfa8"), "goutte", ReglagesAugments.COPIES_MAX, HEROS, Reactif.RARE),

	"ricochet": Reactif.creer("ricochet", "Ricochet",
		"Les projectiles rebondissent vers d'autres ennemis, en perdant de la puissance.",
		{"rebonds_add": 3},
		Color(0.62, 0.86, 0.96), "zigzag", 1, PROJECTILE, Reactif.EPIQUE),
	"perforation": Reactif.creer("perforation", "Perforation",
		"Les projectiles renforcés traversent tous les ennemis sans perte de puissance. Avec Ricochet, les rebonds deviennent illimités.",
		{"degats_projectile_mult": 1.15, "drapeaux": ["perfore_tout", "perforation_sans_perte"]},
		Color(0.86, 0.90, 0.98), "lance", 1, PROJECTILE, Reactif.EPIQUE),
	"spirale": Reactif.creer("spirale", "Éventail",
		"Deux tirs en diagonale supplémentaires couvrent les côtés, sans affaiblir le tir frontal.",
		{"nb_projectiles_add": 2, "projectiles_lateraux_add": 2, "angle_eventail_add": 0.55},
		Color(0.94, 0.78, 1.00), "eventail", ReglagesAugments.COPIES_MAX, PROJECTILE, Reactif.EPIQUE),
	"trait_transpercant": Reactif.creer("trait_transpercant", "Tir indélébile",
		"Les tirs accélèrent et poursuivent leur cible à travers les murs et les autres ennemis.",
		{"vitesse_mult": 1.20, "drapeaux": ["indelebile"]},
		Color(0.78, 0.94, 0.90), "lance", 1, PROJECTILE, Reactif.EPIQUE),
	"peau_de_pierre": Reactif.creer("peau_de_pierre", "Peau de pierre",
		"Plus de vitalité et des dégâts reçus réduits.",
		{"pv_max_mult": 1.25, "degats_subis_mult": 0.95},
		Color(0.68, 0.66, 0.60), "hexagone", 1, HEROS, Reactif.EPIQUE),
	"elan_vital": Reactif.creer("elan_vital", "Élan vital",
		"Se déplacer charge la prochaine attaque. Toutes ses salves bénéficient du bonus.",
		{"drapeaux": ["elan_vital"]},
		Color(0.56, 0.98, 0.86), "sillage", 1, HEROS, Reactif.EPIQUE),
	"garde_remanente": Reactif.creer("garde_remanente", "Garde rémanente",
		"Davantage de vitalité et un coup bloqué dans chaque salle.",
		{"pv_max_mult": 1.15, "boucliers_salle_add": 1},
		Color("b7caef"), "hexagone", 1, HEROS, Reactif.EPIQUE),
	"encre_mordante": Reactif.creer("encre_mordante", "Encre mordante",
		"Des projectiles plus puissants.",
		{"attaque_mult": 1.30},
		Color("abd98c"), "fiole", 1, PROJECTILE, Reactif.EPIQUE),
	"noyau_pesant": Reactif.creer("noyau_pesant", "Noyau pesant",
		"Une attaque plus forte.",
		{"attaque_mult": 1.35},
		Color("d5ac8b"), "masse", ReglagesAugments.COPIES_MAX, PROJECTILE, Reactif.EPIQUE),

	"frappe_lourde": Reactif.creer("frappe_lourde", "Force cataclysmique",
		"Un bonus majeur d'attaque. Les réductions propres aux tirs multiples restent actives.",
		{"attaque_mult": 1.75},
		Color(0.92, 0.60, 0.32), "masse", 1, PROJECTILE, Reactif.LEGENDAIRE),
	"egide": Reactif.creer("egide", "Égide souveraine",
		"Renforce les PV totaux, réduit les dégâts reçus et rend toute la vie à l'acquisition.",
		{"pv_max_final_mult": 1.50, "degats_subis_mult": 0.90, "drapeaux": ["egide"]},
		Color(0.88, 0.92, 1.00), "hexagone", 1, HEROS, Reactif.LEGENDAIRE),
	"courageux": Reactif.creer("courageux", "Courage indomptable",
		"Renforce l'attaque, la cadence, les PV et la défense. Une seconde vie complète par tentative.",
		{"attaque_mult": 1.10, "cadence_mult": 1.10, "pv_max_mult": 1.10, "defense_mult": 1.10, "drapeaux": ["courageux"]},
		Color(0.98, 0.42, 0.40), "flamme", 1, HEROS, Reactif.LEGENDAIRE),
	"battement_triple": Reactif.creer("battement_triple", "Battement triple",
		"Deux salves supplémentaires. Réduit les dégâts de tous les projectiles et conserve les réductions des autres augments.",
		{"salves_add": 2, "degats_salve_mult": ReglagesAugments.MALUS_TIRS_MULT},
		Color("ffce81"), "triple_barre", 1, PROJECTILE, Reactif.LEGENDAIRE),
	"couronne_incisive": Reactif.creer("couronne_incisive", "Couronne incisive",
		"Des critiques plus fréquents et plus puissants. Une part de la chance excédentaire devient des dégâts critiques.",
		{"critique_add": 0.35, "degats_critiques_add": 0.35, "conversion_critique": 0.25},
		Color("ffd98b"), "etoile", 1, HEROS, Reactif.LEGENDAIRE),

}

static func par_id(id: String) -> Reactif:
	return TOUS.get(id)

static func ids() -> Array[String]:
	var liste: Array[String] = []
	for id: String in TOUS:
		liste.append(id)
	liste.sort()
	return liste

static func ids_de_famille(famille: String) -> Array[String]:
	var liste: Array[String] = []
	for id in ids():
		if par_id(id).famille == famille:
			liste.append(id)
	return liste
