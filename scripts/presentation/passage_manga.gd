class_name PassageManga
extends RefCounted

static func preparer(surface: Control) -> void:
	for nom in ["portail", "grimoire"]:
		var icone := StyleAzur.illustration(nom, 0)
		icone.name = "Peinture_" + nom
		surface.add_child(icone)

static func dessiner(surface: Control, dimensions: Vector2, temps: float,
		titre := "Le passage s’ouvre", sous_titre := "Un nouveau niveau vous attend…") -> void:
	var texture: Texture2D = StyleAzur.FOND_ATELIER
	var taille_source := texture.get_size()
	var rapport := maxf(dimensions.x / taille_source.x, dimensions.y / taille_source.y)
	var visible := dimensions / maxf(rapport, 0.01)
	surface.draw_texture_rect_region(texture, Rect2(Vector2.ZERO, dimensions), Rect2((taille_source - visible) * 0.5, visible))
	var haut := Ecran.marge_haute()
	var hauteur := maxf(1.0, dimensions.y - haut - Ecran.marge_basse())
	var cote := minf(dimensions.x * 0.76, hauteur * 0.44)
	var centre := Vector2(dimensions.x * 0.5, haut + hauteur * 0.37)
	var rebond := 0.0 if ReglagesJoueur.effets_reduits else sin(temps * 2.4) * 7.0
	var portail := surface.get_node("Peinture_portail") as TextureRect
	portail.position = centre - Vector2.ONE * cote * 0.5
	portail.size = Vector2.ONE * cote
	var livre := cote * 0.33
	var grimoire := surface.get_node("Peinture_grimoire") as TextureRect
	grimoire.position = centre - Vector2.ONE * livre * 0.5 + Vector2(0, cote * 0.035 + rebond)
	grimoire.size = Vector2.ONE * livre
	var largeur := minf(dimensions.x - 80.0, 880.0)
	var cartouche := Rect2(Vector2((dimensions.x - largeur) * 0.5, haut + hauteur * 0.635), Vector2(largeur, 164))
	surface.draw_style_box(StyleAzur.texture_etirable("bandeau", 24), cartouche)
	_texte_centre(surface, Vector2(cartouche.position.x + 60, cartouche.position.y + 70), largeur - 120, titre, 38, StyleAzur.TEXTE)
	_texte_centre(surface, Vector2(cartouche.position.x + 60, cartouche.position.y + 112), largeur - 120, sous_titre, 25, StyleAzur.ATTENUE)
	var separateur := Rect2(Vector2((dimensions.x - largeur * 0.64) * 0.5, cartouche.end.y + 25), Vector2(largeur * 0.64, 26))
	surface.draw_texture_rect(StyleAzur.texture_interface("separateur"), separateur, false)
	# Une pulsation signale l'attente sans inventer un pourcentage de chargement.
	for index in 3:
		var position := Vector2(dimensions.x * 0.5 + float(index - 1) * 42, cartouche.end.y + 83)
		var alpha := 0.65 if ReglagesJoueur.effets_reduits else 0.45 + (sin(temps * 4.0 - float(index)) + 1.0) * 0.275
		surface.draw_texture_rect(StyleAzur.texture_interface("joystick_curseur"), Rect2(position - Vector2.ONE * 11, Vector2.ONE * 22), false, Color(StyleAzur.MAGIE, alpha))

static func _texte_centre(surface: Control, position: Vector2, largeur: float, texte: String, taille: int, couleur: Color) -> void:
	var largeur_texte := Polices.CORPS.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	var taille_adaptee := mini(taille, maxi(20, floori(taille * largeur / maxf(1.0, largeur_texte))))
	surface.draw_string_outline(Polices.CORPS, position, texte, HORIZONTAL_ALIGNMENT_CENTER, largeur, taille_adaptee, 5, Color(StyleAzur.FOND, 0.95))
	surface.draw_string(Polices.CORPS, position, texte, HORIZONTAL_ALIGNMENT_CENTER, largeur, taille_adaptee, couleur)
