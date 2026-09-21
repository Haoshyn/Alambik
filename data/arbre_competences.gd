class_name ArbreCompetences
extends RefCounted

# Deux noeuds de statistiques a dix rangs, puis un pouvoir majeur a achat unique.
# Les rangs et les noeuds d'une meme statistique s'additionnent : acheter un
# majeur ne multiplie pas de nouveau tous les investissements precedents.
const MAX_RANG := Reglages.MAITRISE_RANG_MAX
# Bareme de l'arbre v1 conserve par la refonte du 16 septembre 2026.
# Un remboursement historique ne doit pas changer avec les prix courants.
const ANCIENS_COUTS := [8, 12, 20, 35, 60, 100, 170, 280, 460, 760]
const ANCIEN_COUT_PAR_RANG := 1.35
const NOEUDS := {
	"force": {"nom": "Force maîtrisée", "description": "+10 % d’attaque par rang", "categorie": "Offensif", "attaque": 0.10, "cout": Reglages.MAITRISE_COUTS[0]},
	"cadence": {"nom": "Œil sûr", "description": "+1,5 % de chance critique par rang", "categorie": "Offensif", "critique": 0.015, "requis": "force", "cout": Reglages.MAITRISE_COUTS[1]},
	"precision": {"nom": "Frappe souveraine", "description": "+10 % de chance critique.", "categorie": "Offensif", "critique": 0.10, "requis": "cadence", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"puissance": {"nom": "Puissance", "description": "+20 % d’attaque par rang", "categorie": "Offensif", "attaque": 0.20, "requis": "precision", "cout": Reglages.MAITRISE_COUTS[3]},
	"rythme": {"nom": "Impact critique", "description": "+5 % de dégâts critiques par rang", "categorie": "Offensif", "degats_critiques": 0.05, "requis": "puissance", "cout": Reglages.MAITRISE_COUTS[4]},
	"catalyse": {"nom": "Catalyse absolue", "description": "+50 % d’attaque.", "categorie": "Offensif", "attaque": 0.5, "requis": "rythme", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"trajectoire": {"nom": "Maîtrise du trait", "description": "+30 % d’attaque par rang", "categorie": "Offensif", "attaque": 0.30, "requis": "catalyse", "cout": Reglages.MAITRISE_COUTS[6]},
	"tempete": {"nom": "Instinct critique", "description": "+2,5 % de chance critique par rang", "categorie": "Offensif", "critique": 0.025, "requis": "trajectoire", "cout": Reglages.MAITRISE_COUTS[7]},
	"domination": {"nom": "Domination", "description": "+75 % d’attaque.", "categorie": "Offensif", "attaque": 0.75, "requis": "tempete", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"grand_oeuvre": {"nom": "Grand Œuvre", "description": "+32,5 % d’attaque par rang", "categorie": "Offensif", "attaque": 0.325, "requis": "domination", "cout": Reglages.MAITRISE_COUTS[9]},
	"constitution": {"nom": "Constitution", "description": "+10 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.10, "cout": Reglages.MAITRISE_COUTS[0]},
	"armure": {"nom": "Défense", "description": "+10 % de Défense par rang", "categorie": "Défensif", "defense": 0.10, "requis": "constitution", "cout": Reglages.MAITRISE_COUTS[1]},
	"vitalite": {"nom": "Vitalité souveraine", "description": "+50 % PV maximum.", "categorie": "Défensif", "pv_mult": 0.50, "requis": "armure", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"rempart": {"nom": "Rempart vivant", "description": "+20 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.20, "requis": "vitalite", "cout": Reglages.MAITRISE_COUTS[3]},
	"robustesse": {"nom": "Robustesse", "description": "+20 % de Défense par rang", "categorie": "Défensif", "defense": 0.20, "requis": "rempart", "cout": Reglages.MAITRISE_COUTS[4]},
	"carapace": {"nom": "Carapace absolue", "description": "Réduit les dégâts reçus de 25 % avant la Défense.", "categorie": "Défensif", "reduction": 0.25, "requis": "robustesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"endurance": {"nom": "Endurance", "description": "+30 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.30, "requis": "carapace", "cout": Reglages.MAITRISE_COUTS[6]},
	"bastion": {"nom": "Bastion", "description": "+30 % de Défense par rang", "categorie": "Défensif", "defense": 0.30, "requis": "endurance", "cout": Reglages.MAITRISE_COUTS[7]},
	"colosse": {"nom": "Colosse", "description": "+100 % PV maximum.", "categorie": "Défensif", "pv_mult": 1.0, "requis": "bastion", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"immortel": {"nom": "Immortel", "description": "+30 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.30, "requis": "colosse", "cout": Reglages.MAITRISE_COUTS[9]},
	"celerite": {"nom": "Alchimie réparatrice", "description": "+5 % aux soins reçus par rang", "categorie": "Utilitaire", "soin": 0.05, "cout": Reglages.MAITRISE_COUTS[0]},
	"collecte": {"nom": "Prospection", "description": "+5 % de Butin par rang", "categorie": "Utilitaire", "collecte": 0.05, "requis": "celerite", "cout": Reglages.MAITRISE_COUTS[1]},
	"distillation": {"nom": "Distillation", "description": "+1 relance d’augmentations par aventure, dans la limite de %d au total, toutes sources confondues." % Reglages.RELANCES_MAX_PAR_RUN, "categorie": "Utilitaire", "rerolls": 1, "requis": "collecte", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"fortune": {"nom": "Puissance magique", "description": "+5 % de dégâts des sorts par rang", "categorie": "Utilitaire", "degats_sorts": 0.05, "requis": "distillation", "cout": Reglages.MAITRISE_COUTS[3]},
	"sagesse": {"nom": "Étude", "description": "+5 % XP de compte par rang", "categorie": "Utilitaire", "experience": 0.05, "requis": "fortune", "cout": Reglages.MAITRISE_COUTS[4]},
	"abondance": {"nom": "Double discipline", "description": "Permet d’équiper un second Passif.", "categorie": "Utilitaire", "second_passif": true, "requis": "sagesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"savoir": {"nom": "Cycle arcanique", "description": "Récupération des sorts −2 % par rang", "categorie": "Utilitaire", "recharge": 0.02, "requis": "abondance", "cout": Reglages.MAITRISE_COUTS[6]},
	"elan": {"nom": "Expansion rituelle", "description": "+3 % de rayon des sorts par rang", "categorie": "Utilitaire", "rayon_sorts": 0.03, "requis": "savoir", "cout": Reglages.MAITRISE_COUTS[7]},
	"prescience": {"nom": "Prescience", "description": "+1 relance d’augmentations par aventure, dans la limite de %d au total, toutes sources confondues." % Reglages.RELANCES_MAX_PAR_RUN, "categorie": "Utilitaire", "rerolls": 1, "requis": "elan", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"philosophe": {"nom": "Abondance", "description": "+5 % de Butin et d’XP de compte par rang", "categorie": "Utilitaire", "collecte": 0.05, "experience": 0.05, "requis": "prescience", "cout": Reglages.MAITRISE_COUTS[9]},
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
	var description := str(NOEUDS[id]["description"]) + (" Pouvoir majeur · achat unique." if rangs(id)==1 else " Dix rangs à plein effet.")
	if NOEUDS[id].has("attaque"):
		description += " S’ajoute aux bonus d’attaque sur votre attaque de base, avant les dégâts finaux."
	elif NOEUDS[id].has("pv_mult"):
		description += " S’ajoute aux autres maîtrises de cette statistique."
	return description

const CHAMPS_LISIBLES := ["attaque", "pv_mult", "defense", "cadence", "critique",
	"degats_critiques", "degats_sorts", "projectile", "reduction", "recharge", "vitesse",
	"soin", "rayon_sorts", "collecte", "coffre", "experience", "pierres"]

static func _nombre(valeur: float) -> String:
	return String.num(valeur, 1).trim_suffix(".0").replace(".", ",")

# Ce qu'un noeud vaut a un rang donne, sans le prefixe « Rang N ». Sert a
# comparer l'etat actuel au rang suivant : une valeur « par rang » oblige sinon
# le joueur a faire la multiplication de tete avant de depenser ses Gouttes.
static func valeur_au_rang(id: String, rang: int) -> String:
	var noeud: Dictionary = NOEUDS.get(id, {})
	var acquis := clampi(rang, 0, rangs(id))
	if noeud.has("collecte") and noeud.has("experience"):
		var butin := poids_rang(acquis) * float(noeud["collecte"]) * 100.0
		var experience := poids_rang(acquis) * float(noeud["experience"]) * 100.0
		return "+%s %% Butin · +%s %% XP de compte" % [_nombre(butin), _nombre(experience)]
	for champ in ["attaque", "pv_mult", "defense", "cadence", "critique", "degats_critiques", "degats_sorts"]:
		if noeud.has(champ):
			return "+%s %%%s" % [_nombre(float(noeud[champ]) * acquis * 100.0), " d’attaque" if champ == "attaque" else ""]
	for champ in CHAMPS_LISIBLES:
		if noeud.has(champ):
			return "%s%s %%" % ["-" if champ in ["reduction", "recharge"] else "+",
				_nombre(poids_rang(acquis) * float(noeud[champ]) * 100.0)]
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

static func bonus_degats_sorts(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "degats_sorts")

static func multiplicateur_soin(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "soin")

static func multiplicateur_rayon_sorts(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "rayon_sorts")

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

static func donne_second_passif(rangs_joueur: Dictionary) -> bool:
	return _somme(rangs_joueur, "second_passif") > 0.0

static func poids_rang(rang: int) -> float:
	return float(clampi(rang,0,MAX_RANG))

static func multiplicateur_recharge(rangs_joueur: Dictionary) -> float:
	return maxf(Reglages.RECHARGE_PLANCHER, 1.0 - _somme(rangs_joueur, "recharge"))
