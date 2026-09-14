class_name CadresAtelier
extends RefCounted

const MEDAILLON := preload("res://assets/visual/arcane/medaillon.svg")
const VERRE := preload("res://assets/visual/arcane/cadre.png")

static func creer(fond: Color, bord: Color, rond := false) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = MEDAILLON if rond else VERRE
	# Les coins peints restent fixes, seuls les chants et le centre s'etirent.
	for cote in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(cote, 0 if rond else VERRE.get_width() * 0.125)
		style.set_content_margin(cote, 28)
	var teinte := Color.WHITE
	if fond.r > fond.g * 1.1:
		teinte = Color(1.15, 0.72, 1.0)
	elif fond.g > fond.r * 1.5:
		teinte = Color(0.65, 1.12, 0.94)
	if fond.v < 0.28: teinte = teinte.darkened(0.28)
	if bord.g > bord.r * 1.5: teinte = teinte.lightened(0.08)
	if rond: style.set_content_margin(SIDE_TOP, 20)
	teinte.a = fond.a
	style.modulate_color = teinte
	return style
