class_name HabillagePeint
extends RefCounted

const PLANCHE := preload("res://assets/visual/interface/peint/icones.png")
const PANNEAU := preload("res://assets/visual/interface/peint/panneau.png")
const ACTION := preload("res://assets/visual/interface/peint/action.png")
const DETOURAGE := preload("res://shaders/interface_peinte.gdshader")
const ICONES := ["forge", "portail", "astrolabe", "grimoire", "couronne", "parametres", "gouttes", "pierres", "fiole"]
# Les silhouettes peintes depassent legerement la grille, surtout le bouchon de la fiole.
const REGIONS_ICONES := [
	Rect2(0, 0, 418, 410), Rect2(418, 0, 418, 410), Rect2(836, 0, 418, 410),
	Rect2(0, 418, 418, 404), Rect2(418, 418, 418, 404), Rect2(836, 418, 418, 384),
	Rect2(0, 826, 418, 428), Rect2(418, 826, 418, 428), Rect2(836, 803, 418, 451),
]
const SURFACES := ["panneau", "cadre", "carte_augment", "bouton_secondaire", "bandeau", "navigation", "medaillon"]
static var _textures: Dictionary = {}
static var _matiere: ShaderMaterial

static func contient(nom: String) -> bool:
	return nom in ICONES or nom in SURFACES or nom == "bouton_principal" or nom == "selection_onglet"

static func texture(nom: String) -> Texture2D:
	if _textures.has(nom):
		var conservee: Texture2D = _textures[nom]
		return conservee
	if nom == "selection_onglet":
		return preload("res://assets/visual/interface/halo_recompense.svg")
	var resultat := AtlasTexture.new()
	var index := ICONES.find(nom)
	if index >= 0:
		resultat.atlas = PLANCHE
		resultat.region = REGIONS_ICONES[index]
	else:
		resultat.atlas = ACTION if nom == "bouton_principal" else PANNEAU
		var taille := resultat.atlas.get_size()
		# Seule la marge transparente externe est exclue ; les coins restent entiers.
		resultat.region = Rect2(taille * 0.025, taille * 0.95)
	resultat.filter_clip = true
	_textures[nom] = resultat
	return resultat

static func appliquer(surface: CanvasItem) -> void:
	surface.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Les controles mixtes dessinent aussi des glyphes MSDF : leur rendu natif doit rester intact.
	if not (surface is TextureRect or surface is Panel or surface is PanelContainer):
		if surface.material == _matiere:
			surface.material = null
		return
	if _matiere == null:
		_matiere = ShaderMaterial.new()
		_matiere.shader = DETOURAGE
	surface.material = _matiere
	if surface is TextureRect:
		surface.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
