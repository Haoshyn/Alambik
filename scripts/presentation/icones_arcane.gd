class_name IconesArcane
extends RefCounted

const PLANCHES := [preload("res://assets/visual/manga/icones_0.png"), preload("res://assets/visual/manga/icones_1.png"), preload("res://assets/visual/manga/icones_2.png")]
const ICONES_INTERFACE := {
	"parametres": "parametres",
	"gouttes": "gouttes",
	"pierres": "pierres",
	"navigation_equipement": "forge",
	"navigation_maitrises": "astrolabe",
	"navigation_sorts": "grimoire",
	"navigation_aventure": "portail",
}
const ALIAS_CAPACITES := {"vortex_alchimique": "spirale", "purification_totale": "lumiere"}
const IDENTIFIANTS := [
	"abondance", "air", "armure", "audace", "avidite", "barrage_de_braise",
	"bastion", "cadence", "cadence_febrile", "carapace", "catalyse", "celerite",
	"chaine_alchimique", "collecte", "colosse", "constitution", "courageux", "dernier_rempart",
	"distillation", "domination", "eau", "echo_alchimique", "egide", "elan",
	"elan_vital", "endurance", "explosion_corrosive", "familier_gardien", "familier_tireur", "feu",
	"force", "fortune", "fragmentation", "frappe_lourde", "grand_oeuvre", "heritage_reactif",
	"homing", "immortel", "impulsion_foudroyante", "lumiere", "mannequin", "meteores",
	"moisson_vitale", "nova_de_givre", "onde_alchimique", "onde_de_choc", "orbes_chargees", "peau_de_pierre",
	"perforation", "philosophe", "precision", "prescience", "puissance", "regeneration",
	"rempart", "rempart_initial", "reserve_ultime", "ricochet", "riposte_alchimique", "robustesse",
	"rythme", "sagesse", "salve", "sang_froid", "savoir", "sceau_celerite",
	"sceau_furie", "sceau_garde", "sceau_portee", "sceau_ruine", "seconde_chance", "soif_de_sang",
	"spirale", "tempete", "temps_suspendu", "tenebres", "terre", "tir_multiple",
	"trait_transpercant", "trajectoire", "transmutation_totale", "vitalite", "zone_heros", "navigation_equipement",
	"navigation_aventure", "navigation_maitrises", "navigation_sorts", "parametres", "gouttes", "pierres",
]
static var _textures := {}

static func contient(id: String) -> bool:
	return id in IDENTIFIANTS or ALIAS_CAPACITES.has(id)

static func texture(id: String) -> Texture2D:
	id = str(ALIAS_CAPACITES.get(id, id))
	if ICONES_INTERFACE.has(id):
		return HabillagePeint.texture(str(ICONES_INTERFACE[id]))
	if _textures.has(id): return _textures[id]
	var index := IDENTIFIANTS.find(id)
	if index < 0: return null
	var atlas := AtlasTexture.new()
	atlas.atlas = PLANCHES[index / 30]
	# La premiere planche comprend deux marges externes ; les exclure du pas
	# preserve le bas des silhouettes, contrairement a une division plein cadre.
	var grille := Rect2(0,70,1374,1020) if index < 30 else Rect2(Vector2.ZERO,atlas.atlas.get_size())
	var cellule := grille.size / Vector2(6,5)
	var position := index % 30
	atlas.region = Rect2(grille.position + Vector2(position % 6, position / 6) * cellule, cellule)
	atlas.filter_clip = true
	_textures[id] = atlas
	return atlas
