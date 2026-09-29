class_name ArbreCompetences
extends RefCounted

# Deux noeuds de statistiques a dix rangs, puis un pouvoir majeur a achat unique.
# Les rangs et les noeuds d'une meme statistique s'additionnent pour former
# le facteur des maitrises, applique entre l'equipement et les passifs.
const MAX_RANG := Reglages.MAITRISE_RANG_MAX
# Bareme de l'arbre v1 conserve par la refonte du 16 septembre 2026.
# Un remboursement historique ne doit pas changer avec les prix courants.
const ANCIENS_COUTS := [8, 12, 20, 35, 60, 100, 170, 280, 460, 760]
const ANCIEN_COUT_PAR_RANG := 1.35
const ATTAQUE_PAR_RANG_INITIALE := 0.04
const ATTAQUE_PAR_RANG_PUISSANCE := 0.025
const ATTAQUE_PAR_RANG_AVANCEE := 0.04
const CRITIQUE_PAR_RANG := 0.01
static var NOEUDS := {
	"force": {"nom": "Force maîtrisée", "description": "+%.0f %% d’attaque par rang" % (ATTAQUE_PAR_RANG_INITIALE * 100.0), "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_INITIALE, "cout": Reglages.MAITRISE_COUTS[0]},
	"cadence": {"nom": "Œil sûr", "description": "+%.0f point de chance critique par rang" % (CRITIQUE_PAR_RANG * 100.0), "categorie": "Offensif", "critique": CRITIQUE_PAR_RANG, "requis": "force", "cout": Reglages.MAITRISE_COUTS[1]},
	"precision": {"nom": "Frappe souveraine", "description": "+2 points de chance critique.", "categorie": "Offensif", "critique": 0.020, "requis": "cadence", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"puissance": {"nom": "Puissance", "description": ("+%.1f %% d’attaque par rang" % (ATTAQUE_PAR_RANG_PUISSANCE * 100.0)).replace(".", ","), "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_PUISSANCE, "requis": "precision", "cout": Reglages.MAITRISE_COUTS[3]},
	"rythme": {"nom": "Impact critique", "description": "+1 point de dégâts critiques par rang", "categorie": "Offensif", "degats_critiques": 0.010, "requis": "puissance", "cout": Reglages.MAITRISE_COUTS[4]},
	"catalyse": {"nom": "Catalyse absolue", "description": "+5 % d’attaque.", "categorie": "Offensif", "attaque": 0.050, "requis": "rythme", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"trajectoire": {"nom": "Maîtrise du trait", "description": "+%.0f %% d’attaque par rang" % (ATTAQUE_PAR_RANG_AVANCEE * 100.0), "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_AVANCEE, "requis": "catalyse", "cout": Reglages.MAITRISE_COUTS[6]},
	"tempete": {"nom": "Instinct critique", "description": "+%.0f point de chance critique par rang" % (CRITIQUE_PAR_RANG * 100.0), "categorie": "Offensif", "critique": CRITIQUE_PAR_RANG, "requis": "trajectoire", "cout": Reglages.MAITRISE_COUTS[7]},
	"domination": {"nom": "Domination", "description": "+7,5 % d’attaque.", "categorie": "Offensif", "attaque": 0.075, "requis": "tempete", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"grand_oeuvre": {"nom": "Grand Œuvre", "description": "+%.0f %% d’attaque par rang" % (ATTAQUE_PAR_RANG_AVANCEE * 100.0), "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_AVANCEE, "requis": "domination", "cout": Reglages.MAITRISE_COUTS[9]},
	"constitution": {"nom": "Constitution", "description": "+1,5 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.015, "cout": Reglages.MAITRISE_COUTS[0]},
	"armure": {"nom": "Défense", "description": "+2 % de Défense par rang", "categorie": "Défensif", "defense": 0.020, "requis": "constitution", "cout": Reglages.MAITRISE_COUTS[1]},
	"vitalite": {"nom": "Vitalité souveraine", "description": "+5 % PV maximum.", "categorie": "Défensif", "pv_mult": 0.050, "requis": "armure", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"rempart": {"nom": "Rempart vivant", "description": "+1,5 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.015, "requis": "vitalite", "cout": Reglages.MAITRISE_COUTS[3]},
	"robustesse": {"nom": "Robustesse", "description": "+2 % de Défense par rang", "categorie": "Défensif", "defense": 0.020, "requis": "rempart", "cout": Reglages.MAITRISE_COUTS[4]},
	"carapace": {"nom": "Carapace absolue", "description": "Réduit les dégâts reçus de 5 % avant la Défense.", "categorie": "Défensif", "reduction": 0.050, "requis": "robustesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"endurance": {"nom": "Endurance", "description": "+2 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.020, "requis": "carapace", "cout": Reglages.MAITRISE_COUTS[6]},
	"bastion": {"nom": "Bastion", "description": "+2,5 % de Défense par rang", "categorie": "Défensif", "defense": 0.025, "requis": "endurance", "cout": Reglages.MAITRISE_COUTS[7]},
	"colosse": {"nom": "Colosse", "description": "+10 % PV maximum.", "categorie": "Défensif", "pv_mult": 0.100, "requis": "bastion", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"immortel": {"nom": "Immortel", "description": "+2 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.020, "requis": "colosse", "cout": Reglages.MAITRISE_COUTS[9]},
	"celerite": {"nom": "Alchimie réparatrice", "description": "+1,5 % aux soins reçus par rang", "categorie": "Utilitaire", "soin": 0.015, "cout": Reglages.MAITRISE_COUTS[0]},
	"collecte": {"nom": "Prospection", "description": "+2 % de Butin par rang", "categorie": "Utilitaire", "collecte": 0.02, "requis": "celerite", "cout": Reglages.MAITRISE_COUTS[1]},
	"distillation": {"nom": "Distillation", "description": "+1 relance · Maximum : %d" % Reglages.RELANCES_MAX_PAR_RUN, "categorie": "Utilitaire", "rerolls": 1, "requis": "collecte", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"fortune": {"nom": "Catalyse pratique", "description": "+0,5 % d’attaque par rang", "categorie": "Utilitaire", "attaque": 0.005, "requis": "distillation", "cout": Reglages.MAITRISE_COUTS[3]},
	"sagesse": {"nom": "Étude", "description": "+3 % XP de compte par rang", "categorie": "Utilitaire", "experience": 0.03, "requis": "fortune", "cout": Reglages.MAITRISE_COUTS[4]},
	"abondance": {"nom": "Double récolte", "description": "+10 % de Butin et de pierres", "categorie": "Utilitaire", "collecte": 0.10, "pierres": 0.10, "requis": "sagesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"savoir": {"nom": "Geste précis", "description": "+0,5 % de cadence par rang", "categorie": "Utilitaire", "cadence": 0.005, "requis": "abondance", "cout": Reglages.MAITRISE_COUTS[6]},
	"elan": {"nom": "Veine profonde", "description": "+3 % de pierres par rang", "categorie": "Utilitaire", "pierres": 0.03, "requis": "savoir", "cout": Reglages.MAITRISE_COUTS[7]},
	"prescience": {"nom": "Prescience", "description": "+1 relance · Maximum : %d" % Reglages.RELANCES_MAX_PAR_RUN, "categorie": "Utilitaire", "rerolls": 1, "requis": "elan", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"philosophe": {"nom": "Abondance", "description": "+2 % de Butin et d’XP de compte par rang", "categorie": "Utilitaire", "collecte": 0.02, "experience": 0.02, "requis": "prescience", "cout": Reglages.MAITRISE_COUTS[9]},
}

const BRANCHES := {
	"Offensif": ["force", "cadence", "precision", "puissance", "rythme", "catalyse", "trajectoire", "tempete", "domination", "grand_oeuvre"],
	"Défensif": ["constitution", "armure", "vitalite", "rempart", "robustesse", "carapace", "endurance", "bastion", "colosse", "immortel"],
	"Utilitaire": ["celerite", "collecte", "distillation", "fortune", "sagesse", "abondance", "savoir", "elan", "prescience", "philosophe"],
}

static func rangs(id: String) -> int:
	return clampi(int(NOEUDS.get(id, {}).get("rangs", MAX_RANG)), 1, MAX_RANG)

# rang_acquis est le nombre de rangs deja payes : c'est le prochain achat qui
# est chiffre, pas celui qui vient d'etre fait.
static func cout(id: String, rang_acquis := 0) -> int:
	return Reglages.cout_maitrise(int(NOEUDS[id]["cout"]), maxi(0, rang_acquis))

static func ancien_cout(index_noeud: int, rang_acquis: int) -> int:
	return maxi(1, roundi(float(ANCIENS_COUTS[index_noeud]) * pow(ANCIEN_COUT_PAR_RANG, float(rang_acquis))))

static func cout_total(id: String) -> int:
	var total := 0
	for rang in rangs(id):
		total += cout(id, rang)
	return total

static func prerequis_atteint(id: String, rangs_joueur: Dictionary) -> bool:
	var noeud: Dictionary = NOEUDS.get(id, {})
	return not noeud.has("requis") or int(rangs_joueur.get(noeud["requis"], 0)) >= 1

static func _somme(rangs_joueur: Dictionary, champ: String) -> float:
	var total := 0.0
	for id in rangs_joueur:
		if not NOEUDS.has(id):
			continue
		var rang := clampi(int(rangs_joueur[id]), 0, rangs(id))
		total += poids_rang(rang) * float(NOEUDS[id].get(champ, 0.0))
	return total

static func description_effective(id: String) -> String:
	return str(NOEUDS[id]["description"])

const CHAMPS_LISIBLES := ["attaque", "pv_mult", "defense", "cadence", "critique",
	"degats_critiques", "projectile", "reduction", "vitesse",
	"soin", "collecte", "coffre", "experience", "pierres"]

const LIBELLES_BONUS := {
	"attaque": "d’attaque", "pv_mult": "de PV maximum", "defense": "de défense",
	"cadence": "de cadence", "critique": "de chance critique", "degats_critiques": "de dégâts critiques",
	"projectile": "de vitesse des projectiles",
	"reduction": "de dégâts reçus", "vitesse": "de vitesse",
	"soin": "aux soins", "collecte": "de butin",
	"coffre": "aux coffres", "experience": "d’XP de compte", "pierres": "de pierres",
}

static func _nombre(valeur: float) -> String:
	return String.num(valeur, 1).trim_suffix(".0").replace(".", ",")

# Ce qu'un noeud vaut a un rang donne, sans le prefixe « Rang N ». Sert a
# comparer l'etat actuel au rang suivant : une valeur « par rang » oblige sinon
# le joueur a faire la multiplication de tete avant de depenser ses Gouttes.
static func valeur_au_rang(id: String, rang: int) -> String:
	var noeud: Dictionary = NOEUDS.get(id, {})
	var acquis := clampi(rang, 0, rangs(id))
	var lignes: Array[String] = []
	for champ in CHAMPS_LISIBLES:
		if noeud.has(champ):
			lignes.append("%s%s %% %s" % ["−" if champ == "reduction" else "+",
				_nombre(poids_rang(acquis) * float(noeud[champ]) * 100.0), str(LIBELLES_BONUS[champ])])
	if not lignes.is_empty():
		return " · ".join(lignes)
	if noeud.has("rerolls"):
		var tirages := acquis * int(noeud["rerolls"])
		return "+%d relance%s (maximum %d au total)" % [tirages, "s" if tirages > 1 else "", Reglages.RELANCES_MAX_PAR_RUN]
	return "acquis" if acquis > 0 else "aucun"

static func resume_rang(id: String, rang: int) -> String:
	var acquis := clampi(rang, 0, rangs(id))
	if acquis <= 0:
		return "Aucun rang acquis"
	return "Rang %d : %s" % [acquis, valeur_au_rang(id, acquis)]

static func bonus_pv(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "pv")

static func multiplicateur_pv(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "pv_mult")

static func reduction_degats(rangs_joueur: Dictionary) -> float:
	return clampf(_somme(rangs_joueur, "reduction"), 0.0, 0.90)

static func multiplicateur_defense(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "defense")

static func bonus_critique(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "critique")

static func bonus_degats_critiques(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "degats_critiques")

static func multiplicateur_soin(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "soin")

static func soin_par_salle(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "soin_salle")

static func donne_bouclier(rangs_joueur: Dictionary) -> bool:
	return _somme(rangs_joueur, "bouclier") > 0.0

static func bonus_attaque(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "attaque")

static func multiplicateur_attaque(rangs_joueur: Dictionary) -> float:
	return 1.0 + bonus_attaque(rangs_joueur)

static func multiplicateur_cadence(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "cadence")

static func multiplicateur_projectile(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "projectile")

static func multiplicateur_vitesse(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "vitesse")

static func multiplicateur_collecte(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "collecte")

static func multiplicateur_experience(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "experience")

static func multiplicateur_coffre(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "coffre")

static func multiplicateur_pierres(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "pierres")

static func nombre_rerolls(rangs_joueur: Dictionary) -> int:
	return mini(Reglages.RELANCES_MAX_PAR_RUN, roundi(_somme(rangs_joueur, "rerolls")))

static func poids_rang(rang: int) -> float:
	return float(clampi(rang,0,MAX_RANG))
