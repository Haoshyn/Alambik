class_name EffetsBijoux
extends RefCounted

const PALIERS := [10]
const ELAN_BONUS_PAR_ATTAQUE := 0.01
const ELAN_CUMULS_MAX := 10
const ELAN_DUREE := 5.0
const IMPACT_ATTAQUES := 5
const IMPACT_MULTIPLICATEUR := 1.50
const SURSIS_PV := 1.0
const CONCENTRATION_ATTAQUE := 0.10
# Pouvoirs volontairement courts : les bijoux renforcent le tir ou la survie
# sans ajouter un second systeme d'attaques automatiques.
const NOMS := {
	"elan_offensif": "Élan offensif",
	"cinquieme_impact": "Cinquième impact",
	"sursis": "Sursis",
	"incantation": "Concentration",
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
	match id:
		"elan_offensif": return "Chaque attaque donne +%s %% de dégâts, cumulable %d fois. Tous les cumuls disparaissent après %s s sans attaquer." % [_nombre(ELAN_BONUS_PAR_ATTAQUE * 100.0), ELAN_CUMULS_MAX, _nombre(ELAN_DUREE)]
		"cinquieme_impact": return "Chaque attaque n° %d inflige %s %% de dégâts supplémentaires." % [IMPACT_ATTAQUES, _nombre((IMPACT_MULTIPLICATEUR - 1.0) * 100.0)]
		"sursis": return "La première blessure mortelle de l’aventure laisse le héros à %s PV." % _nombre(SURSIS_PV)
		"incantation": return "Attaque +%s %% tant que le collier est équipé." % _nombre(CONCENTRATION_ATTAQUE * 100.0)
	return ""

static func _nombre(valeur: float) -> String:
	return str(roundi(valeur))
