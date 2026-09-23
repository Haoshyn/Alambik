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
	var cote := minf(dimensions.x * 0.57, hauteur * 0.31)
	var centre := Vector2(dimensions.x * 0.5, haut + hauteur * 0.37)
	var rebond := 0.0 if ReglagesJoueur.effets_reduits else sin(temps * 2.4) * 7.0
	surface.draw_circle(centre, cote * 0.58, Color("233a6860"))
	surface.draw_circle(centre, cote * 0.46, Color("b4dfee18"))
	var rotation := 0.0 if ReglagesJoueur.effets_reduits else temps * 0.16
	for index in 8:
		var debut := rotation + TAU * float(index) / 8.0
		surface.draw_arc(centre, cote * 0.59, debut, debut + 0.34, 16,
			Color("e5d6b6a3") if index % 2 == 0 else Color("9ce0eca3"), 2.4, true)
	var portail := surface.get_node("Peinture_portail") as TextureRect
	portail.position = centre - Vector2.ONE * cote * 0.5
	portail.size = Vector2.ONE * cote
	var livre := cote * 0.37
	var grimoire := surface.get_node("Peinture_grimoire") as TextureRect
	grimoire.position = centre - Vector2.ONE * livre * 0.5 + Vector2(0, cote * 0.035 + rebond)
	grimoire.size = Vector2.ONE * livre
	var titre_haut := "Le passage"
	_texte_centre(surface, Vector2(dimensions.x * 0.5 - 190, haut + hauteur * 0.175), 380,
		titre_haut, 34, Color("fff6e9"), Polices.TITRE)
	var largeur := minf(dimensions.x - 80.0, 880.0)
	var cartouche := Rect2(Vector2((dimensions.x - largeur) * 0.5, haut + hauteur * 0.615), Vector2(largeur, 152))
	surface.draw_style_box(StyleAzur.texture_etirable("bandeau_monde", 24), cartouche)
	_texte_centre(surface, Vector2(cartouche.position.x + 60, cartouche.position.y + 69), largeur - 120, titre, 39, StyleAzur.TEXTE, Polices.TITRE)
	_texte_centre(surface, Vector2(cartouche.position.x + 60, cartouche.position.y + 112), largeur - 120, sous_titre, 25, StyleAzur.ATTENUE, Polices.CORPS)
	var milieu := dimensions.x * 0.5
	var ligne_y := cartouche.end.y + 57
	surface.draw_line(Vector2(milieu - 80, ligne_y), Vector2(milieu + 80, ligne_y), Color("e0caa072"), 1.5, true)
	# La pulsation indique l'attente sans promettre un pourcentage de chargement.
	for index in 3:
		var position := Vector2(milieu + float(index - 1) * 40, ligne_y)
		var alpha := 0.68 if ReglagesJoueur.effets_reduits else 0.5 + (sin(temps * 4.0 - float(index)) + 1.0) * 0.22
		var diamant := PackedVector2Array([position + Vector2(0, -8), position + Vector2(8, 0),
			position + Vector2(0, 8), position + Vector2(-8, 0)])
		surface.draw_colored_polygon(diamant, Color(StyleAzur.MENTHE, alpha))

static func _texte_centre(surface: Control, position: Vector2, largeur: float, texte: String, taille: int, couleur: Color, police: Font) -> void:
	var largeur_texte := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	var taille_adaptee := mini(taille, maxi(20, floori(taille * largeur / maxf(1.0, largeur_texte))))
	surface.draw_string_outline(police, position, texte, HORIZONTAL_ALIGNMENT_CENTER, largeur, taille_adaptee, 4, Color(StyleAzur.FOND, 0.95))
	surface.draw_string(police, position, texte, HORIZONTAL_ALIGNMENT_CENTER, largeur, taille_adaptee, couleur)
