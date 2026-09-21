class_name EffetsBijoux
extends RefCounted

const PALIERS := [10]
const ELAN_BONUS_PAR_ATTAQUE := 0.01
const ELAN_CUMULS_MAX := 10
const ELAN_DUREE := 5.0
const IMPACT_ATTAQUES := 5
const IMPACT_MULTIPLICATEUR := 2.0
const SURSIS_PV := 1.0
const INCANTATION_BONUS := 0.10
const INCANTATION_DUREE := 5.0
# Pouvoirs volontairement courts : les bijoux renforcent le tir ou la survie
# sans ajouter un second systeme d'attaques automatiques.
const NOMS := {
	"elan_offensif": "Élan offensif",
	"cinquieme_impact": "Cinquième impact",
	"sursis": "Sursis",
	"incantation": "Incantation",
}
const DESCRIPTIONS := {
	"elan_offensif": "Chaque attaque donne +1 % de dégâts, cumulable 10 fois. Tous les cumuls disparaissent après 5 s sans attaquer.",
	"cinquieme_impact": "Chaque cinquième attaque inflige le double de dégâts.",
	"sursis": "La première blessure mortelle de l’aventure laisse le héros à 1 PV.",
	"incantation": "Après un sort actif, dégâts +10 % pendant 5 s.",
}

# Trois pouvoirs fixes par monde : anneau, bracelet, collier. Les anciens
# mondes gardent une combinaison valide pour ne pas casser les sauvegardes.
const PAR_MONDE := [
	["elan_offensif", "sursis", "incantation"],
	["cinquieme_impact", "sursis", "incantation"],
	["elan_offensif", "sursis", "incantation"],
	["cinquieme_impact", "sursis", "incantation"],
	["elan_offensif", "sursis", "incantation"],
	["cinquieme_impact", "sursis", "incantation"],
	["elan_offensif", "sursis", "incantation"],
	["cinquieme_impact", "sursis", "incantation"],
	["elan_offensif", "sursis", "incantation"],
	["cinquieme_impact", "sursis", "incantation"],
]

static func parcours(monde: int, profil: int) -> Array:
	return [PAR_MONDE[monde][profil]]

static func nom(id: String) -> String:
	return str(NOMS.get(id, id))

static func description(id: String) -> String:
	return str(DESCRIPTIONS.get(id, ""))
