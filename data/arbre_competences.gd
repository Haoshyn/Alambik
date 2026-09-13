class_name ArbreCompetences
extends RefCounted

# Trois branches de dix paliers. Chaque palier se rachete plusieurs fois : le
# premier rang accompagne la campagne, les suivants sont ce que le farm pousse
# au maximum. Les valeurs sont donc exprimees PAR RANG, jamais en total.
#
# Budget vise a l'arbre complet : environ x2,35 en DPS pour la branche offensive
# et x2,15 en survie effective pour la defensive. Les Maitrises sont un tiers de
# la progression permanente, pas une source x11 qui rend stuff et Passifs caducs.
const MAX_RANG := Reglages.MAITRISE_RANG_MAX
const NOEUDS := {
	"force": {"nom": "Force", "description": "+1,2 % dégâts par rang", "cout": Reglages.MAITRISE_COUTS[0], "categorie": "Offensif", "degats": 0.012},
	"cadence": {"nom": "Cadence", "description": "+0,8 % cadence par rang", "cout": Reglages.MAITRISE_COUTS[1], "categorie": "Offensif", "requis": "force", "cadence": 0.008},
	"precision": {"nom": "Précision", "description": "+1,2 % vitesse et portée des tirs par rang", "cout": Reglages.MAITRISE_COUTS[2], "categorie": "Offensif", "requis": "cadence", "projectile": 0.012},
	"puissance": {"nom": "Puissance", "description": "+2 % dégâts par rang", "cout": Reglages.MAITRISE_COUTS[3], "categorie": "Offensif", "requis": "precision", "degats": 0.020, "fort": true},
	"rythme": {"nom": "Rythme de guerre", "description": "+1 % cadence par rang", "cout": Reglages.MAITRISE_COUTS[4], "categorie": "Offensif", "requis": "puissance", "cadence": 0.010},
	"catalyse": {"nom": "Catalyse", "description": "+3,2 % dégâts par rang", "cout": Reglages.MAITRISE_COUTS[5], "categorie": "Offensif", "requis": "rythme", "degats": 0.032},
	"trajectoire": {"nom": "Trajectoire absolue", "description": "+1,8 % vitesse et portée des tirs par rang", "cout": Reglages.MAITRISE_COUTS[6], "categorie": "Offensif", "requis": "catalyse", "projectile": 0.018},
	"tempete": {"nom": "Tempête", "description": "+1,4 % cadence par rang", "cout": Reglages.MAITRISE_COUTS[7], "categorie": "Offensif", "requis": "trajectoire", "cadence": 0.014, "fort": true},
	"domination": {"nom": "Domination", "description": "+5,2 % dégâts par rang", "cout": Reglages.MAITRISE_COUTS[8], "categorie": "Offensif", "requis": "tempete", "degats": 0.052},
	"grand_oeuvre": {"nom": "Grand Œuvre", "description": "+9 % dégâts par rang", "cout": Reglages.MAITRISE_COUTS[9], "categorie": "Offensif", "requis": "domination", "degats": 0.090, "fort": true},

	"constitution": {"nom": "Constitution", "description": "+1,6 % PV maximum par rang", "cout": Reglages.MAITRISE_COUTS[0], "categorie": "Défensif", "pv_mult": 0.016},
	"armure": {"nom": "Armure", "description": "-0,2 % dégâts reçus par rang", "cout": Reglages.MAITRISE_COUTS[1], "categorie": "Défensif", "requis": "constitution", "reduction": 0.0020},
	"vitalite": {"nom": "Vitalité", "description": "+2,4 % PV maximum par rang", "cout": Reglages.MAITRISE_COUTS[2], "categorie": "Défensif", "requis": "armure", "pv_mult": 0.024},
	"rempart": {"nom": "Rempart", "description": "-0,28 % dégâts reçus par rang", "cout": Reglages.MAITRISE_COUTS[3], "categorie": "Défensif", "requis": "vitalite", "reduction": 0.0028, "fort": true},
	"robustesse": {"nom": "Robustesse", "description": "+3,2 % PV maximum par rang", "cout": Reglages.MAITRISE_COUTS[4], "categorie": "Défensif", "requis": "rempart", "pv_mult": 0.032},
	"carapace": {"nom": "Carapace", "description": "-0,36 % dégâts reçus par rang", "cout": Reglages.MAITRISE_COUTS[5], "categorie": "Défensif", "requis": "robustesse", "reduction": 0.0036},
	"endurance": {"nom": "Endurance", "description": "+4,8 % PV maximum par rang", "cout": Reglages.MAITRISE_COUTS[6], "categorie": "Défensif", "requis": "carapace", "pv_mult": 0.048},
	"bastion": {"nom": "Bastion", "description": "-0,44 % dégâts reçus par rang", "cout": Reglages.MAITRISE_COUTS[7], "categorie": "Défensif", "requis": "endurance", "reduction": 0.0044, "fort": true},
	"colosse": {"nom": "Colosse", "description": "+7,2 % PV maximum par rang", "cout": Reglages.MAITRISE_COUTS[8], "categorie": "Défensif", "requis": "bastion", "pv_mult": 0.072},
	"immortel": {"nom": "Immortel", "description": "-0,6 % dégâts reçus par rang", "cout": Reglages.MAITRISE_COUTS[9], "categorie": "Défensif", "requis": "colosse", "reduction": 0.0060, "fort": true},

	"celerite": {"nom": "Célérité", "description": "+2 % déplacement par rang", "cout": Reglages.MAITRISE_COUTS[0], "categorie": "Utilitaire", "vitesse": 0.02},
	"collecte": {"nom": "Collecte", "description": "+2 % Gouttes par rang", "cout": Reglages.MAITRISE_COUTS[1], "categorie": "Utilitaire", "requis": "celerite", "collecte": 0.02},
	# Un nouveau tirage change une regle du draft : deux rangs suffisent, cinq
	# rendraient le pool d'Ameliorations entierement choisissable.
	"distillation": {"nom": "Distillation", "description": "+1 nouveau tirage d’Améliorations par rang", "cout": Reglages.MAITRISE_COUTS[2], "categorie": "Utilitaire", "requis": "collecte", "rerolls": 1, "rangs": 2, "fort": true},
	"fortune": {"nom": "Fortune", "description": "+2,5 % Gouttes des coffres par rang", "cout": Reglages.MAITRISE_COUTS[3], "categorie": "Utilitaire", "requis": "distillation", "coffre": 0.025},
	"sagesse": {"nom": "Sagesse", "description": "+4 % XP de compte par rang", "cout": Reglages.MAITRISE_COUTS[4], "categorie": "Utilitaire", "requis": "fortune", "experience": 0.04},
	"abondance": {"nom": "Abondance", "description": "+3 % Gouttes par rang", "cout": Reglages.MAITRISE_COUTS[5], "categorie": "Utilitaire", "requis": "sagesse", "collecte": 0.03},
	"savoir": {"nom": "Double discipline", "description": "Permet d’équiper un second Passif", "cout": Reglages.MAITRISE_COUTS[6], "categorie": "Utilitaire", "requis": "abondance", "second_passif": true, "rangs": 1, "fort": true},
	"elan": {"nom": "Élan", "description": "+3 % déplacement par rang", "cout": Reglages.MAITRISE_COUTS[7], "categorie": "Utilitaire", "requis": "savoir", "vitesse": 0.03},
	"prescience": {"nom": "Prescience", "description": "+1 nouveau tirage d’Améliorations par rang", "cout": Reglages.MAITRISE_COUTS[8], "categorie": "Utilitaire", "requis": "elan", "rerolls": 1, "rangs": 2},
	"philosophe": {"nom": "Pierre philosophale", "description": "+4 % coffres et +6 % Pierres de forge par rang", "cout": Reglages.MAITRISE_COUTS[9], "categorie": "Utilitaire", "requis": "prescience", "coffre": 0.04, "pierres": 0.06, "fort": true},
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
		total += (float(rang) if champ == "rerolls" else poids_rang(rang)) * float(NOEUDS[id].get(champ, 0.0))
	return total

static func description_effective(id: String) -> String:
	return str(NOEUDS[id]["description"]) + (". Progression plus douce après le rang 3." if rangs(id) > 3 else "")

const CHAMPS_LISIBLES := ["degats", "pv_mult", "cadence", "projectile", "reduction",
	"vitesse", "collecte", "coffre", "experience", "pierres"]

static func _nombre(valeur: float) -> String:
	return String.num(valeur, 1).trim_suffix(".0").replace(".", ",")

# Ce qu'un noeud vaut a un rang donne, sans le prefixe « Rang N ». Sert a
# comparer l'etat actuel au rang suivant : une valeur « par rang » oblige sinon
# le joueur a faire la multiplication de tete avant de depenser ses Gouttes.
static func valeur_au_rang(id: String, rang: int) -> String:
	var noeud: Dictionary = NOEUDS.get(id, {})
	var acquis := clampi(rang, 0, rangs(id))
	for champ in CHAMPS_LISIBLES:
		if noeud.has(champ):
			return "%s%s %%" % ["-" if champ == "reduction" else "+",
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
	return 1.0 + _somme(rangs_joueur, "pv_mult")

static func reduction_degats(rangs_joueur: Dictionary) -> float:
	return clampf(_somme(rangs_joueur, "reduction"), 0.0, 0.60)

static func multiplicateur_soin(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "soin")

static func soin_par_salle(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "soin_salle")

static func donne_bouclier(rangs_joueur: Dictionary) -> bool:
	return _somme(rangs_joueur, "bouclier") > 0.0

static func multiplicateur_degats(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "degats")

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
	return float(mini(rang, Reglages.MAITRISE_RANGS_PLEINS)) + float(maxi(0, rang - Reglages.MAITRISE_RANGS_PLEINS)) * Reglages.MAITRISE_POIDS_TARDIF
