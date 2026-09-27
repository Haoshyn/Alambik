class_name IconesArcane
extends RefCounted

const ICONES_INTERFACE := {
	"parametres": "parametres",
	"gouttes": "gouttes",
	"pierres": "pierres",
	"navigation_equipement": "forge",
	"navigation_maitrises": "astrolabe",
	"navigation_passifs": "grimoire",
	"navigation_aventure": "portail",
}
const IDENTIFIANTS := [
	"abondance", "air", "armure", "audace", "avidite",
	"bastion", "cadence", "cadence_febrile", "carapace", "catalyse", "celerite",
	"chaine_alchimique", "collecte", "colosse", "constitution", "courageux", "dernier_rempart",
	"distillation", "domination", "eau", "egide", "elan",
	"elan_vital", "endurance", "familier_gardien", "familier_tireur", "feu",
	"force", "fortune", "fragmentation", "frappe_lourde",
	"homing", "immortel", "lumiere", "mannequin", "meteores",
	"moisson_vitale", "onde_de_choc", "orbes_chargees", "peau_de_pierre",
	"perforation", "philosophe", "precision", "prescience", "puissance", "regeneration",
	"rempart", "rempart_initial", "ricochet", "robustesse",
	"rythme", "sagesse", "salve", "sang_froid", "savoir", "sceau_celerite",
	"sceau_furie", "sceau_garde", "sceau_portee", "sceau_ruine", "seconde_chance", "soif_de_sang",
	"spirale", "tempete", "tenebres", "terre", "tir_multiple",
	"trait_transpercant", "trajectoire", "vitalite", "zone_heros", "navigation_equipement",
	"navigation_aventure", "navigation_maitrises", "navigation_passifs", "parametres", "gouttes", "pierres",
]
static var _textures := {}

static func contient(id: String) -> bool:
	return id in IDENTIFIANTS or Passifs.contient(id)

static func texture(id: String) -> Texture2D:
	id = str(Passifs.donnees(id).get("icone", id))
	if ICONES_INTERFACE.has(id):
		return HabillagePeint.texture(str(ICONES_INTERFACE[id]))
	if _textures.has(id): return _textures[id]
	if id not in IDENTIFIANTS: return null
	var icone := load("res://assets/visual/azur/glyphes/" + id + ".svg") as Texture2D
	_textures[id] = icone
	return icone
