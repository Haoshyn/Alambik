class_name HabillagePeint
extends RefCounted

const PARCHEMIN := preload("res://assets/visual/interface/cadres/panneau.svg")
const ACTION := preload("res://assets/visual/interface/cadres/action.svg")
const SECONDAIRE := preload("res://assets/visual/interface/cadres/secondaire.svg")
const NAVIGATION := preload("res://assets/visual/interface/cadres/navigation.svg")
const CADRES := {
	"panneau": preload("res://assets/visual/interface/cadres/conteneur.svg"),
	"cadre": preload("res://assets/visual/interface/cadres/conteneur.svg"),
	"carte_augment": preload("res://assets/visual/interface/cadres/carte.svg"),
	"carte_selection": preload("res://assets/visual/interface/cadres/carte_selection.svg"),
	"case": preload("res://assets/visual/interface/cadres/case.svg"),
	"case_selection": preload("res://assets/visual/interface/cadres/case_selection.svg"),
	"zone_texte": preload("res://assets/visual/interface/cadres/zone_texte.svg"),
	"saisie": preload("res://assets/visual/interface/cadres/saisie.svg"),
	"saisie_focus": preload("res://assets/visual/interface/cadres/saisie_focus.svg"),
	"action_pressee": preload("res://assets/visual/interface/cadres/action_pressee.svg"),
	"secondaire_pressee": preload("res://assets/visual/interface/cadres/secondaire_pressee.svg"),
	"bandeau": preload("res://assets/visual/interface/cadres/bandeau.svg"),
	"compteur": preload("res://assets/visual/interface/cadres/compteur.svg"),
	"medaillon": preload("res://assets/visual/interface/cadres/medaillon.svg"),
}
const DETOURAGE := preload("res://shaders/interface_peinte.gdshader")
const ICONES := ["forge", "portail", "astrolabe", "grimoire", "couronne", "parametres", "gouttes", "pierres", "fiole", "mine", "epreuves", "heros"]
const SURFACES := ["panneau", "cadre", "carte_augment", "bouton_secondaire", "bandeau", "navigation", "medaillon", "parchemin", "compteur"]
static var _textures: Dictionary = {}

static func contient(nom: String) -> bool:
	return CADRES.has(nom) or nom in ICONES or nom in SURFACES or nom == "bouton_principal" or nom == "selection_onglet"

static func texture(nom: String) -> Texture2D:
	if CADRES.has(nom): return CADRES[nom]
	if _textures.has(nom):
		var conservee: Texture2D = _textures[nom]
		return conservee
	if nom == "selection_onglet":
		return preload("res://assets/visual/interface/halo_recompense.svg")
	if nom in ICONES:
		var icone := load("res://assets/visual/interface/" + nom + ".svg") as Texture2D
		_textures[nom] = icone
		return icone
	var resultat: Texture2D = SECONDAIRE
	if nom == "parchemin": resultat = PARCHEMIN
	elif nom == "bouton_principal": resultat = ACTION
	elif nom == "bouton_secondaire": resultat = SECONDAIRE
	elif nom in ["navigation", "compteur"]: resultat = NAVIGATION
	_textures[nom] = resultat
	return resultat

static func appliquer(surface: CanvasItem) -> void:
	# Le filtrage alpha ancien decoupait les reflets des SVG natifs.
	if surface.material is ShaderMaterial and (surface.material as ShaderMaterial).shader == DETOURAGE:
		surface.material = null
	surface.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
