extends Node

# 112 unités sur notre viewport de 1080 correspondent à une cible confortable
# sur un téléphone courant. Aucun bouton essentiel ne doit passer dessous.
const CIBLE_TACTILE := 112.0

# L'encoche et la barre de navigation mangent le haut et le bas de l'ecran.
# Tout ce qui est tactile doit rester dans la zone sure, sinon le pouce tape
# le systeme au lieu du jeu. Les marges sont exprimees dans le viewport de
# reference (1080 de large), pas en pixels physiques.

func _zone_sure() -> Rect2:
	var visible := get_viewport().get_visible_rect()
	if OS.get_name() != "Android":
		return visible
	# La transformation inclut les bandes de cadrage : une encoche dans une
	# bande ne doit pas decaler une seconde fois toute l'interface.
	var sure := Rect2(DisplayServer.get_display_safe_area())
	sure.position -= Vector2(DisplayServer.window_get_position())
	return convertir_zone_sure(visible, sure, get_viewport().get_screen_transform())

static func convertir_zone_sure(visible: Rect2, sure: Rect2, transformation: Transform2D) -> Rect2:
	if not sure.has_area():
		return visible
	var intersection := visible.intersection(transformation.affine_inverse() * sure)
	return intersection if intersection.has_area() else visible

func marge_haute() -> float:
	if OS.get_name() != "Android":
		return 24.0
	return maxf(24.0, _zone_sure().position.y)

func marge_basse() -> float:
	if OS.get_name() != "Android":
		return 24.0
	return maxf(24.0, hauteur_visible() - _zone_sure().end.y)

# Le cadrage uniforme conserve les proportions, y compris en multifenetre.
func hauteur_visible() -> float:
	var taille := get_viewport().get_visible_rect().size
	return taille.y

func largeur_visible() -> float:
	return get_viewport().get_visible_rect().size.x
