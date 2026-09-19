class_name RangsEnnemis
extends RefCounted

const COSTAUDS := ["scribe_essaimeur", "sceau_belier", "miroir_encre", "fuseau_tisseur"]
const COSTAUDS_PAR_VAGUE := 1
const REMPLACANT_COMMUN := "encrier_rampant"
const PREMIER_CHAPITRE_ELITES := 1
const CHANCE_ELITE_PAR_VAGUE := .10
const ELITE_PV_COMMUN := 1.50
const ELITE_PV_COSTAUD := 1.25
const ELITE_DEGATS_COMMUN := 1.15
const ELITE_DEGATS_COSTAUD := 1.10
const ELITE_EXPERIENCE := 2.0
const ELITE_GOUTTES := 2.0
const COULEUR_ELITE := Color("e7bc65")

static func categorie(id: String) -> String:
	return "costaud" if id in COSTAUDS else "commun"

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
	var costaud := str(resultat.get("categorie", "commun")) == "costaud"
	resultat["elite"] = true
	resultat["nom"] = "%s élite" % str(resultat["nom"])
	resultat["pv"] = float(resultat["pv"]) * (ELITE_PV_COSTAUD if costaud else ELITE_PV_COMMUN)
	resultat["degats"] = float(resultat["degats"]) * (ELITE_DEGATS_COSTAUD if costaud else ELITE_DEGATS_COMMUN)
	resultat["experience"] = ceili(float(resultat["experience"]) * ELITE_EXPERIENCE)
	return resultat

static func bonus_gouttes(chapitre: int, nombre: int) -> int:
	return roundi(nombre * ELITE_GOUTTES * pow(Reglages.GOUTTES_MULT_PAR_CHAPITRE, chapitre))
