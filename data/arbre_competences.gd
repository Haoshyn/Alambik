class_name ArbreCompetences
extends RefCounted

# Deux noeuds de statistiques a dix rangs, puis un pouvoir majeur a achat unique.
# Les rangs s'additionnent ; les noeuds de degats/PV se multiplient.
const MAX_RANG := Reglages.MAITRISE_RANG_MAX
const NOEUDS := {
	"force": {"nom": "Force", "description": "+10 % dégâts par rang", "categorie": "Offensif", "degats": 0.1, "cout": Reglages.MAITRISE_COUTS[0]},
	"cadence": {"nom": "Cadence", "description": "+1 % cadence par rang", "categorie": "Offensif", "cadence": 0.01, "requis": "force", "cout": Reglages.MAITRISE_COUTS[1]},
	"precision": {"nom": "Frappe souveraine", "description": "Double les dégâts.", "categorie": "Offensif", "degats": 1.0, "requis": "cadence", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"puissance": {"nom": "Puissance", "description": "+15 % dégâts par rang", "categorie": "Offensif", "degats": 0.15, "requis": "precision", "cout": Reglages.MAITRISE_COUTS[3]},
	"rythme": {"nom": "Rythme maîtrisé", "description": "+1,5 % cadence par rang", "categorie": "Offensif", "cadence": 0.015, "requis": "puissance", "cout": Reglages.MAITRISE_COUTS[4]},
	"catalyse": {"nom": "Catalyse absolue", "description": "Double les dégâts.", "categorie": "Offensif", "degats": 1.0, "requis": "rythme", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"trajectoire": {"nom": "Maîtrise du trait", "description": "+20 % dégâts par rang", "categorie": "Offensif", "degats": 0.2, "requis": "catalyse", "cout": Reglages.MAITRISE_COUTS[6]},
	"tempete": {"nom": "Tempête mesurée", "description": "+2 % cadence par rang", "categorie": "Offensif", "cadence": 0.02, "requis": "trajectoire", "cout": Reglages.MAITRISE_COUTS[7]},
	"domination": {"nom": "Domination", "description": "Double les dégâts.", "categorie": "Offensif", "degats": 1.0, "requis": "tempete", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"grand_oeuvre": {"nom": "Grand Œuvre", "description": "+25 % dégâts par rang", "categorie": "Offensif", "degats": 0.25, "requis": "domination", "cout": Reglages.MAITRISE_COUTS[9]},
	"constitution": {"nom": "Constitution", "description": "+10 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.1, "cout": Reglages.MAITRISE_COUTS[0]},
	"armure": {"nom": "Armure", "description": "+5 % armure par rang", "categorie": "Défensif", "armure": 0.05, "requis": "constitution", "cout": Reglages.MAITRISE_COUTS[1]},
	"vitalite": {"nom": "Vitalité souveraine", "description": "Double les PV maximum.", "categorie": "Défensif", "pv_mult": 1.0, "requis": "armure", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"rempart": {"nom": "Rempart vivant", "description": "+15 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.15, "requis": "vitalite", "cout": Reglages.MAITRISE_COUTS[3]},
	"robustesse": {"nom": "Robustesse", "description": "+7 % armure par rang", "categorie": "Défensif", "armure": 0.07, "requis": "rempart", "cout": Reglages.MAITRISE_COUTS[4]},
	"carapace": {"nom": "Carapace absolue", "description": "Divise les dégâts reçus par deux.", "categorie": "Défensif", "resistance_mult": 1.0, "requis": "robustesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"endurance": {"nom": "Endurance", "description": "+20 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.2, "requis": "carapace", "cout": Reglages.MAITRISE_COUTS[6]},
	"bastion": {"nom": "Bastion", "description": "+10 % armure par rang", "categorie": "Défensif", "armure": 0.1, "requis": "endurance", "cout": Reglages.MAITRISE_COUTS[7]},
	"colosse": {"nom": "Colosse", "description": "Double les PV maximum.", "categorie": "Défensif", "pv_mult": 1.0, "requis": "bastion", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"immortel": {"nom": "Immortel", "description": "+25 % PV maximum par rang", "categorie": "Défensif", "pv_mult": 0.25, "requis": "colosse", "cout": Reglages.MAITRISE_COUTS[9]},
	"celerite": {"nom": "Récolte", "description": "+4 % Gouttes gagnées par rang", "categorie": "Utilitaire", "collecte": 0.04, "cout": Reglages.MAITRISE_COUTS[0]},
	"collecte": {"nom": "Prospection", "description": "+4 % Pierres de forge par rang", "categorie": "Utilitaire", "pierres": 0.04, "requis": "celerite", "cout": Reglages.MAITRISE_COUTS[1]},
	"distillation": {"nom": "Distillation", "description": "+1 nouveau tirage d’augmentations par aventure.", "categorie": "Utilitaire", "rerolls": 1, "requis": "collecte", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"fortune": {"nom": "Fortune", "description": "+4 % Gouttes des coffres par rang", "categorie": "Utilitaire", "coffre": 0.04, "requis": "distillation", "cout": Reglages.MAITRISE_COUTS[3]},
	"sagesse": {"nom": "Sagesse", "description": "+4 % XP de compte par rang", "categorie": "Utilitaire", "experience": 0.04, "requis": "fortune", "cout": Reglages.MAITRISE_COUTS[4]},
	"abondance": {"nom": "Double discipline", "description": "Permet d’équiper un second Passif.", "categorie": "Utilitaire", "second_passif": true, "requis": "sagesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"savoir": {"nom": "Artisanat", "description": "+6 % Pierres de forge par rang", "categorie": "Utilitaire", "pierres": 0.06, "requis": "abondance", "cout": Reglages.MAITRISE_COUTS[6]},
	"elan": {"nom": "Abondance", "description": "+6 % Gouttes gagnées par rang", "categorie": "Utilitaire", "collecte": 0.06, "requis": "savoir", "cout": Reglages.MAITRISE_COUTS[7]},
	"prescience": {"nom": "Prescience", "description": "+1 nouveau tirage d’augmentations par aventure.", "categorie": "Utilitaire", "rerolls": 1, "requis": "elan", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"philosophe": {"nom": "Pierre philosophale", "description": "+6 % Gouttes des coffres par rang", "categorie": "Utilitaire", "coffre": 0.06, "requis": "prescience", "cout": Reglages.MAITRISE_COUTS[9]},
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
		total += (float(rang) if champ in ["rerolls", "cadence", "armure"] else poids_rang(rang)) * float(NOEUDS[id].get(champ, 0.0))
	return total

static func description_effective(id: String) -> String:
	return str(NOEUDS[id]["description"]) + (" Pouvoir majeur · achat unique." if rangs(id)==1 else " Dix rangs à plein effet.")

const CHAMPS_LISIBLES := ["degats", "pv_mult", "cadence", "projectile", "armure", "reduction",
	"recharge", "vitesse", "collecte", "coffre", "experience", "pierres"]

static func _nombre(valeur: float) -> String:
	return String.num(valeur, 1).trim_suffix(".0").replace(".", ",")

# Ce qu'un noeud vaut a un rang donne, sans le prefixe « Rang N ». Sert a
# comparer l'etat actuel au rang suivant : une valeur « par rang » oblige sinon
# le joueur a faire la multiplication de tete avant de depenser ses Gouttes.
static func valeur_au_rang(id: String, rang: int) -> String:
	var noeud: Dictionary = NOEUDS.get(id, {})
	var acquis := clampi(rang, 0, rangs(id))
	if noeud.has("resistance_mult"): return "Dégâts reçus ÷ 2" if acquis > 0 else "Aucun bonus"
	for champ in ["degats", "pv_mult", "cadence", "armure"]:
		if noeud.has(champ):
			return "+%s %%" % _nombre(float(noeud[champ]) * acquis * 100.0)
	for champ in CHAMPS_LISIBLES:
		if noeud.has(champ):
			return "%s%s %%" % ["-" if champ in ["reduction", "recharge"] else "+",
				_nombre(poids_rang(acquis) * float(noeud[champ]) * 100.0)]
	if noeud.has("rerolls"):
		var tirages := acquis * int(noeud["rerolls"])
		return "+%d tirage%s" % [tirages, "s" if tirages > 1 else ""]
	return "acquis" if acquis > 0 else "aucun"

static func resume_rang(id: String, rang: int) -> String:
	var acquis := clampi(rang, 0, rangs(id))
	if acquis <= 0:
		return "Aucun rang acquis"
	return "Rang %d : %s" % [acquis, valeur_au_rang(id, acquis)]

static func bonus_pv(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "pv")

static func multiplicateur_pv(rangs_joueur: Dictionary) -> float:
	return _produit_noeuds(rangs_joueur, "pv_mult")

static func reduction_degats(rangs_joueur: Dictionary) -> float:
	return 1.0 - 1.0 / ((1.0 + _somme(rangs_joueur, "armure")) * _produit_noeuds(rangs_joueur,"resistance_mult"))

static func multiplicateur_soin(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "soin")

static func soin_par_salle(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "soin_salle")

static func donne_bouclier(rangs_joueur: Dictionary) -> bool:
	return _somme(rangs_joueur, "bouclier") > 0.0

static func multiplicateur_degats(rangs_joueur: Dictionary) -> float:
	return _produit_noeuds(rangs_joueur, "degats")

static func _produit_noeuds(rangs_joueur: Dictionary, champ: String) -> float:
	var facteur := 1.0
	for id in rangs_joueur:
		if NOEUDS.has(id) and NOEUDS[id].has(champ):
			facteur *= 1.0 + float(NOEUDS[id][champ]) * clampi(int(rangs_joueur[id]), 0, rangs(id))
	return facteur

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
	return roundi(_somme(rangs_joueur, "rerolls"))

static func donne_second_passif(rangs_joueur: Dictionary) -> bool:
	return _somme(rangs_joueur, "second_passif") > 0.0

static func poids_rang(rang: int) -> float:
	return float(clampi(rang,0,MAX_RANG))

static func multiplicateur_recharge(rangs_joueur: Dictionary) -> float:
	return maxf(Reglages.RECHARGE_PLANCHER, 1.0 - _somme(rangs_joueur, "recharge"))
