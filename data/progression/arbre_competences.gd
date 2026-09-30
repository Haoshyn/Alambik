class_name ArbreCompetences
extends RefCounted

# Chaque rang multiplie la valeur acquise ; les noeuds tardifs ont des taux
# superieurs. Les points de critique restent une addition de chances.
const MAX_RANG := Reglages.MAITRISE_RANG_MAX
# Bareme historique pour les remboursements des anciennes sauvegardes.
const ANCIENS_COUTS := [8, 12, 20, 35, 60, 100, 170, 280, 460, 760]
const ANCIEN_COUT_PAR_RANG := 1.35
const ATTAQUE_PAR_RANG_INITIALE := 0.02
const ATTAQUE_PAR_RANG_PUISSANCE := 0.02
const ATTAQUE_PAR_RANG_AVANCEE := 0.03
const ATTAQUE_PAR_RANG_FINALE := 0.04
const CRITIQUE_PAR_RANG := 0.01
static var NOEUDS := _avec_descriptions({
	"force": {"nom": "Force maîtrisée", "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_INITIALE, "cout": Reglages.MAITRISE_COUTS[0]},
	"cadence": {"nom": "Œil sûr", "categorie": "Offensif", "critique": CRITIQUE_PAR_RANG, "requis": "force", "cout": Reglages.MAITRISE_COUTS[1]},
	"precision": {"nom": "Frappe souveraine", "categorie": "Offensif", "critique": 0.02, "requis": "cadence", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"puissance": {"nom": "Puissance", "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_PUISSANCE, "requis": "precision", "cout": Reglages.MAITRISE_COUTS[3]},
	"rythme": {"nom": "Impact critique", "categorie": "Offensif", "degats_critiques": 0.02, "requis": "puissance", "cout": Reglages.MAITRISE_COUTS[4]},
	"catalyse": {"nom": "Catalyse absolue", "categorie": "Offensif", "attaque": 0.05, "requis": "rythme", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"trajectoire": {"nom": "Maîtrise du trait", "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_AVANCEE, "requis": "catalyse", "cout": Reglages.MAITRISE_COUTS[6]},
	"tempete": {"nom": "Instinct critique", "categorie": "Offensif", "critique": 0.02, "requis": "trajectoire", "cout": Reglages.MAITRISE_COUTS[7]},
	"domination": {"nom": "Domination", "categorie": "Offensif", "attaque": 0.10, "requis": "tempete", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"grand_oeuvre": {"nom": "Grand Œuvre", "categorie": "Offensif", "attaque": ATTAQUE_PAR_RANG_FINALE, "requis": "domination", "cout": Reglages.MAITRISE_COUTS[9]},
	"constitution": {"nom": "Constitution", "categorie": "Défensif", "pv_mult": 0.01, "cout": Reglages.MAITRISE_COUTS[0]},
	"armure": {"nom": "Défense", "categorie": "Défensif", "defense": 0.02, "requis": "constitution", "cout": Reglages.MAITRISE_COUTS[1]},
	"vitalite": {"nom": "Vitalité souveraine", "categorie": "Défensif", "pv_mult": 0.05, "requis": "armure", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"rempart": {"nom": "Rempart vivant", "categorie": "Défensif", "pv_mult": 0.02, "requis": "vitalite", "cout": Reglages.MAITRISE_COUTS[3]},
	"robustesse": {"nom": "Robustesse", "categorie": "Défensif", "defense": 0.03, "requis": "rempart", "cout": Reglages.MAITRISE_COUTS[4]},
	"carapace": {"nom": "Carapace absolue", "categorie": "Défensif", "reduction": 0.05, "requis": "robustesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"endurance": {"nom": "Endurance", "categorie": "Défensif", "pv_mult": 0.03, "requis": "carapace", "cout": Reglages.MAITRISE_COUTS[6]},
	"bastion": {"nom": "Bastion", "categorie": "Défensif", "defense": 0.04, "requis": "endurance", "cout": Reglages.MAITRISE_COUTS[7]},
	"colosse": {"nom": "Colosse", "categorie": "Défensif", "pv_mult": 0.10, "requis": "bastion", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"immortel": {"nom": "Immortel", "categorie": "Défensif", "pv_mult": 0.04, "requis": "colosse", "cout": Reglages.MAITRISE_COUTS[9]},
	"celerite": {"nom": "Alchimie réparatrice", "categorie": "Utilitaire", "soin": 0.02, "cout": Reglages.MAITRISE_COUTS[0]},
	"collecte": {"nom": "Prospection", "categorie": "Utilitaire", "collecte": 0.02, "requis": "celerite", "cout": Reglages.MAITRISE_COUTS[1]},
	"distillation": {"nom": "Distillation", "categorie": "Utilitaire", "rerolls": 1, "requis": "collecte", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[2] * Reglages.MAITRISE_COUT_MAJEUR},
	"fortune": {"nom": "Catalyse pratique", "categorie": "Utilitaire", "attaque": 0.01, "requis": "distillation", "cout": Reglages.MAITRISE_COUTS[3]},
	"sagesse": {"nom": "Étude", "categorie": "Utilitaire", "experience": 0.03, "requis": "fortune", "cout": Reglages.MAITRISE_COUTS[4]},
	"abondance": {"nom": "Double récolte", "categorie": "Utilitaire", "collecte": 0.10, "pierres": 0.10, "requis": "sagesse", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[5] * Reglages.MAITRISE_COUT_MAJEUR},
	"savoir": {"nom": "Geste précis", "categorie": "Utilitaire", "cadence": 0.01, "requis": "abondance", "cout": Reglages.MAITRISE_COUTS[6]},
	"elan": {"nom": "Veine profonde", "categorie": "Utilitaire", "pierres": 0.04, "requis": "savoir", "cout": Reglages.MAITRISE_COUTS[7]},
	"prescience": {"nom": "Prescience", "categorie": "Utilitaire", "rerolls": 1, "requis": "elan", "rangs": 1, "fort": true, "cout": Reglages.MAITRISE_COUTS[8] * Reglages.MAITRISE_COUT_MAJEUR},
	"philosophe": {"nom": "Abondance", "categorie": "Utilitaire", "collecte": 0.04, "experience": 0.04, "requis": "prescience", "cout": Reglages.MAITRISE_COUTS[9]},
})

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
		total += bonus_au_rang(id, rang, champ)
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
				_nombre(bonus_au_rang(id, acquis, champ) * 100.0), str(LIBELLES_BONUS[champ])])
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
	return _facteur(rangs_joueur, "pv_mult")

static func reduction_degats(rangs_joueur: Dictionary) -> float:
	return clampf(_somme(rangs_joueur, "reduction"), 0.0, 0.90)

static func multiplicateur_defense(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "defense")

static func bonus_critique(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "critique")

static func bonus_degats_critiques(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "degats_critiques")

static func multiplicateur_soin(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "soin")

static func soin_par_salle(rangs_joueur: Dictionary) -> float:
	return _somme(rangs_joueur, "soin_salle")

static func donne_bouclier(rangs_joueur: Dictionary) -> bool:
	return _somme(rangs_joueur, "bouclier") > 0.0

static func bonus_attaque(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "attaque") - 1.0

static func multiplicateur_attaque(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "attaque")

static func multiplicateur_cadence(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "cadence")

static func multiplicateur_projectile(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "projectile")

static func multiplicateur_vitesse(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "vitesse")

static func multiplicateur_collecte(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "collecte")

static func multiplicateur_experience(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "experience")

static func multiplicateur_coffre(rangs_joueur: Dictionary) -> float:
	return 1.0 + _somme(rangs_joueur, "coffre")

static func multiplicateur_pierres(rangs_joueur: Dictionary) -> float:
	return _facteur(rangs_joueur, "pierres")

static func nombre_rerolls(rangs_joueur: Dictionary) -> int:
	return mini(Reglages.RELANCES_MAX_PAR_RUN, roundi(_somme(rangs_joueur, "rerolls")))

static func bonus_au_rang(id: String, rang: int, champ: String) -> float:
	var noeud: Dictionary = NOEUDS.get(id, {})
	var taux := float(noeud.get(champ, 0.0))
	var acquis := clampi(rang, 0, rangs(id))
	if champ in ["critique", "degats_critiques", "rerolls"]:
		return taux * float(acquis)
	return pow(1.0 + taux, acquis) - 1.0

static func _facteur(rangs_joueur: Dictionary, champ: String) -> float:
	var facteur := 1.0
	for id: String in rangs_joueur:
		if NOEUDS.has(id):
			facteur *= 1.0 + bonus_au_rang(id, int(rangs_joueur[id]), champ)
	return facteur

static func _avec_descriptions(noeuds: Dictionary) -> Dictionary:
	for id: String in noeuds:
		var noeud: Dictionary = noeuds[id]
		var morceaux: Array[String] = []
		for champ: String in CHAMPS_LISIBLES:
			if not noeud.has(champ): continue
			var taux := _nombre(float(noeud[champ]) * 100.0)
			var suffixe := " par rang" if int(noeud.get("rangs", MAX_RANG)) > 1 else ""
			if champ in ["critique", "degats_critiques"]:
				morceaux.append("+%s points %s%s" % [taux, str(LIBELLES_BONUS[champ]), suffixe])
			elif champ == "reduction":
				morceaux.append("Réduit les dégâts reçus de %s %% avant la Défense." % taux)
			else:
				morceaux.append("+%s %% %s%s, cumul composé" % [taux, str(LIBELLES_BONUS[champ]), suffixe])
		if noeud.has("rerolls"):
			morceaux.append("+%d relance · Maximum : %d" % [int(noeud["rerolls"]), Reglages.RELANCES_MAX_PAR_RUN])
		noeud["description"] = " · ".join(morceaux)
	return noeuds
