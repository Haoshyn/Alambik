class_name Reactif
extends RefCounted

const COMMUN := "commun"
const RARE := "rare"
const EPIQUE := "epique"

var rarete := EPIQUE
var id: String
var nom: String
var description: String
var mods: Dictionary
var est_transformation := false
var famille := ""
var teinte := Color(0.9, 0.8, 0.5)
var glyphe := "goutte"
# Les drapeaux sont uniques ; seuls les petits bonus peuvent se reprendre.
var copies_max := 0

static func creer(id_: String, nom_: String, description_: String, mods_: Dictionary,
		transformation := false, teinte_ := Color(0.9, 0.8, 0.5), glyphe_ := "goutte",
		copies := 0, famille_ := "", rarete_ := EPIQUE) -> Reactif:
	var r := Reactif.new()
	r.id = id_
	r.nom = nom_
	r.description = description_
	r.mods = mods_
	r.est_transformation = transformation
	r.teinte = teinte_
	r.glyphe = glyphe_
	r.copies_max = copies
	r.famille = famille_
	r.rarete = rarete_
	return r

func copies_permises() -> int:
	return copies_max if copies_max > 0 else Reglages.COPIES_MAX

func nom_rarete() -> String:
	match rarete:
		COMMUN: return "Commun"
		RARE: return "Rare"
	return "Épique"

func couleur_rarete() -> Color:
	match rarete:
		COMMUN: return Color("a7c0b5")
		RARE: return Color("8dc8eb")
	return Color("cc9df0")
