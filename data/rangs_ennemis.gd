class_name RangsEnnemis
extends RefCounted

const COSTAUDS := ["scribe_essaimeur", "sceau_belier", "miroir_encre", "fuseau_tisseur"]
const FRAGILES := ["encrier_rampant", "tache_veloce", "fiole_volatile"]
const COSTAUDS_PAR_VAGUE := 1
const REMPLACANT_COMMUN := "encrier_rampant"
const PREMIER_CHAPITRE_ELITES := 1
const PREMIERE_SALLE_ELITES := 3
const CHANCE_ELITE_PAR_VAGUE := .10
const ELITE_PV := 2.0
const ELITE_DEGATS := 2.0
const ELITE_VITESSE := 1.12
const ELITE_RECHARGE := 0.90
const ELITE_PROJECTILE := 1.08
const CHANCE_ELITE_INCENDIAIRE := 0.35
const ELITE_GOUTTES := 2.0
const COULEUR_ELITE := Color("e7bc65")

static func categorie(id: String) -> String:
	if id in COSTAUDS: return "costaud"
	return "fragile" if id in FRAGILES else "commun"

static func limiter_costauds(vague: Array) -> Array:
	var resultat: Array = []
	var nombre := 0
	for id in vague:
		if categorie(str(id)) == "costaud":
			nombre += 1
			resultat.append(REMPLACANT_COMMUN if nombre > COSTAUDS_PAR_VAGUE else id)
		else:
			resultat.append(id)
	return resultat

static func renforcer(source: Dictionary) -> Dictionary:
	var resultat := source.duplicate(true)
	resultat["elite"] = true
	resultat["nom"] = "%s élite" % str(resultat["nom"])
	resultat["pv"] = float(resultat["pv"]) * ELITE_PV
	resultat["degats"] = float(resultat["degats"]) * ELITE_DEGATS
	resultat["vitesse"] = float(resultat["vitesse"]) * ELITE_VITESSE
	if resultat.has("recharge"):
		resultat["recharge"] = float(resultat["recharge"]) * ELITE_RECHARGE
	if resultat.has("vitesse_projectile"):
		resultat["vitesse_projectile"] = float(resultat["vitesse_projectile"]) * ELITE_PROJECTILE
	return resultat

static func bonus_gouttes(chapitre: int, nombre: int) -> int:
	return roundi(nombre * ELITE_GOUTTES * pow(Reglages.GOUTTES_MULT_PAR_CHAPITRE, chapitre))
