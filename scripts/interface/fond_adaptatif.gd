class_name FondAdaptatif
extends RefCounted

const LARGEUR_REFERENCE := 1080.0

# Les chassis restent intacts. Seule la bande comprise entre les deux coupures
# absorbe la difference de hauteur d'un telephone a l'autre.
static func dessiner(canvas: CanvasItem, texture: Texture2D, taille: Vector2,
		haut_fixe: float, bas_fixe: float, modulation := Color.WHITE) -> void:
	if texture == null or taille.x <= 0.0 or taille.y <= 0.0:
		return
	var echelle := taille.x / LARGEUR_REFERENCE
	var hauteur_source := float(texture.get_height()) / float(texture.get_width()) * LARGEUR_REFERENCE
	var hauteur_cible := taille.y / echelle
	var milieu_source := maxf(4.0, hauteur_source - haut_fixe - bas_fixe)
	var milieu_cible := maxf(4.0, hauteur_cible - haut_fixe - bas_fixe)
	var facteur_pixels := float(texture.get_height()) / hauteur_source
	var largeur_pixels := float(texture.get_width())
	var haut_pixels := haut_fixe * facteur_pixels
	var bas_pixels := bas_fixe * facteur_pixels
	canvas.draw_texture_rect_region(texture,
		Rect2(0.0, 0.0, taille.x, haut_fixe * echelle),
		Rect2(0.0, 0.0, largeur_pixels, haut_pixels), modulation, false, true)
	canvas.draw_texture_rect_region(texture,
		Rect2(0.0, haut_fixe * echelle, taille.x, milieu_cible * echelle),
		Rect2(0.0, haut_pixels, largeur_pixels, milieu_source * facteur_pixels),
		modulation, false, true)
	canvas.draw_texture_rect_region(texture,
		Rect2(0.0, taille.y - bas_fixe * echelle, taille.x, bas_fixe * echelle),
		Rect2(0.0, float(texture.get_height()) - bas_pixels, largeur_pixels, bas_pixels),
		modulation, false, true)
